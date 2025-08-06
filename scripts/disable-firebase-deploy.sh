#!/bin/bash

# Temporary CI/CD Fix: Disable Firebase Deployment
# This script comments out Firebase deployment steps to allow CI/CD to pass
# while you set up Firebase secrets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Temporary CI/CD Fix: Disable Firebase Deployment${NC}"
echo "===================================================="

# Backup original files
echo -e "${YELLOW}📋 Creating backups...${NC}"
cp .github/workflows/ci-cd.yml .github/workflows/ci-cd.yml.backup
cp .github/workflows/deploy-web.yml .github/workflows/deploy-web.yml.backup

echo -e "${GREEN}✅ Backups created${NC}"

# Comment out Firebase deployment in ci-cd.yml
echo -e "${YELLOW}🔧 Modifying ci-cd.yml...${NC}"
sed -i.tmp '
/Deploy to development/,/projectId: snakes-fight-dev/s/^/      # TEMPORARILY_DISABLED: /
/Deploy to production/,/projectId: snakes-fight-prod/s/^/      # TEMPORARILY_DISABLED: /
' .github/workflows/ci-cd.yml

# Comment out Firebase deployment in deploy-web.yml
echo -e "${YELLOW}🔧 Modifying deploy-web.yml...${NC}"
sed -i.tmp '
/Deploy to Firebase Hosting/,/projectId: snakes-fight-prod/s/^/      # TEMPORARILY_DISABLED: /
/Deploy to Development/,/projectId: snakes-fight-dev/s/^/      # TEMPORARILY_DISABLED: /
' .github/workflows/deploy-web.yml

# Clean up temporary files
rm -f .github/workflows/ci-cd.yml.tmp
rm -f .github/workflows/deploy-web.yml.tmp

echo -e "${GREEN}✅ Firebase deployment steps disabled${NC}"

echo ""
echo -e "${YELLOW}⚠️  IMPORTANT NOTES:${NC}"
echo "1. This is a TEMPORARY fix to allow CI/CD to pass"
echo "2. Firebase deployment is now disabled in CI/CD"
echo "3. To re-enable:"
echo "   - Set up GitHub secrets (see FIREBASE_DEPLOYMENT_SETUP.md)"
echo "   - Run: ./scripts/restore-firebase-deploy.sh"
echo ""
echo -e "${BLUE}📋 What happens now:${NC}"
echo "• CI/CD will run tests and build steps"
echo "• Firebase deployment will be skipped"
echo "• No deployment errors will occur"
echo ""
echo -e "${GREEN}🎉 CI/CD should now pass without Firebase secrets!${NC}"
