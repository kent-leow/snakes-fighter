# Task 5.2.1: Multi-Platform Deployment and Distribution

## Overview
- User Story: us-5.2-deployment-distribution
- Task ID: task-5.2.1-multiplatform-deployment-distribution
- Priority: Critical
- Effort: 16 hours
- Dependencies: task-5.1.1-production-environment-security

## Description
Deploy the multiplayer snake game across all target platforms (Web, Android, iOS) with automated build pipelines, app store distribution, and continuous deployment setup. Ensure consistent functionality and performance across all platforms.

## Technical Requirements
### Components
- Web Deployment: Firebase Hosting for web distribution
- Mobile App Builds: Android and iOS app generation
- App Store Distribution: Google Play Store and Apple App Store
- CI/CD Pipeline: Automated build and deployment

### Tech Stack
- Firebase Hosting: Web deployment platform
- Flutter Build: Cross-platform app compilation
- Fastlane: iOS/Android deployment automation
- GitHub Actions: CI/CD pipeline automation

## Implementation Steps
### Step 1: Configure Web Deployment Pipeline
- Action: Set up automated web deployment to Firebase Hosting
- Deliverable: Functional web deployment pipeline
- Acceptance: Web app accessible via production URL with automatic updates
- Files: Web build configuration and deployment scripts

### Step 2: Build Mobile App Distribution Pipeline
- Action: Create automated Android and iOS build and distribution
- Deliverable: Mobile app deployment pipeline
- Acceptance: Apps buildable and deployable to app stores
- Files: Mobile build scripts and store configurations

### Step 3: Set Up App Store Distribution
- Action: Configure Google Play Store and Apple App Store distribution
- Deliverable: App store listings and automated submission
- Acceptance: Apps published and available for download
- Files: App store metadata and submission configurations

### Step 4: Implement CI/CD Automation
- Action: Create complete CI/CD pipeline for all platforms
- Deliverable: Automated build, test, and deployment pipeline
- Acceptance: Code changes automatically deployed after testing
- Files: CI/CD configuration and automation scripts

## Technical Specs
### Web Deployment Configuration
```yaml
# .github/workflows/deploy-web.yml
name: Deploy Web App

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run tests
        run: flutter test
        
      - name: Run integration tests
        run: flutter test integration_test/
        
  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Build web app
        run: |
          flutter build web --release --web-renderer canvaskit
          
      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: snakes-fight-prod
```

### Mobile Build Configuration
```yaml
# .github/workflows/build-mobile.yml
name: Build Mobile Apps

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
          
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Build APK
        run: |
          flutter build apk --release --split-per-abi
          
      - name: Build App Bundle
        run: |
          flutter build appbundle --release
          
      - name: Sign Android Release
        uses: r0adkll/sign-android-release@v1
        with:
          releaseDirectory: build/app/outputs/bundle/release
          signingKeyBase64: ${{ secrets.ANDROID_SIGNING_KEY }}
          alias: ${{ secrets.ANDROID_KEY_ALIAS }}
          keyStorePassword: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          keyPassword: ${{ secrets.ANDROID_KEY_PASSWORD }}
          
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1.0.19
        with:
          serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
          packageName: com.snakesfight.game
          releaseFiles: build/app/outputs/bundle/release/*.aab
          track: production
          status: completed

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable
          
      - name: Build iOS
        run: |
          flutter build ios --release --no-codesign
          
      - name: Build and Archive
        run: |
          cd ios
          xcodebuild -workspace Runner.xcworkspace \
                     -scheme Runner \
                     -configuration Release \
                     -destination generic/platform=iOS \
                     -archivePath build/Runner.xcarchive \
                     archive
                     
      - name: Export IPA
        run: |
          cd ios
          xcodebuild -exportArchive \
                     -archivePath build/Runner.xcarchive \
                     -exportPath build \
                     -exportOptionsPlist ExportOptions.plist
                     
      - name: Upload to App Store
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: ios/build/Runner.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
```

### App Store Configuration
```xml
<!-- android/app/src/main/res/values/strings.xml -->
<resources>  
    <string name="app_name">Snakes Fight</string>
    <string name="app_description">Multiplayer Snake Game</string>
</resources>
```

```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    match(type: "appstore")
    
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
  
  desc "Deploy to App Store"
  lane :release do
    match(type: "appstore")
    
    build_app(
      workspace: "Runner.xcworkspace", 
      scheme: "Runner",
      export_method: "app-store"
    )
    
    upload_to_app_store(
      force: true,
      reject_if_possible: true,
      skip_metadata: false,
      skip_screenshots: false,
      submit_for_review: true,
      automatic_release: true
    )
  end
end
```

### Cross-Platform Build Scripts
```bash
#!/bin/bash
# scripts/build-all-platforms.sh

set -e

echo "Building Snakes Fight for all platforms..."

# Clean previous builds
flutter clean
flutter pub get

# Build for web
echo "Building for web..."
flutter build web --release --web-renderer canvaskit
cp build/web/* ../snakes-fight-web/

# Build for Android
echo "Building for Android..."
flutter build apk --release --split-per-abi
flutter build appbundle --release

# Build for iOS (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building for iOS..."
    flutter build ios --release --no-codesign
    
    cd ios
    xcodebuild -workspace Runner.xcworkspace \
               -scheme Runner \
               -configuration Release \
               -destination generic/platform=iOS \
               -archivePath build/Runner.xcarchive \
               archive
    cd ..
fi

echo "All builds completed successfully!"
echo "Web build: build/web/"
echo "Android APK: build/app/outputs/flutter-apk/"
echo "Android Bundle: build/app/outputs/bundle/release/"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "iOS Archive: ios/build/Runner.xcarchive"
fi
```

### Firebase Hosting Configuration
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css|woff2|woff|ttf|eot)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp|ico)",
        "headers": [
          {
            "key": "Cache-Control", 
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

### Version Management
```dart
// lib/core/app_info.dart
class AppInfo {
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'snakes-fight-dev',
  );
  
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  
  static String get displayVersion => '$version ($buildNumber)';
}
```

### Platform-Specific Configurations
```yaml
# pubspec.yaml platform configurations
flutter:
  assets:
    - assets/images/
    - assets/sounds/
    
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700

# Platform-specific configuration
platforms:
  android:
    package_name: com.snakesfight.game
    min_sdk_version: 21
    target_sdk_version: 33
    
  ios:
    bundle_id: com.snakesfight.game
    deployment_target: 12.0
    
  web:
    web_renderer: canvaskit
    base_href: /
```

## Testing
- [ ] Cross-platform functionality testing
- [ ] App store submission testing
- [ ] CI/CD pipeline validation

## Acceptance Criteria
- [ ] Web app deployed and accessible via production URL
- [ ] Android app published on Google Play Store
- [ ] iOS app published on Apple App Store
- [ ] CI/CD pipeline automating deployments
- [ ] All platforms have consistent functionality
- [ ] Performance benchmarks met on all platforms

## Dependencies
- Before: Production environment and security setup complete
- After: Game fully launched and available to users
- External: App store developer accounts and certificates

## Risks
- Risk: App store approval delays affecting launch timeline
- Mitigation: Submit apps well in advance and prepare for potential rejection scenarios

## Definition of Done
- [ ] Web deployment pipeline operational
- [ ] Mobile build and distribution pipeline working
- [ ] Apps published on all target app stores
- [ ] CI/CD automation functional
- [ ] Cross-platform testing completed
- [ ] Launch materials and documentation prepared
