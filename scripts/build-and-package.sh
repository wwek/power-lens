#!/bin/bash
set -euo pipefail

# Build Power Lens and package as ZIP + DMG
# Usage: ./scripts/build-and-package.sh [version]
# Auto-increments CFBundleVersion on each build.

PROJECT="PowerLens.xcodeproj"
SCHEME="Power Lens"
APP_NAME="Power Lens"
CONFIG="Release"
PLIST="PowerLens/Resources/Info.plist"

# Determine version
if [ -n "${1:-}" ]; then
    VERSION="$1"
    # Update marketing version if specified
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "$PLIST"
else
    VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$PLIST" 2>/dev/null || echo "0.1.0")
fi

# Auto-increment build number
BUILD_NUM=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$PLIST" 2>/dev/null || echo "0")
BUILD_NUM=$((BUILD_NUM + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUM}" "$PLIST"

echo "==> Building ${APP_NAME} v${VERSION} (${BUILD_NUM})..."

# Build Release using cached SPM packages
DERIVED_DATA="build"
xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -configuration "${CONFIG}" \
    -derivedDataPath "${DERIVED_DATA}" build 2>&1 | tail -1

APP_PATH="${DERIVED_DATA}/Build/Products/${CONFIG}/${APP_NAME}.app"
if [ ! -d "${APP_PATH}" ]; then
    echo "Error: ${APP_NAME}.app not found" >&2
    exit 1
fi

echo "    App: ${APP_PATH}"

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
