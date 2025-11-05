#!/bin/bash

# Script to fix DSYM generation for Swift Package Manager dependencies
# This ensures Google Mobile Ads and User Messaging Platform generate DSYMs

echo "🔧 Fixing DSYM generation for Swift Package Manager dependencies..."

# Build the project with DSYM generation enabled
echo "📦 Building project with DSYM generation..."
xcodebuild -project SevenMinuteWorkout.xcodeproj \
    -scheme SevenMinuteWorkout \
    -configuration Release \
    -destination generic/platform=iOS \
    DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
    DWARF_DSYM_FILE_SHOULD_ACCOMPANY_PRODUCT=YES \
    clean build

echo "✅ DSYM generation fix complete!"
echo "📁 DSYM files should now be generated for all frameworks"
