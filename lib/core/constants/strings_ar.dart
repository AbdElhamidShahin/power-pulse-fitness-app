/// كل نصوص التطبيق باللغة العربية
abstract class StringsAr {
  // ─── عام ──────────────────────────────────────────────────
  static const appName        = 'Power Pulse';
  static const ok             = 'حسناً';
  static const cancel         = 'إلغاء';
  static const save           = 'حفظ';
  static const retry          = 'حاول مجدداً';
  static const loading        = 'جاري التحميل...';
  static const error          = 'حدث خطأ';
  static const noData         = 'لا توجد بيانات';
  static const confirm        = 'تأكيد';
  static const back           = 'رجوع';
  static const next           = 'التالي';
  static const skip           = 'تخطي';
  static const done           = 'تم';
  static const delete         = 'حذف';
  static const edit           = 'تعديل';
  static const add            = 'إضافة';
  static const search         = 'بحث';
  static const noResults      = 'لا توجد نتائج';
  static const networkError   = 'تحقق من اتصال الإنترنت';
  static const serverError    = 'خطأ في الخادم، حاول لاحقاً';
  static const unexpectedError = 'حدث خطأ غير متوقع';

  // ─── Auth ─────────────────────────────────────────────────
  static const login          = 'تسجيل الدخول';
  static const logout         = 'تسجيل الخروج';
  static const signUp         = 'إنشاء حساب';
  static const email          = 'البريد الإلكتروني';
  static const password       = 'كلمة المرور';
  static const confirmPass    = 'تأكيد كلمة المرور';
  static const fullName       = 'الاسم الكامل';
  static const loginWithGoogle = 'تسجيل الدخول بجوجل';
  static const signUpWithGoogle = 'التسجيل بجوجل';
  static const forgotPassword = 'نسيت كلمة المرور؟';
  static const continueAsGuest = 'المتابعة كضيف';
  static const welcomeBack    = 'مرحباً بعودتك';
  static const guestMode      = 'وضع الضيف';
  static const guestWarning   = 'أنت في وضع الضيف. سجّل دخولك لحفظ بياناتك.';

  // ─── Auth Errors ──────────────────────────────────────────
  static const invalidCredentials = 'البريد الإلكتروني أو كلمة المرور غير صحيحة 🔑';
  static const emailNotConfirmed  = 'يرجى تأكيد بريدك الإلكتروني أولاً 📧';
  static const emailAlreadyUsed   = 'البريد الإلكتروني مستخدم بالفعل ⚠️';
  static const weakPassword       = 'كلمة المرور ضعيفة جداً 🔒';
  static const invalidEmail       = 'البريد الإلكتروني غير صحيح';
  static const passwordsMismatch  = 'كلمة المرور وتأكيدها غير متطابقين ❌';
  static const rateLimitExceeded  = 'تم تجاوز حد الإرسال مؤقتاً. حاول بعد قليل 📧';
  static const googleLoginFailed  = 'فشل تسجيل الدخول بحساب جوجل 🚨';

  // ─── Home ─────────────────────────────────────────────────
  static const home           = 'الرئيسية';
  static const goodMorning    = 'صباح الخير';
  static const goodAfternoon  = 'مساء الخير';
  static const goodEvening    = 'مساء النور';
  static const quickAccess    = 'الوصول السريع';
  static const todayWorkout   = 'تمرين اليوم';
  static const streak         = 'سلسلة الأيام';
  static const streakDays     = 'أيام متتالية';
  static const activeMinutes  = 'دقائق نشطة';
  static const caloriesBurned = 'سعرات محروقة';

  // ─── Exercises ────────────────────────────────────────────
  static const exercises      = 'التمارين';
  static const exercise       = 'تمرين';
  static const bodyPart       = 'المنطقة';
  static const level          = 'مستوى';
  static const levelBeginner  = 'مبتدئ';
  static const levelIntermediate = 'متوسط';
  static const levelAdvanced  = 'متقدم';
  static const muscleChest    = 'صدر';
  static const muscleBack     = 'ظهر';
  static const muscleLegs     = 'أرجل';
  static const muscleShoulder = 'كتف';
  static const muscleArms     = 'أذرع';
  static const muscleCore     = 'بطن';
  static const muscleCardio   = 'كارديو';
  static const searchExercises = 'ابحث عن تمرين...';
  static const noExercises    = 'لا توجد تمارين';
  static const addToPlan      = 'إضافة للخطة';
  static const instructions   = 'خطوات الأداء';

  // ─── Nutrition ────────────────────────────────────────────
  static const nutrition      = 'التغذية';
  static const calories       = 'سعرات';
  static const protein        = 'بروتين';
  static const carbs          = 'كارب';
  static const fat            = 'دهون';
  static const water          = 'ماء';
  static const breakfast      = 'فطور';
  static const lunch          = 'غداء';
  static const dinner         = 'عشاء';
  static const snack          = 'وجبة خفيفة';
  static const addMeal        = 'إضافة وجبة';
  static const searchFood     = 'ابحث عن طعام...';
  static const calorieGoal    = 'هدف السعرات';
  static const waterGoal      = 'هدف الماء';
  static const noMeals        = 'لم تُضف وجبات بعد';

  // ─── Progress ─────────────────────────────────────────────
  static const progress       = 'التقدم';
  static const thisWeek       = 'هذا الأسبوع';
  static const thisMonth      = 'هذا الشهر';
  static const threeMonths    = '3 أشهر';
  static const totalWorkouts  = 'إجمالي التمارين';
  static const totalMinutes   = 'إجمالي الدقائق';
  static const weightChange   = 'تغير الوزن';
  static const bodyStats      = 'إحصائيات الجسم';
  static const weight         = 'الوزن';
  static const bmi            = 'مؤشر كتلة الجسم';
  static const logWeight      = 'تسجيل الوزن';
  static const dailyActivity  = 'نشاطك اليومي';

  // ─── Profile ──────────────────────────────────────────────
  static const profile        = 'الملف الشخصي';
  static const personalData   = 'البيانات الشخصية';
  static const name           = 'الاسم';
  static const age            = 'العمر';
  static const height         = 'الطول';
  static const weightLabel    = 'الوزن';
  static const goal           = 'الهدف';
  static const activityLevel  = 'مستوى النشاط';
  static const darkMode       = 'الوضع الليلي';
  static const notifications  = 'الإشعارات';
  static const units          = 'الوحدات';
  static const metric         = 'متري (كج، سم)';
  static const imperial       = 'إمبريالي (رطل، قدم)';
  static const privacy        = 'الخصوصية';
  static const deleteData     = 'حذف بياناتي';
  static const deleteConfirm  = 'هل أنت متأكد من حذف كل بياناتك؟';
  static const editProfile    = 'تعديل البيانات';
  static const signInToSave   = 'سجّل دخولك لحفظ بياناتك';

  // ─── Workout Logger ────────────────────────────────────────
  static const workoutLogger  = 'سجل التمرين';
  static const startWorkout   = 'بدء التمرين';
  static const finishWorkout  = 'إنهاء التمرين';
  static const cancelWorkout  = 'إلغاء التمرين';
  static const addExercise    = 'إضافة تمرين';
  static const sets           = 'سيتات';
  static const reps           = 'تكرارات';
  static const kgLabel        = 'كج';
  static const workoutDone    = 'أحسنت! 💪';
  static const duration       = 'المدة';
  static const minutes        = 'دقيقة';

  // ─── Workout Plan ─────────────────────────────────────────
  static const workoutPlan    = 'خطة التمرين';
  static const restDay        = 'يوم راحة';
  static const planSaved      = 'تم حفظ الخطة ✅';

  // ─── Days (Egyptian calendar: Sat = start) ─────────────────
  static const daySat = 'السبت';
  static const daySun = 'الأحد';
  static const dayMon = 'الاثنين';
  static const dayTue = 'الثلاثاء';
  static const dayWed = 'الأربعاء';
  static const dayThu = 'الخميس';
  static const dayFri = 'الجمعة';

  // letters (RTL: Sat first)
  static const dayLettersSat = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
  // map: weekday (Mon=1..Sun=7) → letter
  static String dayLetter(int weekday) {
    const map = {1:'ن', 2:'ث', 3:'ر', 4:'خ', 5:'ج', 6:'س', 7:'ح'};
    return map[weekday] ?? '';
  }

  // ─── Onboarding ───────────────────────────────────────────
  static const welcomeTitle   = 'مرحباً بك في\nPower Pulse';
  static const welcomeSub     = 'تطبيقك المتكامل للياقة البدنية\nتمارين • تغذية • تتبع التقدم';
  static const setupTitle     = 'أخبرنا عن نفسك';
  static const setupSub       = 'لنحسب أهدافك اليومية بدقة';
  static const startJourney   = 'ابدأ رحلتك 🚀';
  static const startSetup     = 'ابدأ الإعداد';
}
