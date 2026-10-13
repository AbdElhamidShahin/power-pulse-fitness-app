import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:power_pulse/core/localization/app_localizations.dart';

import '../../../core/auth/user_mode_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../shared/widgets/pp_button.dart';
import '../logic/cubit/login_cubit.dart';
import '../logic/cubit/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _passHidden = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginCubit>().loginUser(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          final prefs = await SharedPreferences.getInstance();
          final raw = prefs.getString('user_profile');
          final savedCompletionFlag = prefs.getBool('profile_completed');

          var recordSaysComplete = false;
          var recordHasCompletionFlag = false;
          var hasValidMeasurements = false;

          if (raw != null && raw.isNotEmpty) {
            try {
              final profile = jsonDecode(raw) as Map<String, dynamic>;

              recordHasCompletionFlag = profile.containsKey('profileCompleted');

              recordSaysComplete = profile['profileCompleted'] == true;

              hasValidMeasurements = (profile['age'] as num? ?? 0) > 0 &&
                  (profile['heightCm'] as num? ?? 0) > 0 &&
                  (profile['weightKg'] as num? ?? 0) > 0;
            } catch (_) {
              recordSaysComplete = false;
              hasValidMeasurements = false;
            }
          }

          final hasCompleteProfile = recordHasCompletionFlag
              ? recordSaysComplete
              : (savedCompletionFlag == true || hasValidMeasurements);

          if (hasCompleteProfile && savedCompletionFlag != true) {
            await prefs.setBool('profile_completed', true);
          }

          if (!context.mounted) return;

          context.go(
            hasCompleteProfile ? AppRouter.home : AppRouter.onboarding,
          );
        } else if (state is LoginError) {
          _showBanner(
            context,
            message: state.errorMessage,
            isError: true,
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.bgDeep,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH + 4,
              vertical: AppConstants.screenPaddingV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.space3XL),
                const _Header(),
                const SizedBox(height: AppConstants.space4XL),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(context.l10n.email),
                      const SizedBox(height: AppConstants.spaceS),
                      _AuthField(
                        controller: _emailCtrl,
                        hint: 'example@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.alternate_email_rounded,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return context.l10n.enterEmail;
                          }

                          final emailPattern = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );

                          if (!emailPattern.hasMatch(v.trim())) {
                            return context.l10n.invalidEmail;
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),
                      _FieldLabel(context.l10n.password),
                      const SizedBox(height: AppConstants.spaceS),
                      _AuthField(
                        controller: _passCtrl,
                        hint: '••••••••',
                        obscureText: _passHidden,
                        suffix: GestureDetector(
                          onTap: () {
                            setState(() {
                              _passHidden = !_passHidden;
                            });
                          },
                          child: Icon(
                            _passHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: context.colors.textMuted,
                            size: AppConstants.iconM,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return context.l10n.enterPassword;
                          }

                          if (v.length < 8) {
                            return context.l10n.passwordTooShort;
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceL),
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) => PPButton(
                    label: 'تسجيل الدخول',
                    onPressed: _submit,
                    isLoading: state is LoginLoading,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXL),
                const _OrDivider(),
                const SizedBox(height: AppConstants.spaceXL),
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) => _GoogleButton(
                    isLoading: state is LoginLoading,
                    onTap: () {
                      context.read<LoginCubit>().loginWithGoogle();
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.space4XL),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.textMuted,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceXS),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.signUp),
                        child: Text(
                          'إنشاء حساب',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.accentText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceL),
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();

                      await UserModeService.setGuest(prefs);

                      if (context.mounted) {
                        context.go(AppRouter.home);
                      }
                    },
                    child: Text(
                      'متابعة كضيف بدون حساب',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.colors.textMuted,
                        decoration: TextDecoration.underline,
                        decorationColor: context.colors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Header

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceM,
            vertical: AppConstants.spaceXXS + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentDim,
            borderRadius: BorderRadius.circular(
              AppConstants.radiusPill,
            ),
          ),
          child: Text(
            'Power Pulse',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceM),
        Text(
          'أهلاً بعودتك\nمجدداً 💪',
          style: AppTextStyles.displayMedium.copyWith(
            color: context.colors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.spaceS),
        Text(
          'سجّل دخولك وواصل رحلتك نحو اللياقة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}

// Field Label

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleSmall.copyWith(
        color: context.colors.textSecondary,
      ),
    );
  }
}

// Auth Text Field

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textDirection: TextDirection.ltr,
      style: AppTextStyles.bodyMedium.copyWith(
        color: context.colors.textPrimary,
        letterSpacing: obscureText ? 2.0 : 0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: context.colors.borderMedium,
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: context.colors.textMuted,
                size: AppConstants.iconM,
              )
            : null,
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(
                  left: AppConstants.spaceM,
                ),
                child: suffix,
              )
            : null,
        filled: true,
        fillColor: context.colors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusM,
          ),
          borderSide: BorderSide(
            color: context.colors.borderSubtle,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusM,
          ),
          borderSide: BorderSide(
            color: context.colors.borderSubtle,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusM,
          ),
          borderSide: const BorderSide(
            color: AppColors.accent,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusM,
          ),
          borderSide: const BorderSide(
            color: AppColors.danger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.radiusM,
          ),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 1.5,
          ),
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.danger,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical: AppConstants.spaceL,
        ),
      ),
    );
  }
}

// Or Divider

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: context.colors.borderSubtle,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceM,
          ),
          child: Text(
            'أو',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: context.colors.textMuted,
                ),
          ),
        ),
        Expanded(
          child: Divider(
            color: context.colors.borderSubtle,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

// Google Button

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: AppConstants.buttonHeightLarge,
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(
            AppConstants.radiusM,
          ),
          border: Border.all(
            color: context.colors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            else ...[
              const _GoogleIcon(),
              const SizedBox(width: AppConstants.spaceM),
              Text(
                'الدخول بحساب جوجل',
                style: AppTextStyles.labelLarge.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GooglePainter(),
      ),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(cx, cy),
        radius: r,
      ),
      -0.5,
      3.8,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(cx, cy),
        radius: r,
      ),
      3.3,
      1.0,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );

    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r, cy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = 2.8,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Banner helper

void _showBanner(
  BuildContext context, {
  required String message,
  required bool isError,
}) {
  ScaffoldMessenger.of(context).showMaterialBanner(
    MaterialBanner(
      backgroundColor: isError ? AppColors.dangerDim : AppColors.accentDim,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceXXL,
        vertical: AppConstants.spaceM,
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isError ? AppColors.danger : AppColors.accent,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: Text(
            'حسناً',
            style: AppTextStyles.labelMedium.copyWith(
              color: isError ? AppColors.danger : AppColors.accent,
            ),
          ),
        ),
      ],
    ),
  );

  Future.delayed(const Duration(seconds: 3), () {
    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    }
  });
}
