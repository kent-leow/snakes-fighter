#!/bin/bash

# GitHub Secret Setup Helper
# This script helps you set up the Firebase service account secret

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔑 GitHub Secret Setup Helper${NC}"
echo "================================"

echo -e "${YELLOW}Setting up FIREBASE_SERVICE_ACCOUNT_DEV secret${NC}"
echo ""

echo -e "${BLUE}Step 1: Get your Firebase Service Account JSON${NC}"
echo "1. Go to: https://console.firebase.google.com/"
echo "2. Select your project: snakes-fight-dev"
echo "3. Go to: Project Settings → Service Accounts"
echo "4. Click: 'Generate New Private Key'"
echo "5. Download the JSON file"
echo ""

echo -e "${BLUE}Step 2: Add to GitHub Repository${NC}"
echo "1. Go to: https://github.com/kent-leow/snakes-fighter/settings/secrets/actions"
echo "2. Click: 'New repository secret'"
echo "3. Name: FIREBASE_SERVICE_ACCOUNT_DEV"
echo "4. Value: Copy and paste the ENTIRE contents of your JSON file"
echo "5. Click: 'Add secret'"
echo ""

echo -e "${BLUE}Step 3: Verify Setup${NC}"
echo "After adding the secret, push a commit to trigger CI/CD deployment."
echo ""

echo -e "${GREEN}✅ Example of what your JSON file should look like:${NC}"
echo -e "${YELLOW}{"
echo "  \"type\": \"service_account\","
echo "  \"project_id\": \"snakes-fight-dev\","
echo "  \"private_key_id\": \"...\","
echo "  \"private_key\": \"-----BEGIN PRIVATE KEY-----\\n...\\n-----END PRIVATE KEY-----\\n\","
echo "  \"client_email\": \"...@snakes-fight-dev.iam.gserviceaccount.com\","
echo "  \"client_id\": \"...\","
echo "  \"auth_uri\": \"https://accounts.google.com/o/oauth2/auth\","
echo "  \"token_uri\": \"https://oauth2.googleapis.com/token\","
echo "  \"auth_provider_x509_cert_url\": \"https://www.googleapis.com/oauth2/v1/certs\","
echo "  \"client_x509_cert_url\": \"...\""
echo -e "}${NC}"
echo ""

echo -e "${RED}⚠️  SECURITY REMINDER:${NC}"
echo "• Never commit this JSON file to your repository"
echo "• Keep the JSON file secure and delete it after adding to GitHub"
echo "• Only store the secret in GitHub repository settings"
echo ""

echo -e "${BLUE}🚀 Once secret is added, your deployment will work!${NC}"
