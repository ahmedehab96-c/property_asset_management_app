#!/bin/bash
# تشغيل التطبيق على محاكي iPhone 17
# استخدم: ./run_iphone17.sh من مجلد mobile_app

set -e
cd "$(dirname "$0")"

# تشغيل محاكي iPhone 17 (iOS 26.1)
echo "تشغيل محاكي iPhone 17..."
xcrun simctl boot 5F61D7B4-88BC-409E-8FED-8B55AE46E311 2>/dev/null || true
open -a Simulator

echo "انتظر حتى يفتح المحاكي بالكامل (حوالي 20 ثانية)..."
sleep 20

echo "تشغيل التطبيق..."
flutter run -d 5F61D7B4-88BC-409E-8FED-8B55AE46E311
