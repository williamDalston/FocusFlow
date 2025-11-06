# FocusFlow Rename Instructions

## Overview
This document provides instructions for completing the rename from "Ritual7" to "FocusFlow" throughout the codebase.

## ✅ Completed Changes

### Code References
- ✅ `Ritual7App` → `FocusFlowApp` (main app struct)
- ✅ `Ritual7WatchApp` → `FocusFlowWatchApp` (watch app struct)
- ✅ Bundle identifiers updated in code: `com.williamalston.FocusFlow.*`
- ✅ Activity types updated: `com.williamalston.FocusFlow.startFocus`, etc.
- ✅ All Swift file references to "Ritual7" updated to "FocusFlow"
- ✅ Info.plist files updated
- ✅ Project.pbxproj bundle identifiers updated

### Files Updated
- ✅ `Ritual7/Ritual7App.swift` → `FocusFlowApp` struct name
- ✅ `Ritual7Watch/Ritual7WatchApp.swift` → `FocusFlowWatchApp` struct name
- ✅ `Ritual7/System/AppConstants.swift` → Bundle identifiers
- ✅ `Ritual7/Info.plist` → Activity types
- ✅ `Ritual7Watch/Info.plist` → Bundle identifiers
- ✅ `Ritual7/AppDelegate.swift` → Shortcut type
- ✅ `Ritual7/SettingsView.swift` → Text references
- ✅ `Ritual7/Notifications/NotificationManager.swift` → Notification title
- ✅ `Ritual7/Motivation/MotivationalMessageManager.swift` → Message references
- ✅ `Ritual7/Widgets/WorkoutWidget.swift` → Widget name
- ✅ `Ritual7/Shortcuts/WorkoutShortcuts.swift` → Activity title
- ✅ `Ritual7/Health/HealthKitManager.swift` → Metadata
- ✅ `Ritual7/UI/ThemeStore.swift` → File header comment
- ✅ `Ritual7.xcodeproj/project.pbxproj` → All bundle identifiers and target names

## ⚠️ Manual Steps Required

### 1. Rename Directories
You need to rename the following directories in Finder or Terminal:

```bash
cd /Users/williamalston/Desktop/cool_app

# Rename main app directory
mv Ritual7 FocusFlow

# Rename watch app directory
mv Ritual7Watch FocusFlowWatch

# Rename test directories
mv Ritual7Tests FocusFlowTests
mv Ritual7UITests FocusFlowUITests
```

### 2. Rename Xcode Project
```bash
# Rename the Xcode project
mv Ritual7.xcodeproj FocusFlow.xcodeproj
```

### 3. Rename Workspace (if needed)
```bash
# Rename workspace file
mv Ritual7.code-workspace FocusFlow.code-workspace
```

### 4. Rename Swift Files
After renaming directories, rename these files:

```bash
# In FocusFlow directory
mv FocusFlow/Ritual7App.swift FocusFlow/FocusFlowApp.swift

# In FocusFlowWatch directory
mv FocusFlowWatch/Ritual7WatchApp.swift FocusFlowWatch/FocusFlowWatchApp.swift
```

### 5. Update Xcode Project File Paths
After renaming directories, you'll need to:
1. Open the project in Xcode
2. Xcode should automatically detect the renamed directories
3. If files appear red, right-click and "Delete" then "Remove Reference" 
4. Re-add the files from the new directory locations

### 6. Update Bundle Identifiers in Xcode
1. Open `FocusFlow.xcodeproj` in Xcode
2. Select the project in the navigator
3. Select each target (FocusFlow, FocusFlowTests, FocusFlowUITests)
4. Go to "Signing & Capabilities"
5. Verify bundle identifiers are:
   - `williamalston.FocusFlow`
   - `williamalston.FocusFlowTests`
   - `williamalston.FocusFlowUITests`

### 7. Update Entitlements File (if exists)
If there's an entitlements file at `Ritual7/Ritual7.entitlements`, rename it to:
- `FocusFlow/FocusFlow.entitlements`

### 8. Update Documentation Files
Several markdown files still reference "Ritual7". These can be updated manually or left as historical references. The important code references have been updated.

## 📝 Bundle Identifier Summary

### Updated Bundle Identifiers:
- Main App: `williamalston.FocusFlow`
- Tests: `williamalston.FocusFlowTests`
- UI Tests: `williamalston.FocusFlowUITests`
- Watch: `williamalston.FocusFlowWatch` (if separate)

### Activity Types (Updated):
- `com.williamalston.FocusFlow.startFocus`
- `com.williamalston.FocusFlow.startDeepWork`
- `com.williamalston.FocusFlow.startQuickFocus`
- `com.williamalston.FocusFlow.showFocusStats`

## ⚠️ Important Notes

1. **App Store Connect**: If the app is already published, you'll need to create a new app listing with the new bundle identifier. The old bundle identifier cannot be changed.

2. **Provisioning Profiles**: You'll need to create new provisioning profiles with the new bundle identifier.

3. **TestFlight**: New builds will need to be uploaded with the new bundle identifier.

4. **Watch App**: The Watch app bundle identifier in Info.plist has been updated to reference the main app's new bundle identifier.

5. **UserDefaults Keys**: UserDefaults keys have NOT been changed (they still use "focus" and "workout" prefixes). This is intentional to maintain backward compatibility with existing user data.

## Verification Checklist

After completing the manual steps:
- [ ] All directories renamed
- [ ] Xcode project file renamed
- [ ] Swift file names updated
- [ ] Xcode project opens without errors
- [ ] All files visible in Xcode (no red files)
- [ ] App builds successfully
- [ ] Watch app builds successfully
- [ ] Tests run successfully
- [ ] Bundle identifiers verified in Xcode
- [ ] App runs on simulator/device

## Next Steps

1. Complete the manual directory/file renames
2. Open the project in Xcode
3. Verify everything builds
4. Test the app thoroughly
5. Update any remaining documentation as needed

