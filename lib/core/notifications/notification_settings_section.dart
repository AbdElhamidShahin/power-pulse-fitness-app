import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'notification_service.dart';

class NotificationSettingsSection extends StatefulWidget {
  const NotificationSettingsSection({super.key});

  @override
  State<NotificationSettingsSection> createState() =>
      _NotificationSettingsSectionState();
}

class _NotificationSettingsSectionState
    extends State<NotificationSettingsSection> {
  static const _keyWorkout = 'notif_workout';
  static const _keySteps   = 'notif_steps';
  static const _keyWater   = 'notif_water';

  bool _workout = true;
  bool _steps   = true;
  bool _water   = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workout = prefs.getBool(_keyWorkout) ?? true;
      _steps   = prefs.getBool(_keySteps)   ?? true;
      _water   = prefs.getBool(_keyWater)   ?? false;
      _loading = false;
    });
  }

  Future<void> _toggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    final ns = NotificationService.instance;

    switch (key) {
      case _keyWorkout:
        setState(() => _workout = value);
        if (value) {
          await ns.scheduleWorkoutMorningReminder();
          await ns.scheduleWorkoutEveningReminder();
        } else {
          await ns.cancelWorkoutReminders();
        }
      case _keySteps:
        setState(() => _steps = value);
        if (value) {
          await ns.scheduleStepsReminder();
        } else {
          await ns.cancelStepsReminder();
        }
      case _keyWater:
        setState(() => _water = value);
        if (value) {
          await ns.scheduleWaterReminders();
        } else {
          await ns.cancelWaterReminders();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإشعارات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              _NotifTile(
                emoji:    '💪',
                title:    'تذكير التمرين',
                subtitle: '8 ص و 6 م يومياً',
                value:    _workout,
                onChanged: (v) => _toggle(_keyWorkout, v),
              ),
              Divider(height: 1, color: AppColors.borderSubtle),
              _NotifTile(
                emoji:    '👟',
                title:    'تذكير الخطوات',
                subtitle: '12 الظهر لو لسه بعيد عن الهدف',
                value:    _steps,
                onChanged: (v) => _toggle(_keySteps, v),
              ),
              Divider(height: 1, color: AppColors.borderSubtle),
              _NotifTile(
                emoji:    '💧',
                title:    'تذكير الماء',
                subtitle: 'كل ساعتين من 8 ص لـ 10 م',
                value:    _water,
                onChanged: (v) => _toggle(_keyWater, v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 22.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
