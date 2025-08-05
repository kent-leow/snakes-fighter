#!/bin/bash

# Build script for Snakes Fight Flutter project
# Usage: ./scripts/build.sh [platform] [mode] [environment]
# Platforms: web, android, ios, all
# Modes: debug, profile, release
# Environments: development, staging, production

set -e

PLATFORM=${1:-web}
MODE=${2:-release}
ENVIRONMENT=${3:-development}

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

echo "🏗️  Building Snakes Fight for $PLATFORM in $MODE mode ($ENVIRONMENT environment)..."

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation if needed
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    echo "🔧 Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

# Common build flags
BUILD_FLAGS="--$MODE --dart-define=ENVIRONMENT=$ENVIRONMENT --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID"

# Build for specified platform
case $PLATFORM in
    web)
        echo "🌐 Building for web..."
        flutter build web $BUILD_FLAGS --web-renderer canvaskit
        echo "✅ Web build completed in: build/web/"
        ;;
    android)
        echo "🤖 Building for Android..."
        flutter build apk $BUILD_FLAGS --split-per-abi
        flutter build appbundle $BUILD_FLAGS
        echo "✅ Android builds completed:"
        echo "   APK: build/app/outputs/flutter-apk/"
        echo "   Bundle: build/app/outputs/bundle/release/"
        ;;
    ios)
        echo "🍎 Building for iOS..."
        if [[ "$OSTYPE" != "darwin"* ]]; then
            echo "❌ iOS builds require macOS"
            exit 1
        fi
        flutter build ios $BUILD_FLAGS --no-codesign
        echo "✅ iOS build completed in: build/ios/"
        ;;
    all)
        echo "� Building for all platforms..."
        
        # Web
        echo "🌐 Building web..."
        flutter build web $BUILD_FLAGS --web-renderer canvaskit
        
        # Android
        echo "🤖 Building Android..."
        flutter build apk $BUILD_FLAGS --split-per-abi
        flutter build appbundle $BUILD_FLAGS
        
        # iOS (only on macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "🍎 Building iOS..."
            flutter build ios $BUILD_FLAGS --no-codesign
        else
            echo "⏭️  Skipping iOS build (requires macOS)"
        fi
        
        echo "✅ All platform builds completed!"
        ;;
    *)
        echo "❌ Unknown platform: $PLATFORM"
        echo "Available platforms: web, android, ios, all"
        exit 1
        ;;
esac

# Build summary
echo ""
echo "📊 Build Summary:"
echo "Platform: $PLATFORM"
echo "Mode: $MODE"
echo "Environment: $ENVIRONMENT"
echo "Firebase Project: $FIREBASE_PROJECT_ID"

# Performance info for web builds
if [ "$PLATFORM" = "web" ] || [ "$PLATFORM" = "all" ]; then
    if [ -d "build/web" ]; then
        WEB_SIZE=$(du -sh build/web | cut -f1)
        echo "Web build size: $WEB_SIZE"
    fi
fi

echo "✅ Build completed successfully!"
