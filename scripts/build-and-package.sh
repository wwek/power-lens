#!/bin/bash
set -euo pipefail

# Build Power Lens, sign, notarize, and package as ZIP + DMG
# Usage: ./scripts/build-and-package.sh [version]
# Prerequisites: Developer ID Application certificate + app-specific password in Keychain

PROJECT="PowerLens.xcodeproj"
SCHEME="Power Lens"
APP_NAME="Power Lens"
CONFIG="Release"
PLIST="PowerLens/Resources/Info.plist"
BUNDLE_ID="com.powerlens.app"

# Signing identity
# Signing — read from local xcconfig (gitignored)
SIGN_IDENTITY=""
TEAM_ID=""
XCCONFIG="PowerLens.xcconfig"
if [ -f "$XCCONFIG" ]; then
    SIGN_IDENTITY=$(grep CODE_SIGN_IDENTITY "$XCCONFIG" | head -1 | sed 's/.*= *"//;s/";$//')
    TEAM_ID=$(grep DEVELOPMENT_TEAM "$XCCONFIG" | head -1 | sed 's/.*= *//;s/ *;.*//')
fi

# Determine version
if [ -n "${1:-}" ]; then
    VERSION="$1"
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "$PLIST"
else
    VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$PLIST" 2>/dev/null || echo "0.1.0")
fi

# Auto-increment build number
BUILD_NUM=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$PLIST" 2>/dev/null || echo "0")
BUILD_NUM=$((BUILD_NUM + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUM}" "$PLIST"

echo "==> Building ${APP_NAME} v${VERSION} (${BUILD_NUM})..."

DERIVED_DATA="build"
xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -configuration "${CONFIG}" \
    -derivedDataPath "${DERIVED_DATA}" \
    CODE_SIGN_IDENTITY="${SIGN_IDENTITY}" \
    CODE_SIGN_STYLE=Manual \
    DEVELOPMENT_TEAM="${TEAM_ID}" \
    build 2>&1 | tail -1

APP_PATH="${DERIVED_DATA}/Build/Products/${CONFIG}/${APP_NAME}.app"
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: ${APP_NAME}.app not found" >&2
    exit 1
fi

# Re-sign with hardened runtime (required for notarization)
if [ -n "${SIGN_IDENTITY}" ]; then
    echo "==> Re-signing with hardened runtime..."
    codesign --deep --force --options runtime --timestamp \
        --sign "${SIGN_IDENTITY}" \
        "${APP_PATH}" 2>&1 && echo "    Hardened runtime signed ✓"
fi

# Verify signature
echo "==> Verifying signature..."
codesign --verify --deep --strict "${APP_PATH}" 2>&1 && echo "    Signature valid ✓" || {
    echo "    Signature INVALID" >&2
    exit 1
}

# Notarize
NOTARIZE_PROFILE="${NOTARIZE_PROFILE:-power-lens-notary}"
if [ -n "${NOTARIZE_PROFILE}" ]; then
    echo "==> Notarizing..."
    # Create ZIP for notarization
    NOTARIZE_ZIP=$(mktemp /tmp/powerlens-XXXXXX.zip)
    ditto -c -k --keepParent "${APP_PATH}" "${NOTARIZE_ZIP}"

    # Submit
    xcrun notarytool submit "${NOTARIZE_ZIP}" --keychain-profile "${NOTARIZE_PROFILE}" --wait 2>&1 | tail -5
    rm -f "${NOTARIZE_ZIP}"

    # Staple
    xcrun stapler staple "${APP_PATH}" 2>&1 && echo "    Notarization stapled ✓"
else
    echo "==> Skipping notarization (set NOTARIZE_PROFILE to enable)"
fi

# Package
ZIP_NAME="Power_Lens_v${VERSION}.zip"
DMG_NAME="Power_Lens_v${VERSION}.dmg"
VOLUME_NAME="Power Lens"

echo "==> Packaging..."

STAGING_DIR=$(mktemp -d)
trap "rm -rf '${STAGING_DIR}'" EXIT

cp -R "${APP_PATH}" "${STAGING_DIR}/"

# ZIP
echo "    Creating ZIP..."
rm -f "${ZIP_NAME}"
cd "${STAGING_DIR}"
zip -r -q "${OLDPWD}/${ZIP_NAME}" "${APP_NAME}.app"
cd "${OLDPWD}"

# DMG
echo "    Creating DMG..."
ln -s /Applications "${STAGING_DIR}/Applications"
rm -f "${DMG_NAME}"
hdiutil create \
    -volname "${VOLUME_NAME}" \
    -srcfolder "${STAGING_DIR}" \
    -ov \
    -format UDZO \
    -imagekey zlib-level=9 \
    "${DMG_NAME}" \
    >/dev/null 2>&1

ZIP_SIZE=$(du -h "${ZIP_NAME}" | cut -f1)
DMG_SIZE=$(du -h "${DMG_NAME}" | cut -f1)
echo ""
echo "==> Done!"
echo "    ${ZIP_NAME} (${ZIP_SIZE})"
echo "    ${DMG_NAME} (${DMG_SIZE})"
echo ""
echo "Upload to GitHub with:"
echo "    gh release create v${VERSION} '${ZIP_NAME}' '${DMG_NAME}' --title '${APP_NAME} v${VERSION}'"
