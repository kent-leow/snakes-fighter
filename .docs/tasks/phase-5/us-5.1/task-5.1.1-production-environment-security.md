# Task 5.1.1: Production Environment Setup and Security Hardening

## Overview
- User Story: us-5.1-production-environment
- Task ID: task-5.1.1-production-environment-security
- Priority: Critical
- Effort: 12 hours
- Dependencies: task-4.3.1-comprehensive-testing-framework

## Description
Set up production Firebase environment with enterprise-grade security, monitoring, and backup systems. Configure production-ready security rules, implement monitoring and alerting, and establish disaster recovery procedures.

## Technical Requirements
### Components
- Production Firebase Project: Isolated production environment
- Security Hardening: Production-grade security configuration
- Monitoring & Alerting: Real-time system monitoring
- Backup & Recovery: Data protection and disaster recovery

### Tech Stack
- Firebase Production Environment: Separate production project
- Firebase Security Rules: Production-hardened rules
- Firebase Performance Monitoring: Real-time performance tracking
- Firebase Crashlytics: Error tracking and reporting

## Implementation Steps
### Step 1: Create Production Firebase Environment
- Action: Set up separate production Firebase project with proper configuration
- Deliverable: Isolated production environment
- Acceptance: Production environment completely separated from development
- Files: Production Firebase project configuration

### Step 2: Implement Production Security Rules
- Action: Deploy hardened security rules with comprehensive access control
- Deliverable: Production-grade security configuration
- Acceptance: Security rules prevent all unauthorized access attempts
- Files: Production `database.rules.json` and security configuration

### Step 3: Configure Monitoring and Alerting
- Action: Set up comprehensive monitoring with real-time alerts
- Deliverable: Complete monitoring and alerting system
- Acceptance: All critical metrics monitored with appropriate alerts
- Files: Monitoring configuration and alert rules

### Step 4: Establish Backup and Recovery Procedures
- Action: Implement automated backup and disaster recovery procedures
- Deliverable: Complete backup and recovery system
- Acceptance: Data can be recovered within defined RTO/RPO targets
- Files: Backup scripts and recovery procedures

## Technical Specs
### Production Security Rules
```json
{
  "rules": {
    "rooms": {
      ".indexOn": ["roomCode", "createdAt", "status"],
      "$roomId": {
        ".read": "auth != null && (data.child('players').child(auth.uid).exists() || (!data.exists() && auth.uid != null))",
        ".write": "auth != null && (newData.child('players').child(auth.uid).exists() || !data.exists())",
        ".validate": "newData.hasChildren(['roomCode', 'hostId', 'status', 'createdAt', 'maxPlayers'])",
        
        "roomCode": {
          ".validate": "newData.isString() && newData.val().matches(/^[A-Z0-9]{6}$/)"
        },
        
        "hostId": {
          ".validate": "newData.isString() && newData.val().length > 0"
        },
        
        "status": {
          ".validate": "newData.isString() && newData.val().matches(/^(waiting|active|ended)$/)"
        },
        
        "maxPlayers": {
          ".validate": "newData.isNumber() && newData.val() >= 2 && newData.val() <= 4"
        },
        
        "players": {
          ".validate": "newData.hasChildren() && newData.numChildren() <= data.parent().child('maxPlayers').val()",
          "$playerId": {
            ".write": "auth != null && ($playerId == auth.uid || data.parent().parent().child('hostId').val() == auth.uid)",
            ".validate": "newData.hasChildren(['uid', 'displayName', 'color', 'joinedAt'])",
            
            "uid": {
              ".validate": "newData.isString() && newData.val() == $playerId"
            },
            
            "displayName": {
              ".validate": "newData.isString() && newData.val().length >= 1 && newData.val().length <= 20"
            },
            
            "color": {
              ".validate": "newData.isString() && newData.val().matches(/^(red|blue|green|yellow)$/)"
            },
            
            "isReady": {
              ".validate": "newData.isBoolean()"
            }
          }
        },
        
        "gameState": {
          ".write": "auth != null && data.parent().child('players').child(auth.uid).exists() && data.parent().child('status').val() == 'active'",
          ".validate": "newData.hasChildren(['startedAt', 'food', 'snakes'])",
          
          "food": {
            ".validate": "newData.hasChildren(['x', 'y']) && newData.child('x').isNumber() && newData.child('y').isNumber()"
          },
          
          "snakes": {
            "$playerId": {
              ".write": "auth != null && ($playerId == auth.uid || root.child('functions').child('serverValidation').val() == true)",
              ".validate": "newData.hasChildren(['positions', 'direction', 'alive', 'score'])",
              
              "alive": {
                ".validate": "newData.isBoolean()"
              },
              
              "score": {
                ".validate": "newData.isNumber() && newData.val() >= 0"
              },
              
              "direction": {
                ".validate": "newData.isString() && newData.val().matches(/^(up|down|left|right)$/)"
              }
            }
          }
        }
      }
    },
    
    "users": {
      ".indexOn": ["lastActive"],
      "$userId": {
        ".read": "auth != null && $userId == auth.uid",
        ".write": "auth != null && $userId == auth.uid",
        ".validate": "newData.hasChildren(['displayName', 'isAnonymous'])",
        
        "displayName": {
          ".validate": "newData.isString() && newData.val().length >= 1 && newData.val().length <= 20"
        },
        
        "isAnonymous": {
          ".validate": "newData.isBoolean()"
        },
        
        "stats": {
          "gamesPlayed": {
            ".validate": "newData.isNumber() && newData.val() >= 0"
          },
          
          "gamesWon": {
            ".validate": "newData.isNumber() && newData.val() >= 0"
          }
        }
      }
    },
    
    // Rate limiting and abuse prevention
    ".read": "auth != null",
    ".write": "auth != null && (!root.child('rateLimiting').child(auth.uid).exists() || root.child('rateLimiting').child(auth.uid).child('lastWrite').val() < (now - 100))"
  }
}
```

### Monitoring Configuration
```typescript
// functions/src/monitoring/production-monitoring.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const monitorSystemHealth = functions.pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    const metrics = await collectSystemMetrics();
    
    // Check critical thresholds
    const alerts = [];
    
    if (metrics.activeRooms > 1000) {
      alerts.push({
        type: 'HIGH_ROOM_COUNT',
        message: `Active rooms: ${metrics.activeRooms}`,
        severity: 'warning',
      });
    }
    
    if (metrics.databaseConnections > 5000) {
      alerts.push({
        type: 'HIGH_DB_CONNECTIONS',
        message: `Database connections: ${metrics.databaseConnections}`,
        severity: 'critical',
      });
    }
    
    if (metrics.errorRate > 0.05) {
      alerts.push({
        type: 'HIGH_ERROR_RATE',
        message: `Error rate: ${(metrics.errorRate * 100).toFixed(2)}%`,
        severity: 'critical',
      });
    }
    
    // Send alerts if any issues detected
    if (alerts.length > 0) {
      await sendAlerts(alerts);
    }
    
    // Store metrics for trending
    await storeMetrics(metrics);
  });

async function collectSystemMetrics() {
  const db = admin.database();
  
  // Count active rooms
  const roomsSnapshot = await db.ref('rooms')
    .orderByChild('status')
    .equalTo('active')
    .once('value');
  
  const activeRooms = roomsSnapshot.numChildren();
  
  // Get error logs from last minute
  const oneMinuteAgo = Date.now() - 60000;
  const errorsSnapshot = await db.ref('errorLogs')
    .orderByChild('timestamp')
    .startAt(oneMinuteAgo)
    .once('value');
  
  const errorCount = errorsSnapshot.numChildren();
  
  // Calculate error rate (simplified)
  const totalRequests = await getTotalRequests();
  const errorRate = totalRequests > 0 ? errorCount / totalRequests : 0;
  
  return {
    activeRooms,
    databaseConnections: await getDatabaseConnections(),
    errorRate,
    memoryUsage: process.memoryUsage().heapUsed / 1024 / 1024, // MB
    timestamp: Date.now(),
  };
}

async function sendAlerts(alerts: any[]) {
  // Send to monitoring service (e.g., PagerDuty, Slack)
  for (const alert of alerts) {
    await admin.firestore().collection('alerts').add({
      ...alert,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    // Send to external monitoring service
    if (alert.severity === 'critical') {
      await sendCriticalAlert(alert);
    }
  }
}
```

### Backup System
```typescript
// functions/src/backup/automated-backup.ts
export const dailyBackup = functions.pubsub
  .schedule('0 2 * * *') // Daily at 2 AM
  .onRun(async (context) => {
    try {
      const backupData = await createBackup();
      await storeBackup(backupData);
      await cleanOldBackups();
      
      console.log('Daily backup completed successfully');
    } catch (error) {
      console.error('Backup failed:', error);
      await sendBackupAlert('BACKUP_FAILED', error.message);
    }
  });

async function createBackup() {
  const db = admin.database();
  
  // Backup critical data
  const [rooms, users] = await Promise.all([
    db.ref('rooms').once('value'),
    db.ref('users').once('value'),
  ]);
  
  return {
    timestamp: Date.now(),
    rooms: rooms.val(),
    users: users.val(),
    metadata: {
      version: '1.0',
      environment: 'production',
    },
  };
}

async function storeBackup(backupData: any) {
  const storage = admin.storage();
  const bucket = storage.bucket('snakes-fight-backups');
  
  const timestamp = new Date().toISOString().split('T')[0];
  const filename = `backup-${timestamp}-${backupData.timestamp}.json`;
  
  const file = bucket.file(filename);
  await file.save(JSON.stringify(backupData, null, 2), {
    metadata: {
      contentType: 'application/json',
      metadata: {
        type: 'daily-backup',
        environment: 'production',
      },
    },
  });
}

async function cleanOldBackups() {
  const storage = admin.storage();
  const bucket = storage.bucket('snakes-fight-backups');
  
  const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);
  
  const [files] = await bucket.getFiles({
    prefix: 'backup-',
  });
  
  const oldFiles = files.filter(file => {
    const created = new Date(file.metadata.timeCreated).getTime();
    return created < thirtyDaysAgo;
  });
  
  await Promise.all(oldFiles.map(file => file.delete()));
  
  console.log(`Cleaned up ${oldFiles.length} old backup files`);
}
```

### Disaster Recovery Procedures
```typescript
// functions/src/recovery/disaster-recovery.ts
export const initiateRecovery = functions.https.onCall(async (data, context) => {
  // Verify admin access
  if (!context.auth?.token.admin) {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }
  
  const { backupTimestamp, recoveryType } = data;
  
  try {
    switch (recoveryType) {
      case 'FULL_RESTORE':
        await performFullRestore(backupTimestamp);
        break;
      case 'PARTIAL_RESTORE':
        await performPartialRestore(backupTimestamp, data.components);
        break;
      default:
        throw new Error('Invalid recovery type');
    }
    
    await logRecoveryEvent(recoveryType, backupTimestamp, 'SUCCESS');
    return { success: true, message: 'Recovery completed successfully' };
    
  } catch (error) {
    await logRecoveryEvent(recoveryType, backupTimestamp, 'FAILED', error.message);
    throw new functions.https.HttpsError('internal', `Recovery failed: ${error.message}`);
  }
});

async function performFullRestore(backupTimestamp: number) {
  const backup = await loadBackup(backupTimestamp);
  const db = admin.database();
  
  // Create maintenance mode
  await db.ref('maintenance').set({
    active: true,
    message: 'System restoration in progress',
    startTime: Date.now(),
  });
  
  try {
    // Restore data
    await Promise.all([
      db.ref('rooms').set(backup.rooms),
      db.ref('users').set(backup.users),
    ]);
    
    // Verify restoration
    await verifyDataIntegrity();
    
  } finally {
    // Remove maintenance mode
    await db.ref('maintenance').remove();
  }
}
```

## Testing
- [ ] Security penetration testing on production rules
- [ ] Monitoring and alerting system validation
- [ ] Backup and recovery procedure testing

## Acceptance Criteria
- [ ] Production environment completely isolated from development
- [ ] Security rules prevent all unauthorized access
- [ ] Monitoring system tracks all critical metrics
- [ ] Alerting system responds to threshold breaches
- [ ] Backup system creates recoverable data snapshots
- [ ] Recovery procedures tested and documented

## Dependencies
- Before: Application testing and QA complete
- After: Production deployment can proceed safely
- External: Production Firebase project and monitoring services

## Risks
- Risk: Production security misconfiguration exposing data
- Mitigation: Comprehensive security testing and review process

## Definition of Done
- [ ] Production Firebase environment configured
- [ ] Security rules hardened and tested
- [ ] Monitoring and alerting operational
- [ ] Backup system functional and tested
- [ ] Recovery procedures documented and verified
- [ ] Security audit completed and passed
