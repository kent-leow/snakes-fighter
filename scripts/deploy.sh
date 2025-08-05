#!/bin/bash

# Deployment script for Snakes Fight
# Handles deployment to different environments with proper coordination

set -e

ENVIRONMENT=${1:-staging}
VERSION=${2:-$(grep 'version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)}
BUILD_NUMBER=${3:-$(date +%s)}

echo "🚀 Deploying Snakes Fight v$VERSION+$BUILD_NUMBER to $ENVIRONMENT"

# Validate environment
case $ENVIRONMENT in
    development|staging|production)
        echo "✅ Valid environment: $ENVIRONMENT"
        ;;
    *)
        echo "❌ Invalid environment: $ENVIRONMENT"
        echo "Valid environments: development, staging, production"
        exit 1
        ;;
esac

# Set Firebase project
case $ENVIRONMENT in
    production)
        FIREBASE_PROJECT="snakes-fight-prod"
        FIREBASE_CONFIG="firebase.prod.json"
        ;;
    staging)
        FIREBASE_PROJECT="snakes-fight-staging"
        FIREBASE_CONFIG="firebase.staging.json"
        ;;
    *)
        FIREBASE_PROJECT="snakes-fight-dev"
        FIREBASE_CONFIG="firebase.json"
        ;;
esac

echo "📋 Deployment Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   Version: $VERSION"
echo "   Build Number: $BUILD_NUMBER"
echo "   Firebase Project: $FIREBASE_PROJECT"
echo "   Config File: $FIREBASE_CONFIG"
echo ""

# Pre-deployment checks
echo "🔍 Running pre-deployment checks..."

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Please install it first:"
    echo "   npm install -g firebase-tools"
    exit 1
fi

# Check if logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase. Please run:"
    echo "   firebase login"
    exit 1
fi

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

echo "✅ Pre-deployment checks passed"

# Run tests before deployment
echo "🧪 Running tests..."
if ! flutter test; then
    echo "❌ Tests failed. Deployment cancelled."
    exit 1
fi
echo "✅ All tests passed"

# Build the application
echo "🏗️  Building application..."
if ! ./scripts/build.sh web release $ENVIRONMENT; then
    echo "❌ Build failed. Deployment cancelled."
    exit 1
fi
echo "✅ Build completed successfully"

# Deploy to Firebase Hosting
echo "🌐 Deploying to Firebase Hosting..."
if [ -f "$FIREBASE_CONFIG" ]; then
    firebase use $FIREBASE_PROJECT
    firebase deploy --only hosting --config $FIREBASE_CONFIG
else
    firebase use $FIREBASE_PROJECT
    firebase deploy --only hosting
fi

# Deployment verification
echo "🔍 Verifying deployment..."
sleep 5  # Give Firebase a moment to update

# Get the hosting URL
HOSTING_URL="https://${FIREBASE_PROJECT}.web.app"
echo "🌍 Application deployed to: $HOSTING_URL"

# Test if the site is accessible
if curl -sf "$HOSTING_URL" > /dev/null; then
    echo "✅ Deployment verified - site is accessible"
else
    echo "⚠️  Warning: Site may not be immediately accessible"
fi

# Update deployment record
DEPLOY_RECORD="deployments/${ENVIRONMENT}-$(date +%Y%m%d-%H%M%S).json"
mkdir -p deployments
cat > "$DEPLOY_RECORD" << EOF
{
  "environment": "$ENVIRONMENT",
  "version": "$VERSION",
  "buildNumber": "$BUILD_NUMBER",
  "firebaseProject": "$FIREBASE_PROJECT",
  "deploymentTime": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "hostingUrl": "$HOSTING_URL",
  "deployer": "$(whoami)",
  "gitCommit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
  "gitBranch": "$(git branch --show-current 2>/dev/null || echo 'unknown')"
}
EOF

echo ""
echo "🎉 Deployment Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌍 URL: $HOSTING_URL"
echo "📦 Version: $VERSION+$BUILD_NUMBER"
echo "🎯 Environment: $ENVIRONMENT"
echo "📝 Record: $DEPLOY_RECORD"
echo ""
echo "Next steps:"
if [ "$ENVIRONMENT" = "staging" ]; then
    echo "   • Test the staging deployment thoroughly"
    echo "   • Deploy to production: ./scripts/deploy.sh production"
elif [ "$ENVIRONMENT" = "production" ]; then
    echo "   • Monitor application performance"
    echo "   • Announce the release to users"
else
    echo "   • Test the development deployment"
    echo "   • Deploy to staging when ready"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
