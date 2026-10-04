## [Unreleased] — Bugfix round

- Router: الضيف يقدر يفتح login/sign-up من الإعدادات (كان بيتحوّل للرئيسية).
- التطبيق بيفتح على شاشة الدخول (entry) لو مفيش حساب مسجّل.
- عداد الخطوات: طلب صلاحية ACTIVITY_RECOGNITION (permission_handler)، حساب صح عند تغيّر اليوم/ريستارت الموبايل، حفظ سجل يومي.
- الإشعارات: إضافة ScheduledNotificationReceiver في الـ Manifest، جدولة المفعّل عند كل تشغيل، fallback للـ exact alarms، زرار تجربة، ربط السويتش الرئيسي.
- حفظ الخطة: WorkoutPlanCubit بقى singleton مشترك + addExerciseAndSave (إصلاح race كان بيمسح الخطة).
- حفظ البيانات: الاستعادة من السحابة بقت دمج بدل استبدال، وكل الـ keys الصح بتترفع (وجبات، مياه، خطوات، سجل تمارين).
- Progress: مربوطة بالخطوات والتغذية والمياه وخطة التمرين والملف الشخصي (الطول/الوزن).
- الأكلات: +250 صنف مصري/عربي/معلبات/مشروبات، بحث عربي مطبّع، Open Food Facts مع منتجات مصر أولاً، إصلاح حساب السعرات لمنتجات الـ API.

# Changelog — Power Pulse

All notable changes to this project will be documented in this file.

---

## [Unreleased]

## [2.0.0] — Phase 3 — Features
### Added
- ✅ `exercises` feature — full Clean Architecture
- ✅ `ApiResult<T>` sealed type for domain layer
- ✅ `AppFailure` sealed class — pure Dart
- ✅ `ExercisesCubit` + `ExerciseSearchCubit` + `ExerciseDetailCubit`
- ✅ ExerciseDB API integration
- ✅ Body part filter tabs with Arabic translation
- ✅ Pagination support
- ✅ Exercise detail screen with GIF + instructions

## [2.0.0] — Phase 2 — Core Setup
### Added
- ✅ `failures.dart` + `exceptions.dart` — error handling
- ✅ `DioClient` — Dio instances with interceptors
- ✅ `NetworkInfo` — connectivity checker
- ✅ `injection.dart` — GetIt DI setup
- ✅ `AppRouter` — GoRouter with ShellRoute
- ✅ `MainShell` — Bottom nav shell

## [2.0.0] — Phase 1 — Design System
### Added
- ✅ `app_colors.dart` — full dark palette + accent #BFFF00
- ✅ `app_text_styles.dart` — Cairo font, 14 styles
- ✅ `app_constants.dart` — spacing, radius, sizes, durations
- ✅ `app_theme.dart` — full ThemeData dark mode
- ✅ `app_strings.dart` — all Arabic strings
- ✅ `PPButton` — Primary / Outline / Ghost
- ✅ `PPCard` + `PPHeroCard` + `PPStatCard`
- ✅ `PPBadge` + `MuscleGroupBadge` + `LevelBadge`
- ✅ `PPSearchBar` + `PPTextField` + `PPProgressBar`
- ✅ `AppBottomNav` — animated dot indicator
