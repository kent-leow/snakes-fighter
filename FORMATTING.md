# Code Formatting Configuration

This project uses consistent code formatting to ensure readability and maintainability across all environments.

## Configuration

- **Line Length**: 80 characters
- **Formatter**: `dart format`
- **Import Sorting**: `import_sorter` package

## Commands

### Local Development

```bash
# Format all files
./scripts/format.sh

# Check formatting (CI mode)
./scripts/format.sh --check

# Format with custom line width
./scripts/format.sh --page-width 120
```

### Manual Commands

```bash
# Format all files with 80-character width
dart format --page-width=80 .

# Check formatting without changes
dart format --page-width=80 --output=none --set-exit-if-changed .

# Sort imports
dart run import_sorter:main --no-comments
```

## CI/CD Integration

The CI/CD pipeline automatically checks formatting using:
```yaml
dart format --page-width=80 --output=none --set-exit-if-changed .
```

## IDE Configuration

### VS Code
Add to your `.vscode/settings.json`:
```json
{
  "dart.lineLength": 80,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.rulers": [80]
  }
}
```

### Android Studio / IntelliJ
1. Go to **Settings** → **Editor** → **Code Style** → **Dart**
2. Set **Right margin (columns)** to `80`
3. Enable **Format on save**

## Why 80 Characters?

- **Consistency**: Matches Dart/Flutter ecosystem defaults
- **Readability**: Works well on various screen sizes
- **Git diffs**: Cleaner side-by-side comparisons
- **Code reviews**: Better viewing experience on GitHub/GitLab

## Troubleshooting

If you encounter formatting issues:

1. **Different line lengths**: Ensure all environments use `--page-width=80`
2. **IDE conflicts**: Configure your IDE to match project settings
3. **CI failures**: Run `./scripts/format.sh --check` locally before pushing

## Related Files

- `.github/workflows/ci-cd.yml` - CI/CD formatting checks
- `.github/workflows/flutter-ci.yml` - Additional CI formatting
- `scripts/format.sh` - Local formatting script
- `analysis_options.yaml` - Dart analyzer configuration
- `import_sorter.yaml` - Import sorting configuration
