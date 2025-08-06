#!/bin/bash

# Restore Firebase Deployment in CI/CD
# This script restores Firebase deployment steps after secrets are configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Restore Firebase Deployment in CI/CD${NC}"
echo "======================================="

# Check if backups exist
if [ ! -f .github/workflows/ci-cd.yml.backup ]; then
    echo -e "${RED}❌ No backup found for ci-cd.yml${NC}"
    echo -e "${YELLOW}💡 Firebase deployment may not have been disabled by our script${NC}"
    exit 1
fi

if [ ! -f .github/workflows/deploy-web.yml.backup ]; then
    echo -e "${RED}❌ No backup found for deploy-web.yml${NC}"
    echo -e "${YELLOW}💡 Firebase deployment may not have been disabled by our script${NC}"
    exit 1
fi

# Restore from backups
echo -e "${YELLOW}📋 Restoring from backups...${NC}"
cp .github/workflows/ci-cd.yml.backup .github/workflows/ci-cd.yml
cp .github/workflows/deploy-web.yml.backup .github/workflows/deploy-web.yml

echo -e "${GREEN}✅ Firebase deployment steps restored${NC}"

# Clean up backups
echo -e "${YELLOW}🧹 Cleaning up backup files...${NC}"
rm .github/workflows/ci-cd.yml.backup
rm .github/workflows/deploy-web.yml.backup

echo -e "${GREEN}✅ Backup files cleaned up${NC}"

echo ""
echo -e "${GREEN}🎉 Firebase deployment restored in CI/CD!${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT:${NC}"
echo "Ensure you have set up GitHub secrets before pushing:"
echo "• FIREBASE_SERVICE_ACCOUNT_DEV"
echo "• FIREBASE_SERVICE_ACCOUNT"
echo ""
echo -e "${BLUE}📋 See FIREBASE_DEPLOYMENT_SETUP.md for details${NC}"
