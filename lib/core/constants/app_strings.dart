abstract class AppStrings {
  AppStrings._();

  // ─── App ───────────────────────────────────────────────────
  static const String appName = 'Power Pulse';

  // ─── Auth screens ──────────────────────────────────────────
  static const String login            = 'تسجيل الدخول';
  static const String loginWelcomeBack = 'أهلاً بعودتك\nمجدداً 💪';
  static const String loginSubtitle    = 'سجّل دخولك وواصل رحلتك نحو اللياقة';
  static const String loginButton      = 'تسجيل الدخول';
  static const String loginWithGoogle  = 'الدخول بحساب جوجل';
  static const String noAccount        = 'ليس لديك حساب؟';
  static const String createAccount    = 'إنشاء حساب';

  static const String signUp              = 'إنشاء حساب جديد';
  static const String signUpTitle         = 'انضم إلى\nمجتمع الفائزين 🏆';
  static const String signUpSubtitle      = 'أنشئ حسابك وابدأ رحلتك مع Power Pulse';
  static const String signUpButton        = 'إنشاء الحساب';
  static const String alreadyHaveAccount  = 'لديك حساب بالفعل؟';

  // ─── Form fields ───────────────────────────────────────────
  static const String fieldEmail           = 'البريد الإلكتروني';
  static const String fieldPassword        = 'كلمة المرور';
  static const String fieldConfirmPassword = 'تأكيد كلمة المرور';
  static const String fieldFullName        = 'الاسم الكامل';

  static const String hintEmail           = 'example@gmail.com';
  static const String hintPassword        = '••••••••';
  static const String hintPasswordMin     = '8 أحرف على الأقل';
  static const String hintConfirmPassword = 'أعد كتابة كلمة المرور';
  static const String hintName            = 'اسمك الكريم';

  // ─── Validation messages ───────────────────────────────────
  static const String validationEmailEmpty    = 'أدخل بريدك الإلكتروني';
  static const String validationEmailInvalid  = 'بريد إلكتروني غير صحيح';
  static const String validationPasswordEmpty = 'أدخل كلمة المرور';
  static const String validationPasswordShort = 'كلمة المرور قصيرة (8 أحرف على الأقل)';
  static const String validationPasswordMatch = 'كلمتا المرور غير متطابقتين';
  static const String validationNameEmpty     = 'أدخل اسمك';
  static const String validationConfirmEmpty  = 'أعد كتابة كلمة المرور';

  // ─── Auth success / error messages ────────────────────────
  static const String loginSuccessPrefix  = 'مرحباً بعودتك ';
  static const String loginSuccessSuffix  = ' 👋';
  static const String signUpSuccessPrefix = '🎉 مرحباً ';
  static const String signUpSuccessSuffix = '! حسابك جاهز';
  static const String logoutConfirmTitle   = 'تسجيل الخروج';
  static const String logoutConfirmContent =
      'هل أنت متأكد؟ ستستمر بياناتك محفوظة على السحابة ويمكنك تسجيل الدخول مجددًا لاستعادتها.';
  static const String logoutButton = 'تسجيل الخروج';
  static const String cancelButton = 'إلغاء';
  static const String retryButton  = 'إعادة المحاولة';
  static const String orDivider    = 'أو';

  // ─── Conflict dialog ───────────────────────────────────────
  static const String conflictTitle       = 'تعارض في البيانات';
  static const String conflictContentPre  = 'لديك بيانات محفوظة محليًا كضيف، وحسابك "';
  static const String conflictContentPost =
      '" يحتوي على بيانات في السحابة.\n\nاختر أيهما تريد الاحتفاظ به:';
  static const String conflictLocal   = 'بياناتي المحلية';
  static const String conflictAccount = 'بيانات الحساب';

  // ─── Profile screen ────────────────────────────────────────
  static const String profilePersonalData = 'البيانات الشخصية';
  static const String profileSettings     = 'الإعدادات';
  static const String profileName         = 'الاسم';
  static const String profileAge          = 'العمر';
  static const String profileHeight       = 'الطول';
  static const String profileWeight       = 'الوزن';
  static const String profileGoal         = 'الهدف';
  static const String profilePrivacy      = 'الخصوصية';
  static const String profileAgeUnit      = ' سنة';
  static const String profileHeightUnit   = ' سم';
  static const String profileWeightUnit   = ' كجم';

  static const String settingNotifications = 'الإشعارات';
  static const String settingDarkMode      = 'الوضع الليلي';
  static const String settingUnits         = 'الوحدات (كجم/سم)';

  // ─── Guest banner ──────────────────────────────────────────
  static const String guestBannerText  =
      'أنت في وضع الضيف. أنشئ حسابًا لحفظ بياناتك على السحابة.';
  static const String guestLoginButton = 'تسجيل الدخول';

  // ─── Privacy sheet ─────────────────────────────────────────
  static const String privacyTitle          = 'الخصوصية والبيانات';
  static const String privacyLocalTitle     = 'البيانات محفوظة محلياً';
  static const String privacyLocalDesc      =
      'كل بياناتك محفوظة على جهازك فقط ولا تُرسل لأي خادم';
  static const String privacyNoAdsTitle     = 'لا إعلانات';
  static const String privacyNoAdsDesc      =
      'التطبيق خالي من الإعلانات وتتبع البيانات';
  static const String privacyDeleteTitle    = 'حذف البيانات';
  static const String privacyDeleteDesc     =
      'يمكنك حذف كل بياناتك من خلال تسجيل الخروج';

  // ─── Error messages ────────────────────────────────────────
  static const String errorLoadData     = 'تعذّر تحميل البيانات';
  static const String errorPageNotFound = 'الصفحة غير موجودة';
  static const String errorUnexpected   = 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً 🚧';
  static const String errorGoogleLogin  = 'فشل تسجيل الدخول بحساب جوجل 🚨';

  // ─── Home screen ───────────────────────────────────────────
  static const String homeQuickAccess    = 'الوصول السريع';
  static const String homeTodayWorkout   = 'تمرين اليوم';

  // ─── Profile header stats ──────────────────────────────────
  static const String statWorkouts = 'تمرين';
  static const String statStreak   = 'سلسلة';
  static const String statWeight   = 'الوزن';

  // ─── Notification settings ────────────────────────────────
  static const String notifSectionTitle    = 'الإشعارات';
  static const String notifWorkoutTitle    = 'تذكير التمرين';
  static const String notifWorkoutSubtitle = '8 ص و 6 م يومياً';
  static const String notifStepsTitle      = 'تذكير الخطوات';
  static const String notifStepsSubtitle   = '12 الظهر لو لسه بعيد عن الهدف';
  static const String notifWaterTitle      = 'تذكير الماء';
  static const String notifWaterSubtitle   = 'كل ساعتين من 8 ص لـ 10 م';

  // ─── Muscle Groups ────────────────────────────────────────
  static const String muscleChest    = 'صدر';
  static const String muscleBack     = 'ظهر';
  static const String muscleLegs     = 'أرجل';
  static const String muscleShoulder = 'كتف';
  static const String muscleArms     = 'أذرع';
  static const String muscleCore     = 'بطن';
  static const String muscleCardio   = 'كارديو';

  // ─── Levels ───────────────────────────────────────────────
  static const String levelBeginner    = 'مبتدئ';
  static const String levelIntermediate = 'متوسط';
  static const String levelAdvanced    = 'متقدم';
  static const String level            = 'مستوى';
}
