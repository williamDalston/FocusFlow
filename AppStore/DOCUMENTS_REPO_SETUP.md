# Documents Repository Setup Guide

## 🎯 Purpose

Create a **separate, public repository** for your support and marketing pages. This repository will **ONLY contain simple HTML pages** - no app code.

---

## 📋 Step-by-Step Setup

### Step 1: Create New Repository on GitHub

1. Go to [github.com](https://github.com) and sign in
2. Click the **"+" icon** in the top right → **"New repository"**
3. **Repository name:** `ritual7-docs` or `ritual7-support`
4. **Description:** "Support and marketing pages for Ritual7 app"
5. **Visibility:** ✅ **Public** (required for free GitHub Pages)
6. **Initialize:** ✅ Check "Add a README file"
7. Click **"Create repository"**

### Step 2: Upload Support Page

1. In your new repository, click **"Add file"** → **"Upload files"**
2. Upload the `support.html` file from this project
3. **Rename it to:** `index.html` (this makes it the default page)
4. Click **"Commit changes"**

### Step 3: Enable GitHub Pages

1. Go to your repository → **"Settings"**
2. Scroll down to **"Pages"** section (left sidebar)
3. Under **"Source"**, select **"Deploy from a branch"**
4. Choose **"main"** branch and **"/ (root)"** folder
5. Click **"Save"**

### Step 4: Get Your Support URL

Your support page will be available at:
```
https://williamDalston.github.io/ritual7-docs
```

*(Replace `ritual7-docs` with your actual repository name)*

### Step 5: Verify It Works

1. Wait 2-3 minutes for GitHub Pages to deploy
2. Visit your URL: `https://williamDalston.github.io/ritual7-docs`
3. You should see your support page

---

## 🔒 Security: Make App Repository Private

### Option 1: Make Current Repository Private

1. Go to your **app code repository:** `exerciseappformyself`
2. Click **"Settings"** tab
3. Scroll down to **"Danger Zone"** section
4. Click **"Change repository visibility"**
5. Select **"Change to private"**
6. Type the repository name to confirm
7. Click **"I understand, change repository visibility"**

**Note:** If your repository is free, you can have unlimited private repositories.

### Option 2: Create New Private Repository

If you want to keep the current one as-is and create a new private one:

1. Create a new repository (same steps as above)
2. Choose **"Private"** instead of Public
3. Push your code there

---

## 📝 Files in Documents Repository

Your documents repository should **ONLY contain:**

- ✅ `index.html` (support page)
- ✅ `README.md` (optional - repository description)
- ✅ `app-ads.txt` (if needed for AdMob)

**DO NOT include:**
- ❌ Any Swift/SwiftUI code
- ❌ Xcode project files
- ❌ App source code
- ❌ Any sensitive information

---

## 🎯 Final Support URL

Once set up, your support URL will be:

```
https://williamDalston.github.io/ritual7-docs
```

*(Or whatever you name your repository)*

Use this URL in **App Store Connect** → **App Information** → **Support URL**

---

## ✅ Checklist

- [ ] Created new public repository for documents
- [ ] Uploaded `support.html` (renamed to `index.html`)
- [ ] Enabled GitHub Pages
- [ ] Verified support page works
- [ ] Made app code repository private
- [ ] Added support URL to App Store Connect

---

## 🆘 Troubleshooting

**Page not showing?**
- Wait 2-3 minutes for GitHub Pages to deploy
- Check repository settings → Pages section
- Ensure file is named `index.html`
- Ensure repository is public

**Need help?**
- Check GitHub Pages documentation
- Verify your repository name matches the URL

---

*Remember: Keep your app code private and documents public!*

