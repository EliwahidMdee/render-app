#!/bin/bash

# Live Agent App - Release APK Builder
# This script helps you create a signed release APK

set -e

echo "🚀 Live Agent App - Release Build Script"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to android directory
cd "$(dirname "$0")/android"

# Check if keystore exists
if [ ! -f "upload-keystore.jks" ]; then
    echo -e "${YELLOW}⚠️  Keystore not found. Let's create one!${NC}"
    echo ""
    echo "You will be asked to provide:"
    echo "  1. Keystore password (SAVE THIS!)"
    echo "  2. Key password (can be same as keystore password)"
    echo "  3. Your name/organization details"
    echo ""
    read -p "Press Enter to continue..."

    keytool -genkey -v -keystore upload-keystore.jks \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -alias live-agent-app

    echo ""
    echo -e "${GREEN}✅ Keystore created successfully!${NC}"
    echo ""
else
    echo -e "${GREEN}✅ Keystore found: upload-keystore.jks${NC}"
fi

# Check if key.properties exists
if [ ! -f "key.properties" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  key.properties not found. Let's create it!${NC}"
    echo ""
    read -sp "Enter your keystore password: " STORE_PASSWORD
    echo ""
    read -sp "Enter your key password: " KEY_PASSWORD
    echo ""

    cat > key.properties <<EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=live-agent-app
storeFile=../upload-keystore.jks
EOF

    echo -e "${GREEN}✅ key.properties created successfully!${NC}"
    echo ""
else
    echo -e "${GREEN}✅ key.properties found${NC}"
fi

# Go back to project root
cd ..

echo ""
echo "🏗️  Building release APK..."
echo ""

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build release APK
echo "Building release APK..."
flutter build apk --release

echo ""
echo -e "${GREEN}🎉 SUCCESS! Release APK created!${NC}"
echo ""
echo "📦 Your release APK is located at:"
echo "   build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "📱 To install on device:"
echo "   flutter install --release"
echo ""
echo "   Or use adb:"
echo "   adb install build/app/outputs/flutter-apk/app-release.apk"
echo ""

# Get file size
APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
echo "📊 APK Size: $APK_SIZE"
echo ""

echo -e "${YELLOW}⚠️  IMPORTANT REMINDERS:${NC}"
echo "  1. Backup your keystore (upload-keystore.jks) to a secure location"
echo "  2. Save your passwords in a password manager"
echo "  3. Never commit keystore or key.properties to Git"
echo "  4. You need the same keystore for all future updates"
echo ""
echo -e "${GREEN}✅ Done!${NC}"

