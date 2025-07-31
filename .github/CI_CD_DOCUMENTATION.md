# CI/CD Pipeline Documentation

## Overview
This repository uses GitHub Actions for Continuous Integration and Continuous Deployment (CI/CD). The pipeline automatically runs tests, code quality checks, and builds on every push and pull request.

## Workflow Structure

### 🧪 Test Job
- **Purpose**: Runs unit and widget tests with coverage reporting
- **Triggers**: Push to main/develop, Pull requests to main
- **Duration**: ~2-5 minutes
- **Steps**:
  1. Code checkout
  2. Flutter setup with caching
  3. Dependency installation
  4. Code formatting verification
  5. Static analysis (flutter analyze)
  6. Test execution with coverage
  7. Coverage upload to Codecov

### 🔨 Build Job
- **Purpose**: Multi-platform build validation
- **Triggers**: After test job passes
- **Duration**: ~5-10 minutes
- **Platforms**: Web, Android
- **Steps**:
  1. Code checkout
  2. Flutter setup with caching
  3. Platform-specific environment setup
  4. Dependency installation with caching
  5. Platform build execution
  6. Artifact upload

### 🔍 Code Quality Job
- **Purpose**: Advanced code quality analysis
- **Triggers**: Parallel with test job
- **Duration**: ~2-3 minutes
- **Tools**: dart_code_metrics, import_sorter
- **Steps**:
  1. Code checkout
  2. Flutter setup with caching
  3. Dependency installation
  4. Metrics analysis
  5. Import sorting validation

### 🔒 Security Scan Job
- **Purpose**: Basic security vulnerability scanning
- **Triggers**: Parallel with other jobs
- **Duration**: ~1 minute
- **Steps**:
  1. Code checkout
  2. Dependency vulnerability check

## Performance Optimizations

### Caching Strategy
- **Flutter SDK**: Cached by subosito/flutter-action
- **Pub dependencies**: Cached using actions/cache with pubspec.lock hash
- **Gradle dependencies**: Cached for Android builds
- **Build artifacts**: Uploaded with 7-day retention

### Parallel Execution
- Test, code-quality, and security-scan jobs run in parallel
- Build job runs after test completion
- Matrix strategy for multi-platform builds

### Timeouts
- Test job: 10 minutes
- Build job: 15 minutes  
- Code quality: 10 minutes
- Security scan: 5 minutes

## Required Status Checks
Before merging to main branch, these checks must pass:
- ✅ `test` - All tests passing
- ✅ `build (web)` - Web build successful
- ✅ `build (android)` - Android build successful
- ✅ `code-quality` - Code quality standards met
- ✅ `security-scan` - No security issues found

## Local Development
Run these commands locally before pushing:

```bash
# Install dependencies
flutter pub get

# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Check code quality
dart run dart_code_metrics:metrics analyze lib --disable-sunset-warning
dart run import_sorter:main --no-comments --exit-if-changed

# Test builds
flutter build web --release
flutter build apk --release
```

## Troubleshooting

### Common Issues
1. **Test failures**: Check test output and fix failing tests
2. **Format issues**: Run `dart format .` locally
3. **Analysis issues**: Fix linting errors shown in `flutter analyze`
4. **Build failures**: Check platform-specific build logs

### Performance Issues
- Monitor job execution times
- Check cache hit rates
- Optimize build commands if needed

### Branch Protection
- Ensure all required status checks are configured
- Verify PR review requirements are set
- Check that force push protection is enabled

## Maintenance
- Update Flutter version in workflow when upgrading project
- Review and update dependencies regularly
- Monitor workflow performance and optimize as needed
- Keep security scanning tools updated
