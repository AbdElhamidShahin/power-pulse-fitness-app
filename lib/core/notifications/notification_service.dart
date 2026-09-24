import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  static const int idWaterReminder = 4;
  static const int idAchievement = 5;

  // ─── Init ─────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database.
    tz.initializeTimeZones();

    // Egypt timezone.
    tz.setLocalLocation(
      tz.getLocation('Africa/Cairo'),
    );

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
      body: 'نص اليوم عدى — قوم اتمشى لو الخطوات أقل من هدفك',
      hour: 12,
      minute: 0,
      channel: _chSteps,
    );
  }

  // ─── Water Reminders ─────────────────────────────────────

  Future<void> scheduleWaterReminders() async {
    const List<int> hours = [
      8,
      10,
      12,
      14,
      16,
      18,
      20,
    ];

    for (final int hour in hours) {
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
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chAchievement,
          'الإنجازات',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showStepsGoalReached(int steps) async {
    await _plugin.show(
      idAchievement + 1,
      '🏆 وصلت لهدف الخطوات!',
      '$steps خطوة اليوم — متميز!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _chAchievement,
          'الإنجازات',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(),
      ),
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
    const List<int> hours = [
      8,
      10,
      12,
      14,
      16,
      18,
      20,
    ];

    for (final int hour in hours) {
      await _plugin.cancel(idWaterReminder + hour);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ─── Internal Schedule Helper ─────────────────────────────

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

    // If today's time already passed,
    // schedule it for tomorrow.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(
        const Duration(days: 1),
      );
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
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
      DateTimeComponents.time,
    );
  }
}
