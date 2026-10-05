import 'package:flutter/material.dart';
import '../../../../../../core/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../logic/cubit/home_cubit.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 48.r,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => context.read<HomeCubit>().load(),
              child: Text(
                context.l10n.retry,
                style: AppTextStyles.accentLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}