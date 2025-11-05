# Fix Archive Validation Issues

## ✅ Fixed: Interface Orientations

The Info.plist has been updated to include all required interface orientations:
- ✅ `UISupportedInterfaceOrientations` (all orientations)
- ✅ `UISupportedInterfaceOrientations~ipad` (all orientations)
- ✅ `UISupportedInterfaceOrientations~iphone` (portrait and landscape)

## 🔧 Fix dSYM Issues for GoogleMobileAds and UserMessagingPlatform

The dSYM errors occur because third-party frameworks from Swift Package Manager need their dSYM files included in the archive. Here's how to fix it:

### Option 1: Enable dSYM Generation in Xcode (Recommended)

1. **Open Xcode project**
2. **Select your project** in the navigator
3. **Select the Ritual7 target**
4. **Go to Build Settings tab**
5. **Search for "Debug Information Format"**
6. **For Release configuration:**
   - Set `DEBUG_INFORMATION_FORMAT` to `dwarf-with-dsym`
   - This should already be set, but verify it
7. **Search for "Strip Debug Symbols During Copy"**
   - Set `COPY_PHASE_STRIP` to `NO` (should already be set)
8. **Search for "Strip Linked Product"**
   - Set `STRIP_INSTALLED_PRODUCT` to `NO` for Release builds

### Option 2: Add Build Phase to Copy dSYM Files

1. **Select your project** in Xcode
2. **Select the Ritual7 target**
3. **Go to Build Phases tab**
4. **Click "+" and select "New Run Script Phase"**
5. **Name it "Copy dSYM Files"**
6. **Add this script:**

```bash
# Copy dSYM files for all frameworks
if [ "${CONFIGURATION}" == "Release" ]; then
    find "${BUILT_PRODUCTS_DIR}" -name "*.dSYM" -type d -exec cp -R {} "${ARCHIVE_DSYMS_PATH}/" \;
fi
```

7. **Move this script phase ABOVE the "Embed Frameworks" phase**

### Option 3: Manual Archive Settings

When creating an archive:
1. **Product → Archive**
2. **After archive is created, click "Distribute App"**
3. **Select "App Store Connect"**
4. **Select "Upload"**
5. **In the options, ensure "Include bitcode" is checked (if applicable)**
6. **Ensure "Include symbols for debugging" is checked**

### Option 4: Verify Package Dependencies

1. **In Xcode, go to File → Packages → Resolve Package Versions**
2. **Clean build folder** (Product → Clean Build Folder, ⇧⌘K)
3. **Rebuild and archive again**

## 🔍 Verification Steps

After making changes:
1. **Clean Build Folder** (Product → Clean Build Folder, ⇧⌘K)
2. **Product → Archive**
3. **Wait for archive to complete**
4. **Click "Distribute App" → "App Store Connect" → "Upload"**
5. **Check that validation passes**

## 📝 Notes

- The dSYM errors are warnings and won't prevent upload, but they should be fixed for proper crash reporting
- GoogleMobileAds and UserMessagingPlatform are Swift Package Manager dependencies
- Their dSYM files should be automatically included if build settings are correct
- If issues persist, you may need to contact Google AdMob support or check their documentation


