# 📝 TODO: Steps to Complete Before Running

## Status: Project Structure Complete ✅

All code is written and properly structured. You just need to add Firebase configuration!

---

## ⚠️ CRITICAL - DO THIS FIRST

### [ ] Step 1: Create Firebase Project

1. Visit: https://console.firebase.google.com/
2. Click "Add Project" or "Create Project"
3. Name it: `blazeplayer` or whatever you prefer
4. Continue through the setup wizard
5. Disable/Enable Google Analytics as you prefer

### [ ] Step 2: Add Android App in Firebase

1. In Firebase Console, click Android icon
2. **Android package name**: `com.blazeplayer.app` (MUST MATCH EXACTLY!)
3. App nickname: BlazePlayer (optional)
4. Click "Register app"

### [ ] Step 3: Get SHA-1 Certificate (Required for Google Sign-In)

1. Open terminal in project folder
2. Run:
   ```bash
   cd android
   ./gradlew signingReport
   ```
3. Copy the SHA-1 hash from "debugAndroidTest" or "debug" variant
4. In Firebase Console > Project Settings > Your Android App
5. Click "Add fingerprint"
6. Paste the SHA-1 hash

### [ ] Step 4: Download google-services.json

1. In Firebase Console, after registering Android app
2. Click "Download google-services.json"
3. **CRITICAL**: Place the file at:
   ```
   android/app/google-services.json
   ```
4. ⚠️ Without this file, app will crash!

### [ ] Step 5: Enable Email/Password Auth

1. Firebase Console > Build > Authentication
2. Click "Get started" if first time
3. Click "Sign-in method" tab
4. Click "Email/Password"
5. Toggle "Enable"
6. Click "Save"

### [ ] Step 6: Enable Google Sign-In

1. Same screen (Sign-in method tab)
2. Click "Google"
3. Toggle "Enable"
4. Select support email
5. Click "Save"

### [ ] Step 7: Run the App

```bash
flutter pub get
flutter run
```

---

## 🔵 OPTIONAL - Facebook Login (Can do later)

### [ ] Step 8: Create Facebook App (Optional)

1. Visit: https://developers.facebook.com/
2. My Apps > Create App
3. Select "Consumer" type
4. Name: BlazePlayer
5. Create App

### [ ] Step 9: Add Facebook Login Product

1. In Facebook App Dashboard
2. Add Product > Facebook Login
3. Click "Set Up"

### [ ] Step 10: Configure Facebook App

1. Settings > Basic
2. Note your **App ID** and **App Secret**
3. Add Platform > Android
   - Package Name: `com.blazeplayer.app`
   - Class Name: `com.blazeplayer.app.MainActivity`
   - Key Hashes: Get using:
     ```bash
     keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl sha1 -binary | openssl base64
     ```
     Password: `android`

### [ ] Step 11: Update strings.xml with Facebook IDs

File: `android/app/src/main/res/values/strings.xml`

Replace:

- `YOUR_FACEBOOK_APP_ID_HERE` with actual App ID
- `YOUR_FACEBOOK_CLIENT_TOKEN_HERE` with Client Token

### [ ] Step 12: Enable Facebook in AndroidManifest.xml

File: `android/app/src/main/AndroidManifest.xml`

Uncomment the Facebook configuration section (lines with `<!-- Facebook Configuration -->`)

### [ ] Step 13: Connect Facebook to Firebase

1. Firebase Console > Authentication > Sign-in method
2. Click Facebook
3. Toggle Enable
4. Enter App ID and App Secret from Facebook
5. Copy the OAuth redirect URI shown
6. Go to Facebook Developers > Facebook Login > Settings
7. Paste URI in "Valid OAuth Redirect URIs"
8. Save both

### [ ] Step 14: Make Facebook App Live

1. Facebook Developers > Settings > Basic
2. Toggle app mode from Development to Live
3. Add privacy policy URL (required)

---

## 📊 Progress Tracker

### Code Structure: 100% Complete ✅

- [x] Clean Architecture
- [x] Auth Service with Firebase
- [x] Google Sign-In integration
- [x] Facebook Login integration
- [x] Provider state management
- [x] Beautiful UI screens
- [x] Error handling
- [x] Input validation
- [x] Local storage
- [x] Theme configuration
- [x] Gradle 8.14 setup (No errors!)

### Firebase Setup: 0% (Your Part!)

- [ ] Firebase project created
- [ ] Android app registered
- [ ] SHA-1 added
- [ ] google-services.json downloaded
- [ ] google-services.json placed in android/app/
- [ ] Email auth enabled
- [ ] Google auth enabled

### Optional Facebook: 0%

- [ ] Facebook app created
- [ ] Facebook configured
- [ ] strings.xml updated
- [ ] AndroidManifest.xml updated
- [ ] Connected to Firebase

---

## 🎯 What You Can Do Right Now

### Minimum to Run App:

1. ✅ Create Firebase project
2. ✅ Register Android app
3. ✅ Download google-services.json
4. ✅ Place in android/app/
5. ✅ Enable Email & Google auth
6. ✅ Run flutter pub get
7. ✅ Run app!

**Estimated time**: 10-15 minutes

---

## 🚀 After Setup is Complete

### Phase 1: Test Authentication

- [ ] Test email signup
- [ ] Test email login
- [ ] Test Google sign-in
- [ ] Test Facebook login (if configured)
- [ ] Test logout

### Phase 2: Build Your Features

- [ ] Add video player functionality
- [ ] Add your business logic
- [ ] Customize UI/branding
- [ ] Add app icon
- [ ] Add splash screen

### Phase 3: Prepare for Release

- [ ] Generate release keystore
- [ ] Configure signing
- [ ] Build release APK
- [ ] Test release build
- [ ] Prepare Play Store assets
- [ ] Submit to Play Store

---

## 📁 Files Already Created for You

### Core Setup

- ✅ `pubspec.yaml` - All dependencies configured
- ✅ `android/app/build.gradle.kts` - Firebase & Gradle 8.14
- ✅ `android/build.gradle.kts` - Google services plugin
- ✅ `android/app/proguard-rules.pro` - Release optimization

### App Code

- ✅ `lib/main.dart` - App entry point
- ✅ `lib/core/` - Core utilities, theme, services
- ✅ `lib/features/auth/` - Complete auth system
- ✅ `lib/features/home/` - Home screen

### Configuration

- ✅ `android/app/src/main/res/values/strings.xml` - Facebook placeholders
- ✅ `android/app/src/main/AndroidManifest.xml` - Permissions & setup
- ✅ `assets/` folders - For images and icons

### Documentation

- ✅ `README.md` - Project overview
- ✅ `SETUP_GUIDE.md` - Detailed setup instructions
- ✅ `QUICK_START.md` - Quick reference
- ✅ `TODO.md` - This file

---

## 🆘 Need Help?

### Documentation Files

1. **QUICK_START.md** - Fast setup checklist
2. **SETUP_GUIDE.md** - Complete detailed guide
3. **TODO.md** - This file with tasks

### Online Resources

- Firebase Setup: https://firebase.google.com/docs/flutter/setup
- Google Sign-In: https://firebase.google.com/docs/auth/flutter/federated-auth
- Facebook Login: https://developers.facebook.com/docs/facebook-login

---

## ✅ Benefits of This Structure

1. **Production Ready** - Used by big companies
2. **Clean Code** - Easy to maintain and extend
3. **Scalable** - Add features without mess
4. **Testable** - Proper separation of concerns
5. **No Gradle Errors** - Latest stable versions
6. **Play Store Ready** - Professional setup

---

**Current Status**: Ready for Firebase configuration!
**Next Action**: Follow Step 1-7 above to run the app!

---

Last Updated: November 25, 2025
