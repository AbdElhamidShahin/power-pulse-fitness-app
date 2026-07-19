# 🔤 إصلاح مشكلة الفونت — Cairo بدل Poppins

## المشكلة
في `pubspec.yaml` الحالي، عندك:
```yaml
fonts:
  - family: Cairo
    fonts:
      - asset: assets/fonts/Poppins-Regular.ttf  ← ❌ خطأ! Poppins مش Cairo
```
يعني حتى لو كتبت `fontFamily: 'Cairo'` في الكود، هو بيحمّل Poppins.

---

## الحل (اختار واحد من 3 طرق)

### ✅ الطريقة 1 — تنزيل Cairo وإضافته (الأفضل للإنتاج)

1. روح على: https://fonts.google.com/specimen/Cairo
2. اضغط "Download family"
3. فك الضغط وخذ الملفات دي:
   - `Cairo-Regular.ttf`
   - `Cairo-Medium.ttf`
   - `Cairo-SemiBold.ttf`
   - `Cairo-Bold.ttf`
   - `Cairo-ExtraBold.ttf`
   - `Cairo-Black.ttf`
4. حطّها في مجلد `assets/fonts/`
5. `pubspec.yaml` المُرفق جاهز — فيه الـ config الصح

---

### ✅ الطريقة 2 — google_fonts (الأسهل)

#### 1. أضف للـ pubspec.yaml:
```yaml
dependencies:
  google_fonts: ^6.2.1
```

#### 2. في `main.dart` أضف:
```dart
import 'package:google_fonts/google_fonts.dart';

// في MaterialApp.router:
theme: AppTheme.light.copyWith(
  textTheme: GoogleFonts.cairoTextTheme(AppTheme.light.textTheme),
),
```

#### 3. احذف قسم fonts من pubspec.yaml تماماً

---

### ✅ الطريقة 3 — تعديل سريع (مؤقت)

غيّر كل ملف Cairo-Regular.ttf إلى نفس اسم الـ Poppins الموجود:
```yaml
# ❌ بدل
- asset: assets/fonts/Cairo-Regular.ttf

# ✅ اكتب
- asset: assets/fonts/Poppins-Regular.ttf
```
ده هيخلي الفونت يشتغل (Poppins) لحد ما تحمّل Cairo.

---

## ملاحظة مهمة
بعد إضافة الملفات نفّذ:
```bash
flutter pub get
flutter clean
flutter run
```

---

## التحقق
شغّل التطبيق وشوف إذا النص بقى عربي ناعم مع أرقام تانية.
Cairo فيها أرقام عربية `٠١٢٣` بشكل تلقائي مع `fontFeatures`.
