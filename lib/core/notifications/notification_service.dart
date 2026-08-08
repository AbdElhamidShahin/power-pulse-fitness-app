import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// NotificationService — كل الإشعارات الـ offline بتعدي من هنا
/// تشتغل حتى لو التطبيق مقفول ومفيش نت
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ─── Channel IDs ──────────────────────────────────────────
  static const _chWorkout = 'workout_reminder';
  static const _chSteps = 'steps_reminder';
  static const _chWater = 'water_reminder';
  static const _chAchievement = 'achievement';

  // ─── Notification IDs ─────────────────────────────────────
  static const idWorkoutMorning = 1;
  static const idWorkoutEvening = 2;
  static const idStepsReminder = 3;
  static const idWaterReminder = 4;
  static const idAchievement = 5;

  // ─── Init ─────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _createChannels();
    _initialized = true;
  }

  Future<void> _createChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin
        ?.createNotificationChannel(const AndroidNotificationChannel(
      _chWorkout,
      'تذكير التمرين',
      description: 'إشعارات تذكير بمواعيد التمرين',
      importance: Importance.high,
      playSound: true,
    ));
    await androidPlugin
        ?.createNotificationChannel(const AndroidNotificationChannel(
      _chSteps,
      'تذكير الخطوات',
      description: 'إشعارات تذكير بعداد الخطوات',
      importance: Importance.defaultImportance,
    ));
    await androidPlugin
        ?.createNotificationChannel(const AndroidNotificationChannel(
      _chWater,
      'تذكير الماء',
      description: 'إشعارات تذكير بشرب الماء',
      importance: Importance.low,
    ));
    await androidPlugin
        ?.createNotificationChannel(const AndroidNotificationChannel(
      _chAchievement,
      'الإنجازات',
      description: 'إشعارات الإنجازات والأهداف',
      importance: Importance.high,
      playSound: true,
    ));
  }

  // ─── Request Permission ───────────────────────────────────
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // ═══════════════════════════════════════════════════════════
  // ─── Workout Reminders ────────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  /// تذكير صباحي يومي — 8 الصبح
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

  /// تذكير مسائي — 6 المساء لو اليوزر مش اتمرن
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

  // ═══════════════════════════════════════════════════════════
  // ─── Steps Reminder ───────────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  /// تذكير الخطوات — 12 الظهر
  Future<void> scheduleStepsReminder() async {
    await _scheduleDailyAt(
      id: idStepsReminder,
      title: '👟 تحرك شوية!',
      body: 'نص اليوم عدى — قوم اتمشى لو الخطوات أقل من هدفك',
      hour: 12,
      minute: 0,
      channel: _chSteps,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── Water Reminder ───────────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  /// تذكير الماء — كل 2 ساعة من 8 الصبح لـ 10 الليل
  Future<void> scheduleWaterReminders() async {
    final hours = [8, 10, 12, 14, 16, 18, 20];
    for (final h in hours) {
      await _scheduleDailyAt(
        id: idWaterReminder + h, // ID فريد لكل ساعة
        title: '💧 اشرب ماء!',
        body: 'جسمك محتاج ماء — كوباية صغيرة كل شوية',
        hour: h,
        minute: 0,
        channel: _chWater,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ─── Achievement Notifications ────────────────────────────
  // ═══════════════════════════════════════════════════════════

  /// إشعار فوري لما اليوزر يخلص تمرين
  Future<void> showWorkoutCompleted({
    required String workoutName,
    required int durationMinutes,
  }) async {
    await _plugin.show(
      idAchievement,
      '🎉 أنهيت تمرينك!',
      '$workoutName — $durationMinutes دقيقة. عمل رائع!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chAchievement,
          'الإنجازات',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }

  /// إشعار فوري لما يوصل الهدف اليومي للخطوات
  Future<void> showStepsGoalReached(int steps) async {
    await _plugin.show(
      idAchievement + 1,
      '🏆 وصلت لهدف الخطوات!',
      '$steps خطوة اليوم — متميز!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _chAchievement,
          'الإنجازات',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ─── Cancel ───────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  Future<void> cancelWorkoutReminders() async {
    await _plugin.cancel(idWorkoutMorning);
    await _plugin.cancel(idWorkoutEvening);
  }

  Future<void> cancelStepsReminder() async {
    await _plugin.cancel(idStepsReminder);
  }

  Future<void> cancelWaterReminders() async {
    for (final h in [8, 10, 12, 14, 16, 18, 20]) {
      await _plugin.cancel(idWaterReminder + h);
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  // ═══════════════════════════════════════════════════════════
  // ─── Helpers ──────────────────────────────────────────────
  // ═══════════════════════════════════════════════════════════

  Future<void> _scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channel,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // لو الوقت عدى النهارده، جدوله بكرة
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channel,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
