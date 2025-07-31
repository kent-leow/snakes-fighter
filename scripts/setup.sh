#!/bin/bash

# Setup script for Snakes Fight Flutter project
# Usage: ./scripts/setup.sh

set -e

echo "🚀 Setting up Snakes Fight development environment..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter doctor
echo "🏥 Running Flutter doctor..."
flutter doctor

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p lib/core/{constants,theme,utils}
mkdir -p lib/features/{auth,game,rooms}
mkdir -p lib/shared/{models,widgets}
mkdir -p test/{unit,widget,integration}

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x scripts/*.sh

# Run initial code formatting
echo "💅 Running initial code formatting..."
dart format lib test --line-length 80

# Run initial analysis
echo "🔍 Running initial code analysis..."
flutter analyze

echo "✅ Development environment setup completed!"
echo ""
echo "🎉 You're ready to start developing!"
echo ""
echo "Available commands:"
echo "  ./scripts/dev.sh start    - Start development server"
echo "  ./scripts/dev.sh test     - Run tests"
echo "  ./scripts/dev.sh analyze  - Analyze code"
echo "  ./scripts/dev.sh format   - Format code"
echo "  ./scripts/build.sh web    - Build for web"
