import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

interface SystemMetrics {
  activeRooms: number;
  databaseConnections: number;
  errorRate: number;
  memoryUsage: number;
  timestamp: number;
  responseTime: number;
  userCount: number;
}

interface Alert {
  type: string;
  message: string;
  severity: "info" | "warning" | "critical";
  timestamp: number;
  metric?: string;
  value?: number;
  threshold?: number;
}

// System health monitoring - runs every minute
export const monitorSystemHealth = functions.pubsub
  .schedule("every 1 minutes")
  .onRun(async context => {
    try {
      const metrics = await collectSystemMetrics();
      const alerts = await analyzeMetrics(metrics);

      // Send alerts if any issues detected
      if (alerts.length > 0) {
        await sendAlerts(alerts);
      }

      // Store metrics for trending
      await storeMetrics(metrics);

      console.log(`Health check completed - ${alerts.length} alerts generated`);
    } catch (error) {
      console.error("Health monitoring failed:", error);
      await sendCriticalAlert({
        type: "MONITORING_FAILURE",
        message: `Health monitoring failed: ${error instanceof Error ? error.message : String(error)}`,
        severity: "critical",
        timestamp: Date.now(),
      });
    }
  });

// Performance monitoring for critical functions
export const performanceMonitor = functions.https.onCall(async (data, context) => {
  const startTime = Date.now();

  try {
    if (!context.auth) {
      throw new functions.https.HttpsError("unauthenticated", "Authentication required");
    }

    const { operation, parameters } = data;

    // Monitor specific operations
    switch (operation) {
    case "room_join":
      await monitorRoomJoin(parameters);
      break;
    case "game_state_update":
      await monitorGameStateUpdate(parameters);
      break;
    default:
      throw new functions.https.HttpsError("invalid-argument", "Unknown operation");
    }

    const duration = Date.now() - startTime;

    // Log performance metrics
    await logPerformanceMetric({
      operation,
      duration,
      userId: context.auth.uid,
      timestamp: Date.now(),
    });

    return { success: true, duration };

  } catch (error) {
    const duration = Date.now() - startTime;

    await logPerformanceMetric({
      operation: data.operation,
      duration,
      userId: context.auth?.uid || "anonymous",
      timestamp: Date.now(),
      error: error instanceof Error ? error.message : String(error),
    });

    throw error;
  }
});

async function collectSystemMetrics(): Promise<SystemMetrics> {
  const db = admin.database();

  try {
    // Count active rooms
    const roomsSnapshot = await db.ref("rooms")
      .orderByChild("status")
      .equalTo("active")
      .limitToFirst(1000)
      .once("value");

    const activeRooms = roomsSnapshot.numChildren();

    // Count total users active in last hour
    const oneHourAgo = Date.now() - 3600000;
    const usersSnapshot = await db.ref("users")
      .orderByChild("lastActive")
      .startAt(oneHourAgo)
      .limitToFirst(1000)
      .once("value");

    const userCount = usersSnapshot.numChildren();

    // Get error logs from last minute
    const oneMinuteAgo = Date.now() - 60000;
    const errorsSnapshot = await db.ref("errorLogs")
      .orderByChild("timestamp")
      .startAt(oneMinuteAgo)
      .limitToFirst(100)
      .once("value");

    const errorCount = errorsSnapshot.numChildren();

    // Calculate error rate (errors per minute)
    const errorRate = errorCount / 60; // errors per second

    // Get memory usage
    const memoryUsage = process.memoryUsage().heapUsed / 1024 / 1024; // MB

    // Simulate database connections (would need actual monitoring in production)
    const databaseConnections = await estimateDatabaseConnections();

    return {
      activeRooms,
      databaseConnections,
      errorRate,
      memoryUsage,
      timestamp: Date.now(),
      responseTime: await measureResponseTime(),
      userCount,
    };
  } catch (error) {
    console.error("Failed to collect metrics:", error);
    throw error;
  }
}

async function analyzeMetrics(metrics: SystemMetrics): Promise<Alert[]> {
  const alerts: Alert[] = [];

  // Check active rooms threshold
  if (metrics.activeRooms > 1000) {
    alerts.push({
      type: "HIGH_ROOM_COUNT",
      message: `Active rooms: ${metrics.activeRooms}`,
      severity: metrics.activeRooms > 2000 ? "critical" : "warning",
      timestamp: Date.now(),
      metric: "activeRooms",
      value: metrics.activeRooms,
      threshold: 1000,
    });
  }

  // Check database connections
  if (metrics.databaseConnections > 5000) {
    alerts.push({
      type: "HIGH_DB_CONNECTIONS",
      message: `Database connections: ${metrics.databaseConnections}`,
      severity: "critical",
      timestamp: Date.now(),
      metric: "databaseConnections",
      value: metrics.databaseConnections,
      threshold: 5000,
    });
  }

  // Check error rate
  if (metrics.errorRate > 0.05) {
    alerts.push({
      type: "HIGH_ERROR_RATE",
      message: `Error rate: ${(metrics.errorRate * 100).toFixed(2)}%`,
      severity: metrics.errorRate > 0.1 ? "critical" : "warning",
      timestamp: Date.now(),
      metric: "errorRate",
      value: metrics.errorRate,
      threshold: 0.05,
    });
  }

  // Check memory usage
  if (metrics.memoryUsage > 512) {
    alerts.push({
      type: "HIGH_MEMORY_USAGE",
      message: `Memory usage: ${metrics.memoryUsage.toFixed(2)}MB`,
      severity: metrics.memoryUsage > 1024 ? "critical" : "warning",
      timestamp: Date.now(),
      metric: "memoryUsage",
      value: metrics.memoryUsage,
      threshold: 512,
    });
  }

  // Check response time
  if (metrics.responseTime > 2000) {
    alerts.push({
      type: "SLOW_RESPONSE_TIME",
      message: `Response time: ${metrics.responseTime}ms`,
      severity: metrics.responseTime > 5000 ? "critical" : "warning",
      timestamp: Date.now(),
      metric: "responseTime",
      value: metrics.responseTime,
      threshold: 2000,
    });
  }

  return alerts;
}

async function sendAlerts(alerts: Alert[]): Promise<void> {
  const db = admin.firestore();

  for (const alert of alerts) {
    // Store alert in Firestore
    await db.collection("alerts").add({
      ...alert,
      resolved: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send critical alerts to external monitoring
    if (alert.severity === "critical") {
      await sendCriticalAlert(alert);
    }

    console.log(`Alert generated: ${alert.type} - ${alert.message}`);
  }
}

async function sendCriticalAlert(alert: Alert): Promise<void> {
  // In production, this would integrate with external services like PagerDuty, Slack, etc.
  console.error(`CRITICAL ALERT: ${alert.type} - ${alert.message}`);

  // Store in database for immediate visibility
  const db = admin.database();
  await db.ref("criticalAlerts").push({
    ...alert,
    timestamp: admin.database.ServerValue.TIMESTAMP,
  });

  // TODO: Integrate with external alerting service
  // await notifyPagerDuty(alert);
  // await sendSlackNotification(alert);
}

async function storeMetrics(metrics: SystemMetrics): Promise<void> {
  const db = admin.firestore();

  await db.collection("systemMetrics").add({
    ...metrics,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Also store in Realtime Database for real-time dashboard
  const rtdb = admin.database();
  await rtdb.ref("systemHealth/current").set(metrics);
}

async function estimateDatabaseConnections(): Promise<number> {
  // This would need to be implemented with actual Firebase monitoring
  // For now, return a simulated value based on active rooms
  const db = admin.database();
  const roomsSnapshot = await db.ref("rooms").limitToFirst(100).once("value");
  const roomCount = roomsSnapshot.numChildren();

  // Estimate: each active room might have 2-4 connections
  return roomCount * 3;
}

async function measureResponseTime(): Promise<number> {
  const startTime = Date.now();

  try {
    const db = admin.database();
    await db.ref(".info/connected").once("value");
    return Date.now() - startTime;
  } catch (error) {
    return Date.now() - startTime;
  }
}

async function monitorRoomJoin(parameters: any): Promise<void> {
  // Monitor room join performance
  const startTime = Date.now();

  // Simulate room join monitoring
  await new Promise(resolve => setTimeout(resolve, 100));

  const duration = Date.now() - startTime;

  if (duration > 1000) {
    console.warn(`Slow room join detected: ${duration}ms`);
  }
}

async function monitorGameStateUpdate(parameters: any): Promise<void> {
  // Monitor game state update performance
  const startTime = Date.now();

  // Simulate game state monitoring
  await new Promise(resolve => setTimeout(resolve, 50));

  const duration = Date.now() - startTime;

  if (duration > 500) {
    console.warn(`Slow game state update detected: ${duration}ms`);
  }
}

async function logPerformanceMetric(metric: {
  operation: string;
  duration: number;
  userId: string;
  timestamp: number;
  error?: string;
}): Promise<void> {
  const db = admin.firestore();

  await db.collection("performanceMetrics").add({
    ...metric,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
