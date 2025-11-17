#!/bin/bash

# Live Agent App - Signed APK Builder (Fixed Dashboard Version)
# This script builds a signed release APK with the dashboard fixes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Clean previous builds
echo -e "${YELLOW}🧹 Step 1/5: Cleaning previous builds...${NC}"
flutter clean
echo -e "${GREEN}✅ Clean complete${NC}"
echo ""

# Step 2: Get dependencies
echo -e "${YELLOW}📦 Step 2/5: Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dependencies retrieved${NC}"
echo ""

# Step 3: Verify keystore
echo -e "${YELLOW}🔑 Step 3/5: Verifying signing configuration...${NC}"
if [ -f "android/upload-keystore.jks" ]; then
    echo -e "${GREEN}✅ Keystore found: android/upload-keystore.jks${NC}"
else
    echo -e "${RED}❌ Keystore not found!${NC}"
    exit 1
fi

if [ -f "android/key.properties" ]; then
    echo -e "${GREEN}✅ Key properties found${NC}"
else
    echo -e "${RED}❌ key.properties not found!${NC}"
    exit 1
fi
echo ""

# Step 4: Build release APK
echo -e "${YELLOW}🔨 Step 4/5: Building release APK...${NC}"
echo -e "${BLUE}This may take a few minutes...${NC}"
echo ""
flutter build apk --release --split-per-abi
echo ""
echo -e "${GREEN}✅ Build complete!${NC}"
echo ""

# Step 5: Show output information
echo -e "${YELLOW}📋 Step 5/5: Build Summary${NC}"
echo "================================================"
echo ""

APK_DIR="build/app/outputs/flutter-apk"

if [ -d "$APK_DIR" ]; then
    echo -e "${GREEN}✅ APK files created successfully!${NC}"
    echo ""
    echo "📦 Output files:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    for apk in "$APK_DIR"/app-*-release.apk; do
        if [ -f "$apk" ]; then
            filename=$(basename "$apk")
            size=$(du -h "$apk" | cut -f1)
            echo -e "  📱 ${BLUE}$filename${NC} (${size})"
        fi
    done

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📂 Location: $APK_DIR"
    echo ""
    echo -e "${GREEN}🎉 Build successful!${NC}"
    echo ""
    echo "💡 APK Types:"
    echo "   • app-armeabi-v7a-release.apk  → For 32-bit ARM devices"
    echo "   • app-arm64-v8a-release.apk    → For 64-bit ARM devices (most modern phones)"
    echo "   • app-x86_64-release.apk       → For x86_64 emulators/devices"
    echo ""
    echo "📱 Recommended for distribution: app-arm64-v8a-release.apk"
    echo ""
    echo "✨ New Features in this build:"
    echo "   ✅ Agent name displayed in app bar title"
    echo "   ✅ Agent icon (🎧) added to dashboard"
    echo "   ✅ Automatic session loading on login"
    echo "   ✅ Improved navigation flow"
    echo "   ✅ Debug logging for troubleshooting"
    echo ""
else
    echo -e "${RED}❌ APK directory not found!${NC}"
    exit 1
fi
