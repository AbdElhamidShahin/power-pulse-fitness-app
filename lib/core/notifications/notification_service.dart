import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _chWorkout = 'workout_reminder';
  static const _chSteps = 'steps_reminder';
  static const _chWater = 'water_reminder';
  static const _chAchievement = 'achievement';

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

    // v20.1.0: initialize() — ALL named parameters.
    // Signature: initialize({required InitializationSettings settings, ...})
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    await _createChannels();
    _initialized = true;
  }

  // Must be static (top-level equivalent) for background isolate use.
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // Background tap — add navigation logic here if needed.
  }

  void _onNotificationResponse(NotificationResponse response) {
    // Foreground tap — add navigation logic here if needed.
  }

  Future<void> _createChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
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
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  // ─── Workout Reminders ────────────────────────────────────
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

  Future<void> scheduleWaterReminders() async {
    final hours = [8, 10, 12, 14, 16, 18, 20];
    for (final h in hours) {
      await _scheduleDailyAt(
        id: idWaterReminder + h,
        title: '💧 اشرب ماء!',
        body: 'جسمك محتاج ماء — كوباية صغيرة كل شوية',
        hour: h,
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
    // v20.1.0: show() — ALL named parameters.
    // Signature: show({required int id, String? title, String? body,
    //                  NotificationDetails? notificationDetails, String? payload})
    await _plugin.show(
      id: idAchievement,
      title: '🎉 أنهيت تمرينك!',
      body: '$workoutName — $durationMinutes دقيقة. عمل رائع!',
      notificationDetails: const NotificationDetails(
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
      id: idAchievement + 1,
      title: '🏆 وصلت لهدف الخطوات!',
      body: '$steps خطوة اليوم — متميز!',
      notificationDetails: const NotificationDetails(
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
  // v20.1.0: cancel() — named parameter.
  // Signature: cancel({required int id, String? tag})
  Future<void> cancelWorkoutReminders() async {
    await _plugin.cancel(id: idWorkoutMorning);
    await _plugin.cancel(id: idWorkoutEvening);
  }

  Future<void> cancelStepsReminder() async {
    await _plugin.cancel(id: idStepsReminder);
  }

  Future<void> cancelWaterReminders() async {
    for (final h in [8, 10, 12, 14, 16, 18, 20]) {
      await _plugin.cancel(id: idWaterReminder + h);
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  // ─── Internal helper ──────────────────────────────────────
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
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // v20.1.0: zonedSchedule() — ALL named parameters.
    // Signature: zonedSchedule({required int id,
    //                           required TZDateTime scheduledDate,
    //                           required NotificationDetails notificationDetails,
    //                           required AndroidScheduleMode androidScheduleMode,
    //                           String? title, String? body, String? payload,
    //                           DateTimeComponents? matchDateTimeComponents})
    // NOTE: `title` and `body` come AFTER the three required params.
    // NOTE: `uiLocalNotificationDateInterpretation` is REMOVED in v20.
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channel,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
