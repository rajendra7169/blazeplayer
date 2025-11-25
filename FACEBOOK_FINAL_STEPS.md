# Complete Facebook Setup - NEXT STEPS

## ✅ What I've Already Done

1. Updated strings.xml with your Facebook App ID: **537680446107470**
2. Enabled Facebook SDK in AndroidManifest.xml

## ⚠️ What YOU Need to Do Now

### Step 1: Get Facebook Client Token

1. Go to: https://developers.facebook.com/apps/537680446107470/settings/basic/
2. Scroll down to find **"Client Token"** (under App Secret)
3. Copy the Client Token value
4. Update `android/app/src/main/res/values/strings.xml`:
   - Replace `YOUR_FACEBOOK_CLIENT_TOKEN_HERE` with the actual token

### Step 2: Configure Firebase Console

1. Go to: https://console.firebase.google.com
2. Select project: **Blaze Player**
3. Go to: **Authentication** → **Sign-in method** → **Facebook**
4. Click **Enable**
5. Enter your Facebook credentials:
   - **App ID**: `537680446107470`
   - **App Secret**: Get from https://developers.facebook.com/apps/537680446107470/settings/basic/
6. **IMPORTANT**: Copy the **OAuth redirect URI** from Firebase (looks like: `https://blaze-player-xxxxx.firebaseapp.com/__/auth/handler`)
7. Click **Save**

### Step 3: Configure Facebook App Settings

1. Go to: https://developers.facebook.com/apps/537680446107470/fb-login/settings/
2. Under **"Valid OAuth Redirect URIs"**, paste the Firebase OAuth redirect URI you copied
3. Click **Save Changes**

### Step 4: Add Android Platform to Facebook App

1. Go to: https://developers.facebook.com/apps/537680446107470/settings/basic/
2. Click **"+ Add Platform"** → Select **"Android"**
3. Enter:
   - **Package Name**: `com.example.blazeplayer_master`
   - **Class Name**: `com.example.blazeplayer_master.MainActivity`
   - **Key Hashes**: Run this command in PowerShell to get your debug key hash:

```powershell
cd "C:\Program Files\Android\Android Studio\jbr\bin"
.\keytool -exportcert -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android | certutil -encode - | findstr /v "CERTIFICATE"
```

If that doesn't work, try:

```powershell
cd "C:\Program Files\Java\jdk-17\bin"
.\keytool -exportcert -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android | openssl sha1 -binary | openssl base64
```

- Copy the output key hash and paste it in Facebook App settings

4. Click **Save Changes**

### Step 5: Test Facebook Login

After completing all steps above:

1. Update the Client Token in `strings.xml`
2. Run in terminal:

```bash
flutter clean
flutter pub get
flutter run
```

3. Tap "Continue with Facebook" button
4. Facebook login should now work! 🎉

## Troubleshooting

### "Invalid Key Hash" Error

- Make sure you generated the correct key hash for your debug keystore
- Add it to Facebook App → Settings → Basic → Android → Key Hashes

### "App Not Set Up" Error

- Make sure Facebook App is properly configured with Android platform
- Check that package name matches: `com.example.blazeplayer_master`

### Still Not Working?

- Make sure Facebook App is in "Development Mode"
- Add your test account in Facebook App → Roles → Test Users
- Check that OAuth redirect URI is correctly added in Facebook Login settings

## Current Status

- ✅ Facebook App ID: 537680446107470 (configured)
- ⏳ Client Token: Needs to be added
- ⏳ Firebase Facebook Auth: Needs to be enabled
- ⏳ Facebook App Platform: Needs Android configuration
- ⏳ Key Hash: Needs to be generated and added

Complete these steps and Facebook login will work perfectly!
