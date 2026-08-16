#!/bin/bash
# Builds Kumone with SwiftPM and wraps the product into a .app bundle.
# Usage: Scripts/build-app.sh [debug|release]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

CONF="${1:-debug}"
APP_NAME="Kumone"
BUNDLE_ID="im.missuo.Kumone"
MARKETING_VERSION="0.1.0"
BUILD_NUMBER="1"
[ -f "$ROOT/version.env" ] && source "$ROOT/version.env"

BUILD_DIR="$ROOT/.build/app"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

swift build -c "$CONF" --product "$APP_NAME"
BIN_PATH="$(swift build -c "$CONF" --show-bin-path)"

rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"

cp "$BIN_PATH/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# SwiftPM resource bundles (if any)
find "$BIN_PATH" -maxdepth 1 -name '*.bundle' -not -name '*Tests*' -print0 |
  while IFS= read -r -d '' bundle; do
    cp -R "$bundle" "$APP_BUNDLE/Contents/Resources/"
  done

# App icon: compile the Icon Composer bundle into Assets.car and keep the
# source bundle alongside for Liquid Glass light/dark rendering on macOS 26.
ICON_SOURCE="$ROOT/AppIcon.icon"
if [ -d "$ICON_SOURCE" ]; then
  cp -R "$ICON_SOURCE" "$APP_BUNDLE/Contents/Resources/AppIcon.icon"
  xcrun actool "$ICON_SOURCE" \
    --compile "$APP_BUNDLE/Contents/Resources" \
    --notices --warnings --errors \
    --output-partial-info-plist "$BUILD_DIR/icon-partial.plist" \
    --app-icon AppIcon \
    --enable-on-demand-resources NO \
    --development-region zh-Hans \
    --target-device mac \
    --minimum-deployment-target 15.0 \
    --platform macosx >/dev/null
  if [ ! -f "$APP_BUNDLE/Contents/Resources/Assets.car" ]; then
    echo "ERROR: actool did not produce Assets.car" >&2
    exit 1
  fi
fi

printf 'APPL????' > "$APP_BUNDLE/Contents/PkgInfo"

GIT_COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key><string>zh-Hans</string>
    <key>CFBundleExecutable</key><string>$APP_NAME</string>
    <key>CFBundleIconName</key><string>AppIcon</string>
    <key>CFBundleIcons</key>
    <dict>
        <key>CFBundlePrimaryIcon</key>
        <dict>
            <key>CFBundleIconName</key><string>AppIcon</string>
        </dict>
    </dict>
    <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>CFBundleName</key><string>$APP_NAME</string>
    <key>CFBundleDisplayName</key><string>$APP_NAME</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$MARKETING_VERSION</string>
    <key>CFBundleVersion</key><string>$BUILD_NUMBER</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.music</string>
    <key>LSMinimumSystemVersion</key><string>15.0</string>
    <key>NSHumanReadableCopyright</key><string>© 2026 missuo</string>
    <key>NSPrincipalClass</key><string>NSApplication</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key><true/>
    </dict>
    <key>KumoneGitCommit</key><string>$GIT_COMMIT</string>
</dict>
</plist>
PLIST

xattr -cr "$APP_BUNDLE" 2>/dev/null || true
codesign --force --sign - "$APP_BUNDLE" >/dev/null 2>&1 || true

echo "Built $APP_BUNDLE ($CONF, $GIT_COMMIT)"
