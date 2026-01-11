#!/bin/sh

# ci_post_xcodebuild.sh
# DrinkSomeWater
#
# Xcode Cloud post-xcodebuild script for uploading dSYMs to Firebase Crashlytics
# Reference: https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports?platform=ios

set -e

echo "=== Xcode Cloud Post Xcodebuild Script ==="

# Only run when archive is created
if [[ -z "$CI_ARCHIVE_PATH" ]]; then
    echo "No archive path found. Skipping dSYM upload."
    exit 0
fi

echo "Found valid archive path: $CI_ARCHIVE_PATH"
echo "Derived data path: $CI_DERIVED_DATA_PATH"
echo "Scheme: $CI_XCODE_SCHEME"

# Define paths
SCRIPT_DIR=$(dirname "$(realpath "$0")")
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
GOOGLE_SERVICE_INFO_PLIST="$PROJECT_ROOT/DrinkSomeWater/Resources/GoogleService-Info.plist"
DSYM_PATH="$CI_ARCHIVE_PATH/dSYMs"

# Find upload-symbols script from SPM checkouts
# In Xcode Cloud, SPM packages are stored in DerivedData/SourcePackages/checkouts
UPLOAD_SYMBOLS_PATH="$CI_DERIVED_DATA_PATH/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"

echo "Looking for upload-symbols at: $UPLOAD_SYMBOLS_PATH"

# Check if upload-symbols script exists
if [[ ! -f "$UPLOAD_SYMBOLS_PATH" ]]; then
    echo "Warning: upload-symbols script not found at expected path."
    echo "Searching for upload-symbols in SourcePackages..."

    # Try to find it
    FOUND_PATH=$(find "$CI_DERIVED_DATA_PATH/SourcePackages" -name "upload-symbols" -type f 2>/dev/null | head -n 1)

    if [[ -n "$FOUND_PATH" ]]; then
        UPLOAD_SYMBOLS_PATH="$FOUND_PATH"
        echo "Found upload-symbols at: $UPLOAD_SYMBOLS_PATH"
    else
        echo "Error: Could not find upload-symbols script."
        echo "Please ensure Firebase Crashlytics is properly integrated via SPM."
        exit 1
    fi
fi

# Check if GoogleService-Info.plist exists
if [[ ! -f "$GOOGLE_SERVICE_INFO_PLIST" ]]; then
    echo "Error: GoogleService-Info.plist not found at: $GOOGLE_SERVICE_INFO_PLIST"
    exit 1
fi

echo "GoogleService-Info.plist found at: $GOOGLE_SERVICE_INFO_PLIST"

# Check if dSYMs directory exists
if [[ ! -d "$DSYM_PATH" ]]; then
    echo "Warning: dSYMs directory not found at: $DSYM_PATH"
    exit 0
fi

echo "dSYMs directory found at: $DSYM_PATH"

# Make upload-symbols executable
chmod +x "$UPLOAD_SYMBOLS_PATH"

# Upload dSYMs to Firebase Crashlytics
echo "Uploading dSYMs to Firebase Crashlytics..."

"$UPLOAD_SYMBOLS_PATH" \
    -gsp "$GOOGLE_SERVICE_INFO_PLIST" \
    -p ios \
    "$DSYM_PATH"

echo "=== dSYM Upload Complete ==="
