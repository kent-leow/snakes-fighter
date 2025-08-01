#!/bin/bash

# Security Verification Script
# Verifies that no credentials are committed to git

set -e

echo "🔒 Security Verification Check"
echo "=============================="

# Check if sensitive files are being tracked by git
echo "📋 Checking for tracked credential files..."

TRACKED_CREDS=$(git ls-files | grep -E "(\.env$|firebase_options\.dart$|google-services\.json$|GoogleService-Info\.plist$)" || true)

if [ -n "$TRACKED_CREDS" ]; then
    echo "❌ SECURITY ISSUE: The following credential files are tracked by git:"
    echo "$TRACKED_CREDS"
    echo ""
    echo "Run the following commands to fix this:"
    echo "git rm --cached [filename]"
    echo "git commit -m 'security: Remove credentials from git tracking'"
    exit 1
else
    echo "✅ No credential files are tracked by git"
fi

# Check if .gitignore has proper rules
echo ""
echo "📋 Checking .gitignore rules..."

REQUIRED_PATTERNS=(
    ".env*"
    "lib/firebase_options.dart"
    "android/app/google-services.json"
    "ios/Runner/GoogleService-Info.plist"
    "firebase-debug.log*"
    ".firebase/"
)

MISSING_PATTERNS=()

for pattern in "${REQUIRED_PATTERNS[@]}"; do
    if ! grep -q "$pattern" .gitignore; then
        MISSING_PATTERNS+=("$pattern")
    fi
done

if [ ${#MISSING_PATTERNS[@]} -gt 0 ]; then
    echo "⚠️  Missing .gitignore patterns:"
    for pattern in "${MISSING_PATTERNS[@]}"; do
        echo "  - $pattern"
    done
else
    echo "✅ All required .gitignore patterns are present"
fi

# Check for API keys in committed files (basic check)
echo ""
echo "📋 Checking for exposed API keys in git history..."

API_KEY_PATTERNS=(
    "AIza[0-9A-Za-z_-]{35}"
    "api[_-]?key.*=.*['\"][^'\"]*['\"]"
    "FIREBASE_API_KEY.*=.*[^#]*"
)

FOUND_KEYS=false
for pattern in "${API_KEY_PATTERNS[@]}"; do
    if git log --all --grep="$pattern" --oneline | head -1 | grep -q .; then
        echo "⚠️  Potential API key found in commit messages"
        FOUND_KEYS=true
    fi
    
    if git log --all -p | grep -E "$pattern" | head -1 | grep -q .; then
        echo "⚠️  Potential API key found in commit content (check manually)"
        FOUND_KEYS=true
    fi
done

if [ "$FOUND_KEYS" = false ]; then
    echo "✅ No obvious API keys found in git history"
fi

# Check current working directory for credential files
echo ""
echo "📋 Checking local credential files..."

LOCAL_CREDS=()
if [ -f .env.development ]; then LOCAL_CREDS+=(".env.development"); fi
if [ -f lib/firebase_options.dart ]; then LOCAL_CREDS+=("lib/firebase_options.dart"); fi
if [ -f android/app/google-services.json ]; then LOCAL_CREDS+=("android/app/google-services.json"); fi
if [ -f ios/Runner/GoogleService-Info.plist ]; then LOCAL_CREDS+=("ios/Runner/GoogleService-Info.plist"); fi

if [ ${#LOCAL_CREDS[@]} -gt 0 ]; then
    echo "✅ Local credential files found (ignored by git):"
    for cred in "${LOCAL_CREDS[@]}"; do
        echo "  - $cred"
    done
else
    echo "⚠️  No local credential files found"
    echo "   Run './scripts/setup-credentials.sh' to set up local development"
fi

echo ""
echo "🔒 Security Check Summary"
echo "========================"

if [ -z "$TRACKED_CREDS" ] && [ ${#MISSING_PATTERNS[@]} -eq 0 ]; then
    echo "✅ PASS: Repository is secure"
    echo "   - No credentials tracked by git"
    echo "   - Proper .gitignore rules in place"
    echo "   - Local development files can be set up safely"
else
    echo "❌ SECURITY ISSUES FOUND"
    echo "   Please fix the issues listed above"
    exit 1
fi
