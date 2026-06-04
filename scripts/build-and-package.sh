#!/bin/bash
set -euo pipefail

# Build Power Lens and package as ZIP + DMG
# Usage: ./scripts/build-and-package.sh [version]

PROJECT="PowerLens.xcodeproj"
SCHEME="Power Lens"
APP_NAME="Power Lens"
CONFIG="Release"

# Determine version
if [ -n "${1:-}" ]; then
    VERSION="$1"
else
    VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" \
        "PowerLens/Resources/Info.plist" 2>/dev/null || echo "0.1.0")
fi

ZIP_NAME="Power_Lens_v${VERSION}.zip"
DMG_NAME="Power_Lens_v${VERSION}.dmg"
VOLUME_NAME="Power Lens"

echo "==> Building ${APP_NAME} v${VERSION}..."

xcodebuild -project "${PROJECT}" -scheme "${SCHEME}" -configuration "${CONFIG}" build \
    2>&1 | tail -1

# Find the built app
DERIVED=$(ls -d ~/Library/Developer/Xcode/DerivedData/PowerLens-*/Build/Products/${CONFIG}/ 2>/dev/null | head -1)
if [ -z "${DERIVED}" ] || [ ! -d "${DERIVED}${APP_NAME}.app" ]; then
    echo "Error: ${APP_NAME}.app not found in DerivedData" >&2
    exit 1
fi

APP_PATH="${DERIVED}${APP_NAME}.app"
echo "    App: ${APP_PATH}"

echo "==> Packaging..."

STAGING_DIR=$(mktemp -d)
trap "rm -rf '${STAGING_DIR}'" EXIT

cp -R "${APP_PATH}" "${STAGING_DIR}/"

# Create ZIP
echo "    Creating ZIP..."
rm -f "${ZIP_NAME}"
cd "${STAGING_DIR}"
zip -r -q "${OLDPWD}/${ZIP_NAME}" "${APP_NAME}.app"
cd "${OLDPWD}"

# Create DMG
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
