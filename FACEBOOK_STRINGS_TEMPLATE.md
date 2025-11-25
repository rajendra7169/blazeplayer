# Facebook Configuration Template

When setting up this project, you need to create the following file:

**Location:** `android/app/src/main/res/values/strings.xml`

**Content:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">BlazePlayer</string>
    <!-- Facebook App ID from https://developers.facebook.com -->
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
    <!-- Facebook Client Token - Get this from Facebook App Dashboard → Settings → Advanced -->
    <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

**Where to get your values:**

1. Go to https://developers.facebook.com/
2. Select your app
3. Settings → Basic
4. Copy "App ID" and "App Secret"

**Important:** This file should NOT be committed to Git (it's in .gitignore)
