import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

interface RecoveryOptions {
  backupId: string;
  recoveryType: "FULL_RESTORE" | "PARTIAL_RESTORE" | "POINT_IN_TIME";
  components?: string[];
  targetTimestamp?: number;
  dryRun?: boolean;
}

interface RecoveryResult {
  success: boolean;
  message: string;
  recoveryId: string;
  restoredComponents: string[];
  duration: number;
}

// Disaster recovery initiation
export const initiateRecovery = functions.https.onCall(async (data: RecoveryOptions, context) => {
  // Verify admin access
  if (!context.auth?.token.admin) {
    throw new functions.https.HttpsError("permission-denied", "Admin access required");
  }

  const startTime = Date.now();
  const recoveryId = `recovery-${startTime}`;

  try {
    const { backupId, recoveryType, components, dryRun = false } = data;

    console.log(`Initiating ${recoveryType} recovery with backup ${backupId}`);

    // Log recovery attempt
    await logRecoveryEvent(recoveryId, recoveryType, backupId, "STARTED");

    let result: RecoveryResult;

    switch (recoveryType) {
    case "FULL_RESTORE":
      result = await performFullRestore(recoveryId, backupId, dryRun);
      break;
    case "PARTIAL_RESTORE":
      result = await performPartialRestore(recoveryId, backupId, components || [], dryRun);
      break;
    case "POINT_IN_TIME":
      result = await performPointInTimeRestore(recoveryId, backupId, data.targetTimestamp, dryRun);
      break;
    default:
      throw new Error("Invalid recovery type");
    }

    result.duration = Date.now() - startTime;

    await logRecoveryEvent(recoveryId, recoveryType, backupId, "SUCCESS", result.message);
    return result;

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);

    await logRecoveryEvent(recoveryId, data.recoveryType, data.backupId, "FAILED", errorMessage);

    throw new functions.https.HttpsError("internal", `Recovery failed: ${errorMessage}`);
  }
});

// Recovery status check
export const getRecoveryStatus = functions.https.onCall(async (data: { recoveryId: string }, context) => {
  if (!context.auth?.token.admin) {
    throw new functions.https.HttpsError("permission-denied", "Admin access required");
  }

  const { recoveryId } = data;

  const firestore = admin.firestore();
  const recoveryDoc = await firestore.collection("recoveryLogs").doc(recoveryId).get();

  if (!recoveryDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Recovery operation not found");
  }

  return recoveryDoc.data();
});

// List available backups for recovery
export const listAvailableBackups = functions.https.onCall(async (data, context) => {
  if (!context.auth?.token.admin) {
    throw new functions.https.HttpsError("permission-denied", "Admin access required");
  }

  const firestore = admin.firestore();
  const backupsSnapshot = await firestore.collection("backups")
    .orderBy("timestamp", "desc")
    .limit(50)
    .get();

  const backups = backupsSnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));

  return { backups };
});

async function performFullRestore(recoveryId: string, backupId: string, dryRun: boolean): Promise<RecoveryResult> {
  console.log(`Starting full restore from backup ${backupId} (dry run: ${dryRun})`);

  const backup = await loadBackup(backupId);
  const db = admin.database();

  if (!dryRun) {
    // Create maintenance mode
    await db.ref("maintenance").set({
      active: true,
      message: "System restoration in progress",
      startTime: Date.now(),
      recoveryId,
    });
  }

  try {
    const restoredComponents: string[] = [];

    if (backup.rooms) {
      if (!dryRun) {
        await db.ref("rooms").set(backup.rooms);
      }
      restoredComponents.push("rooms");
      console.log(`Restored ${Object.keys(backup.rooms).length} rooms`);
    }

    if (backup.users) {
      if (!dryRun) {
        await db.ref("users").set(backup.users);
      }
      restoredComponents.push("users");
      console.log(`Restored ${Object.keys(backup.users).length} users`);
    }

    if (!dryRun) {
      // Verify restoration
      await verifyDataIntegrity();
    }

    return {
      success: true,
      message: `Full restore completed successfully${dryRun ? " (dry run)" : ""}`,
      recoveryId,
      restoredComponents,
      duration: 0, // Will be set by caller
    };

  } finally {
    if (!dryRun) {
      // Remove maintenance mode
      await db.ref("maintenance").remove();
    }
  }
}

async function performPartialRestore(
  recoveryId: string,
  backupId: string,
  components: string[],
  dryRun: boolean
): Promise<RecoveryResult> {
  console.log(`Starting partial restore of ${components.join(", ")} from backup ${backupId}`);

  const backup = await loadBackup(backupId);
  const db = admin.database();
  const restoredComponents: string[] = [];

  for (const component of components) {
    if (backup[component]) {
      if (!dryRun) {
        await db.ref(component).set(backup[component]);
      }
      restoredComponents.push(component);
      console.log(`Restored component: ${component}`);
    } else {
      console.warn(`Component ${component} not found in backup`);
    }
  }

  if (!dryRun && restoredComponents.length > 0) {
    await verifyPartialDataIntegrity(restoredComponents);
  }

  return {
    success: true,
    message: `Partial restore completed${dryRun ? " (dry run)" : ""}. Restored: ${restoredComponents.join(", ")}`,
    recoveryId,
    restoredComponents,
    duration: 0,
  };
}

async function performPointInTimeRestore(
  recoveryId: string,
  backupId: string,
  targetTimestamp: number | undefined,
  dryRun: boolean
): Promise<RecoveryResult> {
  if (!targetTimestamp) {
    throw new Error("Target timestamp required for point-in-time restore");
  }

  console.log(`Starting point-in-time restore to ${new Date(targetTimestamp).toISOString()}`);

  // Find the best backup for the target timestamp
  const bestBackup = await findBestBackupForTimestamp(targetTimestamp);
  const backup = await loadBackup(bestBackup.id);

  // Filter data to only include items before target timestamp
  const filteredData = await filterBackupByTimestamp(backup, targetTimestamp);

  const db = admin.database();
  const restoredComponents: string[] = [];

  if (!dryRun) {
    await db.ref("maintenance").set({
      active: true,
      message: `Point-in-time restoration in progress to ${new Date(targetTimestamp).toISOString()}`,
      startTime: Date.now(),
      recoveryId,
    });
  }

  try {
    if (filteredData.rooms) {
      if (!dryRun) {
        await db.ref("rooms").set(filteredData.rooms);
      }
      restoredComponents.push("rooms");
    }

    if (filteredData.users) {
      if (!dryRun) {
        await db.ref("users").set(filteredData.users);
      }
      restoredComponents.push("users");
    }

    return {
      success: true,
      message: `Point-in-time restore completed${dryRun ? " (dry run)" : ""}`,
      recoveryId,
      restoredComponents,
      duration: 0,
    };

  } finally {
    if (!dryRun) {
      await db.ref("maintenance").remove();
    }
  }
}

async function loadBackup(backupId: string): Promise<any> {
  const firestore = admin.firestore();
  const backupDoc = await firestore.collection("backups").doc(backupId).get();

  if (!backupDoc.exists) {
    throw new Error(`Backup ${backupId} not found`);
  }

  const backupData = backupDoc.data();
  if (!backupData) {
    throw new Error(`Backup ${backupId} has no data`);
  }

  // Load backup file from storage
  const storage = admin.storage();
  const bucket = storage.bucket("snakes-fight-backups");
  const file = bucket.file(backupData.filename);

  const [exists] = await file.exists();
  if (!exists) {
    throw new Error(`Backup file ${backupData.filename} not found in storage`);
  }

  const [fileContent] = await file.download();
  const backup = JSON.parse(fileContent.toString());

  // Verify checksum if available
  if (backupData.checksum && backup.metadata?.checksum) {
    const backupContent = JSON.stringify({ rooms: backup.rooms, users: backup.users });
    const calculatedChecksum = generateChecksum(backupContent);

    if (calculatedChecksum !== backup.metadata.checksum) {
      throw new Error("Backup integrity check failed: checksum mismatch");
    }
  }

  return backup;
}

async function verifyDataIntegrity(): Promise<void> {
  console.log("Verifying data integrity...");

  const db = admin.database();

  // Basic integrity checks
  const [roomsSnapshot, usersSnapshot] = await Promise.all([
    db.ref("rooms").limitToFirst(10).once("value"),
    db.ref("users").limitToFirst(10).once("value"),
  ]);

  if (!roomsSnapshot.exists() && !usersSnapshot.exists()) {
    throw new Error("Data integrity check failed: no data found");
  }

  // Check room structure
  const rooms = roomsSnapshot.val();
  if (rooms) {
    for (const roomId of Object.keys(rooms).slice(0, 5)) {
      const room = rooms[roomId];
      if (!room.roomCode || !room.hostId || !room.status) {
        throw new Error(`Data integrity check failed: invalid room structure for ${roomId}`);
      }
    }
  }

  // Check user structure
  const users = usersSnapshot.val();
  if (users) {
    for (const userId of Object.keys(users).slice(0, 5)) {
      const user = users[userId];
      if (!user.displayName) {
        throw new Error(`Data integrity check failed: invalid user structure for ${userId}`);
      }
    }
  }

  console.log("Data integrity verification successful");
}

async function verifyPartialDataIntegrity(components: string[]): Promise<void> {
  console.log(`Verifying partial data integrity for: ${components.join(", ")}`);

  const db = admin.database();

  for (const component of components) {
    const snapshot = await db.ref(component).limitToFirst(5).once("value");

    if (!snapshot.exists()) {
      console.warn(`Component ${component} appears to be empty`);
      continue;
    }

    console.log(`Component ${component} integrity verified`);
  }
}

async function findBestBackupForTimestamp(targetTimestamp: number): Promise<{ id: string; timestamp: number }> {
  const firestore = admin.firestore();

  // Find the latest backup before the target timestamp
  const backupsSnapshot = await firestore.collection("backups")
    .where("timestamp", "<=", new Date(targetTimestamp))
    .orderBy("timestamp", "desc")
    .limit(1)
    .get();

  if (backupsSnapshot.empty) {
    throw new Error("No suitable backup found for the target timestamp");
  }

  const backup = backupsSnapshot.docs[0];
  const data = backup.data();

  return {
    id: backup.id,
    timestamp: data.timestamp.toMillis(),
  };
}

async function filterBackupByTimestamp(backup: any, targetTimestamp: number): Promise<any> {
  const filteredData: any = {};

  // Filter rooms by creation timestamp
  if (backup.rooms) {
    filteredData.rooms = {};
    for (const [roomId, room] of Object.entries(backup.rooms)) {
      const roomData = room as any;
      if (roomData.createdAt && roomData.createdAt <= targetTimestamp) {
        filteredData.rooms[roomId] = room;
      }
    }
  }

  // Filter users by creation timestamp
  if (backup.users) {
    filteredData.users = {};
    for (const [userId, user] of Object.entries(backup.users)) {
      const userData = user as any;
      if (userData.createdAt && userData.createdAt <= targetTimestamp) {
        filteredData.users[userId] = user;
      }
    }
  }

  return filteredData;
}

async function logRecoveryEvent(
  recoveryId: string,
  recoveryType: string,
  backupId: string,
  status: "STARTED" | "SUCCESS" | "FAILED",
  message?: string
): Promise<void> {
  const firestore = admin.firestore();

  const eventData = {
    recoveryId,
    recoveryType,
    backupId,
    status,
    message: message || "",
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  };

  // Update or create recovery log document
  await firestore.collection("recoveryLogs").doc(recoveryId).set(eventData, { merge: true });

  // Also log to console
  console.log(`Recovery ${recoveryId}: ${status} - ${message || "No message"}`);

  // Send alert for critical events
  if (status === "FAILED") {
    const db = admin.database();
    await db.ref("recoveryAlerts").push({
      recoveryId,
      type: "RECOVERY_FAILED",
      message: `Recovery operation ${recoveryId} failed: ${message}`,
      severity: "critical",
      timestamp: admin.database.ServerValue.TIMESTAMP,
    });
  }
}

function generateChecksum(content: string): string {
  const crypto = require("crypto");
  return crypto.createHash("sha256").update(content).digest("hex");
}
