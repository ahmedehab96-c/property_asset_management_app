#!/usr/bin/env bash
# Build release APK for the owner mobile app.
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
flutter analyze
flutter test
flutter build apk --release
echo "Output: $(pwd)/build/app/outputs/flutter-apk/app-release.apk"
