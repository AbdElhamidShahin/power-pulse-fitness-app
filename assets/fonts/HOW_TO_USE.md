# ✅ Cairo Font — طريقة الاستخدام

## الخطوات:

### 1. انسخ كل ملفات .ttf لمجلد مشروعك:
```
your_project/
  assets/
    fonts/
      Cairo-Regular.ttf      ← weight 400
      Cairo-Medium.ttf       ← weight 500
      Cairo-SemiBold.ttf     ← weight 600
      Cairo-Bold.ttf         ← weight 700
      Cairo-ExtraBold.ttf    ← weight 800
      Cairo-Black.ttf        ← weight 900
```

### 2. أضف في pubspec.yaml:
```yaml
flutter:
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Regular.ttf
          weight: 400
        - asset: assets/fonts/Cairo-Medium.ttf
          weight: 500
        - asset: assets/fonts/Cairo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Cairo-Bold.ttf
          weight: 700
        - asset: assets/fonts/Cairo-ExtraBold.ttf
          weight: 800
        - asset: assets/fonts/Cairo-Black.ttf
          weight: 900
  assets:
    - assets/fonts/
```

### 3. شغّل:
```bash
flutter pub get
flutter clean
flutter run
```

## ملاحظة مهمة:
الملفات دي Variable Font — يعني ملف واحد بيدعم كل الـ weights (400-900)
تلقائياً بدون أي إعداد إضافي. ✅
