# Facebook Authentication Setup Guide

## Current Issue

Facebook sign-in is showing: `MissingPluginException - No implementation found for method login`

This is because Facebook SDK is not properly configured in the Android app.

## Steps to Fix

### 1. Create Facebook App

1. Go to https://developers.facebook.com
2. Click "My Apps" → "Create App"
3. Select "Consumer" app type
4. Enter Display Name: **BlazePlayer**
5. Click "Create App"

### 2. Get Facebook Credentials

After creating the app, you'll need:

- **App ID** - Found on the app dashboard
- **Client Token** - Found in Settings → Basic
- **App Secret** - Found in Settings → Basic

### 3. Configure Firebase Console

1. Go to https://console.firebase.google.com
2. Select your project: **Blaze Player**
3. Go to Authentication → Sign-in method
4. Click Facebook and enable it
5. Enter:
   - App ID: (from Facebook)
   - App secret: (from Facebook)
6. Copy the **OAuth redirect URI** (looks like: `https://blaze-player-xxxxx.firebaseapp.com/__/auth/handler`)

### 4. Configure Facebook App

1. In Facebook App Dashboard, go to: Add Product → Facebook Login → Set Up
2. Select "Android" platform
3. Click Settings → Facebook Login → Settings
4. Add the Firebase OAuth redirect URI to "Valid OAuth Redirect URIs"
5. Save changes

### 5. Add Package Name and Key Hash

1. In Facebook App → Settings → Basic → Add Platform → Android
2. Add:
   - **Package Name**: `com.example.blazeplayer_master`
   - **Class Name**: `com.example.blazeplayer_master.MainActivity`
   - **Key Hashes**: Run this command to get your debug key hash:

```powershell
cd "C:\Program Files\Java\jdk-<version>\bin"
.\keytool -exportcert -alias androiddebugkey -keystore "%USERPROFILE%\.android\debug.keystore" | openssl sha1 -binary | openssl base64
```

Default password is: `android`

### 6. Update strings.xml

Once you have your Facebook App ID and Client Token, update:
`android/app/src/main/res/values/strings.xml`

Replace:

- `YOUR_FACEBOOK_APP_ID_HERE` with your actual Facebook App ID
- `YOUR_FACEBOOK_CLIENT_TOKEN_HERE` with your actual Client Token

### 7. Update AndroidManifest.xml

Uncomment the Facebook configuration section in:
`android/app/src/main/AndroidManifest.xml`

The section between lines 29-58 needs to be uncommented.

### 8. Rebuild the App

After updating both files:

```bash
flutter clean
flutter pub get
flutter run
```

## Quick Test After Setup

1. Tap "Continue with Facebook" button
2. Facebook login dialog should appear
3. After granting permissions, you should be signed in

## Troubleshooting

- If you get "Invalid Key Hash", generate the key hash again and add it to Facebook App settings
- Make sure Facebook App is in "Development Mode" for testing
- Add your test account email in Facebook App → Roles → Test Users if needed

## Alternative: Test Without Facebook First

If you want to skip Facebook for now:

1. Remove the Facebook sign-in button from the UI
2. Use only Google and Email/Password authentication
3. Set up Facebook later when ready to publish
