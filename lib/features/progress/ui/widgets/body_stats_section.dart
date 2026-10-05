import 'package:flutter/material.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:power_pulse/features/profile/data/models/user_profile_entity.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../profile/logic/cubit/profile_cubit.dart';
import '../../../profile/logic/cubit/profile_state.dart';
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
    // نجيب بيانات الـ profile الحقيقية
    final profileState = context.watch<ProfileCubit>().state;
    final profile = profileState is ProfileLoaded ? profileState.profile : null;

    // الطول من الـ profile — لو مش موجود نستخدم 175 كافتراضي
    final heightCm  = profile?.heightCm ?? 175.0;
    final heightM   = heightCm / 100;

    // الوزن الحالي: من الـ progress logs أو من الـ profile
    final currentWeight = summary.currentWeight ?? profile?.weightKg;

    // BMI حقيقي
    final bmi = currentWeight != null
        ? currentWeight / (heightM * heightM)
        : null;

    // تصنيف الوزن
    final bmiCategory = bmi == null
        ? '--'
        : bmi < 18.5 ? context.l10n.underweight
        : bmi < 25.0 ? context.l10n.normalWeight
        : bmi < 30.0 ? context.l10n.overweight
        : context.l10n.obese;

    final bmiColor = bmi == null
        ? context.colors.textMuted
        : bmi < 18.5 ? AppColors.info
        : bmi < 25.0 ? AppColors.success
        : bmi < 30.0 ? AppColors.warning
        : AppColors.danger;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.bodyMeasurements,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8A8A8A),
                letterSpacing: 0.8,
              ),
            ),
            GestureDetector(
              onTap: () => _showWeightSheet(context),
              child: Text(
                context.l10n.updateWeight,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // ── الوزن ──────────────────────────────────────────────
        BodyStatRow(
          emoji: '⚖️',
          label: context.l10n.weight,
          value: currentWeight != null
              ? '${currentWeight.toStringAsFixed(1)} كجم'
              : '--',
          change: weightChange != null
              ? '${weightChange! < 0 ? '' : '+'}${weightChange!.toStringAsFixed(1)} كجم'
              : null,
          changeColor: (weightChange ?? 0) < 0
              ? AppColors.accent
              : AppColors.danger,
        ),
        SizedBox(height: 8.h),

        // ── الطول — من الـ profile الحقيقي ────────────────────
        BodyStatRow(
          emoji: '📏',
          label: context.l10n.height,
          value: profile != null
              ? '${profile.heightCm.toInt()} سم'
              : '-- سم',
        ),
        SizedBox(height: 8.h),

        // ── BMI — حقيقي ────────────────────────────────────────
        BodyStatRow(
          emoji: '🧮',
          label: context.l10n.bmiLabel,
          value: bmi != null ? bmi.toStringAsFixed(1) : '--',
          change: bmiCategory,
          changeColor: bmiColor,
        ),
        SizedBox(height: 8.h),

        // ── الهدف ──────────────────────────────────────────────
        if (profile != null)
          BodyStatRow(
            emoji: '🎯',
            label: 'الهدف',
            value: profile.goal.labelAr,
          ),
      ],
    );
  }

  void _showWeightSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgSurface,
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
