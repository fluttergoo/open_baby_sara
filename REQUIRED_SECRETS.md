# Required GitHub Secrets

Bu CI/CD pipeline'ının çalışması için aşağıdaki GitHub Secrets'ların repository settings'de tanımlanması gerekiyor:

## Firebase Secrets
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `FIREBASE_PROJECT_NUMBER` - Firebase project number
- `FIREBASE_STORAGE_BUCKET` - Firebase storage bucket
- `FIREBASE_MESSAGING_SENDER_ID` - Firebase messaging sender ID

### Firebase API Keys
- `FIREBASE_WEB_API_KEY` - Firebase web API key
- `FIREBASE_ANDROID_API_KEY` - Firebase Android API key
- `FIREBASE_IOS_API_KEY` - Firebase iOS API key

### Firebase App IDs
- `FIREBASE_WEB_APP_ID` - Firebase web app ID
- `FIREBASE_ANDROID_APP_ID` - Firebase Android app ID
- `FIREBASE_IOS_APP_ID` - Firebase iOS app ID
- `FIREBASE_MACOS_APP_ID` - Firebase macOS app ID
- `FIREBASE_WINDOWS_APP_ID` - Firebase Windows app ID

## Bundle Identifiers
- `BUNDLE_ID_ANDROID` - Android package name (e.g., com.suleymansurucu.sarababy)
- `BUNDLE_ID_IOS` - iOS bundle identifier (e.g., com.suleymansurucu.babysara)

## Optional Secrets
- `SUPPORTED_LOCALES` - Supported locales (default: en-US,tr-TR,ar-SA,de-DE,es-ES,fr-FR,id-ID,ko-KR,nl-NL,ru-RU,zh-TW)

## Android Signing Secrets
- `KEYSTORE_BASE64` - Base64 encoded keystore file
- `KEYSTORE_PASSWORD` - Keystore password
- `KEY_PASSWORD` - Key password
- `KEY_ALIAS` - Key alias

## Apple/App Store Connect Secrets
- `APPLE_ID` - Apple ID email
- `APPLE_TEAM_ID` - Apple Team ID
- `APP_STORE_CONNECT_TEAM_ID` - App Store Connect Team ID
- `APP_STORE_CONNECT_API_KEY_ID` - App Store Connect API Key ID
- `APP_STORE_CONNECT_API_KEY` - App Store Connect API Key (P8 file content)
- `APP_STORE_CONNECT_ISSUER_ID` - App Store Connect Issuer ID

## Google Play Secrets
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - Google Play Service Account JSON

## How to Add Secrets

1. Go to your GitHub repository
2. Click on "Settings" tab
3. Click on "Secrets and variables" → "Actions"
4. Click "New repository secret"
5. Add each secret with the exact name and value

## Security Notes

- Never commit these values to the repository
- Use environment-specific values for different environments
- Regularly rotate API keys and passwords
- Use least privilege principle for service accounts
