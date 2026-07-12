import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/user_profile_entity.dart';

abstract interface class ProfileLocalService {
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<bool> hasProfile();
}

final class ProfileLocalServiceImpl implements ProfileLocalService {
  ProfileLocalServiceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'user_profile';

  @override
  Future<UserProfile?> getProfile() async {
    try {
      final raw = _prefs.getString(_key);
      if (raw == null) return null;
      return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      throw const CacheException(message: 'خطأ في قراءة بيانات الملف الشخصي');
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      await _prefs.setString(_key, jsonEncode(_toJson(profile)));
    } catch (_) {
      throw const CacheException(message: 'خطأ في حفظ الملف الشخصي');
    }
  }

  @override
  Future<bool> hasProfile() async =>
      _prefs.containsKey(_key);

  // ─── JSON ─────────────────────────────────────────────────────
  Map<String, dynamic> _toJson(UserProfile p) => {
        'name':          p.name,
        'age':           p.age,
        'heightCm':      p.heightCm,
        'weightKg':      p.weightKg,
        'gender':        p.gender.name,
        'goal':          p.goal.name,
        'activityLevel': p.activityLevel.name,
        'avatarPath':    p.avatarPath,
      };

  UserProfile _fromJson(Map<String, dynamic> j) => UserProfile(
        name:          j['name'] as String,
        age:           j['age'] as int,
        heightCm:      (j['heightCm'] as num).toDouble(),
        weightKg:      (j['weightKg'] as num).toDouble(),
        gender:        Gender.values.byName(j['gender'] as String),
        goal:          FitnessGoal.values.byName(j['goal'] as String),
        activityLevel: ActivityLevel.values.byName(j['activityLevel'] as String),
        avatarPath:    j['avatarPath'] as String?,
      );
}
