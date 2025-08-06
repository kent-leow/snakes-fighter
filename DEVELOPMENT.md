# Development Environment Setup

This document outlines the development environment configuration for the Snakes Fight Flutter project.

## Environment Configuration

### VS Code Settings
- **File**: `.vscode/settings.json`
- **Features**: Auto-formatting, hot reload, debugging configuration
- **Key Settings**:
  - Format on save enabled
  - Hot reload on all saves
  - Line length set to 80 characters
  - Dart/Flutter SDK auto-detection

### Code Quality Tools
- **Analysis Options**: `analysis_options.yaml`
- **Dart Code Metrics**: `dart_code_metrics.yaml`
- **Import Sorter**: `import_sorter.yaml`
- **Linting Rules**: Strict linting with Flutter recommended rules plus custom rules

### Debug Configurations
- **File**: `.vscode/launch.json`
- **Configurations**:
  - Web debugging (Chrome)
  - Mobile debugging
  - Profile mode
  - Release mode

## Development Scripts

### Code Formatting
- **Script**: `scripts/format.sh`
- **Purpose**: Ensures consistent code formatting across all environments
- **Usage**:
  ```bash
  # Format all files
  ./scripts/format.sh
  
  # Check formatting (CI mode)
  ./scripts/format.sh --check
  
  # Custom line width
  ./scripts/format.sh --page-width 120
  ```
- **Configuration**: 80-character line length (matches CI/CD)

### Available Scripts
Located in the `scripts/` directory:

#### `./scripts/dev.sh [command]`
- `start` - Start development server with hot reload
- `test` - Run tests with coverage
- `analyze` - Run code analysis and metrics
- `format` - Format code and sort imports
- `clean` - Clean and reinstall dependencies
- `deps` - Get and upgrade dependencies
- `build-web` - Build web version for development
- `serve` - Serve web build locally

#### `./scripts/build.sh [platform] [mode]`
- **Platforms**: web, android, ios, macos, linux, windows
- **Modes**: debug, profile, release
- Example: `./scripts/build.sh web release`

#### `./scripts/setup.sh`
- Initial environment setup
- Creates directory structure
- Makes scripts executable
- Runs initial validation

## Code Quality Standards

### Linting Rules
- Single quotes preferred
- Trailing commas required
- Avoid print statements in production
- Const constructors enforced
- Prefer final variables
- Sort child properties last

### Code Formatting
- Line length: 80 characters
- Auto-formatting on save
- Import sorting enabled

### Analysis Configuration
- Strong mode enabled
- Implicit casts disabled
- Generated files excluded
- External package debugging disabled

## Testing Configuration

### Test Structure
- Unit tests: `test/unit/`
- Widget tests: `test/widget/`
- Integration tests: `test/integration/`

### Test Commands
```bash
# Run all tests
./scripts/dev.sh test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

## Hot Reload Setup

### Configuration
- Enabled for all file changes
- Works with web and mobile platforms
- Preview hot reload watcher enabled

### Usage
- Save any Dart file to trigger hot reload
- Use `r` in terminal for manual hot reload
- Use `R` for hot restart

## Debugging Setup

### Web Debugging
1. Open VS Code
2. Press F5 or use Run → Start Debugging
3. Select "snakes-fight (web)" configuration
4. Chrome will launch with debugging enabled

### Mobile Debugging
1. Connect device or start simulator
2. Select "snakes-fight (mobile)" configuration
3. App will launch with debugging enabled

## Build Process

### Development Build
```bash
./scripts/build.sh web debug
```

### Production Build
```bash
./scripts/build.sh web release
```

### Platform-Specific Builds
```bash
# Android
./scripts/build.sh android release

# iOS (macOS only)
./scripts/build.sh ios release
```

## Performance Monitoring

### Code Metrics
- Cyclomatic complexity: Max 20
- Maximum nesting level: 5
- Number of parameters: Max 4
- Source lines of code: Max 50 per method

### Analysis Reports
HTML reports generated in `metrics/` directory when running analysis.

## Troubleshooting

### Common Issues

#### Hot Reload Not Working
1. Check VS Code Dart extension is installed
2. Verify `.vscode/settings.json` configuration
3. Restart VS Code or Flutter process

#### Build Failures
1. Run `./scripts/dev.sh clean`
2. Ensure Flutter SDK is up to date
3. Check `flutter doctor` output

#### Linting Errors
1. Run `./scripts/dev.sh format`
2. Fix any remaining manual issues
3. Use `// ignore: rule_name` for exceptions

### Getting Help
- Check Flutter documentation: https://flutter.dev/docs
- Run `flutter doctor` for environment issues
- Use `flutter --help` for command reference

## Quick Start

1. Run initial setup:
   ```bash
   ./scripts/setup.sh
   ```

2. Start development:
   ```bash
   ./scripts/dev.sh start
   ```

3. Open VS Code and start debugging with F5

The development environment is now ready for efficient Flutter development!
