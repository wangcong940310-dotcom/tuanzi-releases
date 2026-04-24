#!/bin/bash
set -e

# ========== 配置 ==========
APP_NAME="团子"
BUNDLE_ID="com.example.tuanzi"
XCODE_PROJECT="/Users/wangcong/Desktop/团子/团子/团子.xcodeproj"
RELEASES_DIR="/Users/wangcong/Desktop/tuanzi-releases"
SIGN_UPDATE="$HOME/Library/Developer/Xcode/DerivedData/团子-ezzaezfvbxwyrtdxmcftncmxoqai/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update"
# ==========================

# 读取版本号（从 project.pbxproj）
VERSION=$(grep 'MARKETING_VERSION' "$XCODE_PROJECT/project.pbxproj" | head -1 | sed 's/.*= //;s/;//;s/ //g')
if [ -z "$VERSION" ]; then
    echo "❌ 无法读取版本号"; exit 1
fi

echo "📦 发布版本: $VERSION"

# 打包路径
ARCHIVE_PATH="/tmp/${APP_NAME}.xcarchive"
ZIP_NAME="tuanzi-${VERSION}.zip"
ZIP_PATH="$RELEASES_DIR/$ZIP_NAME"

# 1. Archive
echo "🔨 正在 Archive..."
xcodebuild archive \
    -project "$XCODE_PROJECT" \
    -scheme "$APP_NAME" \
    -archivePath "$ARCHIVE_PATH" \
    -configuration Release \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    | tail -5

APP_PATH="$ARCHIVE_PATH/Products/Applications/${APP_NAME}.app"

# 2. 压缩
echo "🗜️  正在压缩..."
cd /tmp
zip -r --symlinks "$ZIP_PATH" "${APP_NAME}.app" --include "${APP_NAME}.app/*"
# 从 archive 里复制 app 再压缩
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

FILE_SIZE=$(stat -f%z "$ZIP_PATH")
echo "📁 文件大小: $FILE_SIZE bytes"

# 3. 签名
echo "✍️  正在签名..."
RAW_SIG=$("$SIGN_UPDATE" "$ZIP_PATH")
SIGNATURE=$(echo "$RAW_SIG" | grep -oE '[A-Za-z0-9+/=]{40,}' | head -1)
if [ -z "$SIGNATURE" ]; then
    SIGNATURE="$RAW_SIG"
fi
echo "🔑 签名: $SIGNATURE"

# 4. 读取更新说明
NOTES_FILE="$RELEASES_DIR/release_notes.html"
if [ -f "$NOTES_FILE" ]; then
    RELEASE_NOTES=$(cat "$NOTES_FILE")
    echo "📋 已读取 release_notes.html"
else
    RELEASE_NOTES="<ul><li>Bug fixes and improvements</li></ul>"
    echo "⚠️  未找到 release_notes.html，使用默认说明"
fi

# 5. 更新 appcast.xml
echo "📝 更新 appcast.xml..."
DOWNLOAD_URL="https://github.com/wangcong940310-dotcom/tuanzi-releases/releases/download/v${VERSION}/${ZIP_NAME}"
PUB_DATE=$(date -R)

cat > "$RELEASES_DIR/appcast.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
    <channel>
        <title>团子更新</title>
        <link>https://github.com/wangcong940310-dotcom/tuanzi-releases</link>
        <description>团子最新版本</description>
        <language>zh-cn</language>
        <item>
            <title>版本 ${VERSION}</title>
            <pubDate>${PUB_DATE}</pubDate>
            <sparkle:version>$(echo $VERSION | tr -d '.')</sparkle:version>
            <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
            <description><![CDATA[${RELEASE_NOTES}]]></description>
            <enclosure
                url="${DOWNLOAD_URL}"
                sparkle:edSignature="${SIGNATURE}"
                length="${FILE_SIZE}"
                type="application/octet-stream"/>
        </item>
    </channel>
</rss>
EOF

# 6. 推送 appcast.xml
echo "🚀 推送 appcast.xml..."
cd "$RELEASES_DIR"
git add appcast.xml
git commit -m "release: v${VERSION}"
git push

echo ""
echo "✅ appcast.xml 已更新完毕！"
echo ""
echo "接下来手动操作："
echo "1. 在 GitHub 创建 Release: https://github.com/wangcong940310-dotcom/tuanzi-releases/releases/new"
echo "   - Tag: v${VERSION}"
echo "   - 上传文件: $ZIP_PATH"
