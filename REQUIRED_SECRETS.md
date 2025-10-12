# Required GitHub Secrets

The following GitHub Secrets need to be defined in repository settings for this CI/CD pipeline to work:

> 📖 **For detailed setup instructions, see [CI_CD_SETUP.md](CI_CD_SETUP.md) file.**
> 
> 🔐 **You can use `scripts/encode_secrets.sh` script to encode secrets.**

## Required Secrets

### Android Production Build & Deployment

#### `KEYSTORE_BASE64` ⚠️ **REQUIRED**
Base64 encoded Android keystore file.
```bash
base64 -i your-keystore.jks | pbcopy  # macOS
```

#### `KEYSTORE_PASSWORD` ⚠️ **REQUIRED**
Your keystore password.

#### `KEY_ALIAS` ⚠️ **REQUIRED**
Key alias in the keystore.

#### `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` ⚠️ **REQUIRED (For Deploy)**
Google Play Console Service Account JSON content.

### iOS Production Build & Deployment

#### `APP_STORE_CONNECT_API_KEY` ⚠️ **REQUIRED (For Deploy)**
App Store Connect API Key (.p8 file content).

#### `APP_STORE_CONNECT_API_KEY_ID` ⚠️ **REQUIRED (For Deploy)**
App Store Connect API Key ID (e.g.: T793NZB3B5).

#### `APP_STORE_CONNECT_ISSUER_ID` ⚠️ **REQUIRED (For Deploy)**
App Store Connect Issuer ID (UUID format).

## Optional Secrets

### Bundle Identifiers
- `BUNDLE_ID_ANDROID` - Android package name (default: com.suleymansurucu.sarababy)
- `BUNDLE_ID_IOS` - iOS bundle identifier (default: com.suleymansurucu.babysara)

### Apple Developer Account
- `APPLE_ID` - Apple ID email (default: suleymansurucu95@icloud.com)
- `APPLE_TEAM_ID` - Apple Team ID (default: 3588AF9993)
- `APP_STORE_CONNECT_TEAM_ID` - App Store Connect Team ID (default: 3588AF9993)

### Fastlane Match (Certificate Management)
- `MATCH_PASSWORD` - Match repository password
- `MATCH_GIT_BASIC_AUTHORIZATION` - Base64 encoded git credentials
- `MATCH_GIT_URL` - Git repository URL for certificates

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
