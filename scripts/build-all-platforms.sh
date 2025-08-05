#!/bin/bash

# Multi-platform build script for Snakes Fight
# Builds the app for Web, Android, and iOS with proper signing and distribution

set -e

ENVIRONMENT=${1:-production}
VERSION=${2:-1.0.0}
BUILD_NUMBER=${3:-1}

echo "🚀 Building Snakes Fight v$VERSION+$BUILD_NUMBER for all platforms ($ENVIRONMENT)"

# Set Firebase project ID based on environment
case $ENVIRONMENT in
    production)
        FIREBASE_PROJECT_ID="snakes-fight-prod"
        ;;
    staging)
        FIREBASE_PROJECT_ID="snakes-fight-staging"
        ;;
    *)
        FIREBASE_PROJECT_ID="snakes-fight-dev"
        ;;
esac

echo "📋 Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   Version: $VERSION"
echo "   Build Number: $BUILD_NUMBER"
echo "   Firebase Project: $FIREBASE_PROJECT_ID"
echo ""

# Clean and prepare
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Common build arguments
BUILD_ARGS="--dart-define=ENVIRONMENT=$ENVIRONMENT --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID"

# Build for Web
echo "🌐 Building for Web..."
flutter build web --release --web-renderer canvaskit $BUILD_ARGS
WEB_SIZE=$(du -sh build/web | cut -f1)
echo "✅ Web build completed - Size: $WEB_SIZE"
echo "   Output: build/web/"

# Build for Android
echo "🤖 Building for Android..."
flutter build apk --release --split-per-abi $BUILD_ARGS
flutter build appbundle --release $BUILD_ARGS
echo "✅ Android builds completed"
echo "   APK: build/app/outputs/flutter-apk/"
echo "   Bundle: build/app/outputs/bundle/release/"

# Build for iOS (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building for iOS..."
    flutter build ios --release --no-codesign $BUILD_ARGS
    
    echo "📦 Creating iOS archive..."
    cd ios
    xcodebuild -workspace Runner.xcworkspace \
               -scheme Runner \
               -configuration Release \
               -destination generic/platform=iOS \
               -archivePath build/Runner.xcarchive \
               archive
    
    echo "📤 Exporting IPA..."
    xcodebuild -exportArchive \
               -archivePath build/Runner.xcarchive \
               -exportPath build \
               -exportOptionsPlist ExportOptions.plist
    
    cd ..
    echo "✅ iOS build completed"
    echo "   Archive: ios/build/Runner.xcarchive"
    echo "   IPA: ios/build/Runner.ipa"
else
    echo "⏭️  Skipping iOS build (requires macOS)"
fi

# Build summary
echo ""
echo "🎉 Build Summary for v$VERSION+$BUILD_NUMBER:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Platform Status:"
echo "   ✅ Web: Ready for Firebase Hosting"
echo "   ✅ Android: APK & Bundle ready for Play Store"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   ✅ iOS: Archive & IPA ready for App Store"
else
    echo "   ⏭️  iOS: Skipped (macOS required)"
fi
echo ""
echo "📁 Build Artifacts:"
echo "   Web: build/web/"
echo "   Android APK: build/app/outputs/flutter-apk/"
echo "   Android Bundle: build/app/outputs/bundle/release/"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   iOS Archive: ios/build/Runner.xcarchive"
    echo "   iOS IPA: ios/build/Runner.ipa"
fi
echo ""
echo "🔧 Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   Firebase Project: $FIREBASE_PROJECT_ID"
echo "   Version: $VERSION"
echo "   Build Number: $BUILD_NUMBER"

# Performance metrics
if [ -d "build/web" ]; then
    WEB_SIZE_BYTES=$(du -sb build/web | cut -f1)
    WEB_SIZE_MB=$((WEB_SIZE_BYTES / 1024 / 1024))
    echo "   Web Size: ${WEB_SIZE_MB}MB"
    
    if [ $WEB_SIZE_BYTES -gt $((10 * 1024 * 1024)) ]; then
        echo "   ⚠️  Web build exceeds 10MB recommended size"
    fi
fi

echo ""
echo "🚀 Ready for deployment!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
