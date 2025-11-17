#!/bin/bash

# Script to copy app icons to all mipmap folders
# Run this from the project root: bash copy-icons.sh

echo "📱 Copying app icons to mipmap folders..."

# Source icon
ICON_SOURCE="assets/images/icon.png"

# Check if source exists
if [ ! -f "$ICON_SOURCE" ]; then
    echo "❌ Error: $ICON_SOURCE not found!"
    exit 1
fi

# Copy to all mipmap folders
cp "$ICON_SOURCE" "android/app/src/main/res/mipmap-mdpi/ic_launcher.png"
cp "$ICON_SOURCE" "android/app/src/main/res/mipmap-hdpi/ic_launcher.png"
cp "$ICON_SOURCE" "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png"
cp "$ICON_SOURCE" "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"
cp "$ICON_SOURCE" "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"

echo "✅ Icon copied to all mipmap folders!"
echo ""
echo "📍 Icon locations:"
echo "  - mipmap-mdpi/ic_launcher.png"
echo "  - mipmap-hdpi/ic_launcher.png"
echo "  - mipmap-xhdpi/ic_launcher.png"
echo "  - mipmap-xxhdpi/ic_launcher.png"
echo "  - mipmap-xxxhdpi/ic_launcher.png"
echo ""
echo "🎉 Done! You can now build your app."

