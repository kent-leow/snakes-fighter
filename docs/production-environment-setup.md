# Production Environment Setup Guide

## Overview
This guide provides step-by-step instructions for setting up the production environment for Snakes Fight, including Firebase project configuration, security hardening, monitoring, and backup systems.

## Prerequisites
- Firebase CLI installed and configured
- Admin access to create Firebase projects
- Google Cloud Platform account with billing enabled
- Production domain (if using custom hosting)

## Step 1: Create Production Firebase Project

### 1.1 Create Project
```bash
# Login to Firebase
firebase login

# Create new project via Firebase Console
# Project ID: snakes-fight-prod
# Project Name: Snakes Fight Production
```

### 1.2 Enable Required Services
1. **Realtime Database**: Enable in Firebase Console
2. **Cloud Functions**: Enable with Blaze plan
3. **Firebase Hosting**: Enable for web deployment
4. **Cloud Storage**: Enable for backups
5. **Firebase Performance Monitoring**: Enable for monitoring
6. **Crashlytics**: Enable for error tracking

### 1.3 Configure Project
```bash
# Initialize Firebase in your project
firebase init --config firebase.prod.json

# Select:
# - Database: Configure security rules
# - Functions: JavaScript/TypeScript
# - Hosting: Configure files for Firebase Hosting
```

## Step 2: Security Configuration

### 2.1 Deploy Production Security Rules
```bash
# Deploy hardened security rules
firebase deploy --only database --config firebase.prod.json
```

### 2.2 Configure Authentication
1. Enable **Anonymous Authentication** in Firebase Console
2. Set up **App Check** for additional security
3. Configure **CORS** settings for web domains

### 2.3 Set Security Headers
Production hosting includes security headers:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000`
- Content Security Policy for XSS protection

## Step 3: Functions Deployment

### 3.1 Build and Deploy Functions
```bash
cd functions
npm install
npm run build
npm run lint

# Deploy to production
firebase deploy --only functions --config firebase.prod.json
```

### 3.2 Configure Environment Variables
```bash
# Set production environment variables
firebase functions:config:set environment.type="production" --project snakes-fight-prod
firebase functions:config:set monitoring.enabled="true" --project snakes-fight-prod
```

## Step 4: Monitoring Setup

### 4.1 System Health Monitoring
The production environment includes automated monitoring:
- **Health checks**: Every minute via Pub/Sub trigger
- **Performance monitoring**: Response time and error rate tracking
- **Resource monitoring**: Memory usage and database connections
- **Alert system**: Critical alerts for threshold breaches

### 4.2 Configure Alerting
1. **Firestore Collections**: Alerts stored in `/alerts` collection
2. **Critical Alerts**: Stored in Realtime Database `/criticalAlerts`
3. **External Integration**: Configure PagerDuty/Slack webhooks (optional)

### 4.3 Performance Monitoring
- **Firebase Performance**: Automatic performance tracking
- **Custom Metrics**: Function execution times and response rates
- **User Analytics**: Game performance and engagement metrics

## Step 5: Backup System

### 5.1 Automated Backups
- **Daily Backups**: 2 AM UTC, 30-day retention
- **Weekly Backups**: Sunday 3 AM UTC, 1-year retention
- **Storage**: Google Cloud Storage bucket `snakes-fight-backups`

### 5.2 Backup Verification
All backups include:
- **Checksum verification**: SHA-256 integrity checks
- **Structure validation**: Data format verification
- **Size monitoring**: Backup size tracking and alerts

### 5.3 Manual Backup
```bash
# Create manual backup via Functions
firebase functions:shell --project snakes-fight-prod
# Run: createManualBackup({type: 'manual', includeAll: true})
```

## Step 6: Disaster Recovery

### 6.1 Recovery Procedures
Available recovery types:
- **Full Restore**: Complete system restoration
- **Partial Restore**: Specific component restoration
- **Point-in-Time**: Recovery to specific timestamp

### 6.2 Recovery Testing
```bash
# Test recovery (dry run)
firebase functions:shell --project snakes-fight-prod
# Run: initiateRecovery({backupId: 'backup-id', recoveryType: 'FULL_RESTORE', dryRun: true})
```

## Step 7: Deployment Process

### 7.1 Automated Deployment
```bash
# Run production deployment script
./scripts/production/deploy-production.sh
```

### 7.2 Manual Deployment Steps
1. **Pre-deployment backup**: Create system backup
2. **Build verification**: Run tests and linting
3. **Security rules**: Deploy database rules first
4. **Functions deployment**: Deploy Cloud Functions
5. **Hosting deployment**: Deploy web application
6. **Post-deployment verification**: Health checks and testing

## Step 8: Security Hardening

### 8.1 Database Security
- **Authentication required**: All operations require auth
- **Rate limiting**: Global rate limiting to prevent abuse
- **Data validation**: Comprehensive input validation
- **Access control**: Strict user/room-based permissions

### 8.2 Function Security
- **Admin verification**: Admin-only functions with token validation
- **Error handling**: Secure error messages without data leakage
- **Input sanitization**: All inputs validated and sanitized

### 8.3 Hosting Security
- **HTTPS enforcement**: SSL/TLS encryption required
- **Security headers**: Comprehensive security header configuration
- **Content Security Policy**: XSS protection and resource control

## Step 9: Monitoring Dashboard

### 9.1 Real-time Metrics
Access system metrics via:
- **Firebase Console**: Functions and database metrics
- **Custom Dashboard**: Real-time system health at `/systemHealth/current`
- **Alert Dashboard**: Active alerts in Firestore `/alerts`

### 9.2 Performance Metrics
- **Response times**: Function execution performance
- **Error rates**: System error tracking and trending
- **User metrics**: Active users and game statistics
- **Resource usage**: Memory and database connection monitoring

## Step 10: Maintenance Procedures

### 10.1 Regular Maintenance
- **Daily**: Monitor alerts and system health
- **Weekly**: Review performance metrics and optimize
- **Monthly**: Security audit and backup verification
- **Quarterly**: Disaster recovery testing

### 10.2 Emergency Procedures
1. **System Outage**: Enable maintenance mode
2. **Data Corruption**: Initiate recovery procedures
3. **Security Breach**: Implement incident response plan
4. **Performance Issues**: Scale resources and optimize

## Production Checklist

### Pre-launch Verification
- [ ] Production Firebase project created and configured
- [ ] Security rules deployed and tested
- [ ] All functions deployed and operational
- [ ] Monitoring and alerting systems active
- [ ] Backup systems tested and verified
- [ ] Recovery procedures documented and tested
- [ ] Performance testing completed
- [ ] Security audit passed

### Post-launch Monitoring
- [ ] System health monitoring active
- [ ] Error rates within acceptable limits
- [ ] Performance metrics meeting SLA requirements
- [ ] Backup systems creating regular snapshots
- [ ] User feedback and issue tracking system active

## Support and Troubleshooting

### Common Issues
1. **Function timeout**: Increase timeout limits in Firebase Console
2. **Database connection limits**: Monitor concurrent connections
3. **Storage quota**: Monitor backup storage usage
4. **Rate limiting**: Adjust rate limiting thresholds

### Emergency Contacts
- **Firebase Support**: Priority support for production issues
- **Development Team**: 24/7 on-call rotation
- **Infrastructure Team**: Cloud platform support

### Escalation Procedures
1. **Level 1**: Automated monitoring and alerting
2. **Level 2**: On-call developer response
3. **Level 3**: Senior technical lead escalation
4. **Level 4**: Management and external support

## Security Considerations

### Data Protection
- All data encrypted at rest and in transit
- User data privacy compliance (GDPR/CCPA)
- Regular security audits and penetration testing
- Incident response plan for data breaches

### Access Control
- Multi-factor authentication for admin access
- Principle of least privilege for all services
- Regular access review and rotation
- Audit logging for all administrative actions

### Compliance
- Regular security audits and compliance checks
- Documentation of all security measures
- Incident response and breach notification procedures
- Regular backup and recovery testing

## Conclusion

This production environment setup provides enterprise-grade security, monitoring, and reliability for the Snakes Fight multiplayer game. The system is designed to handle production traffic while maintaining high availability and data integrity.

For questions or issues, refer to the troubleshooting section or contact the development team.
