import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.trainedToday});
  final bool trainedToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile,
          AppSpacing.sm, AppSpacing.marginMobile, AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_dateLabel(), style: AppTextStyles.labelMuted),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_greeting(), style: AppTextStyles.labelMuted),
              const SizedBox(height: 2),
              Text(
                trainedToday ? 'تمرين اليوم مكتمل' : 'لنبدأ التدريب',
                style: AppTextStyles.headlineMd.copyWith(
                  color: trainedToday
                      ? AppColors.success
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 17) return 'مساء النشاط';
    return 'مساء الخير';
  }

  String _dateLabel() {
    const days = [
      'الأحد', 'الاثنين', 'الثلاثاء',
      'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
    ];
    final now = DateTime.now();
    return '${days[now.weekday % 7]} · ${now.day}/${now.month}';
  }
}