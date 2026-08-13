import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// بعد تسجيل الدخول أو إنشاء الحساب، نحفظ بيانات المستخدم الأساسية
/// في نفس الـ key اللي بيقراه ProfileLocalService — عشان Home و Profile يشتغلوا صح.
abstract class AuthProfileSync {
  static const String _key = 'user_profile';

  /// نحفظ الـ name و email من Firebase Auth كـ UserProfile أساسي
  static Future<void> saveFromAuth({
    required SharedPreferences prefs,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    // نقرأ الـ profile الموجود (لو كان الشخص سجّل من قبل)
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      // الـ profile موجود — بس نحدّث الـ name و email
      try {
        final json = jsonDecode(existing) as Map<String, dynamic>;
        json['name'] = name;
        json['email'] = email;
        if (avatarUrl != null) json['avatarPath'] = avatarUrl;
        await prefs.setString(_key, jsonEncode(json));
      } catch (_) {
        // لو فشل التحديث، نكتب profile جديد
        await _writeDefault(prefs, name: name, email: email, avatarUrl: avatarUrl);
      }
      return;
    }

    // مفيش profile — نكتب الـ default بالبيانات من Firebase Auth
    await _writeDefault(prefs, name: name, email: email, avatarUrl: avatarUrl);
  }

  static Future<void> _writeDefault(
    SharedPreferences prefs, {
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final json = {
      'name': name.isNotEmpty ? name : 'مستخدم',
      'email': email,
      'age': 25,
      'heightCm': 175.0,
      'weightKg': 75.0,
      'gender': 'male',
      'goal': 'maintain',
      'activityLevel': 'moderate',
      'avatarPath': avatarUrl,
    };
    await prefs.setString(_key, jsonEncode(json));
  }
}
