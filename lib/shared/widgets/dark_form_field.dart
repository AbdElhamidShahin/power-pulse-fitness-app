import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';

class DarkFormField extends StatelessWidget {
  const DarkFormField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.obscureText    = false,
    this.keyboardType,
    this.textDirection  = TextDirection.ltr,
    this.suffix,
    this.suffixLabel,
    this.validator,
    this.onChanged,
    this.errorText,
  });

  final TextEditingController       controller;
  final String                      hint;
  final IconData?                   icon;
  final bool                        obscureText;
  final TextInputType?              keyboardType;
  final TextDirection               textDirection;
  final Widget?                     suffix;
  final String?                     suffixLabel;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>?       onChanged;
  final String?                     errorText;

  static const _bg     = Color(0xFF1A1A1A);
  static const _border = Color(0xFF2E2E2E);
  static const _accent = Color(0xFFA8E063);
  static const _danger = Color(0xFFFF4C6A);
  static const _text   = Color(0xFFFFFFFF);
  static const _hint   = Color(0xFF555555);
  static const _icon   = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    Widget? builtSuffix;
    if (suffix != null) {
      builtSuffix =
          Padding(padding: const EdgeInsets.only(left: 8), child: suffix);
    } else if (suffixLabel != null) {
      builtSuffix = Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(suffixLabel!,
            style: TextStyle(
                fontFamily: 'Cairo', fontSize: 12.sp, color: _hint)),
      );
    }
    final hasError = errorText != null;
    return TextFormField(
      controller:    controller,
      obscureText:   obscureText,
      keyboardType:  keyboardType,
      textDirection: textDirection,
      validator:     validator,
      onChanged:     onChanged,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize:   14.sp,
        color:      _text,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: _hint),
        prefixIcon: icon != null
            ? Icon(icon, color: _icon, size: AppConstants.iconM)
            : null,
        suffixIcon: builtSuffix,
        errorText:  errorText,
        errorStyle: TextStyle(fontFamily: 'Cairo', fontSize: 11.sp, color: _danger),
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
          borderSide: BorderSide(color: hasError ? _danger : _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(
              color: hasError ? _danger : _accent, width: 1.5),
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
