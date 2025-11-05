#!/bin/bash

# Script to build archive with proper DSYM generation for App Store submission
# This fixes the Google Mobile Ads and User Messaging Platform DSYM issue

echo "🚀 Building 7-Minute Workout v1.2 for App Store submission..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild -project Ritual7.xcodeproj \
    -scheme Ritual7 \
    clean

# Build archive with DSYM generation
echo "📦 Building archive with DSYM generation..."
xcodebuild -project Ritual7.xcodeproj \
    -scheme Ritual7 \
    -configuration Release \
    -destination generic/platform=iOS \
    -archivePath ./Ritual7.xcarchive \
    DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
    DWARF_DSYM_FILE_SHOULD_ACCOMPANY_PRODUCT=YES \
    archive

# Verify DSYM files were created
echo "🔍 Verifying DSYM files..."
if [ -d "./Ritual7.xcarchive/dSYMs" ]; then
    echo "✅ DSYM files found:"
    ls -la "./Ritual7.xcarchive/dSYMs/"
else
    echo "❌ No DSYM files found!"
    exit 1
fi

# Check for Google Mobile Ads DSYM
if [ -f "./Ritual7.xcarchive/dSYMs/GoogleMobileAds.framework.dSYM" ]; then
    echo "✅ GoogleMobileAds DSYM found"
else
    echo "⚠️ GoogleMobileAds DSYM not found - this may cause App Store rejection"
fi

# Check for User Messaging Platform DSYM
if [ -f "./Ritual7.xcarchive/dSYMs/UserMessagingPlatform.framework.dSYM" ]; then
    echo "✅ UserMessagingPlatform DSYM found"
else
    echo "⚠️ UserMessagingPlatform DSYM not found - this may cause App Store rejection"
fi

echo "🎉 Archive build complete!"
echo "📁 Archive location: ./Ritual7.xcarchive"
echo "📤 Ready for App Store submission!"
