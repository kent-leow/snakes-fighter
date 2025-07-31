# Branch Protection Rules for GitHub

This document describes the recommended branch protection settings for the Snakes Fight repository.

## Settings for `main` branch:

### Branch protection rule configuration:
- **Restrict pushes that create files**: ✅ Enabled
- **Require status checks to pass before merging**: ✅ Enabled
  - **Require branches to be up to date before merging**: ✅ Enabled
  - **Status checks that are required**:
    - `test`
    - `build (web)`
    - `build (android)`
    - `code-quality`
    - `security-scan`

### Pull Request Requirements:
- **Require pull request reviews before merging**: ✅ Enabled
  - **Required number of reviewers**: 1
  - **Dismiss stale reviews when new commits are pushed**: ✅ Enabled
  - **Require review from code owners**: ❌ Disabled (no CODEOWNERS file yet)
  - **Restrict reviews to users with write access**: ✅ Enabled

### Additional Restrictions:
- **Restrict pushes and merges to this branch**: ❌ Disabled
- **Allow force pushes**: ❌ Disabled
- **Allow deletions**: ❌ Disabled

## GitHub CLI Commands to Set Up Branch Protection:

```bash
# Install GitHub CLI if not already installed
# On macOS: brew install gh

# Authenticate with GitHub
gh auth login

# Create branch protection rule for main branch
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["test","build (web)","build (android)","code-quality","security-scan"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true,"require_code_owner_reviews":false}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

## Manual Setup via GitHub Web Interface:

1. Go to repository Settings → Branches
2. Click "Add rule" or edit existing rule for `main`
3. Configure settings as described above
4. Save changes
