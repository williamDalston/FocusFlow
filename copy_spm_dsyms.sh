#!/bin/bash

# Copy dSYM files for Swift Package Manager frameworks
# This ensures GoogleMobileAds and UserMessagingPlatform dSYM files are included in archive

set -e

# Find dSYM files in common locations
DSYM_DEST="${DWARF_DSYM_FOLDER_PATH:-${BUILT_PRODUCTS_DIR}}"

# Function to copy dSYM if it exists
copy_dsym() {
    local dSYM_PATH="$1"
    if [ -d "$dSYM_PATH" ]; then
        echo "Copying dSYM: $dSYM_PATH to $DSYM_DEST"
        cp -R "$dSYM_PATH" "$DSYM_DEST/" || true
    fi
}

# Search for framework dSYM files in built products
find "${BUILT_PRODUCTS_DIR}" -name "GoogleMobileAds.dSYM" -o -name "UserMessagingPlatform.dSYM" 2>/dev/null | while read dSYM_PATH; do
    copy_dsym "$dSYM_PATH"
done

# Also check in Frameworks directory
if [ -d "${BUILT_PRODUCTS_DIR}/Frameworks" ]; then
    find "${BUILT_PRODUCTS_DIR}/Frameworks" -name "*.dSYM" -type d 2>/dev/null | while read dSYM_PATH; do
        FRAMEWORK_NAME=$(basename "$dSYM_PATH" .dSYM)
        if [[ "$FRAMEWORK_NAME" == "GoogleMobileAds" ]] || [[ "$FRAMEWORK_NAME" == "UserMessagingPlatform" ]]; then
            copy_dsym "$dSYM_PATH"
        fi
    done
fi

# Search in Swift Package Manager build directory
SPM_BUILD_DIR="${BUILD_ROOT}/../SourcePackages/checkouts"
if [ -d "$SPM_BUILD_DIR" ]; then
    find "$SPM_BUILD_DIR" -name "GoogleMobileAds.dSYM" -o -name "UserMessagingPlatform.dSYM" 2>/dev/null | while read dSYM_PATH; do
        copy_dsym "$dSYM_PATH"
    done
fi

# Search in DerivedData for SPM frameworks
DERIVED_DATA="${BUILD_ROOT}/../.."
if [ -d "$DERIVED_DATA" ]; then
    find "$DERIVED_DATA" -path "*/SourcePackages/artifacts/*" -name "GoogleMobileAds.dSYM" -o -path "*/SourcePackages/artifacts/*" -name "UserMessagingPlatform.dSYM" 2>/dev/null | while read dSYM_PATH; do
        copy_dsym "$dSYM_PATH"
    done
fi

echo "dSYM copy script completed"


