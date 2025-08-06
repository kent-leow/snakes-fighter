# Firebase Deployment Setup - Simplified for Development Only

## ✅ Changes Made

### 1. Simplified CI/CD Workflows
- **Updated** `.github/workflows/ci-cd.yml` to use only `FIREBASE_SERVICE_ACCOUNT_DEV`
- **Updated** `.github/workflows/deploy-web.yml` to deploy to dev environment only
- **Removed** production deployment complexity
- **Unified** deployment to single Firebase project: `snakes-fight-dev`

### 2. Updated Documentation
- **Simplified** `FIREBASE_DEPLOYMENT_SETUP.md` for single environment
- **Updated** `README.md` with streamlined instructions
- **Updated** `DEVELOPMENT.md` with new scripts

### 3. Removed Unnecessary Files
- **Deleted** `scripts/disable-firebase-deploy.sh` (not needed for single env)
- **Deleted** `scripts/restore-firebase-deploy.sh` (not needed for single env)

### 4. Added Helper Scripts
- **Created** `scripts/setup-github-secret.sh` - Interactive setup guide
- **Kept** `scripts/test-firebase-deploy.sh` - Local deployment testing

## 🎯 What You Need to Do

### Step 1: Get Firebase Service Account
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `snakes-fight-dev`
3. Project Settings → Service Accounts
4. Generate New Private Key → Download JSON

### Step 2: Add GitHub Secret
1. Go to: `https://github.com/kent-leow/snakes-fighter/settings/secrets/actions`
2. Click "New repository secret"
3. Name: `FIREBASE_SERVICE_ACCOUNT_DEV`
4. Value: Paste entire JSON file contents
5. Click "Add secret"

### Step 3: Test Deployment
```bash
# Run this helper for step-by-step instructions
./scripts/setup-github-secret.sh

# Test deployment locally (optional)
./scripts/test-firebase-deploy.sh
```

## 🚀 Result

- **Single secret required**: `FIREBASE_SERVICE_ACCOUNT_DEV`
- **Deploys to**: `snakes-fight-dev` Firebase project
- **Triggers on**: Push to `main` or `develop` branches
- **Simpler setup**: No production environment complexity

## 🔧 Deployment Behavior

| Branch | Action | Result |
|---------|---------|---------|
| `main` | Push | Deploy to Firebase Hosting live |
| `develop` | Push | Deploy to Firebase Hosting live |
| PR | Open | Deploy to preview channel |

All deployments use the same Firebase project (`snakes-fight-dev`) for simplicity.

## ✅ Your CI/CD Will Now Pass

Once you add the `FIREBASE_SERVICE_ACCOUNT_DEV` secret, your Firebase deployment error will be resolved! 🎉
