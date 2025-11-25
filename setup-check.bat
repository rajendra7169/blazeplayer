@echo off
echo ============================================
echo BlazePlayer - Setup Verification Script
echo ============================================
echo.

echo [1/6] Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed!
    pause
    exit /b 1
)
echo OK - Flutter is installed
echo.

echo [2/6] Checking project dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies!
    pause
    exit /b 1
)
echo OK - Dependencies installed
echo.

echo [3/6] Checking for google-services.json...
if exist "android\app\google-services.json" (
    echo OK - google-services.json found!
) else (
    echo WARNING: google-services.json NOT FOUND!
    echo.
    echo This file is REQUIRED from Firebase Console!
    echo Location: android\app\google-services.json
    echo.
    echo Please:
    echo 1. Go to https://console.firebase.google.com/
    echo 2. Create/Select your project
    echo 3. Add Android app with package: com.blazeplayer.app
    echo 4. Download google-services.json
    echo 5. Place it at: android\app\google-services.json
    echo.
    echo Then run this script again.
    echo.
    pause
    exit /b 1
)
echo.

echo [4/6] Checking Android toolchain...
flutter doctor
echo.

echo [5/6] Getting SHA-1 certificate...
echo This is needed for Google Sign-In
echo.
cd android
call gradlew signingReport
cd ..
echo.
echo IMPORTANT: Copy the SHA-1 from above and add it to Firebase!
echo Firebase Console -^> Project Settings -^> Your Android App -^> Add Fingerprint
echo.

echo [6/6] Setup Status
echo ============================================
echo.
if exist "android\app\google-services.json" (
    echo Status: READY TO RUN!
    echo.
    echo To run the app:
    echo    flutter run
    echo.
    echo To build release APK:
    echo    flutter build apk --release
    echo.
) else (
    echo Status: MISSING FIREBASE CONFIG
    echo Add google-services.json and run this script again
    echo.
)
echo ============================================
echo.
echo See TODO.md for detailed setup steps
echo See SETUP_GUIDE.md for complete instructions
echo.
pause
