# App-ads.txt Setup Guide

## What is app-ads.txt?
The app-ads.txt file helps prevent ad fraud by allowing app developers to declare which companies are authorized to sell their app's advertising inventory.

## Why is it important?
Without this file, you could lose significant ad revenue due to:
- Ad fraud prevention measures
- Reduced ad fill rates
- Lower CPMs (cost per mille)

## How to set it up:

### Option 1: Quick Setup (Recommended)
1. **Create a simple website** (even a single page is fine)
   - Use services like GitHub Pages (free)
   - Or get a cheap domain ($1-5/year)

2. **Upload the app-ads.txt file**
   - Place the `app-ads.txt` file in your website's root directory
   - It should be accessible at: `https://yourdomain.com/app-ads.txt`

3. **Verify it works**
   - Visit `https://yourdomain.com/app-ads.txt` in your browser
   - You should see the content starting with `google.com, pub-6752586327...`

### Option 2: Use a free hosting service
- **GitHub Pages**: Create a repository, upload the file, enable Pages
- **Netlify**: Drag and drop the file, get a free subdomain
- **Vercel**: Similar to Netlify, very easy setup

### Option 3: If you have an existing website
Simply upload the `app-ads.txt` file to your website's root directory.

## Important Notes:
- The file MUST be accessible at the root of your domain
- It should be served as plain text (not HTML)
- No redirects should be used
- The file should be updated whenever you add new ad networks

## Current app-ads.txt content:
```
# app-ads.txt file for 7-Minute Workout iOS App
google.com, pub-6752586327, DIRECT, f08c47fec0942fa0
```

## Next Steps:
1. Choose a hosting option
2. Upload the app-ads.txt file
3. Verify it's accessible via HTTPS
4. Update AdMob with your website URL (if prompted)

This will significantly improve your ad revenue and prevent fraud-related issues.
