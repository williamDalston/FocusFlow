# Cursor AI Prompt for GitHub Pages Project

## 🎯 Project Overview

Create a GitHub Pages website for Ritual7 app with two pages:
1. **Support Page** (`index.html` in `ritual7-docs` repository)
2. **Marketing Page** (`index.html` in `ritual7` repository)

Both pages should be simple, static HTML with inline CSS. No frameworks, no external dependencies, no JavaScript (except for email links). The pages should be professional, modern, and match the app's aesthetic.

---

## 📋 Project Structure

```
ritual7-docs/          (Support repository)
├── index.html         (Support page)
└── README.md

ritual7/               (Marketing repository)
├── index.html         (Marketing page)
└── README.md
```

---

## 🎨 Design Requirements

### Color Scheme
- **Primary Gradient:** `linear-gradient(135deg, #667eea 0%, #764ba2 100%)`
- **Primary Color:** `#667eea` (purple-blue)
- **Secondary Color:** `#764ba2` (deep purple)
- **Text Color:** `#333` (dark gray)
- **Background:** White with gradient overlay
- **Accent:** `#f8f9fa` (light gray for sections)

### Typography
- **Font Family:** `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif`
- **Headings:** Bold, larger sizes
- **Body:** Regular weight, readable line-height (1.6)

### Layout
- **Max Width:** 600px (support) / 900px (marketing)
- **Responsive:** Mobile-friendly, works on all screen sizes
- **Padding:** 40-60px on desktop, 20px on mobile
- **Border Radius:** 12-16px for cards/containers
- **Shadows:** Subtle shadows for depth

---

## 📄 SUPPORT PAGE (`ritual7-docs/index.html`)

### Page Title
**"Ritual7 Support"**

### Header Section
- **Main Heading:** "Ritual7 Support" (large, purple-blue color)
- **Subtitle:** "Need help? We're here for you." (gray, smaller)

### Contact Section
Include two contact options:

**1. Email Support**
- **Icon:** 📧 (or envelope emoji)
- **Title:** "Email Support"
- **Description:** "Get help with any questions or issues"
- **Button:** "Contact Support" (purple gradient button)
- **Link:** `mailto:support@ritual7.app?subject=Support%20Request`

**2. Report an Issue**
- **Icon:** 🐛 (or bug emoji)
- **Title:** "Report an Issue"
- **Description:** "Found a bug or have a suggestion?"
- **Button:** "Report Issue" (purple gradient button)
- **Link:** `mailto:support@ritual7.app?subject=Bug%20Report`

### Information Box
Include a light blue info box with:
- **Response Time:** "We typically respond within 24-48 hours"
- **App Version:** "1.3"
- **Support Hours:** "Monday - Friday, 9 AM - 5 PM EST"

### Footer
- Link back to app: "← Back to Ritual7 App" (link to App Store)
- Link: `https://apps.apple.com/app/ritual7`

### Design Elements
- Gradient background (purple-blue)
- White card container with shadow
- Rounded corners (16px)
- Centered layout
- Hover effects on buttons
- Professional, clean design

---

## 📄 MARKETING PAGE (`ritual7/index.html`)

### Page Title
**"Ritual7 - 7-Minute HIIT Workout App"**

### Hero Section
- **Main Heading:** "Ritual7" (very large, purple-blue)
- **Tagline:** "Transform Your Fitness in Just 7 Minutes" (large, gray)
- **Description:** "Science-backed HIIT workouts. No equipment needed. Beautiful design. Apple Watch support."
- **Primary CTA Button:** "📱 Download on App Store" (large, prominent)
- **Link:** `https://apps.apple.com/app/ritual7`

### Features Grid (6 features in a 3x2 grid)
Each feature card should include:
1. **🏋️ Science-Backed**
   - "12 exercises based on research from the American College of Sports Medicine"

2. **⚡ 7 Minutes**
   - "Complete full-body workout in just 7 minutes - perfect for busy schedules"

3. **🏠 No Equipment**
   - "Work out anywhere - no gym membership or equipment needed"

4. **⌚ Apple Watch**
   - "Full workout experience on your wrist with seamless sync"

5. **📊 Track Progress**
   - "Beautiful analytics, streaks, and achievements to stay motivated"

6. **🎨 Beautiful Design**
   - "Modern, intuitive interface that makes working out enjoyable"

### Benefits Section
Light gray background with grid of benefits:
- Time Efficient
- No Equipment Required
- Science-Backed Routine
- Progress Tracking
- Apple Watch Support
- HealthKit Integration
- Fully Accessible
- Beautiful Design

### Platforms Section
- **Heading:** "Available On"
- **Icons:** 📱 iPhone, 📱 iPad, ⌚ Apple Watch
- Light blue background

### Secondary CTA
- **Button:** "Start Your 7-Minute Journey Today"
- **Link:** `https://apps.apple.com/app/ritual7`

### Footer
- Copyright: "© 2024 Ritual7. Transform your fitness in just 7 minutes."
- Links: "Support | Contact"
- Support link: `https://williamDalston.github.io/ritual7-docs`
- Contact link: `mailto:support@ritual7.app`

### Design Elements
- Gradient background (purple-blue)
- White card container with shadow
- Feature cards with icons
- Responsive grid layout
- Hover effects on buttons
- Professional, modern design
- Mobile-responsive

---

## 🔧 Technical Requirements

### HTML Structure
- Use semantic HTML5 elements (`<header>`, `<main>`, `<section>`, `<footer>`)
- Include proper meta tags for SEO:
  - `<meta charset="UTF-8">`
  - `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
  - `<meta name="description" content="...">` (unique for each page)
- Include `<title>` tag with appropriate page title
- Add `lang="en"` to `<html>` tag

### CSS Requirements
- **Inline CSS only** (no external stylesheets)
- Use CSS Grid and Flexbox for layouts
- Mobile-responsive with media queries
- Smooth transitions and hover effects
- Use CSS custom properties (variables) for colors if desired
- Ensure good contrast for accessibility

### Performance
- No external resources (fonts, images, scripts)
- Optimize for fast loading
- Use system fonts (no external font loading)
- Keep file size small (< 50KB per page)

### Accessibility
- Proper heading hierarchy (h1, h2, h3)
- Alt text for any images (if added)
- Semantic HTML
- Good color contrast
- Keyboard accessible links

### Browser Compatibility
- Works on all modern browsers
- Mobile-friendly (iOS Safari, Chrome, etc.)
- Desktop-friendly (Chrome, Safari, Firefox, Edge)

---

## 📱 Responsive Design

### Mobile (< 768px)
- Reduced font sizes
- Single column layout
- Stacked feature cards
- Reduced padding (20px)
- Full-width buttons

### Desktop (> 768px)
- Larger font sizes
- Multi-column layouts
- Side-by-side feature cards
- More padding (40-60px)
- Centered content with max-width

---

## ✅ Checklist for Each Page

### Support Page
- [ ] Professional gradient background
- [ ] White card container with shadow
- [ ] Email support button with mailto link
- [ ] Report issue button with mailto link
- [ ] Information box with response time
- [ ] Link back to App Store
- [ ] Responsive design
- [ ] Inline CSS only
- [ ] No external dependencies
- [ ] Fast loading (< 50KB)

### Marketing Page
- [ ] Professional gradient background
- [ ] Hero section with main heading
- [ ] Primary CTA button (App Store link)
- [ ] 6 feature cards in grid layout
- [ ] Benefits section with checkmarks
- [ ] Platforms section
- [ ] Secondary CTA button
- [ ] Footer with links
- [ ] Responsive design
- [ ] Inline CSS only
- [ ] No external dependencies
- [ ] Fast loading (< 50KB)

---

## 🎨 Visual Design Notes

### Support Page
- **Focus:** Clean, professional, helpful
- **Layout:** Centered, single column
- **Buttons:** Prominent, gradient background
- **Colors:** Purple-blue gradient, white cards

### Marketing Page
- **Focus:** Engaging, feature-rich, conversion-focused
- **Layout:** Multi-column grid, visually appealing
- **Buttons:** Large, prominent CTAs
- **Colors:** Purple-blue gradient, white cards, light gray sections

---

## 📝 Content Guidelines

### Tone
- Professional but friendly
- Clear and concise
- Action-oriented
- Benefit-focused

### Writing Style
- Use active voice
- Short sentences
- Bullet points for lists
- Clear headings

### Links
- All external links should open in new tab (`target="_blank"`)
- Use descriptive link text
- Ensure links are accessible

---

## 🚀 Final Output

Create two complete HTML files:
1. `support.html` - Support page (to be renamed to `index.html` in `ritual7-docs` repo)
2. `marketing.html` - Marketing page (to be renamed to `index.html` in `ritual7` repo)

Both files should:
- Be standalone (no external dependencies)
- Work immediately when uploaded to GitHub Pages
- Look professional and modern
- Be fully responsive
- Load quickly
- Be accessible

---

## 📋 Example Structure

### Support Page Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <!-- Meta tags -->
    <!-- Title -->
    <!-- Inline CSS -->
</head>
<body>
    <div class="container">
        <header>
            <h1>Ritual7 Support</h1>
            <p class="subtitle">Need help? We're here for you.</p>
        </header>
        
        <main>
            <section class="contact-section">
                <!-- Email Support -->
                <!-- Report Issue -->
            </section>
            
            <section class="info">
                <!-- Response time, version, hours -->
            </section>
        </main>
        
        <footer>
            <!-- Link to app -->
        </footer>
    </div>
</body>
</html>
```

### Marketing Page Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <!-- Meta tags -->
    <!-- Title -->
    <!-- Inline CSS -->
</head>
<body>
    <div class="container">
        <header class="hero">
            <h1>Ritual7</h1>
            <p class="tagline">Transform Your Fitness in Just 7 Minutes</p>
            <!-- CTA Button -->
        </header>
        
        <main>
            <section class="features">
                <!-- 6 feature cards in grid -->
            </section>
            
            <section class="benefits">
                <!-- Benefits list -->
            </section>
            
            <section class="platforms">
                <!-- Platform icons -->
            </section>
            
            <!-- Secondary CTA -->
        </main>
        
        <footer>
            <!-- Copyright and links -->
        </footer>
    </div>
</body>
</html>
```

---

## 🎯 Key Requirements Summary

1. **Two separate HTML files** (support and marketing)
2. **Inline CSS only** (no external stylesheets)
3. **No JavaScript** (except for email links)
4. **No external dependencies** (fonts, images, etc.)
5. **Fully responsive** (mobile and desktop)
6. **Professional design** (gradient backgrounds, modern UI)
7. **Fast loading** (< 50KB per page)
8. **Accessible** (semantic HTML, good contrast)
9. **SEO-friendly** (proper meta tags, titles)
10. **Ready to upload** (works immediately on GitHub Pages)

---

## 💡 Additional Notes

- Use emoji icons for visual appeal (no external images needed)
- Gradient buttons with hover effects
- Smooth transitions and animations
- Professional color scheme matching app design
- Clean, modern aesthetic
- Mobile-first responsive design
- Fast, lightweight pages

---

**Create these two pages following all the specifications above. Make them professional, modern, and ready for production use on GitHub Pages.**

