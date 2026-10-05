import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Localization service — reads JSON files from assets/langs/
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _strings = {};

  Future<void> load() async {
    final jsonStr = await rootBundle
        .loadString('assets/langs/${locale.languageCode}.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonStr);
    _strings = jsonMap.map((k, v) => MapEntry(k, v.toString()));
  }

  String translate(String key) => _strings[key] ?? key;

  // ─── General ──────────────────────────────────────────────
  String get appName         => translate('appName');
  String get ok              => translate('ok');
  String get cancel          => translate('cancel');
  String get save            => translate('save');
  String get retry           => translate('retry');
  String get loading         => translate('loading');
  String get noResults       => translate('noResults');
  String get errorOccurred   => translate('errorOccurred');
  String get confirm         => translate('confirm');
  String get done            => translate('done');
  String get delete          => translate('delete');
  String get edit            => translate('edit');
  String get add             => translate('add');
  String get search          => translate('search');
  String get no              => translate('no');
  String get yes             => translate('yes');

  // ─── Navigation ────────────────────────────────────────────
  String get home            => translate('home');
  String get exercises       => translate('exercises');
  String get nutrition       => translate('nutrition');
  String get progress        => translate('progress');
  String get profile         => translate('profile');
  String get workoutPlan     => translate('workoutPlan');
  String get settings        => translate('settingsLabel');

  // ─── Auth ─────────────────────────────────────────────────
  String get login           => translate('login');
  String get logout          => translate('logout');
  String get signUp          => translate('signUp');
  String get continueAsGuest => translate('continueAsGuest');
  String get email           => translate('email');
  String get password        => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get name            => translate('name');
  String get welcomeBack     => translate('welcomeBack');
  String get forgotPassword  => translate('forgotPassword');
  String get recoverPassword => translate('recoverPassword');
  String get enterEmail      => translate('enterEmail');
  String get invalidEmail    => translate('invalidEmail');
  String get sendLink        => translate('sendLink');
  String get enterPassword   => translate('enterPassword');
  String get passwordTooShort => translate('passwordTooShort');
  String get enterFullName   => translate('enterFullName');
  String get nameTooShort    => translate('nameTooShort');
  String get atLeast8Chars   => translate('atLeast8Chars');
  String get confirmPasswordHint => translate('confirmPasswordHint');
  String get passwordsMismatch => translate('passwordsMismatch');
  String get createAccount   => translate('createAccount');
  String get signUpWithGoogle => translate('signUpWithGoogle');
  String get guestModeTitle  => translate('guestModeTitle');
  String get guestModeSubtitle => translate('guestModeSubtitle');
  String get signinToSave    => translate('signinToSave');
  String get guestWarning    => translate('guestWarning');
  String get loginToSave     => translate('loginToSave');
  String get logoutConfirmContent => translate('logoutConfirmContent');
  String get createAccountLogin => translate('createAccountLogin');
  String get continueWithAccount => translate('continueWithAccount');
  String get continueAsGuestAction => translate('continueAsGuestAction');
  String get startFitnessJourney => translate('startFitnessJourney');
  String get welcomeTitle    => translate('welcomeTitle');
  String get passwordChangedSuccess => translate('passwordChangedSuccess');
  String get changePassword  => translate('changePassword');
  String get createNewPassword => translate('createNewPassword');
  String get useStrongPassword => translate('useStrongPassword');
  String get newPassword     => translate('newPassword');
  String get savePassword    => translate('savePassword');

  // ─── Home ─────────────────────────────────────────────────
  String get goodMorning     => translate('goodMorning');
  String get goodAfternoon   => translate('goodAfternoon');
  String get goodEvening     => translate('goodEvening');
  String get quickAccess     => translate('quickAccess');
  String get todayWorkout    => translate('todayWorkout');
  String get currentStreak   => translate('currentStreak');
  String get day             => translate('day');
  String get days            => translate('days');
  String get activeTime      => translate('activeTime');
  String get minutesToday    => translate('minutesToday');
  String get caloriesLabel   => translate('caloriesLabel');
  String get kcalToday       => translate('kcalToday');
  String get dailyGoals      => translate('dailyGoals');
  String get movement        => translate('movement');
  String get kcal            => translate('kcal');
  String get minute          => translate('minute');
  String get exerciseLabel   => translate('exerciseLabel');
  String get gram            => translate('gram');
  String get startWeeklySetup => translate('startWeeklySetup');
  String get selectExercisesForEachDay => translate('selectExercisesForEachDay');
  String get setupWeeklyPlan => translate('setupWeeklyPlan');
  String get startWorkout    => translate('startWorkout');
  String get logWorkout      => translate('logWorkout');

  // ─── Quick Access Grid ────────────────────────────────────
  String get qaMyProgress    => translate('qaMyProgress');
  String get qaViewStats     => translate('qaViewStats');
  String get qaNutrition     => translate('qaNutrition');
  String get qaTrackMeals    => translate('qaTrackMeals');
  String get qaExercises     => translate('qaExercises');
  String get qaBrowseLibrary => translate('qaBrowseLibrary');
  String get qaMyAccount     => translate('qaMyAccount');
  String get qaPersonalData  => translate('qaPersonalData');

  // ─── Exercises ────────────────────────────────────────────
  String get exerciseLibrary => translate('exerciseLibrary');
  String get searchExercise  => translate('searchExercise');
  String get thisWeekLabel   => translate('thisWeekLabel');
  String get todayExercises  => translate('todayExercises');
  String get all             => translate('all');
  String get forearms        => translate('forearms');
  String get calves          => translate('calves');
  String get neck            => translate('neck');
  String get shoulders       => translate('shoulders');
  String get upperLegs       => translate('upperLegs');
  String get waist           => translate('waist');
  String get secondaryMuscles => translate('secondaryMuscles');
  String get howToPerform    => translate('howToPerform');
  String get addToPlan       => translate('addToPlan');
  String get addToWhichDay   => translate('addToWhichDay');
  String get alreadyAdded    => translate('alreadyAdded');
  String get noWorkoutPlan   => translate('noWorkoutPlan');
  String get restLabel       => translate('restLabel');
  String get noExercises     => translate('noExercises');
  String get muscleChest     => translate('muscleChest');
  String get muscleBack      => translate('muscleBack');
  String get muscleLegs      => translate('muscleLegs');
  String get muscleShoulder  => translate('muscleShoulder');
  String get muscleArms      => translate('muscleArms');
  String get muscleCore      => translate('muscleCore');
  String get muscleCardio    => translate('muscleCardio');
  String get levelBeginner   => translate('levelBeginner');
  String get levelIntermediate => translate('levelIntermediate');
  String get levelAdvanced   => translate('levelAdvanced');
  String get level           => translate('level');

  // ─── Workout Logger ───────────────────────────────────────
  String get cancelWorkoutQ  => translate('cancelWorkoutQ');
  String get cancelWorkoutConfirm => translate('cancelWorkoutConfirm');
  String get finishWorkout   => translate('finishWorkout');
  String get greatJob        => translate('greatJob');
  String get excellent       => translate('excellent');
  String get exerciseUnit    => translate('exerciseUnit');
  String get setUnit         => translate('setUnit');

  // ─── Workout Plan ─────────────────────────────────────────
  String get restDay         => translate('restDay');
  String get planSaved       => translate('planSaved');
  String get addExercise     => translate('addExercise');
  String get sets            => translate('sets');
  String get reps            => translate('reps');

  // ─── Progress ─────────────────────────────────────────────
  String get consecutiveDay  => translate('consecutiveDay');
  String get totalCalories   => translate('totalCalories');
  String get sportsJourney   => translate('sportsJourney');
  String get progressTitle   => translate('progressTitle');
  String get underweight     => translate('underweight');
  String get normalWeight    => translate('normalWeight');
  String get overweight      => translate('overweight');
  String get obese           => translate('obese');
  String get bodyMeasurements => translate('bodyMeasurements');
  String get updateWeight    => translate('updateWeight');
  String get bmiLabel        => translate('bmiLabel');
  String get weeklyWorkouts  => translate('weeklyWorkouts');
  String get dailyActivity   => translate('dailyActivity');
  String get fromStepsAndNutrition => translate('fromStepsAndNutrition');
  String get avgSteps        => translate('avgSteps');
  String get avgCalories     => translate('avgCalories');
  String get avgWater        => translate('avgWater');
  String get workoutPlanCommitment => translate('workoutPlanCommitment');
  String get last7Days       => translate('last7Days');
  String get logMealsAndSteps => translate('logMealsAndSteps');

  // ─── Nutrition ────────────────────────────────────────────
  String get searchFood      => translate('searchFood');
  String get breakfast       => translate('breakfast');
  String get lunch           => translate('lunch');
  String get dinner          => translate('dinner');
  String get snack           => translate('snack');
  String get breakfastLabel  => translate('breakfastLabel');
  String get lunchLabel      => translate('lunchLabel');
  String get dinnerLabel     => translate('dinnerLabel');
  String get snackLabel      => translate('snackLabel');
  String get calories        => translate('calories');
  String get protein         => translate('protein');
  String get carbs           => translate('carbs');
  String get fat             => translate('fat');
  String get water           => translate('water');
  String get trackYourDay    => translate('trackYourDay');
  String get mealsLabel      => translate('mealsLabel');
  String get addMore         => translate('addMore');
  String get waterLabel      => translate('waterLabel');
  String get tapToAddMeal    => translate('tapToAddMeal');
  String get addMoreItems    => translate('addMoreItems');
  String get deleteItemQ     => translate('deleteItemQ');
  String get calorieGoal     => translate('calorieGoal');
  String get waterGoal       => translate('waterGoal');

  // ─── Profile ──────────────────────────────────────────────
  String get personalData    => translate('personalData');
  String get nameLabel       => translate('nameLabel');
  String get ageLabel        => translate('ageLabel');
  String get height          => translate('height');
  String get weight          => translate('weight');
  String get goal            => translate('goal');
  String get activityLevel   => translate('activityLevel');
  String get darkMode        => translate('darkMode');
  String get gender          => translate('gender');
  String get male            => translate('male');
  String get female          => translate('female');
  String get loseWeight      => translate('loseWeight');
  String get gainMuscle      => translate('gainMuscle');
  String get maintain        => translate('maintain');

  // ─── Onboarding ───────────────────────────────────────────
  String get onboardingTitle1   => translate('onboardingTitle1');
  String get onboardingSubtitle1 => translate('onboardingSubtitle1');
  String get onboardingTitle2   => translate('onboardingTitle2');
  String get onboardingSubtitle2 => translate('onboardingSubtitle2');
  String get onboardingTitle3   => translate('onboardingTitle3');
  String get onboardingSubtitle3 => translate('onboardingSubtitle3');
  String get tellUsAboutYourself => translate('tellUsAboutYourself');
  String get calculateGoalsAccurately => translate('calculateGoalsAccurately');
  String get yourNameHint    => translate('yourNameHint');
  String get years           => translate('years');
  String get startJourney    => translate('startJourney');
  String get next            => translate('next');
  String get skip            => translate('skip');

  // ─── Units ────────────────────────────────────────────────
  String get cm              => translate('cm');
  String get kg              => translate('kg');
  String get inch            => translate('inch');
  String get lb              => translate('lb');
  String get g               => translate('g');
  String get ml              => translate('ml');
  String get l               => translate('l');
  String get steps           => translate('steps');

  // ─── Days ─────────────────────────────────────────────────
  String get sunday          => translate('sunday');
  String get monday          => translate('monday');
  String get tuesday         => translate('tuesday');
  String get wednesday       => translate('wednesday');
  String get thursday        => translate('thursday');
  String get friday          => translate('friday');
  String get saturday        => translate('saturday');
  String get dayLetterSun    => translate('dayLetterSun');
  String get dayLetterMon    => translate('dayLetterMon');
  String get dayLetterTue    => translate('dayLetterTue');
  String get dayLetterWed    => translate('dayLetterWed');
  String get dayLetterThu    => translate('dayLetterThu');
  String get dayLetterFri    => translate('dayLetterFri');
  String get dayLetterSat    => translate('dayLetterSat');
  String get shortSun        => translate('shortSun');
  String get shortMon        => translate('shortMon');
  String get shortTue        => translate('shortTue');
  String get shortWed        => translate('shortWed');
  String get shortThu        => translate('shortThu');
  String get shortFri        => translate('shortFri');
  String get shortSat        => translate('shortSat');

  // ─── Misc ─────────────────────────────────────────────────
  String get language        => translate('language');
  String get arabic          => translate('arabic');
  String get english         => translate('english');
  String get workoutReminder => translate('workoutReminder');
  String get waterReminder   => translate('waterReminder');
  String get stepsReminder   => translate('stepsReminder');
  String get feedback        => translate('feedback');
  String get privacyPolicy   => translate('privacyPolicy');
  String get termsConditions => translate('termsConditions');
  String get general         => translate('general');
  String get today           => translate('today');
  String get weekly          => translate('weekly');
  String get monthly         => translate('monthly');
  String get stepsGoal       => translate('stepsGoal');

  bool get isRtl => locale.languageCode == 'ar';

  /// Convenience: day letter from weekday (1=Mon … 7=Sun)
  String dayLetter(int weekday) {
    switch (weekday) {
      case 1: return dayLetterMon;
      case 2: return dayLetterTue;
      case 3: return dayLetterWed;
      case 4: return dayLetterThu;
      case 5: return dayLetterFri;
      case 6: return dayLetterSat;
      case 7: return dayLetterSun;
      default: return '';
    }
  }

  /// Convenience: short day name from weekday (1=Mon … 7=Sun)
  String shortDay(int weekday) {
    switch (weekday) {
      case 1: return shortMon;
      case 2: return shortTue;
      case 3: return shortWed;
      case 4: return shortThu;
      case 5: return shortFri;
      case 6: return shortSat;
      case 7: return shortSun;
      default: return '';
    }
  }

  /// Full day names ordered Sat-first (index 0=Sat)
  List<String> get dayNamesSatFirst =>
      [saturday, sunday, monday, tuesday, wednesday, thursday, friday];

  /// Short day letters ordered Fri-first (for weekly charts, RTL friendly)
  List<String> get dayLettersFriFirst =>
      [dayLetterFri, dayLetterThu, dayLetterWed, dayLetterTue, dayLetterMon, dayLetterSun, dayLetterSat];

  /// Short day names ordered Sun-first (for week strip display)
  List<String> get shortDaysSunFirst =>
      [shortSun, shortMon, shortTue, shortWed, shortThu, shortFri, shortSat];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final l = AppLocalizations(locale);
    await l.load();
    return l;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Quick access extension for widgets
extension LocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isArabic => l10n.isRtl;
}
