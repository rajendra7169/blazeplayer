# 🚨 URGENT: Remove Exposed Secrets from Git History

## Step 1: Remove File from Git History

Run these commands to remove the sensitive file from your entire Git history:

```powershell
cd c:\Users\LOQ\Desktop\blazeplayer

# Remove strings.xml from Git history
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch android/app/src/main/res/values/strings.xml" --prune-empty --tag-name-filter cat -- --all

# Force push to GitHub (this rewrites history)
git push origin --force --all
```

## Step 2: Update .gitignore

Make sure these files are in your `.gitignore`:

```
# Facebook/Google secrets
android/app/src/main/res/values/strings.xml
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart
```

## Step 3: Create Template File

Create a template file for other developers:

```xml
<!-- android/app/src/main/res/values/strings.xml.template -->
<resources>
    <string name="app_name">Blaze Player</string>
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

## Step 4: Recreate strings.xml Locally

After removing from Git, recreate the file locally with your NEW keys:

1. Copy `strings.xml.template` to `strings.xml`
2. Replace placeholders with your NEW Facebook keys
3. DO NOT commit this file!

## Step 5: Alternative - Use Environment Variables

Better approach for secrets:

1. Create a `.env` file (already in .gitignore):
```
FACEBOOK_APP_ID=your_new_app_id
FACEBOOK_CLIENT_TOKEN=your_new_token
```

2. Use a package like `flutter_dotenv` to read environment variables
3. Never commit `.env` files

## Important Notes

- ⚠️ Simply deleting the file and committing won't help - it's still in Git history!
- ⚠️ Anyone who cloned your repo already has access to the old keys
- ✅ Regenerating keys makes the old ones useless
- ✅ Git history cleanup removes traces from GitHub

## Verification

After cleanup:
1. Check GitHub - file should not appear in any commit
2. Search your repo on GitHub for "facebook_app_id"
3. Should return no results

---

**CRITICAL: Do NOT skip regenerating your Facebook App Secret!**
