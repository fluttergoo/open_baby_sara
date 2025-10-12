# CI/CD Pipeline - Quick Start

## 🚀 5-Minute CI/CD Setup

### 1️⃣ Prerequisites Check

```bash
# Run this script
./scripts/setup_ci_cd.sh
```

### 2️⃣ Prepare Secrets

#### For Android:
```bash
# Encode with interactive script
./scripts/encode_secrets.sh

# Or manually:
base64 -i android/app/your-keystore.jks | pbcopy
```

Required Secrets:
- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` (for deployment)

#### For iOS:
```bash
# Open .p8 file and copy its content
cat AuthKey_ABC123.p8
```

Required Secrets:
- `APP_STORE_CONNECT_API_KEY` (p8 file content)
- `APP_STORE_CONNECT_API_KEY_ID` (e.g.: T793NZB3B5)
- `APP_STORE_CONNECT_ISSUER_ID` (UUID format)

### 3️⃣ Add Secrets to GitHub

1. Repository → **Settings**
2. **Secrets and variables** → **Actions**
3. **New repository secret**
4. Add each secret

### 4️⃣ Test

```bash
# Push to develop branch
git checkout develop
git add .
git commit -m "Test CI/CD"
git push origin develop

# Monitor in GitHub Actions tab
```

### 5️⃣ Production Release

```bash
# Update version
# In pubspec.yaml file: version: 1.3.0

# Merge to main
git checkout main
git merge develop
git push origin main

# Create tag
git tag v1.3.0
git push origin v1.3.0
```

---

## 🎯 Pipeline Behavior

| Branch/Tag | What Happens? |
|------------|---------------|
| `develop` push | ✅ Test + 🛠️ Debug builds (Android + iOS) |
| `main` push | ✅ Test + 🚀 Release builds + 📦 Deploy to stores |
| `v*` tag | ✅ Test + 🚀 Release builds + 📋 GitHub Release |

---

## 📱 Build Results

### Development (develop)
- **Android**: `app-debug.apk`, `app-debug.aab`
- **iOS**: `Runner.app` (unsigned)
- **Retention**: 7 days

### Production (main)
- **Android**: `app-release.apk`, `app-release.aab`
- **iOS**: `Runner.ipa` (signed)
- **Retention**: 30 days
- **Deployment**: Automatic (if secrets present)

---

## 🔍 Having Issues?

### Build Failed
```bash
# GitHub Actions → Workflow → Check build logs
```

### Are Secrets Correct?
```bash
# Re-check the values you encoded
./scripts/encode_secrets.sh
```

### Local Test
```bash
# Android
flutter build apk --debug
flutter build appbundle --debug

# iOS
flutter build ios --debug --no-codesign
```

---

## 📚 Detailed Documentation

- **Setup**: [CI_CD_SETUP.md](CI_CD_SETUP.md)
- **Secrets**: [REQUIRED_SECRETS.md](REQUIRED_SECRETS.md)
- **Changes**: [CI_CD_CHANGES.md](CI_CD_CHANGES.md)

---

## ✅ Checklist

For Development:
- [ ] Flutter and dependencies installed
- [ ] `flutter test` works
- [ ] Android debug build works
- [ ] iOS debug build works

For Production:
- [ ] Android keystore ready
- [ ] iOS certificates ready
- [ ] All secrets added to GitHub
- [ ] Test push successful

---

## 🎉 Successful Setup!

Pipeline is now ready. On every push, automatically:

✅ Tests run
✅ Builds are created
✅ (Main branch) Deploy to stores

**Happy coding! 🚀**

---

## 💡 Pro Tips

1. **Development Test**: Push each feature to develop first
2. **Version Management**: Use semantic versioning (1.2.3)
3. **Tag Naming**: Create tags with `v` prefix (v1.2.3)
4. **Secrets Rotation**: Rotate API keys every 3-6 months
5. **Monitoring**: Enable GitHub Actions email notifications

