#!/bin/bash

# Improved dSYM generation script for Swift Package Manager frameworks
# This script generates dSYM files for GoogleMobileAds and UserMessagingPlatform
# during archive builds to satisfy App Store requirements

set -e  # Exit on error

echo "🔧 Starting dSYM generation for SPM frameworks..."

# Determine the correct dSYM destination path
# For archive builds, this should be DWARF_DSYM_FOLDER_PATH
# For regular builds, use BUILT_PRODUCTS_DIR
if [ -n "${DWARF_DSYM_FOLDER_PATH}" ]; then
    DSYM_DEST="${DWARF_DSYM_FOLDER_PATH}"
    echo "📁 Using archive dSYM folder: ${DSYM_DEST}"
else
    DSYM_DEST="${BUILT_PRODUCTS_DIR}"
    echo "📁 Using build products folder: ${DSYM_DEST}"
fi

# Ensure destination exists
mkdir -p "${DSYM_DEST}"

# Function to generate dSYM from framework binary
generate_dsym() {
    local FRAMEWORK_PATH="$1"
    local FRAMEWORK_NAME="$2"
    local BINARY_NAME="$3"
    local DSYM_OUTPUT="${DSYM_DEST}/${FRAMEWORK_NAME}.framework.dSYM"
    
    if [ ! -d "$FRAMEWORK_PATH" ]; then
        echo "⚠️  Framework directory not found: $FRAMEWORK_PATH"
        return 1
    fi
    
    local BINARY_PATH="${FRAMEWORK_PATH}/${BINARY_NAME}"
    if [ ! -f "$BINARY_PATH" ]; then
        echo "⚠️  Framework binary not found: $BINARY_PATH"
        return 1
    fi
    
    echo "📦 Generating dSYM for ${FRAMEWORK_NAME}..."
    echo "   Binary: $BINARY_PATH"
    echo "   Output: $DSYM_OUTPUT"
    
    # Remove existing dSYM if present
    if [ -d "$DSYM_OUTPUT" ]; then
        rm -rf "$DSYM_OUTPUT"
    fi
    
    # Generate dSYM using dsymutil
    if dsymutil "$BINARY_PATH" -o "$DSYM_OUTPUT" 2>&1; then
        echo "✅ Successfully generated ${FRAMEWORK_NAME}.framework.dSYM"
        
        # Verify UUIDs are present
        if [ -d "$DSYM_OUTPUT" ]; then
            echo "   UUIDs:"
            dwarfdump --uuid "$DSYM_OUTPUT" 2>/dev/null || echo "   (Could not read UUIDs)"
        fi
        return 0
    else
        echo "❌ Failed to generate dSYM for ${FRAMEWORK_NAME}"
        return 1
    fi
}

# Search for frameworks in common locations
FRAMEWORK_FOUND=0

# Location 1: PackageFrameworks (most common for SPM)
PACKAGE_FRAMEWORKS="${BUILT_PRODUCTS_DIR}/PackageFrameworks"
if [ -d "$PACKAGE_FRAMEWORKS" ]; then
    echo "📂 Checking PackageFrameworks: $PACKAGE_FRAMEWORKS"
    
    # GoogleMobileAds
    if [ -d "${PACKAGE_FRAMEWORKS}/GoogleMobileAds.framework" ]; then
        if generate_dsym "${PACKAGE_FRAMEWORKS}/GoogleMobileAds.framework" "GoogleMobileAds" "GoogleMobileAds"; then
            FRAMEWORK_FOUND=$((FRAMEWORK_FOUND + 1))
        fi
    fi
    
    # UserMessagingPlatform
    if [ -d "${PACKAGE_FRAMEWORKS}/UserMessagingPlatform.framework" ]; then
        if generate_dsym "${PACKAGE_FRAMEWORKS}/UserMessagingPlatform.framework" "UserMessagingPlatform" "UserMessagingPlatform"; then
            FRAMEWORK_FOUND=$((FRAMEWORK_FOUND + 1))
        fi
    fi
fi

# Location 2: Embedded Frameworks
EMBEDDED_FRAMEWORKS="${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app/Frameworks"
if [ -d "$EMBEDDED_FRAMEWORKS" ]; then
    echo "📂 Checking embedded frameworks: $EMBEDDED_FRAMEWORKS"
    
    # GoogleMobileAds
    if [ -d "${EMBEDDED_FRAMEWORKS}/GoogleMobileAds.framework" ]; then
        if generate_dsym "${EMBEDDED_FRAMEWORKS}/GoogleMobileAds.framework" "GoogleMobileAds" "GoogleMobileAds"; then
            FRAMEWORK_FOUND=$((FRAMEWORK_FOUND + 1))
        fi
    fi
    
    # UserMessagingPlatform
    if [ -d "${EMBEDDED_FRAMEWORKS}/UserMessagingPlatform.framework" ]; then
        if generate_dsym "${EMBEDDED_FRAMEWORKS}/UserMessagingPlatform.framework" "UserMessagingPlatform" "UserMessagingPlatform"; then
            FRAMEWORK_FOUND=$((FRAMEWORK_FOUND + 1))
        fi
    fi
fi

# Location 3: Frameworks directory
FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/Frameworks"
if [ -d "$FRAMEWORKS_DIR" ]; then
    echo "📂 Checking Frameworks: $FRAMEWORKS_DIR"
    
    # GoogleMobileAds
    if [ -d "${FRAMEWORKS_DIR}/GoogleMobileAds.framework" ]; then
        if generate_dsym "${FRAMEWORKS_DIR}/GoogleMobileAds.framework" "GoogleMobileAds" "GoogleMobileAds"; then
            FRAMEWORK_FOUND=$((FRAMEWORK_FOUND + 1))
        fi
    fi
    
    # UserMessagingPlatform
    if [ -d "${FRAMEWORKS_DIR}/UserMessagingPlatform.framework" ]; then
        if generate_dsym "${FRAMEWORKS_DIR}/UserMessagingPlatform.framework" "UserMessagingPlatform" "UserMessagingPlatform"; then
            FRAMEWORK_FOUND=$((FRAMEWORK_FOUND + 1))
        fi
    fi
fi

# Summary
echo ""
echo "=== dSYM Generation Summary ==="
if [ $FRAMEWORK_FOUND -ge 2 ]; then
    echo "✅ Successfully generated dSYM files for both frameworks"
    echo "   GoogleMobileAds.framework.dSYM"
    echo "   UserMessagingPlatform.framework.dSYM"
    exit 0
elif [ $FRAMEWORK_FOUND -eq 1 ]; then
    echo "⚠️  Generated dSYM for only 1 framework (expected 2)"
    exit 1
else
    echo "❌ No frameworks found or dSYM generation failed"
    echo "   Searched in:"
    echo "   - ${PACKAGE_FRAMEWORKS}"
    echo "   - ${EMBEDDED_FRAMEWORKS}"
    echo "   - ${FRAMEWORKS_DIR}"
    exit 1
fi

