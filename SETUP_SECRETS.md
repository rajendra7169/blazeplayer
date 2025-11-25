# 🔐 Setting Up Sensitive Configuration Files

## Overview

This project requires some configuration files with API keys that are **NOT** included in the repository for security reasons.

## Files You Need to Create

### 1. Facebook Configuration (Android)

**File:** `android/app/src/main/res/values/strings.xml`

**Steps:**

1. Copy `strings.xml.template` to `strings.xml` in the same directory
2. Get your Facebook App ID and Client Token from [Facebook Developers](https://developers.facebook.com/)
3. Replace placeholders in `strings.xml`:
   - `YOUR_FACEBOOK_APP_ID` → Your actual Facebook App ID
   - `YOUR_FACEBOOK_CLIENT_TOKEN` → Your actual Facebook Client Token

```xml
<resources>
    <string name="app_name">Blaze Player</string>
    <string name="facebook_app_id">123456789012345</string>
    <string name="facebook_client_token">abc123def456...</string>
</resources>
```

### 2. Firebase Configuration (Android)

**File:** `android/app/google-services.json`

**Steps:**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Open your project: "Blaze Player" (blaze-player-fab67)
3. Go to Project Settings → Your Apps → Android
4. Download `google-services.json`
5. Place it in `android/app/` directory

### 3. Firebase Configuration (iOS)

**File:** `ios/Runner/GoogleService-Info.plist`

**Steps:**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Open your project: "Blaze Player"
3. Go to Project Settings → Your Apps → iOS
4. Download `GoogleService-Info.plist`
5. Place it in `ios/Runner/` directory

## Security Reminders

⚠️ **NEVER commit these files to Git!**

- ✅ They are already in `.gitignore`
- ✅ Only keep them on your local machine
- ✅ Share them securely with team members (not via Git)
- ✅ Use different keys for development and production

## Verification

After setting up, verify:

```bash
# Check if files exist
ls android/app/src/main/res/values/strings.xml
ls android/app/google-services.json

# Verify they're not tracked by Git
git status
# Should NOT show these files as staged or modified
```

## Troubleshooting

**Problem:** App crashes with "Facebook App ID not found"

- **Solution:** Make sure `strings.xml` exists and has valid Facebook keys

**Problem:** Firebase not working

- **Solution:** Check `google-services.json` is in correct location

**Problem:** Files show up in Git

- **Solution:** Run `git rm --cached <filename>` and check `.gitignore`

## For New Team Members

When cloning this repository:

1. Ask team lead for the sensitive configuration files
2. Place them in the correct locations (see above)
3. Never commit them to Git
4. You're ready to run the app!

## Production Deployment

For production:

- Use separate Firebase projects (dev/staging/prod)
- Use separate Facebook apps for each environment
- Store secrets in CI/CD environment variables
- Never hardcode secrets in source code
