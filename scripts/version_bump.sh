#!/bin/bash
# scripts/version_bump.sh

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "version:" pubspec.yaml | cut -d' ' -f2)
echo "Current version: $CURRENT_VERSION"

# Increment version (example: 1.2.0 -> 1.2.1)
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
PATCH_VERSION=$((VERSION_PARTS[2] + 1))
NEW_VERSION="${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.$PATCH_VERSION"

echo "New version: $NEW_VERSION"

# Update pubspec.yaml
sed -i '' "s/version: $CURRENT_VERSION/version: $NEW_VERSION/" pubspec.yaml

# Update Android build.gradle.kts
sed -i '' "s/versionName = \"$CURRENT_VERSION\"/versionName = \"$NEW_VERSION\"/" android/app/build.gradle.kts

# Also increment version code
CURRENT_VERSION_CODE=$(grep "versionCode" android/app/build.gradle.kts | cut -d' ' -f3)
NEW_VERSION_CODE=$((CURRENT_VERSION_CODE + 1))
sed -i '' "s/versionCode = $CURRENT_VERSION_CODE/versionCode = $NEW_VERSION_CODE/" android/app/build.gradle.kts

echo "Version updated to $NEW_VERSION"
echo "Version code updated to $NEW_VERSION_CODE"