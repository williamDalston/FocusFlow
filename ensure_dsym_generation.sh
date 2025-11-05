#!/bin/bash

# Build Phase Script to ensure DSYM generation for Swift Package Manager frameworks
# Add this as a "Run Script" build phase in Xcode

echo "🔧 Ensuring DSYM generation for Swift Package Manager frameworks..."

# Set environment variables to force DSYM generation
export DEBUG_INFORMATION_FORMAT=dwarf-with-dsym
export DWARF_DSYM_FILE_SHOULD_ACCOMPANY_PRODUCT=YES

# Find all .framework files in the build directory
FRAMEWORK_DIR="${BUILT_PRODUCTS_DIR}/PackageFrameworks"
if [ -d "$FRAMEWORK_DIR" ]; then
    echo "📁 Found PackageFrameworks directory: $FRAMEWORK_DIR"
    
    # Check for Google Mobile Ads framework
    if [ -d "$FRAMEWORK_DIR/GoogleMobileAds.framework" ]; then
        echo "✅ Found GoogleMobileAds.framework"
        # Ensure DSYM is generated
        dsymutil "$FRAMEWORK_DIR/GoogleMobileAds.framework/GoogleMobileAds" -o "${DWARF_DSYM_FOLDER_PATH}/GoogleMobileAds.framework.dSYM" 2>/dev/null || true
    fi
    
    # Check for User Messaging Platform framework
    if [ -d "$FRAMEWORK_DIR/UserMessagingPlatform.framework" ]; then
        echo "✅ Found UserMessagingPlatform.framework"
        # Ensure DSYM is generated
        dsymutil "$FRAMEWORK_DIR/UserMessagingPlatform.framework/UserMessagingPlatform" -o "${DWARF_DSYM_FOLDER_PATH}/UserMessagingPlatform.framework.dSYM" 2>/dev/null || true
    fi
else
    echo "⚠️ PackageFrameworks directory not found"
fi

echo "✅ DSYM generation check complete"
