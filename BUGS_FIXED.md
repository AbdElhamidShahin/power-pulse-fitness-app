# 🐛 قائمة الأخطاء المكتشفة والإصلاحات

## بناءً على مقارنة الصور مع الكود

---

## ❌ Bug 1 — الفونت (الأهم)
**المشكلة:** `pubspec.yaml` يحمّل `Poppins-Regular.ttf` بدل Cairo لكل الـ weights
```yaml
# ❌ الكود الحالي — خطأ
- asset: assets/fonts/Poppins-Regular.ttf  ← نفس الملف 6 مرات!
  weight: 400
- asset: assets/fonts/Poppins-Regular.ttf  ← ما فيش فرق في الـ weights
  weight: 900
```
**الإصلاح:** اتبع `FONT_SETUP.md` — 3 طرق للحل

---

## ❌ Bug 2 — RTL: الـ Grid لليسار مش اليمين
**المشكلة:** `crossAxisAlignment: CrossAxisAlignment.start` داخل بطاقات Quick Actions
```dart
// ❌ الكود الحالي
Column(
  crossAxisAlignment: CrossAxisAlignment.start,  // ← يسار! خطأ في RTL
```
**الإصلاح:** `crossAxisAlignment: CrossAxisAlignment.end` ← يمين

---

## ❌ Bug 3 — ترتيب بطاقات Quick Access
**المشكلة:** ترتيب الـ items مش مطابق الصورة
```dart
// ❌ الكود الحالي: التغذية | تقدمي | حسابي | التمارين
// ✅ الصورة تُظهر: تقدمي | التغذية | التمارين | حسابي
```
**الإصلاح:** عُدّل الترتيب في `_QuickAccessGrid`

---

## ❌ Bug 4 — Streak Card: نص يمين مش وسط
**المشكلة:** `CURRENT STREAK` ما كانش RTL محاذاته
**الإصلاح:** `CrossAxisAlignment.end` + `Row` للأيقونة والنص

---

## ❌ Bug 5 — وقت النشاط في الطرف الخطأ
**المشكلة في الصورة:** وقت النشاط (داكن) يمين + السعرات (فاتح) يسار
**الكود الحالي:** السعرات يمين + وقت النشاط يسار ← معكوس!
**الإصلاح:** تبديل مكانهم في الـ Row

---

## ❌ Bug 6 — Status Bar أيقونات خطأ
**المشكلة:** `statusBarIconBrightness: Brightness.light` ← أيقونات بيضاء على خلفية فاتحة = مش شايفها!
```dart
// ❌ في main.dart
statusBarIconBrightness: Brightness.light,  // خطأ لـ light theme
```
**الإصلاح:**
```dart
// ✅
statusBarIconBrightness: Brightness.dark,   // أيقونات داكنة = تظهر على الخلفية الفاتحة
```

---

## ❌ Bug 7 — ExerciseCard: سهم الاتجاه خطأ
**المشكلة:** `Icons.arrow_back_ios_rounded` ← يشير يسار
**الإصلاح:** `Icons.arrow_forward_ios_rounded` ← في RTL يظهر يشير يمين = صح

---

## ❌ Bug 8 — ExerciseCard: Border غير مطلوب
**المشكلة:** البطاقات فيها `border: Border.all(...)` والصورة تُظهر بطاقات بدون borders
**الإصلاح:** حذف الـ border — بطاقات نظيفة

---

## ❌ Bug 9 — نص WorkoutStat: الـ emoji قبل أو بعد؟
**المشكلة:** في RTL الـ emoji يجي بعد النص مش قبله
**الإصلاح:** `Text(emoji)` بعد `Text(label)` في الـ Row

---

## ❌ Bug 10 — textScaler غير محدد
**المشكلة:** لو المستخدم غيّر حجم الخط في الهاتف، التصميم بيتكسر
**الإصلاح في main.dart:**
```dart
builder: (context, child) {
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
    child: Directionality(textDirection: TextDirection.rtl, child: child!),
  );
},
```

---

## ✅ الملفات المُعدّلة
| الملف | التعديل |
|---|---|
| `pubspec.yaml` | إصلاح fonts + إضافة google_fonts |
| `lib/main.dart` | status bar dark + textScaler |
| `lib/features/home/ui/screens/home_screen.dart` | RTL كامل + ترتيب بطاقات صح |
| `lib/shared/widgets/app_bottom_nav.dart` | أيقونات Material واضحة |
| `lib/features/exercises/ui/widgets/exercise_card.dart` | RTL + سهم صح + بدون border |

---

## 🔧 بعد تطبيق التعديلات
```bash
flutter pub get
flutter clean
flutter run
```
