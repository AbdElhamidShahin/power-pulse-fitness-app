import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Small label shown above form fields in the dark auth screens.
// Kept separate so login and signup share one definition.
class DarkFieldLabel extends StatelessWidget {
  const DarkFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelSmall.copyWith(
        fontSize:      12.sp,
        color:         const Color(0xFFAAAAAA),
        letterSpacing: 0.3,
      ),
    );
  }
}
