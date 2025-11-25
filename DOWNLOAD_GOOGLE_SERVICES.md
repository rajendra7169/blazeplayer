# 📥 How to Download google-services.json

## Step-by-Step Instructions

### Method 1: From Firebase Console (Recommended)

1. **Open Firebase Console**

   - Go to: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Select Your Project**

   - Click on "Blaze Player" project

3. **Go to Project Settings**

   - Click the ⚙️ (gear) icon next to "Project Overview"
   - Click "Project settings"

4. **Find Your Android App**

   - Scroll down to "Your apps" section
   - Look for **"Blaze Player"** with package name `com.example.blazeplayer_master`

5. **Download Configuration File**

   - You'll see a download icon or "google-services.json" button
   - Click it to download the file

6. **Place the File**
   - Copy the downloaded file to:
   ```
   c:\Users\LOQ\Desktop\blazeplayer\android\app\google-services.json
   ```

### Method 2: Regenerate if Needed

If you don't see the download option:

1. In Firebase Console > Project Settings
2. Scroll to "Your apps"
3. Find "Blaze Player" (com.example.blazeplayer_master)
4. Click "Download google-services.json" or the settings icon
5. Select "Download google-services.json"

---

## ✅ Verify the File

After downloading, check that:

1. **File Location**: `android/app/google-services.json`
2. **File Name**: Exactly `google-services.json` (not `google-services (1).json`)
3. **File Content**: Should start with:
   ```json
   {
     "project_info": {
       "project_number": "142564994990",
       ...
     }
   }
   ```

---

## 🚀 After Placing the File

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🎯 Quick Checklist

- [ ] Downloaded google-services.json from Firebase Console
- [ ] Placed file at: `android/app/google-services.json`
- [ ] File name is exactly `google-services.json`
- [ ] Ran `flutter pub get`
- [ ] Ready to run `flutter run`

---

**That's all you need! The app will connect to your existing Firebase project.** 🎉
