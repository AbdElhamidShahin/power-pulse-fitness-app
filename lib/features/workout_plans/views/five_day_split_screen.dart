import 'package:flutter/material.dart';
import 'package:task/features/workout_plans/views/widgets/system_banner.dart';
import 'package:task/features/workout_plans/views/widgets/workout_day_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/components/pp_app_bar.dart';

class FiveDaySplitScreen extends StatelessWidget {
  const FiveDaySplitScreen({super.key});

  static const _systemName = 'نظام 5 أيام';

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
              label: 'Five Day Split',
              description:
              'يوم مخصص لكل مجموعة عضلية. '
                  'مثالي للمتقدمين الراغبين في تركيز أعلى لكل عضلة.',
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.xs),
            const WorkoutDayButton(
              titlee: 'اليوم 1 — الصدر',
              type: 'Day 1',
              systemName: _systemName,
              muscleGroup: 'عضلات الصدر',
            ),
            const WorkoutDayButton(
              titlee: 'اليوم 2 — الظهر',
              type: 'Day 2',
              systemName: _systemName,
              muscleGroup: 'عضلات الظهر',
            ),
            const WorkoutDayButton(
              titlee: 'اليوم 3 — الأكتاف',
              type: 'Day 3',
              systemName: _systemName,
              muscleGroup: 'عضلات الكتفين',
            ),
            const WorkoutDayButton(
              titlee: 'اليوم 4 — الذراعين',
              type: 'Day 4',
              systemName: _systemName,
              muscleGroup: 'الذراعين',
            ),
            const WorkoutDayButton(
              titlee: 'اليوم 5 — الأرجل',
              type: 'Day 5',
              systemName: _systemName,
              muscleGroup: 'عضلات الأرجل',
            ),
          ],
        ),
      ),
    );
  }
}
