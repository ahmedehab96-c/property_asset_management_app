# هيكل المشروع - Property Asset Management App

هذا المشروع يحتوي على تطبيقين منفصلين:

## 📱 تطبيق الهاتف (Flutter)
التطبيق الرئيسي للهاتف المحمول موجود في مجلد `mobile_app/`

### الملفات الرئيسية:
- `mobile_app/lib/` - كود التطبيق Flutter
- `mobile_app/android/` - إعدادات Android
- `mobile_app/ios/` - إعدادات iOS
- `mobile_app/pubspec.yaml` - ملف التبعيات Flutter

### للتشغيل:
```bash
cd mobile_app
flutter pub get
flutter run
```

## 🌐 تطبيق الويب (React)
تطبيق الويب موجود في مجلد `web_app/`

### الملفات الرئيسية:
- `web_app/src/` - كود React
- `web_app/public/` - ملفات HTML العامة
- `web_app/package.json` - ملف التبعيات React

### للتشغيل:
```bash
cd web_app
npm install
npm start
```

## البنية الكاملة:

```
property_asset_management_app/
├── web_app/              # تطبيق الويب (React)
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── README.md
│
├── mobile_app/           # تطبيق الهاتف (Flutter)
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── pubspec.yaml
│   └── README.md
│
└── PROJECT_STRUCTURE.md  # هذا الملف
```

## ملاحظات:
- التطبيقان منفصلان تماماً ويمكن تشغيلهما بشكل مستقل
- تطبيق الويب: `web_app/`
- تطبيق الهاتف: `mobile_app/`

