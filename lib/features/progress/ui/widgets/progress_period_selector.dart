import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../data/models/progress_entity.dart';
import '../../logic/cubit/progress_cubit.dart';

class ProgressPeriodSelector extends StatelessWidget {
  const ProgressPeriodSelector({super.key, required this.period});

  final ProgressPeriod period;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ProgressPeriod.values.map((p) {
        final active = period == p;
        return Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: GestureDetector(
            onTap: () => context.read<ProgressCubit>().changePeriod(p),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: active ? AppColors.bgDark : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                p.labelAr,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.textOnDark : AppColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}