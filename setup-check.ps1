# BlazePlayer Setup Verification Script
# Run this after you've added google-services.json

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "BlazePlayer - Setup Verification Script" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter
Write-Host "[1/6] Checking Flutter installation..." -ForegroundColor Yellow
try {
    flutter --version
    Write-Host "OK - Flutter is installed" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Flutter is not installed!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Get dependencies
Write-Host "[2/6] Checking project dependencies..." -ForegroundColor Yellow
try {
    flutter pub get
    Write-Host "OK - Dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to get dependencies!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check for google-services.json
Write-Host "[3/6] Checking for google-services.json..." -ForegroundColor Yellow
$googleServicesPath = "android\app\google-services.json"
if (Test-Path $googleServicesPath) {
    Write-Host "OK - google-services.json found!" -ForegroundColor Green
    $hasFirebase = $true
} else {
    Write-Host "WARNING: google-services.json NOT FOUND!" -ForegroundColor Red
    Write-Host ""
    Write-Host "This file is REQUIRED from Firebase Console!" -ForegroundColor Yellow
    Write-Host "Location: android\app\google-services.json" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Go to https://console.firebase.google.com/" -ForegroundColor White
    Write-Host "2. Create/Select your project" -ForegroundColor White
    Write-Host "3. Add Android app with package: com.blazeplayer.app" -ForegroundColor White
    Write-Host "4. Download google-services.json" -ForegroundColor White
    Write-Host "5. Place it at: android\app\google-services.json" -ForegroundColor White
    Write-Host ""
    $hasFirebase = $false
}
Write-Host ""

# Check Android toolchain
Write-Host "[4/6] Checking Android toolchain..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# Get SHA-1
Write-Host "[5/6] Getting SHA-1 certificate..." -ForegroundColor Yellow
Write-Host "This is needed for Google Sign-In" -ForegroundColor Cyan
Write-Host ""
Push-Location android
try {
    .\gradlew signingReport
} catch {
    Write-Host "Error getting SHA-1" -ForegroundColor Red
}
Pop-Location
Write-Host ""
Write-Host "IMPORTANT: Copy the SHA-1 from above and add it to Firebase!" -ForegroundColor Yellow
Write-Host "Firebase Console -> Project Settings -> Your Android App -> Add Fingerprint" -ForegroundColor White
Write-Host ""

# Summary
Write-Host "[6/6] Setup Status" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
if ($hasFirebase) {
    Write-Host "Status: READY TO RUN!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To run the app:" -ForegroundColor Yellow
    Write-Host "   flutter run" -ForegroundColor White
    Write-Host ""
    Write-Host "To build release APK:" -ForegroundColor Yellow
    Write-Host "   flutter build apk --release" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "Status: MISSING FIREBASE CONFIG" -ForegroundColor Red
    Write-Host "Add google-services.json and run this script again" -ForegroundColor Yellow
    Write-Host ""
}
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "See TODO.md for detailed setup steps" -ForegroundColor Cyan
Write-Host "See SETUP_GUIDE.md for complete instructions" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
