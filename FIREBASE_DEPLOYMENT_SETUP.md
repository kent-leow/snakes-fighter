# Firebase GitHub Actions Deployment Setup

## Issue: Missing Firebase Service Account Secrets

The deployment is failing because GitHub Actions cannot find the required Firebase service account secrets.

## ✅ Solution: Configure GitHub Secrets

### Step 1: Generate Firebase Service Account Key

1. **Go to Firebase Console:**
   - Visit [Firebase Console](https://console.firebase.google.com/)
   - Select your project (`snakes-fight-dev`)

2. **Create Service Account:**
   - Go to **Project Settings** → **Service Accounts**
   - Click **Generate New Private Key**
   - Download the JSON file (keep it secure!)

### Step 2: Add Secrets to GitHub Repository

1. **Go to your GitHub repository:**
   - Navigate to **Settings** → **Secrets and variables** → **Actions**

2. **Add Repository Secrets:**
   
   **For Development Environment:**
   - Name: `FIREBASE_SERVICE_ACCOUNT_DEV`
   - Value: Copy and paste the **entire contents** of your development service account JSON file

### Step 3: Verify Secret Names Match

Your workflows expect this exact secret name:
- `FIREBASE_SERVICE_ACCOUNT_DEV` (for all deployments)

## 🔧 Alternative: Skip Firebase Deployment Temporarily

If you want to test other parts of CI/CD first, you can temporarily disable Firebase deployment:

```yaml
# Comment out or remove the Firebase deployment steps
# - name: Deploy to development
#   uses: FirebaseExtended/action-hosting-deploy@v0
#   with:
#     repoToken: '${{ secrets.GITHUB_TOKEN }}'
#     firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT_DEV }}'
#     channelId: live
#     projectId: snakes-fight-dev
```

## 🚀 Quick Test Commands

After setting up secrets, test locally:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Test deployment to preview channel
firebase hosting:channel:deploy preview --project your-project-id

# Deploy to live
firebase deploy --project your-project-id
```

## 📋 Required GitHub Secrets Summary

| Secret Name | Purpose | Required For |
|-------------|---------|--------------|
| `FIREBASE_SERVICE_ACCOUNT_DEV` | Development deployment | All builds |
| `GITHUB_TOKEN` | Repository access | All workflows (auto-provided) |

## 🔒 Security Notes

- **Never commit** service account JSON files to your repository
- **Store secrets securely** in GitHub repository settings only
- **Use development project** for this personal project
- **Rotate keys regularly** as a security best practice

## 🛠️ Troubleshooting

If you still see errors after adding secrets:

1. **Check secret names** match exactly (case-sensitive)
2. **Verify JSON format** is valid in the secret value
3. **Ensure Firebase project** has Hosting enabled
4. **Check Firebase project permissions** for the service account
5. **Review workflow logs** for specific error details
