# CI/CD Pipeline Setup Guide

## Overview
This document provides comprehensive instructions for setting up the CI/CD pipeline for Sara Baby Tracker app using GitHub Actions.

## Pipeline Structure

### Branches and Triggers
- **develop**: Runs tests and creates development builds (debug mode)
- **main**: Runs tests, creates production builds, and deploys to stores
- **tags (v*)**: Creates releases with GitHub artifacts

### Jobs Overview

1. **test**: Runs unit tests, code analysis, and format checks
2. **build-development**: Creates Android debug builds for develop branch
3. **build-ios-development**: Creates iOS debug builds for develop branch
4. **build-android**: Creates Android production builds for main branch
5. **build-ios-production**: Creates iOS production builds and deploys to App Store
6. **deploy-android**: Deploys Android builds to Google Play Store
7. **create-release**: Creates GitHub releases for version tags

## Required GitHub Secrets

### Android Secrets

#### KEYSTORE_BASE64 (Required for production)
Your Android keystore file encoded in base64.

To generate:
```bash
# Navigate to your project
cd android/app

# Encode your keystore
base64 -i your-keystore.jks | pbcopy  # macOS
base64 -i your-keystore.jks | xclip   # Linux
```

#### KEYSTORE_PASSWORD (Required for production)
The password for your keystore file.

#### KEY_ALIAS (Required for production)
The alias name of your signing key in the keystore.

#### GOOGLE_PLAY_SERVICE_ACCOUNT_JSON (Required for deployment)
Google Play Service Account JSON for automated deployment.

To generate:
1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to **Setup → API access**
3. Create a new service account or use existing
4. Download the JSON key file
5. Copy entire JSON content as secret value

### iOS Secrets

#### APP_STORE_CONNECT_API_KEY (Required for deployment)
The App Store Connect API Key content (p8 file).

To generate:
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access → Keys**
3. Click the **+** button to create new key
4. Give it a name and select **App Manager** role
5. Download the `.p8` file
6. Copy the entire content of the p8 file

Example p8 file content:
```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
-----END PRIVATE KEY-----
```

#### APP_STORE_CONNECT_API_KEY_ID (Required for deployment)
The Key ID from App Store Connect (e.g., `T793NZB3B5`).

You can find this in App Store Connect under **Users and Access → Keys**.

#### APP_STORE_CONNECT_ISSUER_ID (Required for deployment)
The Issuer ID from App Store Connect (UUID format).

Found at the top of the **Users and Access → Keys** page.

#### APPLE_ID (Optional)
Your Apple Developer account email. Default: `suleymansurucu95@icloud.com`

#### APPLE_TEAM_ID (Optional)
Your Apple Developer Team ID. Default: `3588AF9993`

You can find this in:
- [Apple Developer Account](https://developer.apple.com/account)
- Under **Membership** section

#### APP_STORE_CONNECT_TEAM_ID (Optional)
Your App Store Connect Team ID. Default: `3588AF9993`

Usually the same as APPLE_TEAM_ID.

#### MATCH_PASSWORD (Optional)
Password for Fastlane Match certificate repository.

Only needed if using Fastlane Match for certificate management.

#### MATCH_GIT_BASIC_AUTHORIZATION (Optional)
Base64 encoded git credentials for Match repository.

Generate:
```bash
echo -n "username:personal_access_token" | base64
```

### Optional Secrets

#### BUNDLE_ID_ANDROID (Optional)
Android package name. Default: `com.suleymansurucu.sarababy`

#### BUNDLE_ID_IOS (Optional)
iOS bundle identifier. Default: `com.suleymansurucu.babysara`

## Setting Up Secrets in GitHub

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its name and value
5. Click **Add secret**

## Flutter and Build Configuration

### Current Configuration
- **Flutter Version**: 3.27.1
- **Java Version**: 17
- **Ruby Version**: 3.0 (for iOS)
- **App Version**: Read from `pubspec.yaml`

### Version Management

The pipeline automatically reads version from `pubspec.yaml`:
```yaml
version: 1.2.0
```

For development builds, the version format is: `1.2.0-dev+{build_number}`
For production builds, the version format is: `1.2.0` with build number from GitHub run number

## Build Outputs

### Development Builds (develop branch)
- **Android APK**: `app-debug.apk`
- **Android App Bundle**: `app-debug.aab`
- **iOS App**: `Runner.app` (unsigned)
- **Retention**: 7 days

### Production Builds (main branch)
- **Android APK**: `app-release.apk` or `app-debug.apk` (if no keystore)
- **Android App Bundle**: `app-release.aab` or `app-debug.aab` (if no keystore)
- **iOS IPA**: `Runner.ipa` (signed and uploaded to App Store)
- **Retention**: 30 days

## Deployment Process

### Android Deployment
1. Build is created with release signing
2. App Bundle is uploaded to Google Play Console
3. Release notes are generated in multiple languages
4. App is deployed to production track
5. Users can update from Google Play Store

### iOS Deployment
1. Flutter build creates iOS release build
2. Fastlane handles certificate and provisioning profile setup
3. App is built and signed using Xcode
4. IPA is uploaded to App Store Connect
5. App is available for TestFlight or App Store review

## Troubleshooting

### Common Issues

#### Android Build Fails
**Issue**: Keystore not found or invalid
**Solution**: 
- Verify KEYSTORE_BASE64 is correctly encoded
- Check KEYSTORE_PASSWORD and KEY_ALIAS match your keystore
- Ensure keystore file contains the signing key

#### iOS Build Fails
**Issue**: Code signing issues
**Solution**:
- Verify APP_STORE_CONNECT_API_KEY is the complete p8 file content
- Check APP_STORE_CONNECT_API_KEY_ID matches the key ID in App Store Connect
- Ensure your Apple Developer account has necessary certificates
- Consider setting up Fastlane Match for automatic certificate management

#### Deployment Fails
**Issue**: Service account has insufficient permissions
**Solution**:
- For Android: Ensure service account has "Release Manager" role in Google Play Console
- For iOS: Ensure API key has "App Manager" or "Admin" role

### Debug Mode

If you need to debug the pipeline:

1. **Enable debug logging**:
   - Go to GitHub repository Settings → Secrets
   - Add `ACTIONS_STEP_DEBUG` with value `true`

2. **Check build artifacts**:
   - Go to Actions tab
   - Click on the workflow run
   - Download artifacts to inspect builds

## Release Process

### Creating a New Release

1. Update version in `pubspec.yaml`:
```yaml
version: 1.3.0
```

2. Commit and push to main:
```bash
git add pubspec.yaml
git commit -m "Bump version to 1.3.0"
git push origin main
```

3. Create a tag:
```bash
git tag v1.3.0
git push origin v1.3.0
```

4. The pipeline will:
   - Run all tests
   - Build Android and iOS apps
   - Deploy to stores
   - Create GitHub release

## Maintenance

### Updating Flutter Version

Edit `.github/workflows/ci_cd.yml`:
```yaml
env:
  FLUTTER_VERSION: '3.27.1'  # Update this
```

### Updating Dependencies

The pipeline automatically caches dependencies. After updating `pubspec.yaml`, the cache will be rebuilt on next run.

## Support

For issues or questions:
1. Check GitHub Actions logs for detailed error messages
2. Review this documentation
3. Check Flutter and Fastlane documentation
4. Consult Apple Developer and Google Play Console documentation

## Security Notes

⚠️ **Important Security Practices**:

1. Never commit secrets to the repository
2. Use GitHub Secrets for all sensitive data
3. Regularly rotate API keys and passwords
4. Review service account permissions regularly
5. Enable 2FA on all developer accounts
6. Use separate service accounts for CI/CD vs manual access

## Additional Resources

- [Flutter CI/CD Documentation](https://flutter.dev/docs/deployment/cd)
- [Fastlane Documentation](https://docs.fastlane.tools)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Google Play Publishing API](https://developers.google.com/android-publisher)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)

