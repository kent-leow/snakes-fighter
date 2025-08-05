import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

interface BackupData {
  timestamp: number;
  rooms: any;
  users: any;
  metadata: {
    version: string;
    environment: string;
    size: number;
    checksum: string;
  };
}

interface BackupAlert {
  type: string;
  message: string;
  severity: "info" | "warning" | "error";
  timestamp: number;
}

// Daily backup - runs at 2 AM UTC
export const dailyBackup = functions.pubsub
  .schedule("0 2 * * *")
  .timeZone("UTC")
  .onRun(async context => {
    try {
      console.log("Starting daily backup process...");

      const backupData = await createBackup();
      await storeBackup(backupData);
      await cleanOldBackups();
      await validateBackup(backupData);

      console.log("Daily backup completed successfully");

      await sendBackupAlert({
        type: "BACKUP_SUCCESS",
        message: `Daily backup completed successfully. Size: ${formatBytes(backupData.metadata.size)}`,
        severity: "info",
        timestamp: Date.now(),
      });

    } catch (error) {
      console.error("Backup failed:", error);

      await sendBackupAlert({
        type: "BACKUP_FAILED",
        message: `Backup failed: ${error instanceof Error ? error.message : String(error)}`,
        severity: "error",
        timestamp: Date.now(),
      });

      // Re-throw to ensure the function reports failure
      throw error;
    }
  });

// Weekly full backup with extended retention
export const weeklyBackup = functions.pubsub
  .schedule("0 3 * * 0") // Sunday at 3 AM UTC
  .timeZone("UTC")
  .onRun(async context => {
    try {
      console.log("Starting weekly full backup process...");

      const backupData = await createFullBackup();
      await storeBackup(backupData, "weekly");
      await cleanOldWeeklyBackups();

      console.log("Weekly backup completed successfully");

      await sendBackupAlert({
        type: "WEEKLY_BACKUP_SUCCESS",
        message: `Weekly full backup completed. Size: ${formatBytes(backupData.metadata.size)}`,
        severity: "info",
        timestamp: Date.now(),
      });

    } catch (error) {
      console.error("Weekly backup failed:", error);

      await sendBackupAlert({
        type: "WEEKLY_BACKUP_FAILED",
        message: `Weekly backup failed: ${error instanceof Error ? error.message : String(error)}`,
        severity: "error",
        timestamp: Date.now(),
      });

      throw error;
    }
  });

// On-demand backup function
export const createManualBackup = functions.https.onCall(async (data, context) => {
  // Verify admin access
  if (!context.auth?.token.admin) {
    throw new functions.https.HttpsError("permission-denied", "Admin access required");
  }

  try {
    const { type = "manual", includeAll = false } = data;

    console.log(`Starting manual backup (type: ${type})...`);

    const backupData = includeAll ? await createFullBackup() : await createBackup();
    const backupId = await storeBackup(backupData, type);

    await sendBackupAlert({
      type: "MANUAL_BACKUP_SUCCESS",
      message: `Manual backup created successfully. ID: ${backupId}`,
      severity: "info",
      timestamp: Date.now(),
    });

    return {
      success: true,
      backupId,
      size: backupData.metadata.size,
      message: "Manual backup created successfully",
    };

  } catch (error) {
    console.error("Manual backup failed:", error);

    await sendBackupAlert({
      type: "MANUAL_BACKUP_FAILED",
      message: `Manual backup failed: ${error instanceof Error ? error.message : String(error)}`,
      severity: "error",
      timestamp: Date.now(),
    });

    throw new functions.https.HttpsError("internal", `Manual backup failed: ${error instanceof Error ? error.message : String(error)}`);
  }
});

async function createBackup(): Promise<BackupData> {
  const db = admin.database();

  console.log("Collecting backup data...");

  // Backup critical data with limits for performance
  const [roomsSnapshot, usersSnapshot] = await Promise.all([
    db.ref("rooms").limitToLast(10000).once("value"), // Last 10k rooms
    db.ref("users").limitToLast(50000).once("value"), // Last 50k users
  ]);

  const rooms = roomsSnapshot.val() || {};
  const users = usersSnapshot.val() || {};

  const backupContent = JSON.stringify({ rooms, users });
  const checksum = generateChecksum(backupContent);

  return {
    timestamp: Date.now(),
    rooms,
    users,
    metadata: {
      version: "1.0",
      environment: "production",
      size: Buffer.byteLength(backupContent, "utf8"),
      checksum,
    },
  };
}

async function createFullBackup(): Promise<BackupData> {
  const db = admin.database();

  console.log("Collecting full backup data...");

  // Full backup without limits (use with caution)
  const [roomsSnapshot, usersSnapshot] = await Promise.all([
    db.ref("rooms").once("value"),
    db.ref("users").once("value"),
  ]);

  const rooms = roomsSnapshot.val() || {};
  const users = usersSnapshot.val() || {};

  const backupContent = JSON.stringify({ rooms, users });
  const checksum = generateChecksum(backupContent);

  return {
    timestamp: Date.now(),
    rooms,
    users,
    metadata: {
      version: "1.0",
      environment: "production",
      size: Buffer.byteLength(backupContent, "utf8"),
      checksum,
    },
  };
}

async function storeBackup(backupData: BackupData, type: string = "daily"): Promise<string> {
  const storage = admin.storage();
  const bucket = storage.bucket("snakes-fight-backups");

  const date = new Date(backupData.timestamp);
  const dateStr = date.toISOString().split("T")[0];
  const timeStr = date.toISOString().replace(/[:.]/g, "-");

  const filename = `backup-${type}-${dateStr}-${timeStr}.json`;
  const backupId = `${type}-${backupData.timestamp}`;

  console.log(`Storing backup: ${filename}`);

  const file = bucket.file(filename);
  const backupContent = JSON.stringify(backupData, null, 2);

  await file.save(backupContent, {
    metadata: {
      contentType: "application/json",
      metadata: {
        type: `${type}-backup`,
        environment: "production",
        version: backupData.metadata.version,
        size: backupData.metadata.size.toString(),
        checksum: backupData.metadata.checksum,
        backupId,
      },
    },
  });

  // Also store backup metadata in Firestore for quick access
  const firestore = admin.firestore();
  await firestore.collection("backups").doc(backupId).set({
    filename,
    type,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    size: backupData.metadata.size,
    checksum: backupData.metadata.checksum,
    version: backupData.metadata.version,
    environment: "production",
  });

  console.log(`Backup stored successfully: ${filename}`);
  return backupId;
}

async function cleanOldBackups(): Promise<void> {
  const storage = admin.storage();
  const bucket = storage.bucket("snakes-fight-backups");

  // Keep daily backups for 30 days
  const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);

  const [files] = await bucket.getFiles({
    prefix: "backup-daily-",
  });

  const oldFiles = files.filter(file => {
    const timeCreated = file.metadata.timeCreated;
    if (!timeCreated) return false;
    const created = new Date(timeCreated).getTime();
    return created < thirtyDaysAgo;
  });

  if (oldFiles.length > 0) {
    console.log(`Cleaning up ${oldFiles.length} old daily backup files...`);

    await Promise.all(oldFiles.map(file => file.delete()));

    // Also clean up Firestore metadata
    const firestore = admin.firestore();
    const oldBackupsQuery = firestore.collection("backups")
      .where("type", "==", "daily")
      .where("timestamp", "<", new Date(thirtyDaysAgo));

    const oldBackupsSnapshot = await oldBackupsQuery.get();
    const deletePromises = oldBackupsSnapshot.docs.map(doc => doc.ref.delete());
    await Promise.all(deletePromises);

    console.log(`Cleaned up ${oldFiles.length} old backup files and metadata`);
  }
}

async function cleanOldWeeklyBackups(): Promise<void> {
  const storage = admin.storage();
  const bucket = storage.bucket("snakes-fight-backups");

  // Keep weekly backups for 1 year
  const oneYearAgo = Date.now() - (365 * 24 * 60 * 60 * 1000);

  const [files] = await bucket.getFiles({
    prefix: "backup-weekly-",
  });

  const oldFiles = files.filter(file => {
    const timeCreated = file.metadata.timeCreated;
    if (!timeCreated) return false;
    const created = new Date(timeCreated).getTime();
    return created < oneYearAgo;
  });

  if (oldFiles.length > 0) {
    console.log(`Cleaning up ${oldFiles.length} old weekly backup files...`);
    await Promise.all(oldFiles.map(file => file.delete()));
    console.log(`Cleaned up ${oldFiles.length} old weekly backup files`);
  }
}

async function validateBackup(backupData: BackupData): Promise<void> {
  console.log("Validating backup...");

  // Verify data integrity
  const backupContent = JSON.stringify({ rooms: backupData.rooms, users: backupData.users });
  const calculatedChecksum = generateChecksum(backupContent);

  if (calculatedChecksum !== backupData.metadata.checksum) {
    throw new Error("Backup validation failed: checksum mismatch");
  }

  // Verify data structure
  if (!backupData.rooms || !backupData.users) {
    throw new Error("Backup validation failed: missing critical data");
  }

  console.log("Backup validation successful");
}

async function sendBackupAlert(alert: BackupAlert): Promise<void> {
  const firestore = admin.firestore();

  // Store alert in Firestore
  await firestore.collection("backupAlerts").add({
    ...alert,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Log based on severity
  switch (alert.severity) {
  case "error":
    console.error(`BACKUP ALERT: ${alert.message}`);
    break;
  case "warning":
    console.warn(`BACKUP WARNING: ${alert.message}`);
    break;
  default:
    console.log(`BACKUP INFO: ${alert.message}`);
  }

  // Store in Realtime Database for immediate visibility
  const db = admin.database();
  await db.ref("backupAlerts").push({
    ...alert,
    timestamp: admin.database.ServerValue.TIMESTAMP,
  });
}

function generateChecksum(content: string): string {
  const crypto = require("crypto");
  return crypto.createHash("sha256").update(content).digest("hex");
}

function formatBytes(bytes: number): string {
  if (bytes === 0) return "0 Bytes";

  const k = 1024;
  const sizes = ["Bytes", "KB", "MB", "GB"];
  const i = Math.floor(Math.log(bytes) / Math.log(k));

  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
}
