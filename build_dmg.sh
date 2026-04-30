#!/bin/bash
set -e

# ============================================================
# 团子 DMG 打包脚本
# 用法: bash build_dmg.sh [app路径]
#
# 如果不传 app 路径，会自动从 Xcode 构建 Release 版本
# 输出: 桌面/团子安装包/团子.dmg
# ============================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[打包]${NC} $1"; }
warn()    { echo -e "${YELLOW}[警告]${NC} $1"; }
error()   { echo -e "${RED}[错误]${NC} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
OUTPUT_DIR="$HOME/Desktop/团子安装包"
DMG_NAME="团子"
VOL_NAME="团子"
APP_NAME="团子.app"

# ── 1. 获取 .app ────────────────────────────────────────────
if [ -n "$1" ] && [ -d "$1" ]; then
    APP_PATH="$1"
    info "使用指定的 app: $APP_PATH"
else
    info "正在构建 Release 版本..."
    xcodebuild -project "$PROJECT_DIR/团子.xcodeproj" \
        -scheme "团子" \
        -configuration Release \
        -derivedDataPath "$PROJECT_DIR/build" \
        ARCHS="x86_64 arm64" \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGN_IDENTITY="-" \
        CODE_SIGN_STYLE=Manual \
        DEVELOPMENT_TEAM="" \
        clean build 2>&1 | tail -5

    APP_PATH="$PROJECT_DIR/build/Build/Products/Release/$APP_NAME"
    if [ ! -d "$APP_PATH" ]; then
        error "构建失败，未找到 $APP_PATH"
    fi
    info "构建成功 ✓"
fi

# ── 2. 私签 ─────────────────────────────────────────────────
info "正在 ad-hoc 签名..."
codesign --force --deep --sign - "$APP_PATH"
info "签名完成 ✓"

# ── 3. 准备 DMG 内容 ────────────────────────────────────────
STAGING="$PROJECT_DIR/build/dmg_staging"
rm -rf "$STAGING"
mkdir -p "$STAGING"

cp -R "$APP_PATH" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

# 背景图（放在隐藏的 .background 目录）
BG_IMG="$SCRIPT_DIR/dmg_background.png"
if [ -f "$BG_IMG" ]; then
    mkdir -p "$STAGING/.background"
    cp "$BG_IMG" "$STAGING/.background/bg.png"
fi

# ── 4. 创建 DMG ─────────────────────────────────────────────
mkdir -p "$OUTPUT_DIR"
DMG_TEMP="$PROJECT_DIR/build/${DMG_NAME}_temp.dmg"
DMG_FINAL="$OUTPUT_DIR/${DMG_NAME}.dmg"

rm -f "$DMG_TEMP" "$DMG_FINAL"

info "正在创建 DMG..."

hdiutil create -volname "$VOL_NAME" \
    -srcfolder "$STAGING" \
    -ov -format UDRW \
    "$DMG_TEMP"

# ── 5. 设置 DMG 窗口样式 ────────────────────────────────────
info "正在设置 DMG 窗口布局..."

MOUNT_OUTPUT=$(hdiutil attach -readwrite -noverify "$DMG_TEMP")
DEVICE=$(echo "$MOUNT_OUTPUT" | grep '/Volumes/' | head -1 | awk '{print $1}')
MOUNT_POINT="/Volumes/$VOL_NAME"

sleep 1

osascript <<APPLESCRIPT
tell application "Finder"
    tell disk "$VOL_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {200, 120, 760, 440}
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 100
        try
            set background picture of theViewOptions to file ".background:bg.png"
        end try
        set position of item "$APP_NAME" of container window to {140, 160}
        set position of item "Applications" of container window to {420, 160}
        close
        open
        update without registering applications
        delay 1
    end tell
end tell
APPLESCRIPT

# 隐藏系统文件和 .background
SetFile -a V "$MOUNT_POINT/.background" 2>/dev/null || chflags hidden "$MOUNT_POINT/.background" 2>/dev/null || true
rm -rf "$MOUNT_POINT/.fseventsd" 2>/dev/null || true
rm -rf "$MOUNT_POINT/.Trashes" 2>/dev/null || true

sync
hdiutil detach "$DEVICE" -quiet

# ── 6. 压缩为只读 DMG ───────────────────────────────────────
hdiutil convert "$DMG_TEMP" -format UDZO -imagekey zlib-level=9 -o "$DMG_FINAL"
rm -f "$DMG_TEMP"

# ── 7. 清理 ─────────────────────────────────────────────────
rm -rf "$STAGING"

DMG_SIZE=$(du -h "$DMG_FINAL" | awk '{print $1}')
info "打包完成！"
echo ""
echo "  ================================"
echo "  📦 DMG 已生成"
echo "  路径: $DMG_FINAL"
echo "  大小: $DMG_SIZE"
echo ""
echo "  用户安装方式："
echo "  1. 双击打开 DMG"
echo "  2. 将 团子 拖到 Applications 文件夹"
echo "  3. 双击运行 团子安装.command 注册 hooks"
echo "  ================================"
echo ""
