import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/notifications/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/settings_cubit.dart';

/// قسم إعدادات الإشعارات — بيتحط في صفحة الـ Profile
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
    // طلب permission لما المستخدم يشغّل أي إشعار
    if (value) {
      await NotificationService.instance.requestPermissions();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    switch (key) {
      case _keyWorkout:
        setState(() => _workout = value);
      case _keySteps:
        setState(() => _steps = value);
      case _keyWater:
        setState(() => _water = value);
    }

    if (!mounted) return;
    final master = prefs.getBool(NotificationService.kMaster) ?? true;
    if (value && !master) {
      // لو الزرار الرئيسي للإشعارات مقفول، تشغيل أي نوع بيفتحه
      await context.read<AppSettingsCubit>().toggleNotifications(true);
    } else {
      await NotificationService.instance.syncFromPrefs(prefs);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.notifications,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: Column(
            children: [
              _NotifTile(
                emoji:    '💪',
                title:    context.l10n.workoutReminder,
                subtitle: '8 صباحاً و 6 مساءً يومياً',
                value:    _workout,
                onChanged: (v) => _toggle(_keyWorkout, v),
              ),
              Divider(height: 1, color: context.colors.borderSubtle),
              _NotifTile(
                emoji:    '👟',
                title:    context.l10n.stepsReminder,
                subtitle: '12 ظهراً لو لسه بعيد عن هدفك',
                value:    _steps,
                onChanged: (v) => _toggle(_keySteps, v),
              ),
              Divider(height: 1, color: context.colors.borderSubtle),
              _NotifTile(
                emoji:    '💧',
                title:    context.l10n.waterReminder,
                subtitle: 'كل ساعتين من 8 صباحاً لـ 8 مساءً',
                value:    _water,
                onChanged: (v) => _toggle(_keyWater, v),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () async {
              final granted =
                  await NotificationService.instance.requestPermissions();
              await NotificationService.instance.showTest();
              if (!mounted || granted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'الإشعارات مقفولة من إعدادات الموبايل — فعّلها للتطبيق'),
                ),
              );
            },
            icon: const Icon(Icons.notifications_active_outlined,
                size: 18, color: AppColors.accent),
            label: Text(
              'جرّب الإشعار',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
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
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: context.colors.textMuted,
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
