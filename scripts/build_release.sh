#!/bin/bash
# ==============================================================================
# Lamif Kutaa 8 Prep - Google Play Release Build Script
# Builds an optimized, obfuscated Android App Bundle (.aab) and split-per-abi APKs
# with debug symbol generation for Google Play & Crashlytics.
# ==============================================================================

set -eo pipefail

SYMBOLS_DIR="build/symbols"
mkdir -p "$SYMBOLS_DIR"

echo "=========================================================="
echo " Starting Google Play Production Build"
echo " Date: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
echo " Symbols Directory: $SYMBOLS_DIR"
echo "=========================================================="

# 1. Clean previous release build cache
echo "Step 1/3: Cleaning temporary build cache..."
flutter clean
flutter pub get

# 2. Build Android App Bundle (for Google Play Console)
echo "Step 2/3: Building Obfuscated Android App Bundle (AAB)..."
flutter build appbundle \
  --release \
  --obfuscate \
  --split-debug-info="$SYMBOLS_DIR"

# 3. Build Split-per-ABI APKs (for direct distribution / low-end phone testing)
echo "Step 3/3: Building Obfuscated Split-per-ABI APKs..."
flutter build apk \
  --release \
  --split-per-abi \
  --obfuscate \
  --split-debug-info="$SYMBOLS_DIR"

echo "=========================================================="
echo " BUILD SUCCESSFUL!"
echo "=========================================================="

echo ""
echo "Output Artifacts:"
if [ -d "build/app/outputs/bundle/release" ]; then
  ls -lh build/app/outputs/bundle/release/*.aab 2>/dev/null || true
fi
if [ -d "build/app/outputs/flutter-apk" ]; then
  ls -lh build/app/outputs/flutter-apk/*-release.apk 2>/dev/null || true
fi

echo ""
echo "Debug Symbols for Crash Deobfuscation generated in: $SYMBOLS_DIR"
echo "IMPORTANT: Back up '$SYMBOLS_DIR' for this exact version!"
echo "Example archive command:"
echo "  zip -r symbols_\$(date +%Y%m%d)_v1.0.0.zip $SYMBOLS_DIR"
echo "=========================================================="
