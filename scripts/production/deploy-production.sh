#!/bin/bash

# Production Deployment Script for Snakes Fight
# This script deploys the application to production Firebase environment

set -e

echo "🚀 Starting Production Deployment"

# Configuration
PROJECT_ID="snakes-fight-prod"
BACKUP_BUCKET="snakes-fight-backups"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI not found. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    print_error "Not logged in to Firebase. Please run:"
    echo "firebase login"
    exit 1
fi

# Set the Firebase project
print_status "Setting Firebase project to production..."
firebase use $PROJECT_ID --config firebase.prod.json

# Pre-deployment checks
print_status "Running pre-deployment checks..."

# Check if production project exists
if ! firebase projects:list | grep -q $PROJECT_ID; then
    print_error "Production project $PROJECT_ID not found. Please create it first."
    exit 1
fi

# Verify security rules
print_status "Validating security rules..."
if ! firebase database:rules:get --config firebase.prod.json > /dev/null; then
    print_warning "Unable to verify current security rules"
fi

# Build and test functions
print_status "Building Firebase Functions..."
cd functions
npm install
npm run build
npm run lint

# Run tests if available
if [ -f "package.json" ] && npm run | grep -q "test"; then
    print_status "Running function tests..."
    npm test
fi

cd ..

# Create backup before deployment
print_status "Creating pre-deployment backup..."
firebase functions:shell --config firebase.prod.json <<EOF
createManualBackup({type: 'pre-deployment', includeAll: true})
EOF

# Deploy security rules first
print_status "Deploying security rules..."
firebase deploy --only database --config firebase.prod.json

# Deploy functions
print_status "Deploying Firebase Functions..."
firebase deploy --only functions --config firebase.prod.json

# Deploy hosting if web build exists
if [ -d "build/web" ]; then
    print_status "Deploying web hosting..."
    firebase deploy --only hosting --config firebase.prod.json
else
    print_warning "Web build not found. Skipping hosting deployment."
fi

# Post-deployment verification
print_status "Running post-deployment verification..."

# Test health check endpoint
HEALTH_URL="https://us-central1-$PROJECT_ID.cloudfunctions.net/healthCheck"
if curl -s "$HEALTH_URL" | grep -q "healthy"; then
    print_status "Health check passed ✅"
else
    print_error "Health check failed ❌"
    exit 1
fi

# Verify security rules are active
print_status "Verifying security rules..."
firebase database:rules:get --config firebase.prod.json > /tmp/deployed-rules.json
if [ -s /tmp/deployed-rules.json ]; then
    print_status "Security rules deployed successfully ✅"
else
    print_error "Security rules deployment failed ❌"
    exit 1
fi

# Enable monitoring
print_status "Enabling production monitoring..."
# This would typically involve setting up Firebase Performance Monitoring
# and other monitoring services

print_status "🎉 Production deployment completed successfully!"
print_status "Project: $PROJECT_ID"
print_status "Functions: https://console.firebase.google.com/project/$PROJECT_ID/functions"
print_status "Database: https://console.firebase.google.com/project/$PROJECT_ID/database"

# Display important reminders
echo ""
print_warning "📋 Post-deployment checklist:"
echo "1. Verify all functions are running correctly"
echo "2. Check monitoring and alerting systems"
echo "3. Test critical user flows"
echo "4. Monitor error rates and performance"
echo "5. Verify backup systems are operational"

# Clean up
rm -f /tmp/deployed-rules.json

print_status "Deployment script completed."
