import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/app_colors.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: context.colors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}