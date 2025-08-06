#!/bin/bash

# Firebase Deployment Test Script
# This script helps test Firebase deployment locally before pushing to CI/CD

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔥 Firebase Deployment Test${NC}"
echo "============================"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI is not installed${NC}"
    echo -e "${YELLOW}💡 Install with: npm install -g firebase-tools${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Firebase CLI is available${NC}"

# Check if user is logged in
if ! firebase projects:list &>/dev/null; then
    echo -e "${YELLOW}🔐 Not logged in to Firebase${NC}"
    echo -e "${YELLOW}💡 Running: firebase login${NC}"
    firebase login
fi

echo -e "${GREEN}✅ Firebase login verified${NC}"

# Check if Flutter project is ready
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ No pubspec.yaml found. Run from Flutter project root.${NC}"
    exit 1
fi

# Check if firebase.json exists
if [ ! -f "firebase.json" ]; then
    echo -e "${RED}❌ No firebase.json found. Initialize Firebase first.${NC}"
    echo -e "${YELLOW}💡 Run: firebase init hosting${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Firebase project configuration found${NC}"

# Get dependencies
echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
flutter pub get

# Create firebase options if needed
if [ ! -f "lib/firebase_options.dart" ]; then
    echo -e "${YELLOW}📝 Creating Firebase options from template...${NC}"
    cp lib/firebase_options.dart.example lib/firebase_options.dart
fi

# Build the web application
echo -e "${YELLOW}🏗️ Building Flutter web application...${NC}"
flutter build web --release

# Check build output
if [ ! -d "build/web" ]; then
    echo -e "${RED}❌ Web build failed - no build/web directory found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Flutter web build completed${NC}"

# Check build size
WEB_SIZE=$(du -sh build/web | cut -f1)
echo -e "${BLUE}📊 Build size: ${WEB_SIZE}${NC}"

# List available Firebase projects
echo -e "${YELLOW}🔍 Available Firebase projects:${NC}"
firebase projects:list

# Prompt for project selection
echo ""
read -p "Enter Firebase project ID (or press Enter to use default): " PROJECT_ID

# Deploy to preview channel first
echo -e "${YELLOW}🚀 Deploying to preview channel...${NC}"
if [ -n "$PROJECT_ID" ]; then
    firebase hosting:channel:deploy preview --project "$PROJECT_ID"
else
    firebase hosting:channel:deploy preview
fi

echo -e "${GREEN}✅ Preview deployment completed${NC}"

# Ask if user wants to deploy to live
echo ""
read -p "Deploy to live site? (y/N): " DEPLOY_LIVE

if [[ $DEPLOY_LIVE =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🚀 Deploying to live site...${NC}"
    if [ -n "$PROJECT_ID" ]; then
        firebase deploy --only hosting --project "$PROJECT_ID"
    else
        firebase deploy --only hosting
    fi
    echo -e "${GREEN}✅ Live deployment completed${NC}"
else
    echo -e "${BLUE}ℹ️ Skipped live deployment${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Firebase deployment test completed!${NC}"
echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Test your preview/live site"
echo "2. Set up GitHub secrets for CI/CD (see FIREBASE_DEPLOYMENT_SETUP.md)"
echo "3. Push your changes to trigger CI/CD deployment"
