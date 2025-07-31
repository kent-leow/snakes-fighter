#!/bin/bash

# Build script for Snakes Fight Flutter project
# Usage: ./scripts/build.sh [platform] [mode]
# Platforms: web, android, ios, macos, linux, windows
# Modes: debug, profile, release

set -e

PLATFORM=${1:-web}
MODE=${2:-release}

echo "🏗️  Building Snakes Fight for $PLATFORM in $MODE mode..."

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Run code generation if needed
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    echo "🔧 Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

# Build for specified platform
case $PLATFORM in
    web)
        echo "🌐 Building for web..."
        flutter build web --$MODE
        ;;
    android)
        echo "🤖 Building for Android..."
        flutter build apk --$MODE
        ;;
    ios)
        echo "🍎 Building for iOS..."
        flutter build ios --$MODE
        ;;
    macos)
        echo "🖥️  Building for macOS..."
        flutter build macos --$MODE
        ;;
    linux)
        echo "🐧 Building for Linux..."
        flutter build linux --$MODE
        ;;
    windows)
        echo "🪟 Building for Windows..."
        flutter build windows --$MODE
        ;;
    *)
        echo "❌ Unknown platform: $PLATFORM"
        echo "Available platforms: web, android, ios, macos, linux, windows"
        exit 1
        ;;
esac

echo "✅ Build completed successfully!"
