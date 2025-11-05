# Support & Marketing URL Setup Guide

## 🔒 Security Concern

If your code repository is public, you should **NOT** use the same repository for support/marketing URLs. Create **separate repositories** that only contain simple HTML pages (no code).

---

## ✅ Recommended Solutions

### Option 1: Email Support URL (Simplest - No Website Needed)

**Support URL:** `mailto:support@ritual7.app?subject=Support%20Request`

**Pros:**
- ✅ No website needed
- ✅ Works immediately
- ✅ No code exposure
- ✅ Simple and direct

**Cons:**
- ⚠️ Some users may prefer a web form

**Setup:**
1. Create email: `support@ritual7.app` (or use your existing email)
2. Use the mailto link above in App Store Connect

---

### Option 2: Separate GitHub Pages Repositories (Recommended)

Create **NEW, SEPARATE** repositories that only contain simple HTML pages.

#### Support URL Setup

1. **Create new repository:** `ritual7-support` (separate from your code repo)
2. **Add simple HTML file:**

```html
<!DOCTYPE html>
<html>
<head>
    <title>Ritual7 Support</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; 
               max-width: 600px; margin: 50px auto; padding: 20px; }
        h1 { color: #333; }
        .contact { margin: 20px 0; }
        a { color: #007AFF; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Ritual7 Support</h1>
    <p>Need help? Contact us:</p>
    <div class="contact">
        <p><strong>Email:</strong> <a href="mailto:support@ritual7.app">support@ritual7.app</a></p>
    </div>
    <p>We typically respond within 24 hours.</p>
</body>
</html>
```

3. **Enable GitHub Pages** in repository settings
4. **URL:** `https://williamDalston.github.io/ritual7-support`

#### Marketing URL Setup

1. **Create new repository:** `ritual7` (separate from your code repo)
2. **Add simple HTML file:**

```html
<!DOCTYPE html>
<html>
<head>
    <title>Ritual7 - 7-Minute HIIT Workout</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Transform your fitness in just 7 minutes with science-backed HIIT workouts.">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; 
               max-width: 800px; margin: 50px auto; padding: 20px; 
               line-height: 1.6; }
        h1 { color: #333; }
        .cta { background: #007AFF; color: white; padding: 15px 30px; 
               border-radius: 8px; display: inline-block; margin: 20px 0; }
        .cta:hover { background: #0056b3; }
        a { color: #007AFF; text-decoration: none; }
    </style>
</head>
<body>
    <h1>Ritual7</h1>
    <h2>Transform Your Fitness in Just 7 Minutes</h2>
    <p>Science-backed HIIT workouts. No equipment needed. Beautiful design. Apple Watch support.</p>
    <a href="https://apps.apple.com/app/ritual7" class="cta">Download on App Store</a>
    <p><strong>Available on:</strong> iPhone, iPad, Apple Watch</p>
</body>
</html>
```

3. **Enable GitHub Pages** in repository settings
4. **URL:** `https://williamDalston.github.io/ritual7`

**Important:** These repositories are **completely separate** from your code repository and contain **NO code** - just simple HTML pages.

---

### Option 3: Netlify (Free - Completely Separate)

**Pros:**
- ✅ Completely separate from GitHub
- ✅ Free hosting
- ✅ Easy drag-and-drop setup
- ✅ No code exposure

**Setup:**

1. **Go to:** [netlify.com](https://netlify.com)
2. **Create account** (free)
3. **Drag and drop** your HTML files
4. **Get URLs:**
   - Support: `https://ritual7-support.netlify.app`
   - Marketing: `https://ritual7.netlify.app`

**Files needed:**
- `index.html` for support page
- `index.html` for marketing page (in separate sites)

---

### Option 4: Custom Domain (Most Professional)

**Pros:**
- ✅ Professional appearance
- ✅ Branded URLs
- ✅ Better SEO

**Setup:**

1. **Buy domain:** `ritual7.app` or `ritual7.com` (~$10-15/year)
2. **Host on:**
   - Netlify (free)
   - Vercel (free)
   - GitHub Pages with custom domain
3. **URLs:**
   - Support: `https://support.ritual7.app`
   - Marketing: `https://ritual7.app`

---

## 🎯 Recommended Approach

**For Support URL:**
- **Option 1 (Email):** `mailto:support@ritual7.app?subject=Support%20Request`
- **OR Option 2:** Separate GitHub Pages repo with simple contact page

**For Marketing URL:**
- **Option 2:** Separate GitHub Pages repo with simple landing page
- **OR Option 3:** Netlify (separate from GitHub)

---

## ⚠️ Security Best Practices

1. ✅ **Never use your code repository** for support/marketing URLs
2. ✅ **Create separate repositories** that only contain HTML
3. ✅ **Don't include any code** in support/marketing pages
4. ✅ **Use simple static pages** - no backend code
5. ✅ **Keep code repository private** if you're concerned about code exposure

---

## 📝 Quick Setup Checklist

### For Email Support URL:
- [ ] Use: `mailto:support@ritual7.app?subject=Support%20Request`
- [ ] Add to App Store Connect
- [ ] Done! ✅

### For Website Support URL:
- [ ] Create new GitHub repo: `ritual7-support`
- [ ] Add simple HTML contact page
- [ ] Enable GitHub Pages
- [ ] Test URL works
- [ ] Add to App Store Connect

### For Marketing URL:
- [ ] Create new GitHub repo: `ritual7`
- [ ] Add simple HTML landing page
- [ ] Enable GitHub Pages
- [ ] Test URL works
- [ ] Add to App Store Connect

---

## 🔗 Final URLs to Use

**Recommended:**

**Support URL:**
```
mailto:support@ritual7.app?subject=Support%20Request
```

**OR if you prefer a web page:**
```
https://williamDalston.github.io/ritual7-support
```
*(Separate repo - no code)*

**Marketing URL:**
```
https://williamDalston.github.io/ritual7
```
*(Separate repo - no code)*

---

*Remember: Keep your code repository separate from your support/marketing websites!*

