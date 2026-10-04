import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// خدمة الترجمة — تقرأ ملفات JSON من assets/langs/
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

  String get appName         => translate('appName');
  String get home            => translate('home');
  String get exercises       => translate('exercises');
  String get nutrition       => translate('nutrition');
  String get progress        => translate('progress');
  String get profile         => translate('profile');
  String get workoutPlan     => translate('workoutPlan');
  String get settings        => translate('settings');
  String get language        => translate('language');
  String get darkMode        => translate('darkMode');
  String get lightMode       => translate('lightMode');
  String get notifications   => translate('notifications');
  String get logout          => translate('logout');
  String get login           => translate('login');
  String get signUp          => translate('signUp');
  String get continueAsGuest => translate('continueAsGuest');
  String get email           => translate('email');
  String get password        => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get name            => translate('name');
  String get save            => translate('save');
  String get cancel          => translate('cancel');
  String get searchFood      => translate('searchFood');
  String get breakfast       => translate('breakfast');
  String get lunch           => translate('lunch');
  String get dinner          => translate('dinner');
  String get snack           => translate('snack');
  String get calories        => translate('calories');
  String get protein         => translate('protein');
  String get carbs           => translate('carbs');
  String get fat             => translate('fat');
  String get water           => translate('water');
  String get steps           => translate('steps');
  String get weeklyPlan      => translate('weeklyPlan');
  String get startSetup      => translate('startSetup');
  String get arabic          => translate('arabic');
  String get english         => translate('english');
  String get planSaved       => translate('planSaved');
  String get restDay         => translate('restDay');
  String get addExercise     => translate('addExercise');
  String get loading         => translate('loading');
  String get noResults       => translate('noResults');
  String get errorOccurred   => translate('errorOccurred');
  String get welcomeBack     => translate('welcomeBack');
  String get logWorkout      => translate('logWorkout');
  String get startWorkout    => translate('startWorkout');

  // Days
  String get sunday    => translate('sunday');
  String get monday    => translate('monday');
  String get tuesday   => translate('tuesday');
  String get wednesday => translate('wednesday');
  String get thursday  => translate('thursday');
  String get friday    => translate('friday');
  String get saturday  => translate('saturday');

  bool get isRtl => locale.languageCode == 'ar';
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

/// Extension للوصول السريع للترجمات في الـ widgets
extension LocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isArabic => l10n.isRtl;
}
