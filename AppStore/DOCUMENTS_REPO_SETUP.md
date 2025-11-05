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

### Step 2: Upload Pages

**Option A: Support and Marketing in Same Repository**

1. In your new repository, click **"Add file"** → **"Upload files"**
2. Upload both `support.html` and `marketing.html` from this project
3. **Rename `support.html` to:** `index.html` (this makes it the default/support page)
4. **Keep `marketing.html` as:** `marketing.html` (or create a subfolder)
5. Click **"Commit changes"**

**Option B: Separate Repositories (Recommended)**

**For Support Page:**
1. Create repository: `ritual7-docs` (or `ritual7-support`)
2. Upload `support.html` and rename to `index.html`
3. Support URL: `https://williamDalston.github.io/ritual7-docs`

**For Marketing Page:**
1. Create repository: `ritual7` (or `ritual7-marketing`)
2. Upload `marketing.html` and rename to `index.html`
3. Marketing URL: `https://williamDalston.github.io/ritual7`

### Step 3: Enable GitHub Pages

1. Go to your repository → **"Settings"**
2. Scroll down to **"Pages"** section (left sidebar)
3. Under **"Source"**, select **"Deploy from a branch"**
4. Choose **"main"** branch and **"/ (root)"** folder
5. Click **"Save"**

### Step 4: Get Your URLs

**If using separate repositories:**

**Support URL:**
```
https://williamDalston.github.io/ritual7-docs
```

**Marketing URL:**
```
https://williamDalston.github.io/ritual7
```

*(Replace repository names with your actual repository names)*

### Step 5: Verify It Works

1. Wait 2-3 minutes for GitHub Pages to deploy
2. Visit your URLs:
   - Support: `https://williamDalston.github.io/ritual7-docs`
   - Marketing: `https://williamDalston.github.io/ritual7`
3. You should see your pages

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

**Support Repository (`ritual7-docs`):**
- ✅ `index.html` (support page - renamed from `support.html`)
- ✅ `README.md` (optional - repository description)

**Marketing Repository (`ritual7`):**
- ✅ `index.html` (marketing page - renamed from `marketing.html`)
- ✅ `README.md` (optional - repository description)

**Both repositories should ONLY contain:**
- ✅ Simple HTML pages
- ✅ `app-ads.txt` (if needed for AdMob - can be in either repo)

**DO NOT include:**
- ❌ Any Swift/SwiftUI code
- ❌ Xcode project files
- ❌ App source code
- ❌ Any sensitive information

---

## 🎯 Final URLs

Once set up, your URLs will be:

**Support URL:**
```
https://williamDalston.github.io/ritual7-docs
```

**Marketing URL:**
```
https://williamDalston.github.io/ritual7
```

*(Replace repository names with your actual repository names)*

**Use these URLs in App Store Connect:**
- **App Information** → **Support URL**: `https://williamDalston.github.io/ritual7-docs`
- **App Information** → **Marketing URL**: `https://williamDalston.github.io/ritual7`

---

## ✅ Checklist

**Support Repository:**
- [ ] Created new public repository: `ritual7-docs`
- [ ] Uploaded `support.html` (renamed to `index.html`)
- [ ] Enabled GitHub Pages
- [ ] Verified support page works

**Marketing Repository:**
- [ ] Created new public repository: `ritual7`
- [ ] Uploaded `marketing.html` (renamed to `index.html`)
- [ ] Enabled GitHub Pages
- [ ] Verified marketing page works

**App Repository:**
- [ ] Made app code repository private
- [ ] Verified code is protected

**App Store Connect:**
- [ ] Added support URL to App Store Connect
- [ ] Added marketing URL to App Store Connect

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

