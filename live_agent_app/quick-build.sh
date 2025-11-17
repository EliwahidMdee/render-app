#!/bin/bash
# Quick APK Builder - Execute this script to build signed APK

cd "$(dirname "$0")"

echo "════════════════════════════════════════════════"
echo "   Live Agent App - APK Build Script"
echo "   Dashboard Fix Version 1.2.2+1"
echo "════════════════════════════════════════════════"
echo ""

# Step 1: Clean
echo "⏳ Step 1/4: Cleaning previous builds..."
flutter clean > /dev/null 2>&1
echo "✅ Clean complete"

# Step 2: Dependencies
echo "⏳ Step 2/4: Getting dependencies..."
flutter pub get > /dev/null 2>&1
echo "✅ Dependencies ready"

# Step 3: Build
echo "⏳ Step 3/4: Building signed APK (this may take 2-3 minutes)..."
echo ""
flutter build apk --release --split-per-abi

# Step 4: Summary
echo ""
echo "════════════════════════════════════════════════"
echo "   BUILD COMPLETE! ✅"
echo "════════════════════════════════════════════════"
echo ""
echo "📦 APK Files created:"
ls -lh build/app/outputs/flutter-apk/app-*-release.apk 2>/dev/null | awk '{print "   •", $9, "("$5")"}'
echo ""
echo "📂 Location: build/app/outputs/flutter-apk/"
echo ""
echo "💡 Recommended for most devices:"
echo "   → app-arm64-v8a-release.apk"
echo ""
