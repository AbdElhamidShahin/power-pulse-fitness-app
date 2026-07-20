import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/progress_entity.dart';
import '../../logic/cubit/progress_cubit.dart';
import 'body_stat_row.dart';
import 'weight_sheet.dart';

class BodyStatsSection extends StatelessWidget {
  const BodyStatsSection({
    super.key,
    required this.summary,
    required this.weightChange,
  });

  final ProgressSummary summary;
  final double? weightChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'قياسات الجسم',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF8A8A8A),
                letterSpacing: 0.8,
              ),
            ),
            GestureDetector(
              onTap: () => _showWeightSheet(context),
              child: Text(
                'تحديث',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        BodyStatRow(
          emoji: '⚖️',
          label: 'الوزن',
          value: summary.currentWeight != null
              ? '${summary.currentWeight!.toStringAsFixed(0)} كجم'
              : '--',
          change: weightChange != null
              ? '${weightChange! < 0 ? '' : '+'}${weightChange!.toStringAsFixed(0)} كجم'
              : null,
          changeColor:
          (weightChange ?? 0) < 0 ? AppColors.accent : AppColors.danger,
        ),
        SizedBox(height: 8.h),
        const BodyStatRow(
          emoji: '📏',
          label: 'الطول',
          value: '178 سم',
        ),
        SizedBox(height: 8.h),
        BodyStatRow(
          emoji: '🧮',
          label: 'مؤشر كتلة الجسم',
          value: summary.currentWeight != null
              ? (summary.currentWeight! / (1.78 * 1.78)).toStringAsFixed(1)
              : '--',
          change: 'وزن طبيعي',
          changeColor: AppColors.accent,
        ),
        SizedBox(height: 8.h),
        const BodyStatRow(
          emoji: '💧',
          label: 'Body Fat',
          value: '16%',
          change: '-1.2%',
          changeColor: AppColors.accent,
        ),
      ],
    );
  }

  void _showWeightSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<WeightLogCubit>(),
        child: const WeightSheet(),
      ),
    );
  }
}