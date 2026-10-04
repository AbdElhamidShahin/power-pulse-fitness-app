import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ─── Notification Channels ───────────────────────────────

  static const String _chWorkout = 'workout_reminder';
  static const String _chSteps = 'steps_reminder';
  static const String _chWater = 'water_reminder';
  static const String _chAchievement = 'achievement';

  // ─── Notification IDs ────────────────────────────────────

  static const int idWorkoutMorning = 1;
  static const int idWorkoutEvening = 2;
  static const int idStepsReminder = 3;
  static const int idWaterReminder = 100; // 100 + hour
  static const int idAchievement = 5;

  // ─── SharedPreferences keys (نفس اللي بيستخدمها قسم الإعدادات) ──
  static const String kMaster = 'settings_notifications';
  static const String kWorkout = 'notif_workout';
  static const String kSteps = 'notif_steps';
  static const String kWater = 'notif_water';
  static const String _kPermissionAsked = 'notif_permission_asked';

  static const List<int> _waterHours = [8, 10, 12, 14, 16, 18, 20];

  // ─── Init ─────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database.
    tz.initializeTimeZones();

    // Egypt timezone.
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (_) {
      // fallback: UTC
    }

    // Android initialization.
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    // iOS initialization.
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    await _createChannels();

    _initialized = true;
  }

  // ─── Sync مع الإعدادات المحفوظة ───────────────────────────
  //
  // BUGFIX (السبب الرئيسي لإن الإشعارات مكانتش بتشتغل):
  // الإعدادات كانت بتتحفظ بس مفيش حد بيجدول الإشعارات عند فتح التطبيق —
  // الجدولة كانت بتحصل بس لما المستخدم يقلّب السويتش بإيده.
  // دلوقتي بنطلب الإذن مرة واحدة وبنجدول كل اللي مفعّل في كل تشغيل.

  Future<void> syncFromPrefs(SharedPreferences prefs) async {
    try {
      if (!_initialized) await init();

      if (!(prefs.getBool(_kPermissionAsked) ?? false)) {
        await prefs.setBool(_kPermissionAsked, true);
        await requestPermissions();
      }

      final master = prefs.getBool(kMaster) ?? true;
      if (!master) {
        await cancelAll();
        return;
      }

      if (prefs.getBool(kWorkout) ?? true) {
        await scheduleWorkoutMorningReminder();
        await scheduleWorkoutEveningReminder();
      } else {
        await cancelWorkoutReminders();
      }

      if (prefs.getBool(kSteps) ?? true) {
        await scheduleStepsReminder();
      } else {
        await cancelStepsReminder();
      }

      if (prefs.getBool(kWater) ?? false) {
        await scheduleWaterReminders();
      } else {
        await cancelWaterReminders();
      }
    } catch (e) {
      debugPrint('NotificationService.syncFromPrefs failed: $e');
    }
  }

  /// إشعار فوري للتجربة (زرار "جرّب الإشعار")
  Future<void> showTest() async {
    if (!_initialized) await init();
    await _plugin.show(
      99,
      '🔔 الإشعارات شغّالة',
      'تمام! هتوصلك التذكيرات في مواعيدها.',
      _details(_chAchievement),
    );
  }

  // ─── Request Permissions ──────────────────────────────────

  Future<bool> requestPermissions() async {
    if (!_initialized) await init();

    // Android 13+
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      // أندرويد 12+: الجدولة الدقيقة محتاجة إذن "المنبهات والتذكيرات"
      try {
        final canExact = await android.canScheduleExactNotifications() ?? false;
        if (!canExact) await android.requestExactAlarmsPermission();
      } catch (_) {}
      return granted ?? false;
    }

    // iOS
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }



  // ─── Background Notification Callback ────────────────────

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(
    NotificationResponse response,
  ) {
    // Add navigation/background logic here if needed.
  }

  // ─── Foreground Notification Callback ────────────────────

  void _onNotificationResponse(
    NotificationResponse response,
  ) {
    // Add navigation logic here if needed.
  }

  // ─── Notification Channels ───────────────────────────────

  Future<void> _createChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _chWorkout,
        'تذكير التمرين',
        description: 'إشعارات تذكير بمواعيد التمرين',
        importance: Importance.high,
        playSound: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _chSteps,
        'تذكير الخطوات',
        description: 'إشعارات تذكير بعداد الخطوات',
        importance: Importance.defaultImportance,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _chWater,
        'تذكير الماء',
        description: 'إشعارات تذكير بشرب الماء',
        importance: Importance.low,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _chAchievement,
        'الإنجازات',
        description: 'إشعارات الإنجازات والأهداف',
        importance: Importance.high,
        playSound: true,
      ),
    );
  }

  // ─── Request Permission ───────────────────────────────────

  Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted = await android?.requestNotificationsPermission();

    return granted ?? false;
  }

  // ─── Workout Reminders ───────────────────────────────────

  Future<void> scheduleWorkoutMorningReminder() async {
    await _scheduleDailyAt(
      id: idWorkoutMorning,
      title: '💪 وقت التمرين!',
      body: 'ابدأ يومك بتمرين قوي — جسمك يشكرك لاحقاً',
      hour: 8,
      minute: 0,
      channel: _chWorkout,
    );
  }

  Future<void> scheduleWorkoutEveningReminder() async {
    await _scheduleDailyAt(
      id: idWorkoutEvening,
      title: '🔥 لسه فيه وقت!',
      body: 'اليوم راح من غير تمرين؟ 15 دقيقة كفاية تبدأ بيها',
      hour: 18,
      minute: 0,
      channel: _chWorkout,
    );
  }

  // ─── Steps Reminder ───────────────────────────────────────

  Future<void> scheduleStepsReminder() async {
    await _scheduleDailyAt(
      id: idStepsReminder,
      title: '👟 تحرك شوية!',
      body: 'نص اليوم عدّى — افتح التطبيق وشوف وصلت لفين في هدف الخطوات',
      hour: 12,
      minute: 0,
      channel: _chSteps,
    );
  }

  // ─── Water Reminders ─────────────────────────────────────

  Future<void> scheduleWaterReminders() async {
    for (final int hour in _waterHours) {
      await _scheduleDailyAt(
        id: idWaterReminder + hour,
        title: '💧 اشرب ماء!',
        body: 'جسمك محتاج ماء — كوباية صغيرة كل شوية',
        hour: hour,
        minute: 0,
        channel: _chWater,
      );
    }
  }

  // ─── Achievement Notifications ────────────────────────────

  Future<void> showWorkoutCompleted({
    required String workoutName,
    required int durationMinutes,
  }) async {
    await _plugin.show(
      idAchievement,
      '🎉 أنهيت تمرينك!',
      '$workoutName — $durationMinutes دقيقة. عمل رائع!',
      _details(_chAchievement),
    );
  }

  Future<void> showStepsGoalReached(int steps) async {
    await _plugin.show(
      idAchievement + 1,
      '🏆 وصلت لهدف الخطوات!',
      '$steps خطوة اليوم — متميز!',
      _details(_chAchievement),
    );
  }

  // ─── Cancel ───────────────────────────────────────────────

  Future<void> cancelWorkoutReminders() async {
    await _plugin.cancel(idWorkoutMorning);
    await _plugin.cancel(idWorkoutEvening);
  }

  Future<void> cancelStepsReminder() async {
    await _plugin.cancel(idStepsReminder);
  }

  Future<void> cancelWaterReminders() async {
    for (final int hour in _waterHours) {
      await _plugin.cancel(idWaterReminder + hour);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Internal Schedule Helper ─────────────────────────────

  NotificationDetails _details(String channel) => NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          _channelName(channel),
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      );

  String _channelName(String id) => switch (id) {
        _chWorkout => 'تذكير التمرين',
        _chSteps => 'تذكير الخطوات',
        _chWater => 'تذكير الماء',
        _ => 'الإنجازات',
      };

  /// أندرويد 12+ ممكن يرفض الجدولة الدقيقة لو الإذن مش ممنوح →
  /// بنرجع للجدولة التقريبية بدل ما الإشعار ميتجدولش خالص.
  Future<AndroidScheduleMode> _scheduleMode() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return AndroidScheduleMode.exactAllowWhileIdle;
    try {
      final canExact = await android.canScheduleExactNotifications() ?? false;
      return canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (_) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  Future<void> _scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channel,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If today's time already passed, schedule it for tomorrow.
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _details(channel),
        androidScheduleMode: await _scheduleMode(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification $id: $e');
    }
  }
}
