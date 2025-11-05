# Developer Website Setup for App Store & AdMob

## Problem
AdMob couldn't verify your app because:
1. No developer website listed in App Store Connect
2. No app-ads.txt file accessible

## Solution: Quick GitHub Pages Setup

### Step 1: Create GitHub Repository
1. Go to [github.com](https://github.com) and sign in
2. Click "New repository"
3. Name it: `williamalston-dev` or `onetapgratitude-website`
4. Make it **Public** (required for free GitHub Pages)
5. Check "Add a README file"
6. Click "Create repository"

### Step 2: Upload Files
1. Upload these files to your repository root:
   - `index.html` (the website template I created)
   - `app-ads.txt` (with correct AdMob publisher ID)

### Step 3: Enable GitHub Pages
1. Go to your repository → Settings
2. Scroll down to "Pages" section
3. Under "Source", select "Deploy from a branch"
4. Choose "main" branch and "/ (root)" folder
5. Click "Save"

### Step 4: Get Your Website URL
Your website will be available at:
```
https://yourusername.github.io/repository-name
```

Example: `https://williamalston.github.io/williamalston-dev`

### Step 5: Update App Store Connect
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select "7-Minute Workout" app
3. Go to "App Information"
4. Add your GitHub Pages URL in "Developer Website" field
5. Save changes

### Step 6: Verify app-ads.txt
1. Visit: `https://yourusername.github.io/repository-name/app-ads.txt`
2. You should see:
   ```
   # app-ads.txt file for 7-Minute Workout iOS App
   google.com, pub-2214618538122354, DIRECT, f08c47fec0942fa0
   ```

### Step 7: Re-verify in AdMob
1. Go back to AdMob
2. Click "Crawl your app-ads.txt file to verify your app"
3. It should now find and verify the file

## Alternative: Quick Domain Setup

If you prefer a custom domain:

### Option A: Netlify (Free)
1. Go to [netlify.com](https://netlify.com)
2. Drag and drop your `index.html` and `app-ads.txt` files
3. Get a free subdomain like `onetapgratitude.netlify.app`

### Option B: Buy Domain ($1-15/year)
1. Buy a domain like `williamalston.dev` or `onetapgratitude.app`
2. Use free hosting (Netlify, Vercel, GitHub Pages with custom domain)

## Files You Need
- ✅ `index.html` - Simple website template
- ✅ `app-ads.txt` - Updated with correct AdMob publisher ID

## Timeline
- **GitHub Pages setup**: 10 minutes
- **App Store Connect update**: 5 minutes  
- **AdMob verification**: Usually works within hours

This will resolve both the developer website requirement and the app-ads.txt verification issue.
