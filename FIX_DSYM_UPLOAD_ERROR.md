# 🔧 Fix dSYM Upload Errors for GoogleMobileAds and UserMessagingPlatform

**Date:** 2024-12-19  
**Issue:** Missing dSYM files during App Store upload

---

## 🐛 Error Messages

```
Upload Symbols Failed
The archive did not include a dSYM for the GoogleMobileAds.framework with the UUIDs [C26D297E-3D94-335D-A241-CC73268DDF48].

Upload Symbols Failed
The archive did not include a dSYM for the UserMessagingPlatform.framework with the UUIDs [CEAA07C0-65E0-3F48-8E51-CA33FB24D298].
```

---

## ✅ Solution: Update Build Script Phase

The build script phase exists but needs to be improved to handle archive builds correctly. The script needs to:

1. Run during archive builds (not just regular builds)
2. Generate dSYMs for the correct architectures
3. Place dSYMs in the correct location for archives
4. Match the UUIDs that Apple expects

---

## 🔧 Step-by-Step Fix

### Step 1: Verify Build Script Phase Order

In Xcode:
1. Open your project
2. Select the **Ritual7** target
3. Go to **Build Phases** tab
4. Find the **"Copy dSYM Files"** script phase
5. **Important:** It should be AFTER "Copy Bundle Resources" and BEFORE "Code Sign"

If it's not in the right position:
- Drag it to the correct position
- Or create a new one if missing

### Step 2: Update Build Settings

1. Select **Ritual7** target
2. Go to **Build Settings**
3. Search for **"Debug Information Format"**
4. Set **Release** configuration to: **"DWARF with dSYM File"**
5. Search for **"dSYM File Should Accompany Product"**
6. Set **Release** configuration to: **"Yes"**

### Step 3: Clean and Rebuild

1. **Clean Build Folder**: Product → Clean Build Folder (Shift+Cmd+K)
2. **Delete Derived Data**: 
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Ritual7-*
   ```
3. **Rebuild Archive**: Product → Archive

---

## 📋 Alternative: Manual dSYM Generation

If the build script still doesn't work, you can manually generate dSYMs after archiving:

### Option 1: Use Xcode Organizer

1. After archiving, open **Window → Organizer**
2. Right-click on your archive
3. Select **"Show in Finder"**
4. Navigate to: `YourArchive.xcarchive/dSYMs/`
5. Check if dSYM files exist

### Option 2: Generate Manually from Archive

After archiving, run this script:

```bash
#!/bin/bash

ARCHIVE_PATH="path/to/Ritual7.xcarchive"
DSYM_DIR="$ARCHIVE_PATH/dSYMs"

# Find frameworks in archive
FRAMEWORKS_DIR="$ARCHIVE_PATH/Products/Applications/Ritual7.app/Frameworks"

# Generate GoogleMobileAds dSYM
if [ -d "$FRAMEWORKS_DIR/GoogleMobileAds.framework" ]; then
    dsymutil "$FRAMEWORKS_DIR/GoogleMobileAds.framework/GoogleMobileAds" \
        -o "$DSYM_DIR/GoogleMobileAds.framework.dSYM"
fi

# Generate UserMessagingPlatform dSYM
if [ -d "$FRAMEWORKS_DIR/UserMessagingPlatform.framework" ]; then
    dsymutil "$FRAMEWORKS_DIR/UserMessagingPlatform.framework/UserMessagingPlatform" \
        -o "$DSYM_DIR/UserMessagingPlatform.framework.dSYM"
fi
```

---

## 🔍 Verify dSYM Files

After archiving, verify the dSYM files exist and have correct UUIDs:

```bash
# Navigate to archive
cd ~/Library/Developer/Xcode/Archives/$(date +%Y-%m-%d)/Ritual7*.xcarchive/dSYMs

# Check GoogleMobileAds UUID
dwarfdump --uuid GoogleMobileAds.framework.dSYM
# Should include: C26D297E-3D94-335D-A241-CC73268DDF48

# Check UserMessagingPlatform UUID
dwarfdump --uuid UserMessagingPlatform.framework.dSYM
# Should include: CEAA07C0-65E0-3F48-8E51-CA33FB24D298
```

---

## 🚨 Common Issues

### Issue 1: Script Not Running During Archive
**Solution:** Ensure `runOnlyForDeploymentPostprocessing = 0` (not 1)

### Issue 2: Wrong Framework Path
**Solution:** Frameworks might be in different locations:
- `PackageFrameworks/` (SPM)
- `Frameworks/` (embedded)
- Check build logs to see actual path

### Issue 3: Architecture Mismatch
**Solution:** Ensure you're building for correct architecture (arm64 for App Store)

### Issue 4: dSYM Not in Archive
**Solution:** dSYMs must be in `dSYMs/` folder of archive, not just generated

---

## ✅ Verification Checklist

Before uploading to App Store Connect:

- [ ] Build Settings: Debug Information Format = "DWARF with dSYM File" (Release)
- [ ] Build Settings: dSYM File Should Accompany Product = "Yes" (Release)
- [ ] Build Script Phase exists and is in correct position
- [ ] Archive includes dSYMs folder
- [ ] GoogleMobileAds.framework.dSYM exists in archive
- [ ] UserMessagingPlatform.framework.dSYM exists in archive
- [ ] dSYM UUIDs match expected values

---

## 📝 Next Steps

1. **Update build script** (if needed)
2. **Clean build folder**
3. **Create new archive**
4. **Verify dSYM files** exist
5. **Upload to App Store Connect**
6. **Check upload logs** for dSYM validation

---

**Note:** The build script phase in your project should handle this automatically. If errors persist, check the build logs for the script output to see what's happening.

