# Google Play Android Publisher API Setup Guide

This guide explains how to enable the Android Publisher API in Google Cloud Console, which is required for automated uploads to Google Play.

## ⚠️ Common Error

If you see this error:
```
Google Play Android Developer API has not been used in project [PROJECT_ID] before or it is disabled.
```

This means the Android Publisher API needs to be enabled in your Google Cloud project.

## 🔧 Solution

### Step 1: Access Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Sign in with the same Google account used for Google Play Console

### Step 2: Select or Create Project

1. Click the project dropdown at the top
2. Either:
   - **Select existing project**: Choose the project associated with your service account
   - **Create new project**: Click "New Project" and create one

### Step 3: Enable Android Publisher API

**Method 1: Direct URL (Recommended)**

1. Go directly to: `https://console.developers.google.com/apis/api/androidpublisher.googleapis.com/overview?project=[YOUR_PROJECT_ID]`
   - Replace `[YOUR_PROJECT_ID]` with your actual project ID
   - You can find your project ID in the error message or in Google Cloud Console

2. Click **"Enable"** button

**Method 2: Through API Library**

1. Go to [Google Cloud Console APIs & Services](https://console.cloud.google.com/apis/library)
2. Search for "Google Play Android Developer API" or "Android Publisher API"
3. Click on the API
4. Click **"Enable"** button

### Step 4: Wait for Propagation

After enabling the API:
- Wait 2-5 minutes for the API to propagate
- The API needs to be fully activated before uploads will work

### Step 5: Verify API is Enabled

1. Go to [Enabled APIs](https://console.cloud.google.com/apis/dashboard)
2. Search for "Android Publisher API"
3. Confirm it shows as "Enabled"

## 🔍 Finding Your Project ID

If you don't know your project ID:

1. **From the error message**: The error shows the project ID (e.g., `551445714018`)
2. **From Google Cloud Console**: 
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - The project ID is shown in the project dropdown
3. **From Service Account JSON**:
   - Open your service account JSON file
   - Look for `project_id` field

## ✅ Verification

After enabling the API, try uploading again:

1. Push to `release` branch (or manually trigger the workflow)
2. The upload should now succeed

If it still fails:
- Wait a few more minutes
- Verify the service account has correct permissions
- Check that the app exists in Google Play Console

## 📝 Related Steps

Before enabling the API, make sure you have:

1. ✅ Created a service account in Google Cloud Console
2. ✅ Downloaded the service account JSON key
3. ✅ Added the service account to Google Play Console
4. ✅ Granted "App Manager" role to the service account
5. ✅ Created the app in Google Play Console with package name `com.coby.taba`
6. ✅ Added `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret to GitHub

## 🆘 Troubleshooting

### "API not found"

- Make sure you're in the correct Google Cloud project
- The project should be the same one where your service account was created

### "Permission denied"

- Ensure you have "Owner" or "Editor" role in the Google Cloud project
- Or ask someone with access to enable the API for you

### "Still getting errors after enabling"

- Wait 5-10 minutes for full propagation
- Try clearing browser cache
- Verify the service account JSON is correct
- Check Google Play Console permissions

## 🔗 Quick Links

- [Enable Android Publisher API](https://console.developers.google.com/apis/api/androidpublisher.googleapis.com/overview)
- [Google Cloud Console](https://console.cloud.google.com)
- [Google Play Console](https://play.google.com/console)
- [API Library](https://console.cloud.google.com/apis/library)

