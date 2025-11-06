# App Store Connect Privacy Questionnaire - Data Collection

**App Name:** FocusFlow  
**Bundle ID:** williamalston.FocusFlow  
**Date:** 2024

---

## 📋 Data Collection Summary for App Store Connect

Use this guide when filling out the **Privacy** section in App Store Connect.

---

## ✅ YES - Data Collected (Must Declare)

### 1. **Health & Fitness Data** ⚠️ SENSITIVE
- **Data Type:** Health & Fitness
- **Checkboxes to select:**
  - ✅ App Functionality
  - ❌ Third-Party Advertising
  - ❌ Developer's Advertising or Marketing
  - ❌ Analytics
  - ❌ Product Personalization
  - ❌ Other Purposes
- **Linked to User:** ✅ Yes
- **Used to Track:** ❌ No
- **Description:** "We collect workout data (duration, exercises completed, calories burned) to track your fitness progress and sync with Apple Health (with your permission)."
- **Data Collected:**
  - Workout sessions (dates, times, duration)
  - Exercises completed
  - Estimated calories burned
  - Exercise minutes
  - Heart rate (read-only, if available)
  - Weight (read-only, if available)

### 2. **Location Data** 📍
- **Data Type:** Location → Coarse Location
- **Checkboxes to select:**
  - ❌ App Functionality
  - ✅ Third-Party Advertising
  - ❌ Developer's Advertising or Marketing
  - ✅ Analytics
  - ❌ Product Personalization
  - ❌ Other Purposes
- **Linked to User:** ✅ Yes
- **Used to Track:** ❌ No
- **Description:** "Coarse location data (city-level) is collected by Google Mobile Ads to show relevant advertisements."
- **Note:** This is collected by AdMob SDK, not directly by your app

### 3. **Device ID** 📱
- **Data Type:** Device ID
- **Checkboxes to select:**
  - ❌ App Functionality
  - ✅ Third-Party Advertising
  - ❌ Developer's Advertising or Marketing
  - ✅ Analytics
  - ❌ Product Personalization
  - ❌ Other Purposes
- **Linked to User:** ✅ Yes
- **Used to Track:** ✅ Yes
- **Description:** "Device identifier is collected by Google Mobile Ads for advertising and analytics purposes."
- **Note:** This is collected by AdMob SDK

### 4. **Product Interaction** 🎯
- **Data Type:** Product Interaction
- **Checkboxes to select:**
  - ❌ App Functionality
  - ✅ Third-Party Advertising
  - ❌ Developer's Advertising or Marketing
  - ✅ Analytics
  - ❌ Product Personalization
  - ❌ Other Purposes
- **Linked to User:** ✅ Yes
- **Used to Track:** ❌ No
- **Description:** "We collect information about how you interact with ads (views, clicks) for analytics and advertising purposes."
- **Note:** Collected by Google Mobile Ads

### 5. **Advertising Data** 📢
- **Data Type:** Advertising Data
- **Checkboxes to select:**
  - ❌ App Functionality
  - ✅ Third-Party Advertising
  - ❌ Developer's Advertising or Marketing
  - ✅ Analytics
  - ❌ Product Personalization
  - ❌ Other Purposes
- **Linked to User:** ✅ Yes
- **Used to Track:** ❌ No
- **Description:** "Advertising data is collected by Google Mobile Ads to show relevant advertisements."
- **Note:** Collected by AdMob SDK

### 6. **Performance Data** ⚡
- **Data Type:** Performance Data
- **Checkboxes to select:**
  - ❌ App Functionality
  - ✅ Third-Party Advertising
  - ❌ Developer's Advertising or Marketing
  - ✅ Analytics
  - ❌ Product Personalization
  - ❌ Other Purposes
- **Linked to User:** ❌ No
- **Used to Track:** ❌ No
- **Description:** "App performance metrics are collected to improve app functionality and for advertising analytics."
- **Note:** Collected by Google Mobile Ads

### 7. **Crash Data** 💥
- **Data Type:** Crash Data
- **Checkboxes to select:**
  - ❌ App Functionality
  - ❌ Third-Party Advertising
  - ❌ Developer's Advertising or Marketing
  - ✅ Analytics
  - ❌ Product Personalization
  - ❌ Other Purposes
- **Linked to User:** ❌ No
- **Used to Track:** ❌ No
- **Description:** "Crash reports are collected to identify and fix bugs in the app."
- **Note:** Collected by Google Mobile Ads SDK

### 8. **Other Diagnostic Data** 🔧
- **Data Type:** Other Diagnostic Data
- **Checkboxes to select:**
  - ❌ App Functionality
  - ✅ Third-Party Advertising
  - ❌ Developer's Advertising or Marketing
  - ✅ Analytics
  - ❌ Product Personalization
  - ❌ Other Purposes
- **Linked to User:** ❌ No
- **Used to Track:** ❌ No
- **Description:** "Diagnostic data is collected by Google Mobile Ads for analytics and advertising optimization."
- **Note:** Collected by AdMob SDK

---

## ❌ NO - Data NOT Collected (Optional to Declare)

### Data Stored Locally Only
- **Workout History:** Stored locally on device (UserDefaults)
- **User Preferences:** Stored locally on device
- **Settings:** Stored locally on device

**Note:** These are NOT collected by the app server-side, so they typically don't need to be declared in App Store Connect unless you sync them to a server (which you don't).

---

## 🔐 Privacy Usage Descriptions (Already in Info.plist)

Your app already has these privacy usage descriptions:

1. **NSHealthShareUsageDescription**
   - "We use HealthKit to read your weight and activity level to provide better calorie estimates and personalized recommendations for your workouts."

2. **NSHealthUpdateUsageDescription**
   - "We use HealthKit to save your workout sessions, including exercise minutes and calories burned, so you can track your progress in the Health and Activity apps."

3. **NSUserTrackingUsageDescription**
   - "We use this to show relevant ads and support free features."

---

## 📝 Step-by-Step App Store Connect Entry (EXACT CHECKBOXES)

### When Filling Out Privacy Questionnaire:

---

### 1. **Health & Fitness Data**

**Select these checkboxes:**
- ✅ **App Functionality**
- ❌ Third-Party Advertising
- ❌ Developer's Advertising or Marketing
- ❌ Analytics
- ❌ Product Personalization
- ❌ Other Purposes

**Additional Settings:**
- Linked to User: ✅ **Yes**
- Used to Track: ❌ **No**

**Description to enter:**
"We collect workout data (duration, exercises completed, calories burned) to track your fitness progress and sync with Apple Health (with your permission)."

---

### 2. **Location Data** (Coarse Location)

**Select these checkboxes:**
- ❌ App Functionality
- ✅ **Third-Party Advertising**
- ❌ Developer's Advertising or Marketing
- ✅ **Analytics**
- ❌ Product Personalization
- ❌ Other Purposes

**Additional Settings:**
- Linked to User: ✅ **Yes**
- Used to Track: ❌ **No**

**Description to enter:**
"Coarse location data (city-level) is collected by Google Mobile Ads to show relevant advertisements."

---

### 3. **Device ID**

**Select these checkboxes:**
- ❌ App Functionality
- ✅ **Third-Party Advertising**
- ❌ Developer's Advertising or Marketing
- ✅ **Analytics**
- ❌ Product Personalization
- ❌ Other Purposes

**Additional Settings:**
- Linked to User: ✅ **Yes**
- Used to Track: ✅ **Yes**

**Description to enter:**
"Device identifier is collected by Google Mobile Ads for advertising and analytics purposes."

---

### 4. **Product Interaction**

**Select these checkboxes:**
- ❌ App Functionality
- ✅ **Third-Party Advertising**
- ❌ Developer's Advertising or Marketing
- ✅ **Analytics**
- ❌ Product Personalization
- ❌ Other Purposes

**Additional Settings:**
- Linked to User: ✅ **Yes**
- Used to Track: ❌ **No**

**Description to enter:**
"We collect information about how you interact with ads (views, clicks) for analytics and advertising purposes."

---

### 5. **Advertising Data**

**Select these checkboxes:**
- ❌ App Functionality
- ✅ **Third-Party Advertising**
- ❌ Developer's Advertising or Marketing
- ✅ **Analytics**
- ❌ Product Personalization
- ❌ Other Purposes

**Additional Settings:**
- Linked to User: ✅ **Yes**
- Used to Track: ❌ **No**

**Description to enter:**
"Advertising data is collected by Google Mobile Ads to show relevant advertisements."

---

### 6. **Performance Data**

**Select these checkboxes:**
- ❌ App Functionality
- ✅ **Third-Party Advertising**
- ❌ Developer's Advertising or Marketing
- ✅ **Analytics**
- ❌ Product Personalization
- ❌ Other Purposes

**Additional Settings:**
- Linked to User: ❌ **No**
- Used to Track: ❌ **No**

**Description to enter:**
"App performance metrics are collected to improve app functionality and for advertising analytics."

---

### 7. **Crash Data**

**Select these checkboxes:**
- ❌ App Functionality
- ❌ Third-Party Advertising
- ❌ Developer's Advertising or Marketing
- ✅ **Analytics**
- ❌ Product Personalization
- ❌ Other Purposes

**Additional Settings:**
- Linked to User: ❌ **No**
- Used to Track: ❌ **No**

**Description to enter:**
"Crash reports are collected to identify and fix bugs in the app."

---

### 8. **Other Diagnostic Data**

**Select these checkboxes:**
- ❌ App Functionality
- ✅ **Third-Party Advertising**
- ❌ Developer's Advertising or Marketing
- ✅ **Analytics**
- ❌ Product Personalization
- ❌ Other Purposes

**Additional Settings:**
- Linked to User: ❌ **No**
- Used to Track: ❌ **No**

**Description to enter:**
"Diagnostic data is collected by Google Mobile Ads for analytics and advertising optimization."

---

## ⚠️ Important Notes

1. **Third-Party SDKs:** Most data collection comes from Google Mobile Ads (AdMob). This is normal and expected for apps with advertising.

2. **HealthKit Data:** HealthKit data is stored by Apple Health, not by your app. You only read/write data with user permission.

3. **Local Storage:** Data stored locally on the device (UserDefaults) typically doesn't need to be declared unless you sync it to a server.

4. **Tracking:** The app uses App Tracking Transparency (ATT) for tracking. Users can opt out.

5. **User Control:** Users can:
   - Revoke HealthKit permissions anytime
   - Opt out of ad tracking in iOS Settings
   - Delete all app data from within the app

---

## 🔗 Related Documentation

- Privacy Policy: `AppStore/PrivacyPolicy.md`
- HealthKit Setup: `APPLE_WATCH_SETUP.md`
- AdMob Setup: `ADMOB_SETUP_VERIFICATION.md`

---

**Last Updated:** 2024  
**Next Review:** After any major feature additions or third-party SDK changes

