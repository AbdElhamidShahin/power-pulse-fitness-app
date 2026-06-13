import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../widgets/workout_day_button.dart';
import '../widgets/system_banner.dart';

class YourExersize extends StatelessWidget {
  YourExersize({super.key});

  static const _systemName = 'النظام الخاص';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PpBackBar(title: _systemName),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
            top: AppSpacing.sm, bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SystemBanner(
              label: 'Custom 7-Day Split',
              description:
                  'برنامج مخصص لكل أيام الأسبوع. '
                  'أضف تمارينك لكل يوم وابنِ روتينك الخاص.',
              color: AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.xs),
            const WorkoutDayButton(
              titlee: 'اليوم الأول', type: 'Day 1',
              systemName: _systemName, muscleGroup: 'اليوم الأول'),
            const WorkoutDayButton(
              titlee: 'اليوم الثاني', type: 'Day 2',
              systemName: _systemName, muscleGroup: 'اليوم الثاني'),
            const WorkoutDayButton(
              titlee: 'اليوم الثالث', type: 'Day 3',
              systemName: _systemName, muscleGroup: 'اليوم الثالث'),
            const WorkoutDayButton(
              titlee: 'اليوم الرابع', type: 'Day 4',
              systemName: _systemName, muscleGroup: 'اليوم الرابع'),
            const WorkoutDayButton(
              titlee: 'اليوم الخامس', type: 'Day 5',
              systemName: _systemName, muscleGroup: 'اليوم الخامس'),
            const WorkoutDayButton(
              titlee: 'اليوم السادس', type: 'Day 6',
              systemName: _systemName, muscleGroup: 'اليوم السادس'),
            const WorkoutDayButton(
              titlee: 'اليوم السابع', type: 'Day 7',
              systemName: _systemName, muscleGroup: 'اليوم السابع'),
          ],
        ),
      ),
    );
  }
}
