# 🚀 SETUP GUIDE - BlazePlayer Firebase Authentication

## IMPORTANT: Follow these steps BEFORE running the app!

## Step 1: Firebase Setup (REQUIRED)

### 1.1 Create Firebase Project

1. Go to https://console.firebase.google.com/
2. Click "Create a project" or "Add project"
3. Name: `blazeplayer` or your choice
4. Accept terms and click Continue
5. Disable Google Analytics (or enable if you want)
6. Click "Create Project"

### 1.2 Add Android App to Firebase

1. In Firebase console, click the Android icon
2. **Package name**: `com.blazeplayer.app` (MUST match exactly)
3. App nickname: BlazePlayer (optional)
4. Debug signing certificate (SHA-1): Get it by running:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 from the debug variant
5. Click "Register app"
6. **Download** `google-services.json`
7. **IMPORTANT**: Place `google-services.json` in:
   ```
   android/app/google-services.json
   ```

### 1.3 Enable Authentication in Firebase

1. In Firebase Console, go to **Build** > **Authentication**
2. Click "Get Started"
3. Go to **Sign-in method** tab
4. Enable the following:
   - ✅ **Email/Password** - Click Enable and Save
   - ✅ **Google** - Click Enable and Save
   - ✅ **Facebook** - (Keep disabled for now, we'll enable later)

## Step 2: Google Sign-In Setup

### 2.1 Already Configured!

- When you added Android app to Firebase with SHA-1, Google Sign-In is automatically configured
- The OAuth Client ID is created automatically

### 2.2 Verify Google Sign-In

1. Firebase Console > Authentication > Sign-in method
2. Click on "Google"
3. Make sure "Enable" toggle is ON
4. Note the "Web SDK configuration" - you'll see Web client ID (auto-generated)

## Step 3: Facebook Login Setup (OPTIONAL but recommended)

### 3.1 Create Facebook App

1. Go to https://developers.facebook.com/
2. Click "My Apps" > "Create App"
3. Select "Consumer" as app type
4. App Name: `BlazePlayer` or your choice
5. App Contact Email: Your email
6. Click "Create App"

### 3.2 Add Facebook Login Product

1. In your Facebook app dashboard
2. Find "Facebook Login" in the left menu or "Add Product"
3. Click "Set Up" on Facebook Login

### 3.3 Configure Facebook App Settings

1. Go to **Settings** > **Basic**
2. Note your:
   - **App ID** (e.g., 123456789012345)
   - **App Secret** (click "Show")
3. Add Android Platform:

   - Scroll down to "Add Platform"
   - Choose "Android"
   - Package Name: `com.blazeplayer.app`
   - Class Name: `com.blazeplayer.app.MainActivity`
   - Key Hashes: Generate using:
     ```bash
     keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl sha1 -binary | openssl base64
     ```
     Password: `android`
   - Paste the hash

4. Enable "Single Sign On": Toggle ON
5. Click "Save Changes"

### 3.4 Update App Files with Facebook Credentials

**File**: `android/app/src/main/res/values/strings.xml`

- Already created! Just update:
  - Replace `YOUR_FACEBOOK_APP_ID_HERE` with your App ID (e.g., 123456789012345)
  - Replace `YOUR_FACEBOOK_CLIENT_TOKEN_HERE` with Client Token from Facebook settings

Example:

```xml
<string name="facebook_app_id">123456789012345</string>
<string name="fb_login_protocol_scheme">fb123456789012345</string>
<string name="facebook_client_token">abc123def456</string>
```

### 3.5 Update AndroidManifest.xml

**File**: `android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag (after other <activity> tags):

```xml
<!-- Facebook Configuration -->
<meta-data
    android:name="com.facebook.sdk.ApplicationId"
    android:value="@string/facebook_app_id"/>

<meta-data
    android:name="com.facebook.sdk.ClientToken"
    android:value="@string/facebook_client_token"/>

<activity
    android:name="com.facebook.FacebookActivity"
    android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
    android:label="@string/app_name" />

<activity
    android:name="com.facebook.CustomTabActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="@string/fb_login_protocol_scheme" />
    </intent-filter>
</activity>
```

### 3.6 Connect Facebook to Firebase

1. Firebase Console > Authentication > Sign-in method
2. Click on "Facebook"
3. Toggle "Enable"
4. Enter:
   - **App ID** from Facebook
   - **App Secret** from Facebook
5. Copy the **OAuth redirect URI** shown
6. Go back to Facebook Developers > Facebook Login > Settings
7. Paste the URI in "Valid OAuth Redirect URIs"
8. Save in both Firebase and Facebook

### 3.7 Make Facebook App Live

1. Facebook Developers > Settings > Basic
2. Toggle "App Mode" from Development to Live
3. Choose a category for your app
4. Add Privacy Policy URL (required for live apps)

## Step 4: Run the App

### 4.1 Verify Files

Make sure these files exist:

- ✅ `android/app/google-services.json` (from Firebase)
- ✅ `android/app/src/main/res/values/strings.xml` (Facebook IDs updated)
- ✅ `android/app/src/main/AndroidManifest.xml` (Facebook activities added)

### 4.2 Run Flutter App

```bash
flutter pub get
flutter run
```

## Step 5: Test Authentication

### Test Email/Password

1. Click "Sign Up" in the app
2. Enter email and password
3. Should create account and login

### Test Google Sign-In

1. Click "Continue with Google"
2. Select Google account
3. Should authenticate and login

### Test Facebook Login

1. Click "Continue with Facebook"
2. Login with Facebook
3. Should authenticate and login

## Troubleshooting

### App Crashes on Start

- **Missing google-services.json**: Add it to `android/app/`
- Check package name matches: `com.blazeplayer.app`

### Google Sign-In Fails

- Add SHA-1 to Firebase project (Step 1.2, item 4)
- Verify Google is enabled in Firebase Auth

### Facebook Login Fails

- Verify App ID in strings.xml matches Facebook app
- Check Facebook app is in "Live" mode
- Verify Key Hash is correct
- Make sure OAuth Redirect URI is added in Facebook Login settings

### Gradle Errors

- Already fixed! Project uses Gradle 8.14

## Summary Checklist

Before running the app:

- [ ] Firebase project created
- [ ] Android app added to Firebase with package name `com.blazeplayer.app`
- [ ] SHA-1 certificate added to Firebase
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] Email/Password authentication enabled in Firebase
- [ ] Google authentication enabled in Firebase
- [ ] (Optional) Facebook app created and configured
- [ ] (Optional) Facebook credentials added to strings.xml
- [ ] (Optional) Facebook configuration added to AndroidManifest.xml
- [ ] (Optional) Facebook connected to Firebase
- [ ] Run `flutter pub get`
- [ ] Run the app!

## Next Steps After Setup

1. ✅ Test all authentication methods
2. ✅ Build your video player features
3. ✅ Customize UI colors and branding
4. ✅ Add app icon and splash screen
5. ✅ Configure release signing for Play Store
6. ✅ Build and test release APK
7. ✅ Submit to Google Play Store

## Need Help?

- Firebase Docs: https://firebase.google.com/docs/flutter/setup
- Google Sign-In: https://pub.dev/packages/google_sign_in
- Facebook Login: https://pub.dev/packages/flutter_facebook_auth

---

**Remember**: The app will NOT run without `google-services.json` file!
