import 'package:flutter/material.dart';
import 'package:task/features/workout_plans/views/widgets/system_banner.dart';
import 'package:task/features/workout_plans/views/widgets/workout_day_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/components/pp_app_bar.dart';

class PushPullLegsScreen extends StatelessWidget {
  const PushPullLegsScreen({super.key});

  static const _systemName = 'دفع - سحب - أرجل';

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
              label: 'Push / Pull / Legs',
              description:
              'تقسيم التمارين إلى محاور الدفع والسحب والأرجل. '
                  'فعّال جداً لبناء القوة وكتلة العضلات.',
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xs),
            const WorkoutDayButton(
              titlee: 'تمارين الدفع',
              type: 'Push',
              systemName: _systemName,
              muscleGroup: 'الصدر والكتفين والترايسبس',
            ),
            const WorkoutDayButton(
              titlee: 'تمارين السحب',
              type: 'Pull',
              systemName: _systemName,
              muscleGroup: 'الظهر والبايسبس',
            ),
            const WorkoutDayButton(
              titlee: 'تمارين الأرجل',
              type: 'Leg',
              systemName: _systemName,
              muscleGroup: 'الأرجل والمؤخرة',
            ),
          ],
        ),
      ),
    );
  }
}

