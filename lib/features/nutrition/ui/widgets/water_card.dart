import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../logic/cubit/nutrition_cubit.dart';
import '../../logic/cubit/nutrition_state.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({
    super.key,
    required this.current,
    required this.goal,
  });

  final double current;
  final double goal;

  static const int _totalBars = 5;

  int get _filledBars =>
      (current / goal * _totalBars).round().clamp(0, _totalBars);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('💧', style: TextStyle(fontSize: 13.sp)),
                  SizedBox(width: 4.w),
                  Text(
                    'الماء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Cairo'),
                  children: [
                    TextSpan(
                      text: '${_round(current)}L',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.info,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${_round(goal)}L',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  _WaterButton(
                    icon: Icons.remove_rounded,
                    onTap: () => context.read<NutritionCubit>().removeWater(),
                    enabled: current > 0,
                  ),
                  SizedBox(width: 8.w),
                  _WaterButton(
                    icon: Icons.add_rounded,
                    onTap: () => context.read<NutritionCubit>().addWater(),
                    enabled: current < goal * 2,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: List.generate(_totalBars, (i) {
              final isFilled = i < _filledBars;
              return GestureDetector(
                onTap: () {
                  final targetLiters =
                      ((i + 1) / _totalBars * goal * 4).round() / 4.0;
                  context
                      .read<NutritionCubit>()
                      .setWater(targetLiters.clamp(0.0, goal));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 6.w),
                  width: 16.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? AppColors.info
                        : AppColors.info.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _round(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

class _WaterButton extends StatelessWidget {
  const _WaterButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          width: 26.r,
          height: 26.r,
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.r, color: AppColors.info),
        ),
      ),
    );
  }
}

class WaterCardConnected extends StatelessWidget {
  const WaterCardConnected({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionCubit, NutritionState>(
      buildWhen: (prev, curr) {
        if (prev is NutritionLoaded && curr is NutritionLoaded) {
          return prev.daily.waterLiters != curr.daily.waterLiters;
        }
        return curr is NutritionLoaded;
      },
      builder: (context, state) {
        if (state is! NutritionLoaded) return const SizedBox.shrink();
        return WaterCard(
          current: state.daily.waterLiters,
          goal: state.daily.waterGoal,
        );
      },
    );
  }
}