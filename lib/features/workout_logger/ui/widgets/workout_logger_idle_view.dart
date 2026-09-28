import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WorkoutLoggerIdleView extends StatelessWidget {
  const WorkoutLoggerIdleView({super.key});

  @override
  Widget build(BuildContext context) {
    // لحظة انتقالية — الـ screen بتبدأ الجلسة تلقائياً في initState
    return const Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );
  }
}
