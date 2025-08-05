# Multi-Platform Deployment and Distribution

This document describes the comprehensive deployment and distribution setup for Snakes Fight across Web, Android, and iOS platforms.

## Overview

The project implements automated CI/CD pipelines that handle:
- **Web Deployment**: Firebase Hosting with CDN distribution
- **Android Distribution**: Google Play Store via automated builds
- **iOS Distribution**: Apple App Store via TestFlight and App Store Connect
- **Cross-Platform Builds**: Consistent builds across all target platforms

## Deployment Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Development   │    │     Staging      │    │   Production    │
│                 │    │                  │    │                 │
│ snakes-fight-   │    │ snakes-fight-    │    │ snakes-fight-   │
│ dev.web.app     │    │ staging.web.app  │    │ prod.web.app    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────────────┐
                    │     CI/CD Pipeline      │
                    │                         │
                    │ • Code Quality Checks   │
                    │ • Security Scanning     │
                    │ • Automated Testing     │
                    │ • Multi-Platform Builds │
                    │ • Automated Deployment  │
                    └─────────────────────────┘
```

## Platform Configurations

### Web Platform
- **Hosting**: Firebase Hosting with global CDN
- **Renderer**: CanvasKit for optimal performance
- **Caching**: Aggressive caching for static assets
- **Security**: CSP headers, HTTPS enforcement

### Android Platform
- **Package**: `com.snakesfight.game`
- **Min SDK**: API 21 (Android 5.0)
- **Target SDK**: API 34 (Android 14)
- **Distribution**: Google Play Store
- **Signing**: Release signing with secure keystore

### iOS Platform
- **Bundle ID**: `com.snakesfight.game`
- **Min Version**: iOS 12.0
- **Distribution**: Apple App Store via TestFlight
- **Signing**: Automatic signing with Xcode

## CI/CD Pipelines

### 1. Main CI/CD Pipeline (`.github/workflows/ci-cd.yml`)
Runs on every push and pull request:
- Code quality checks (formatting, analysis)
- Security scanning
- Automated testing
- Environment-specific deployments
- Performance monitoring

### 2. Web Deployment (`.github/workflows/deploy-web.yml`)
Handles web application deployment:
- Builds optimized web bundle
- Deploys to Firebase Hosting
- Provides preview deployments for PRs

### 3. Mobile Builds (`.github/workflows/build-mobile.yml`)
Creates signed mobile applications:
- Builds Android APK and App Bundle
- Creates iOS archive and IPA
- Uploads to respective app stores

## Build Scripts

### `scripts/build.sh`
Main build script for single platforms:
```bash
./scripts/build.sh [platform] [mode] [environment]
```

### `scripts/build-all-platforms.sh`
Comprehensive build for all platforms:
```bash
./scripts/build-all-platforms.sh [environment] [version] [build_number]
```

### `scripts/deploy.sh`
Deployment orchestration script:
```bash
./scripts/deploy.sh [environment] [version] [build_number]
```

## Environment Configuration

### Development
- **Firebase Project**: `snakes-fight-dev`
- **URL**: https://snakes-fight-dev.web.app
- **Purpose**: Active development and testing

### Staging
- **Firebase Project**: `snakes-fight-staging`
- **URL**: https://snakes-fight-staging.web.app
- **Purpose**: Pre-production testing and QA

### Production
- **Firebase Project**: `snakes-fight-prod`
- **URL**: https://snakes-fight-prod.web.app
- **Purpose**: Live production environment

## App Store Distribution

### Google Play Store
- **Package Name**: `com.snakesfight.game`
- **Automation**: Fastlane + GitHub Actions
- **Tracks**: Internal testing → Production
- **Metadata**: Automated via fastlane metadata

### Apple App Store
- **Bundle ID**: `com.snakesfight.game`
- **Automation**: Fastlane + GitHub Actions
- **Distribution**: TestFlight → App Store
- **Signing**: App Store Connect API

## Security Configuration

### Android Signing
- Keystore managed via GitHub Secrets
- Separate debug/release signing configs
- ProGuard enabled for release builds

### iOS Signing
- Certificates managed via App Store Connect
- Automatic signing for simplicity
- Provisioning profiles auto-managed

### Firebase Security
- Environment-specific projects
- Secure database rules
- API key restrictions

## Deployment Process

### Automated Deployment
1. **Trigger**: Push to main/develop or release tag
2. **Quality Gates**: Tests, security, performance checks
3. **Build**: Multi-platform builds with environment configs
4. **Deploy**: Automatic deployment to respective environments
5. **Verify**: Post-deployment health checks

### Manual Deployment
```bash
# Deploy to staging
./scripts/deploy.sh staging

# Deploy to production
./scripts/deploy.sh production

# Build all platforms
./scripts/build-all-platforms.sh production 1.0.0 123
```

## Monitoring and Rollback

### Deployment Monitoring
- Firebase Hosting metrics
- App store console monitoring
- Performance tracking via Firebase Analytics

### Rollback Strategy
- Firebase Hosting: Instant rollback via console
- Mobile apps: Version management and staged rollouts
- Database: Environment isolation prevents cross-contamination

## Required Secrets

### GitHub Secrets
```
# Firebase
FIREBASE_SERVICE_ACCOUNT
FIREBASE_SERVICE_ACCOUNT_DEV

# Android
ANDROID_KEYSTORE
ANDROID_KEY_ALIAS
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_PASSWORD
GOOGLE_PLAY_SERVICE_ACCOUNT

# iOS
IOS_BUILD_CERTIFICATE_BASE64
IOS_P12_PASSWORD
IOS_BUILD_PROVISION_PROFILE_BASE64
IOS_KEYCHAIN_PASSWORD
APPSTORE_ISSUER_ID
APPSTORE_API_KEY_ID
APPSTORE_API_PRIVATE_KEY
```

## Performance Optimizations

### Web
- CanvasKit renderer for smooth animations
- Aggressive asset caching (1 year for static assets)
- Gzip compression enabled
- Build size monitoring (< 10MB target)

### Mobile
- APK splitting for reduced download sizes
- ProGuard/R8 optimization for Android
- iOS archive optimization
- Background processing optimization

## Release Process

### Version Management
1. Update version in `pubspec.yaml`
2. Create git tag: `git tag v1.0.0`
3. Push tag: `git push origin v1.0.0`
4. GitHub Actions automatically builds and deploys

### App Store Releases
1. **iOS**: Automatic TestFlight upload → Manual App Store submission
2. **Android**: Automatic Play Store upload to production track
3. **Web**: Automatic deployment to Firebase Hosting

## Troubleshooting

### Common Issues
- **Build failures**: Check Flutter/dependencies versions
- **Signing issues**: Verify certificates and provisioning profiles
- **Deployment failures**: Check Firebase permissions and project settings
- **App store rejections**: Review app store guidelines and metadata

### Debug Commands
```bash
# Check build status
flutter doctor

# Test local build
./scripts/build.sh web release development

# Verify Firebase connection
firebase projects:list

# Check Git status
git status
git log --oneline -n 5
```

## Future Enhancements

### Planned Improvements
- **Progressive Web App**: Add PWA capabilities for better mobile web experience
- **Desktop Platforms**: Extend to macOS, Windows, and Linux
- **Beta Testing**: Implement beta testing tracks for both platforms
- **Analytics**: Enhanced deployment and usage analytics
- **Monitoring**: Real-time error tracking and performance monitoring

### Infrastructure Scaling
- CDN optimization for global performance
- Database scaling for increased concurrent users
- Load balancing for high availability
- Disaster recovery planning

---

This deployment system ensures reliable, secure, and automated distribution of Snakes Fight across all target platforms while maintaining quality and performance standards.
