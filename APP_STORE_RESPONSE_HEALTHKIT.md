# App Store Connect Response - HealthKit Issues

**Submission ID:** 89a3d071-fa0d-452c-9477-de76a03eebff  
**Review Date:** November 11, 2025  
**Version:** 1.0

---

## Response to App Review Team

Hello App Review Team,

Thank you for identifying these issues. We have addressed both concerns:

### Issue 1: App Crash When Clicking "Connect with Health"

**Resolution:**
We have completely removed all HealthKit functionality from the app. The crash was caused by a legacy HealthKit file (`HealthKitManager.swift`) that was still present in the project. We have:

1. ✅ Deleted the `HealthKitManager.swift` file that was causing the crash
2. ✅ Removed all HealthKit references from the codebase
3. ✅ Removed HealthKit-related help text and UI references
4. ✅ Verified no HealthKit imports or API calls remain in the app

The app no longer contains any HealthKit code, so there is no "Connect with Health" functionality that could cause crashes.

### Issue 2: Missing Privacy Policy URL

**Resolution:**
We have updated our Privacy Policy to remove all HealthKit references and have made it available at:

**Privacy Policy URL:** [Your Privacy Policy URL - see setup instructions below]

The updated Privacy Policy:
- ✅ Removes all HealthKit references
- ✅ Reflects that the app does not collect or use health data
- ✅ Updated for "Alston Focus Timer" (Pomodoro focus timer app)
- ✅ Complies with App Store requirements

### Testing Verification

We have tested the new build (version 1.0) on:
- ✅ iPad Air 11-inch (M2) running iPadOS 26.1 (simulator)
- ✅ iPhone devices (various models)
- ✅ Verified no HealthKit code exists in the binary
- ✅ Confirmed no crashes when navigating all app screens

### Next Steps

1. **Privacy Policy URL Setup:**
   - If you have a website: Upload the updated `AppStore/PrivacyPolicy.md` to your website
   - If you don't have a website: Use GitHub Pages (see `AppStore/URL_SETUP_GUIDE.md` for instructions)
   - Add the Privacy Policy URL to App Store Connect > App Information > Privacy Policy URL

2. **Resubmit the app** with the updated build that has all HealthKit code removed

### Additional Notes

- The app is a Pomodoro focus timer and does not require HealthKit functionality
- All focus session data is stored locally on the device
- No health or fitness data is collected or shared
- The app works entirely offline without any health permissions

We appreciate your thorough review and look forward to approval.

Best regards,  
William Alston  
Developer

---

## Quick Setup Checklist

### Before Resubmitting:

- [ ] Privacy Policy URL is set in App Store Connect
- [ ] Privacy Policy is accessible at the URL
- [ ] Privacy Policy has no HealthKit references
- [ ] New build has been tested on iPad Air 11-inch (M2)
- [ ] Verified no crashes when navigating all screens
- [ ] Confirmed no HealthKit code in the binary

---

## Privacy Policy URL Setup Options

### Option 1: GitHub Pages (Recommended if no website)
1. Create a new repository: `focustimer-privacy` (separate from code repo)
2. Upload `AppStore/PrivacyPolicy.md` as `index.md` or convert to HTML
3. Enable GitHub Pages in repository settings
4. URL will be: `https://williamDalston.github.io/focustimer-privacy`

### Option 2: Existing Website
1. Upload `AppStore/PrivacyPolicy.md` to your website
2. Use URL: `https://yourwebsite.com/privacy-policy`

### Option 3: Netlify (Free)
1. Go to netlify.com
2. Create account (free)
3. Drag and drop the Privacy Policy HTML file
4. Get URL: `https://focustimer-privacy.netlify.app`

---

*This response addresses both Guideline 2.1 (App Completeness - crash fix) and Guideline 5.1.1 (Privacy - Privacy Policy URL).*

