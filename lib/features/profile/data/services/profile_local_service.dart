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

  static const String _key = 'user_profile';

  @override
  Future<UserProfile?> getProfile() async {
    try {
      final raw = _prefs.getString(_key);

      if (raw == null || raw.isEmpty) {
        return null;
      }

      final json = jsonDecode(raw);

      if (json is! Map<String, dynamic>) {
        throw const FormatException('Invalid profile data');
      }

      return _fromJson(json);
    } catch (e) {
      throw CacheException(
        message: 'خطأ في قراءة بيانات الملف الشخصي: ${e.runtimeType}',
      );
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      final json = _toJson(profile);

      await _prefs.setString(
        _key,
        jsonEncode(json),
      );
    } catch (e) {
      throw CacheException(
        message: 'خطأ في حفظ بيانات الملف الشخصي: ${e.runtimeType}',
      );
    }
  }

  @override
  Future<bool> hasProfile() async {
    return _prefs.containsKey(_key);
  }

  Map<String, dynamic> _toJson(UserProfile profile) {
    return {
      'name': profile.name,
      'email': profile.email,
      'age': profile.age,
      'heightCm': profile.heightCm,
      'weightKg': profile.weightKg,
      'gender': profile.gender.name,
      'goal': profile.goal.name,
      'activityLevel': profile.activityLevel.name,
      'avatarPath': profile.avatarPath,
    };
  }

  UserProfile _fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      gender: Gender.values.firstWhere(
        (e) => e.name == (json['gender'] as String? ?? ''),
        orElse: () => Gender.male,
      ),
      goal: FitnessGoal.values.firstWhere(
        (e) => e.name == (json['goal'] as String? ?? ''),
        orElse: () => FitnessGoal.maintain,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == (json['activityLevel'] as String? ?? ''),
        orElse: () => ActivityLevel.moderate,
      ),
      avatarPath: json['avatarPath'] as String?,
    );
  }
}