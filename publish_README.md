# Publishing Guide

## Step-by-Step Publishing Process

### 1. Push Code to GitHub
```bash
git add .
git commit -m "Prepare for release v[X.Y.Z]"
git push origin main
```

### 2. Create and Push Tag
```bash
git tag v[X.Y.Z]
git push origin v[X.Y.Z]
```

### 3. Create GitHub Release
- Go to GitHub repository → Releases → Create new release
- Select the tag you just created (v[X.Y.Z])
- Add release title and description
- Publish the release

### 4. Update CHANGELOG.md
- Add new version entry at the top
- Document all changes since last version
- Follow semantic versioning (MAJOR.MINOR.PATCH)

### 5. Authenticate with pub.dev
```bash
# Login to pub.dev (opens browser for Google authentication)
dart pub login
```

### 6. Publish to pub.dev
```bash
# Publish your package
dart pub publish --server=https://pub.dev
```

### 7. Verify Publication
- Check https://pub.dev/packages/dio_bridge
- Verify version appears correctly
- Test installation: `flutter pub add dio_bridge`

## What Gets Published
When you run `dart pub publish`, the following files are uploaded:
- `lib/` directory (your package code)
- `bin/` directory (if any)
- `README.md`
- `CHANGELOG.md`
- `LICENSE` file
- `pubspec.yaml`
- Any files specified in `pubspec.yaml` under `screenshots`, `topics`, etc.

**Note**: Files listed in `.gitignore` are NOT published unless explicitly included.

## Important Notes
- **Publishing is forever**: Once published, you cannot unpublish (except in rare cases)
- Always test with `--dry-run` first
- Ensure all dependencies are properly specified
- Package must have a valid LICENSE file
- Consider using a verified publisher for better trust

## Prerequisites
- Account on https://pub.dev/
- Repository hosted on GitHub
- Valid pubspec.yaml with proper metadata
- All tests passing
- Documentation complete

## Version Format
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)
