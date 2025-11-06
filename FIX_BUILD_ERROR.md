# Fix Build Error: Multiple Commands Produce Info.plist

## Error
```
Multiple commands produce '/Users/williamalston/Library/Developer/Xcode/DerivedData/Ritual7-.../FocusFlow.app/Info.plist'

Target 'FocusFlow' (project 'Ritual7') has copy command from '/Users/williamalston/Desktop/cool_app/FocusFlow/Info.plist' to ...
Target 'FocusFlow' (project 'Ritual7') has process command with output ...
```

## Root Cause
The project uses `PBXFileSystemSynchronizedRootGroup` which automatically includes all files. When `GENERATE_INFOPLIST_FILE = NO` and `INFOPLIST_FILE` is set, Xcode tries to both:
1. Copy Info.plist as a resource (from synchronized group)
2. Process Info.plist based on INFOPLIST_FILE setting

This creates a conflict.

## Solution

### Option 1: Clean Derived Data (Already Done)
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### Option 2: Fix in Xcode (Recommended)
1. Open `FocusFlow.xcodeproj` in Xcode
2. Select the **FocusFlow** target
3. Go to **Build Phases** tab
4. Expand **Copy Bundle Resources**
5. If `Info.plist` is listed there, **remove it** (select and press Delete)
6. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
7. **Rebuild**: Product → Build (⌘B)

### Option 3: Verify Exception Configuration
The project file should have an exception that excludes Info.plist from the synchronized group. Verify it exists:

```xml
EF80DEAE2EBB7B4300D7E41B /* Exceptions for "FocusFlow" folder in "FocusFlow" target */ = {
    isa = PBXFileSystemSynchronizedBuildFileExceptionSet;
    membershipExceptions = (
        Info.plist,
    );
    target = EF9A2EB62E78B7390047B4FD /* FocusFlow */;
};
```

If this exception is missing or not working, use Option 2 above.

## Verification
After fixing:
1. Clean build folder (⇧⌘K)
2. Build project (⌘B)
3. Should build successfully without Info.plist conflict

## Notes
- The project name showing as "Ritual7" in the error is from cached derived data
- After cleaning derived data, it should show "FocusFlow" correctly
- Info.plist should NOT be in Copy Bundle Resources when using GENERATE_INFOPLIST_FILE = NO

