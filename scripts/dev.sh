#!/bin/bash

# Development script for Snakes Fight Flutter project
# Usage: ./scripts/dev.sh [command]
# Commands: start, test, analyze, format, clean

set -e

COMMAND=${1:-start}

echo "🛠️  Running development command: $COMMAND"

case $COMMAND in
    start)
        echo "🚀 Starting development server..."
        flutter pub get
        flutter run -d chrome --hot
        ;;
    test)
        echo "🧪 Running tests..."
        flutter test --coverage
        ;;
    analyze)
        echo "🔍 Analyzing code..."
        flutter analyze
        dart run dart_code_metrics:metrics analyze lib --reporter=html
        ;;
    format)
        echo "💅 Formatting code..."
        dart format lib test --line-length 80
        dart run import_sorter:main
        ;;
    clean)
        echo "🧹 Cleaning project..."
        flutter clean
        flutter pub get
        ;;
    deps)
        echo "📦 Getting dependencies..."
        flutter pub get
        flutter pub upgrade
        ;;
    build-web)
        echo "🌐 Building for web development..."
        flutter build web --debug
        ;;
    serve)
        echo "🌍 Serving web build locally..."
        cd build/web && python3 -m http.server 8080
        ;;
    *)
        echo "❌ Unknown command: $COMMAND"
        echo "Available commands:"
        echo "  start     - Start development server"
        echo "  test      - Run tests with coverage"
        echo "  analyze   - Run code analysis"
        echo "  format    - Format code and sort imports"
        echo "  clean     - Clean and reinstall dependencies"
        echo "  deps      - Get and upgrade dependencies"
        echo "  build-web - Build web version for development"
        echo "  serve     - Serve web build locally"
        exit 1
        ;;
esac

echo "✅ Development command completed successfully!"
