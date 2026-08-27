import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';

// Reusable dark-themed form field for login, signup, and similar screens.
// Handles validation, obscure text, prefix icon, and optional suffix widget.
class DarkFormField extends StatelessWidget {
  const DarkFormField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText    = false,
    this.keyboardType,
    this.textDirection  = TextDirection.ltr,
    this.suffix,
    this.validator,
  });

  final TextEditingController     controller;
  final String                    hint;
  final IconData                  icon;
  final bool                      obscureText;
  final TextInputType?            keyboardType;
  final TextDirection             textDirection;
  final Widget?                   suffix;
  final FormFieldValidator<String>? validator;

  // Dark palette — these screens are always dark regardless of app theme
  static const _bg     = Color(0xFF1A1A1A);
  static const _border = Color(0xFF2E2E2E);
  static const _accent = Color(0xFFA8E063);
  static const _danger = Color(0xFFFF4C6A);
  static const _text   = Color(0xFFFFFFFF);
  static const _hint   = Color(0xFF555555);
  static const _icon   = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:    controller,
      obscureText:   obscureText,
      keyboardType:  keyboardType,
      textDirection: textDirection,
      validator:     validator,
      style: TextStyle(
        fontFamily:  'Cairo',
        fontSize:    14.sp,
        color:       _text,
        fontWeight:  FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 14.sp, color: _hint),
        prefixIcon: Icon(icon, color: _icon, size: AppConstants.iconM),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(left: 8), child: suffix)
            : null,
        errorStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 11.sp, color: _danger),
        filled:      true,
        fillColor:   _bg,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceL, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _danger, width: 1.5),
        ),
      ),
    );
  }
}
