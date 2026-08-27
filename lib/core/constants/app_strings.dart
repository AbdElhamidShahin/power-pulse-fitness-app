// All fixed text strings used across the app.
// Never write Arabic/English UI text directly in widgets — use these instead.
// This makes translation and text changes much easier.

abstract class AppStrings {
  AppStrings._();

  // App name
  static const String appName = 'Power Pulse';
  static const String appTagline = 'ابدأ رحلتك الآن';

  // Onboarding slides
  static const String slide1Tag   = 'اللياقة البدنية';
  static const String slide1Title = 'حوّل جسمك\nبالعلم والالتزام';
  static const String slide1Body  = 'برامج تمارين مخصصة، تتبع دقيق للتغذية،\nوتحليل مستمر لتقدمك';
  static const String slide2Tag   = 'التغذية الذكية';
  static const String slide2Title = 'اعرف ما تأكل\nوابنِ جسمك';
  static const String slide2Body  = 'قاعدة بيانات ضخمة من الأطعمة\nتتبع السعرات والماكروز بدقة عالية';
  static const String slide3Tag   = 'تتبع التقدم';
  static const String slide3Title = 'شاهد نتائجك\nتتحقق يوماً بيوم';
  static const String slide3Body  = 'رسوم بيانية واضحة ومقارنات أسبوعية\nتُريك كيف تتحسّن كل يوم';

  static const String onboardingSetupTag   = 'إعداد الملف الشخصي';
  static const String onboardingSetupTitle = 'أخبرنا\nعن نفسك';
  static const String onboardingSetupBody  = 'لنحسب أهدافك اليومية بدقة';
  static const String onboardingStart      = 'ابدأ رحلتك ⚡';
  static const String onboardingSetupProfile = 'إعداد ملفي الشخصي';
  static const String onboardingNext       = 'التالي';
  static const String onboardingSkip       = 'تخطي';

  // Entry screen
  static const String entryTitle         = 'اختر\nطريقة المتابعة';
  static const String entryDataSaved     = 'بياناتك اتحفظت ✓  اختر كيف تكمل';
  static const String entryTerms         = 'بالمتابعة فأنت توافق على شروط الاستخدام';
  static const String entryAccountTitle  = 'إنشاء حساب أو تسجيل الدخول';
  static const String entryAccountSub    = 'احفظ بياناتك على السحابة واستعدها\nفي أي جهاز وأي وقت';
  static const String entryAccountBtn    = 'تسجيل الدخول / إنشاء حساب';
  static const String entryAccountBadge  = 'موصى به';
  static const String entryPerk1         = 'مزامنة تلقائية عبر الأجهزة';
  static const String entryPerk2         = 'نسخ احتياطي دائم للبيانات';
  static const String entryPerk3         = 'استعادة البيانات عند تغيير الهاتف';
  static const String entryGuestTitle    = 'متابعة كضيف';
  static const String entryGuestSub      = 'البيانات محفوظة على الجهاز فقط\nيمكنك إنشاء حساب لاحقاً';
  static const String entryGuestBtn      = 'متابعة بدون حساب';

  // Login
  static const String loginTag           = 'تسجيل الدخول';
  static const String loginTitle         = 'أهلاً بعودتك\nمجدداً 💪';
  static const String loginSubtitle      = 'سجّل دخولك وواصل رحلتك نحو اللياقة';
  static const String loginBtn           = 'تسجيل الدخول';
  static const String loginGoogle        = 'الدخول بحساب جوجل';
  static const String loginNoAccount     = 'ليس لديك حساب؟';
  static const String loginCreateAccount = 'إنشاء حساب';
  static const String loginOr            = 'أو';
  static const String loginEmailHint     = 'example@gmail.com';
  static const String loginPassHint      = '••••••••';

  // Sign up
  static const String signUpTag       = 'إنشاء حساب جديد';
  static const String signUpTitle     = 'انضم إلى\nمجتمع الفائزين 🏆';
  static const String signUpSubtitle  = 'أنشئ حسابك وابدأ رحلتك مع Power Pulse';
  static const String signUpBtn       = 'إنشاء الحساب';
  static const String signUpHasAccount = 'لديك حساب بالفعل؟';
  static const String signUpLogin     = 'تسجيل الدخول';

  // Form field labels
  static const String fieldName         = 'الاسم الكامل';
  static const String fieldNameHint     = 'اسمك الكريم';
  static const String fieldEmail        = 'البريد الإلكتروني';
  static const String fieldPass         = 'كلمة المرور';
  static const String fieldPassHint     = '8 أحرف على الأقل';
  static const String fieldPassConfirm  = 'تأكيد كلمة المرور';
  static const String fieldPassConfirmH = 'أعد كتابة كلمة المرور';
  static const String fieldAge          = 'العمر';
  static const String fieldAgeHint      = '25';
  static const String fieldAgeSuffix    = 'سنة';
  static const String fieldHeight       = 'الطول';
  static const String fieldHeightHint   = '175';
  static const String fieldHeightSuffix = 'سم';
  static const String fieldWeight       = 'الوزن';
  static const String fieldWeightHint   = '70.0';
  static const String fieldWeightSuffix = 'كجم';
  static const String fieldGender       = 'الجنس';
  static const String fieldGoal         = 'هدفك من التمرين';
  static const String fieldActivity     = 'مستوى نشاطك';

  // Validation errors
  static const String errEnterName      = 'أدخل اسمك';
  static const String errEnterEmail     = 'أدخل بريدك الإلكتروني';
  static const String errInvalidEmail   = 'بريد إلكتروني غير صحيح';
  static const String errEnterPass      = 'أدخل كلمة المرور';
  static const String errPassShort      = 'كلمة المرور قصيرة (8 أحرف على الأقل)';
  static const String errPassMismatch   = 'كلمتا المرور غير متطابقتين';
  static const String errEnterPassConf  = 'أعد كتابة كلمة المرور';
  static const String errEnterNumber    = 'أدخل رقماً صحيحاً';

  // Profile
  static const String profilePersonal   = 'البيانات الشخصية';
  static const String profileSettings   = 'الإعدادات';
  static const String profileName       = 'الاسم';
  static const String profileAge        = 'العمر';
  static const String profileHeight     = 'الطول';
  static const String profileWeight     = 'الوزن';
  static const String profileGoal       = 'الهدف';
  static const String profileActivity   = 'مستوى النشاط';
  static const String profileGender     = 'الجنس';
  static const String profileEmail      = 'البريد الإلكتروني';
  static const String profileWorkouts   = 'تمرين';
  static const String profileStreak     = 'سلسلة';
  static const String profileDarkMode   = 'الوضع الداكن';
  static const String profileNotifs     = 'الإشعارات';
  static const String profileUnits      = 'وحدات القياس';
  static const String profileMetric     = 'متري (كجم، سم)';
  static const String profileImperial   = 'إمبريالي (lb، ft)';
  static const String profileLogout     = 'تسجيل الخروج';
  static const String profileLogoutQ    = 'تسجيل الخروج';
  static const String profileLogoutMsg  = 'هل أنت متأكد؟ ستستمر بياناتك محفوظة على السحابة.';
  static const String profileLogoutCancel = 'إلغاء';
  static const String profileLogoutConfirm = 'تسجيل الخروج';

  // General
  static const String cancel     = 'إلغاء';
  static const String confirm    = 'تأكيد';
  static const String save       = 'حفظ';
  static const String back       = 'رجوع';
  static const String loading    = 'جاري التحميل...';
  static const String errorGeneric = 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً 🚧';
  static const String noInternet = 'لا يوجد اتصال بالإنترنت';

  // Muscle groups
  static const String muscleChest    = 'صدر';
  static const String muscleBack     = 'ظهر';
  static const String muscleLegs     = 'أرجل';
  static const String muscleShoulder = 'كتف';
  static const String muscleArms     = 'أذرع';
  static const String muscleCore     = 'بطن';
  static const String muscleCardio   = 'كارديو';

  // Levels
  static const String levelBeginner     = 'مبتدئ';
  static const String levelIntermediate = 'متوسط';
  static const String levelAdvanced     = 'متقدم';

  // Workout
  static const String workoutResume     = 'استئناف التمرين؟';
  static const String workoutResumeMsg  = 'لديك تمرين لم تكمله. هل تريد الاستمرار أم البدء من جديد؟';
  static const String workoutResumeBtn  = 'استئناف';
  static const String workoutRestartBtn = 'ابدأ من جديد';

  // Pedometer
  static const String pedometerSteps   = 'خطوة';
  static const String pedometerGoal    = 'الهدف';
  static const String pedometerDenied  = 'تتبع الخطوات غير متاح';
  static const String pedometerGrantMsg = 'امنح إذن تتبع النشاط من إعدادات الجهاز';

  // Conflict dialog
  static const String conflictTitle    = 'تعارض في البيانات';
  static const String conflictLocal    = 'بياناتي المحلية';
  static const String conflictCloud    = 'بيانات الحساب';

  // Notifications
  static const String notifWorkout = 'تذكير التمرين';
  static const String notifSteps   = 'تذكير الخطوات';
  static const String notifWater   = 'تذكير الماء';
}
