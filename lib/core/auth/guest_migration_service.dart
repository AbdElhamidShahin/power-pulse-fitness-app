import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// مزامنة البيانات المحلية (SharedPreferences) مع جدول `user_data` في Supabase.
///
/// ─── ليه اتعدّل الملف ده؟ ─────────────────────────────────────────
/// النسخة القديمة كانت:
///  1. بتستعيد بيانات السحابة **فوق** البيانات المحلية في كل مرة التطبيق
///     يفتح → أي تمرين/خطة/وزن جديد يضيع ويرجع للنسخة القديمة.
///  2. بتستخدم أسماء keys غلط (workout_sessions بدل workout_sessions_history،
///     ومفيش workout_logs ولا الوجبات ولا المياه).
///
/// دلوقتي:
///  • الاستعادة **دمج** (merge) مش استبدال: القوائم بتتدمج بالـ id،
///    والبيانات الموجودة محلياً مبتتمسحش.
///  • كل البيانات (الوجبات، المياه، الخطوات، سجل التمارين…) بتترفع.
///  • الأعمدة المستخدمة هي نفس الأعمدة الموجودة أصلاً في `user_data`
///    (مفيش تغيير في الـ schema): الوجبات/المياه/الخطوات جوه `nutrition_logs`.
abstract class GuestMigrationService {
  GuestMigrationService._();

  // local key → cloud column (قوائم بتتدمج بالـ id)
  static const Map<String, String> _listKeys = {
    'workout_logs': 'progress_entries',
    'weight_entries': 'weight_entries',
    'workout_sessions_history': 'workout_sessions',
  };

  // local key → cloud column (قيمة واحدة)
  static const Map<String, String> _singleKeys = {
    'user_profile': 'user_profile',
    'workout_plan': 'workout_plan',
    'active_workout_session': 'active_workout_session',
  };

  // لما المستخدم يسجّل دخول على حساب موجود: السحابة تكسب في دول
  static const Set<String> _preferCloudOnLogin = {
    'user_profile',
    'workout_plan',
  };

  static const String _nutritionColumn = 'nutrition_logs';

  static bool _isNutritionKey(String k) =>
      k.startsWith('meals_') ||
      k.startsWith('water_') ||
      k.startsWith('steps_') ||
      k == 'calorie_goal';

  // ═══════════════════════════════════════════════════════════════
  // Push
  // ═══════════════════════════════════════════════════════════════

  /// يرفع كل البيانات المحلية للسحابة. (الاسم القديم متحفوظ للتوافق)
  static Future<void> migrateGuestDataToCloud({
    required SharedPreferences prefs,
    required SupabaseClient supabase,
    required String uid,
  }) =>
      pushLocalToCloud(prefs: prefs, supabase: supabase, uid: uid);

  static Future<void> pushLocalToCloud({
    required SharedPreferences prefs,
    required SupabaseClient supabase,
    required String uid,
  }) async {
    final payload = <String, dynamic>{'uid': uid};

    _listKeys.forEach((key, column) {
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) payload[column] = _decode(raw);
    });

    _singleKeys.forEach((key, column) {
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        payload[column] = _decode(raw);
      } else if (key != 'user_profile') {
        // اتمسحت محلياً (خطة اتحذفت / جلسة خلصت) → نمسحها من السحابة كمان
        payload[column] = null;
      }
    });

    final nutrition = <String, dynamic>{};
    for (final k in prefs.getKeys()) {
      if (_isNutritionKey(k)) {
        final v = prefs.get(k);
        if (v != null) nutrition[k] = v;
      }
    }
    if (nutrition.isNotEmpty) payload[_nutritionColumn] = nutrition;

    await supabase.from('user_data').upsert(payload);
  }

  // ═══════════════════════════════════════════════════════════════
  // Restore (merge — never destructive)
  // ═══════════════════════════════════════════════════════════════

  static Future<void> restoreCloudDataToLocal({
    required SharedPreferences prefs,
    required SupabaseClient supabase,
    required String uid,
    bool preferCloud = false,
  }) async {
    final rows =
        await supabase.from('user_data').select().eq('uid', uid).limit(1);
    if (rows.isEmpty) return;
    final row = Map<String, dynamic>.from(rows.first as Map);

    // قوائم → دمج بالـ id
    for (final entry in _listKeys.entries) {
      final cloud = _asDecoded(row[entry.value]);
      if (cloud is! List || cloud.isEmpty) continue;
      final localRaw = prefs.getString(entry.key);
      final local = (localRaw == null || localRaw.isEmpty)
          ? <dynamic>[]
          : (_decode(localRaw) as List<dynamic>? ?? <dynamic>[]);
      await prefs.setString(entry.key, jsonEncode(_mergeById(local, cloud)));
    }

    // قيم مفردة
    for (final entry in _singleKeys.entries) {
      final cloud = row[entry.value];
      if (cloud == null) continue;
      final localRaw = prefs.getString(entry.key);
      final hasLocal = localRaw != null && localRaw.isNotEmpty;
      final cloudWins = preferCloud && _preferCloudOnLogin.contains(entry.key);
      if (!hasLocal || cloudWins) {
        await prefs.setString(
          entry.key,
          cloud is String ? cloud : jsonEncode(cloud),
        );
      }
    }

    // وجبات / مياه / خطوات / هدف السعرات
    final nutrition = _asDecoded(row[_nutritionColumn]);
    if (nutrition is Map) {
      for (final e in nutrition.entries) {
        final k = e.key.toString();
        final v = e.value;
        if (v == null || !_isNutritionKey(k)) continue;

        if (k.startsWith('meals_')) {
          final cloudList = _asDecoded(v);
          final localRaw = prefs.getString(k);
          if (cloudList is List) {
            final local = (localRaw == null || localRaw.isEmpty)
                ? <dynamic>[]
                : (_decode(localRaw) as List<dynamic>? ?? <dynamic>[]);
            await prefs.setString(k, jsonEncode(_mergeById(local, cloudList)));
          }
        } else if (k.startsWith('water_')) {
          final cloudVal = (v as num).toDouble();
          final local = prefs.getDouble(k) ?? 0.0;
          if (cloudVal > local) await prefs.setDouble(k, cloudVal);
        } else if (k.startsWith('steps_')) {
          final cloudVal = (v as num).toInt();
          final local = prefs.getInt(k) ?? 0;
          if (cloudVal > local) await prefs.setInt(k, cloudVal);
        } else if (k == 'calorie_goal') {
          if (!prefs.containsKey(k)) {
            await prefs.setDouble(k, (v as num).toDouble());
          }
        }
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Clear (عند تسجيل الخروج)
  // ═══════════════════════════════════════════════════════════════

  static Future<void> clearLocalUserData(SharedPreferences prefs) async {
    final keys = <String>{
      ..._listKeys.keys,
      ..._singleKeys.keys,
      for (final k in prefs.getKeys())
        if (_isNutritionKey(k)) k,
    };
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────

  static dynamic _decode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return raw;
    }
  }

  static dynamic _asDecoded(dynamic v) => v is String ? _decode(v) : v;

  static List<dynamic> _mergeById(List<dynamic> local, List<dynamic> cloud) {
    final byId = <String, dynamic>{};
    final noId = <dynamic>[];
    for (final item in [...cloud, ...local]) {
      // local بيتحط آخر → بيكسب لو نفس الـ id
      if (item is Map && item['id'] != null) {
        byId[item['id'].toString()] = item;
      } else {
        noId.add(item);
      }
    }
    return [...byId.values, ...noId];
  }
}
