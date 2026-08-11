import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../app_regex.dart';
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
      listener: (context, state) {
        if (state is LoginSuccess) {
          _showBanner(
            context,
            message: 'مرحباً بعودتك، ${state.name} 👋',
            isError: false,
          );
          context.go(AppRouter.home);
        } else if (state is LoginError) {
          _showBanner(context, message: state.errorMessage, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
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

                // ── Logo + headline ────────────────────────────────
                _Header(),

                const SizedBox(height: AppConstants.space4XL),

                // ── Form ──────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('البريد الإلكتروني'),
                      const SizedBox(height: AppConstants.spaceS),
                      _AuthField(
                        controller: _emailCtrl,
                        hint: 'example@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.alternate_email_rounded,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'أدخل بريدك الإلكتروني';
                          if (!AppRegex.isEmailValid(v))
                            return 'بريد إلكتروني غير صحيح';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),
                      _FieldLabel('كلمة المرور'),
                      const SizedBox(height: AppConstants.spaceS),
                      _AuthField(
                        controller: _passCtrl,
                        hint: '••••••••',
                        obscureText: _passHidden,
                        icon: Icons.lock_outline_rounded,
                        suffix: GestureDetector(
                          onTap: () =>
                              setState(() => _passHidden = !_passHidden),
                          child: Icon(
                            _passHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: AppConstants.iconM,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                          if (!AppRegex.hasMinLength(v))
                            return 'كلمة المرور قصيرة جداً (8 أحرف على الأقل)';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.space3XL),

                // ── Login button ───────────────────────────────────
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) => PPButton(
                    label: 'تسجيل الدخول',
                    onPressed: _submit,
                    isLoading: state is LoginLoading,
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXL),

                // ── Divider ────────────────────────────────────────
                _OrDivider(),

                const SizedBox(height: AppConstants.spaceXL),

                // ── Google ─────────────────────────────────────────
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) => _GoogleButton(
                    isLoading: state is LoginLoading,
                    onTap: () => context.read<LoginCubit>().loginWithGoogle(),
                  ),
                ),

                const SizedBox(height: AppConstants.space4XL),

                // ── Sign up link ───────────────────────────────────
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceXS),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.signUp),
                        child: Text(
                          'إنشاء حساب',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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

// ─── Header Widget ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Accent pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceM,
            vertical: AppConstants.spaceXXS + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentDim,
            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
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
            color: const Color(0xFFF5F5F0),
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.spaceS),
        Text(
          'سجّل دخولك وواصل رحلتك نحو اللياقة',
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }
}

// ─── Field Label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleSmall.copyWith(
        color: const Color(0xFFB0B0B0),
      ),
    );
  }
}

// ─── Auth Text Field ─────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
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
        color: const Color(0xFFF5F5F0),
        letterSpacing: obscureText ? 2.0 : 0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF3A3A3A),
        ),
        prefixIcon: Icon(icon,
            color: const Color(0xFF4B4B4B), size: AppConstants.iconM),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(left: AppConstants.spaceM),
                child: suffix,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL,
          vertical: AppConstants.spaceL,
        ),
      ),
    );
  }
}

// ─── Or Divider ───────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFF2A2A2A), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
          child: Text(
            'أو',
            style: AppTextStyles.bodySmall
                .copyWith(color: const Color(0xFF4B4B4B)),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFF2A2A2A), thickness: 1)),
      ],
    );
  }
}

// ─── Google Button ─────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: AppConstants.buttonHeightLarge,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: const Color(0xFF2A2A2A)),
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
              _GoogleIcon(),
              const SizedBox(width: AppConstants.spaceM),
              Text(
                'الدخول بحساب جوجل',
                style: AppTextStyles.labelLarge.copyWith(
                  color: const Color(0xFFB0B0B0),
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
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Blue arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.5,
      3.8,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );
    // Red arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.3,
      1.0,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );
    // Bar
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

// ─── Banner helper ────────────────────────────────────────────────────────────

void _showBanner(BuildContext context,
    {required String message, required bool isError}) {
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
          onPressed: () =>
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
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
