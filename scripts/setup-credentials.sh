#!/bin/bash

# Firebase Credentials Setup Script
# This script helps developers set up their local Firebase configuration

set -e

echo "🔥 Firebase Credentials Setup"
echo "=============================="

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "📝 Creating .env.development from template..."
    cp .env.example .env.development
    echo "✅ Created .env.development"
    echo "⚠️  Please edit .env.development with your Firebase project credentials"
else
    echo "✅ .env.development already exists"
fi

# Check if firebase_options.dart exists
if [ ! -f lib/firebase_options.dart ]; then
    echo "📝 Creating firebase_options.dart from template..."
    cp lib/firebase_options.dart.example lib/firebase_options.dart
    echo "✅ Created lib/firebase_options.dart"
    echo "⚠️  Please run 'flutterfire configure' to generate proper Firebase options"
else
    echo "✅ lib/firebase_options.dart already exists"
fi

# Check if google-services.json exists for Android
if [ ! -f android/app/google-services.json ]; then
    echo "⚠️  android/app/google-services.json not found"
    echo "   Please download it from Firebase Console and place it in android/app/"
else
    echo "✅ android/app/google-services.json exists"
fi

# Check if GoogleService-Info.plist exists for iOS
if [ ! -f ios/Runner/GoogleService-Info.plist ]; then
    echo "⚠️  ios/Runner/GoogleService-Info.plist not found"
    echo "   Please download it from Firebase Console and place it in ios/Runner/"
else
    echo "✅ ios/Runner/GoogleService-Info.plist exists"
fi

echo ""
echo "🚀 Next Steps:"
echo "1. Edit .env.development with your Firebase project details"
echo "2. Run 'flutterfire configure' to generate proper Firebase options"
echo "3. Download google-services.json and GoogleService-Info.plist from Firebase Console"
echo "4. Run 'flutter pub get' to install dependencies"
echo "5. Run 'flutter test --exclude-tags=firebase' to verify setup"
echo ""
echo "🔒 Security Note:"
echo "Your credential files are now ignored by git and won't be committed."
