import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pp_button.dart';
import '../../login/app_regex.dart';
import '../logic/cubit/sign_up_cubit.dart';
import '../logic/cubit/sign_up_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _passHidden = true;
  bool _confirmPassHidden = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SignUpCubit>().signUpUser(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      confirmPassword: _confirmPassCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          _showBanner(
            context,
            message: 'مرحباً بك، ${state.name}! حسابك جاهز 🎉',
            isError: false,
          );
          context.go(AppRouter.home);
        } else if (state is SignUpVerificationRequired) {
          _showVerificationSheet(context, email: state.email);
        } else if (state is SignUpError) {
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
                const SizedBox(height: AppConstants.spaceXXL),

                // ── Back button ───────────────────────────────────
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go(AppRouter.login),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFB0B0B0),
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXXL),

                // ── Header ────────────────────────────────────────
                _SignUpHeader(),

                const SizedBox(height: AppConstants.space3XL),

                // ── Form ──────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('الاسم الكامل'),
                      const SizedBox(height: AppConstants.spaceS),
                      _AuthField(
                        controller: _nameCtrl,
                        hint: 'Ahmed Mohamed',
                        icon: Icons.person_outline_rounded,
                        textDirection: TextDirection.rtl,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'أدخل اسمك';
                          if (v.trim().length < 2) return 'الاسم قصير جداً';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),
                      _FieldLabel('البريد الإلكتروني'),
                      const SizedBox(height: AppConstants.spaceS),
                      _AuthField(
                        controller: _emailCtrl,
                        hint: 'example@gmail.com',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'أدخل بريدك الإلكتروني';
                          if (!AppRegex.isEmailValid(v)) return 'بريد إلكتروني غير صحيح';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),
                      _FieldLabel('كلمة المرور'),
                      const SizedBox(height: AppConstants.spaceS),
                      _AuthField(
                        controller: _passCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _passHidden,
                        suffix: GestureDetector(
                          onTap: () => setState(() => _passHidden = !_passHidden),
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
                          if (!AppRegex.hasMinLength(v)) return '8 أحرف على الأقل';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),
                      _FieldLabel('تأكيد كلمة المرور'),
                      const SizedBox(height: AppConstants.spaceS),
                      _AuthField(
                        controller: _confirmPassCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _confirmPassHidden,
                        suffix: GestureDetector(
                          onTap: () => setState(() => _confirmPassHidden = !_confirmPassHidden),
                          child: Icon(
                            _confirmPassHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: AppConstants.iconM,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'أكّد كلمة المرور';
                          if (v != _passCtrl.text) return 'كلمتا المرور غير متطابقتين';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.space3XL),

                // ── Create account button ──────────────────────────
                BlocBuilder<SignUpCubit, SignUpState>(
                  builder: (context, state) => PPButton(
                    label: 'إنشاء الحساب',
                    onPressed: _submit,
                    isLoading: state is SignUpLoading,
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXL),

                // ── Divider ────────────────────────────────────────
                _OrDivider(),

                const SizedBox(height: AppConstants.spaceXL),

                // ── Google ─────────────────────────────────────────
                BlocBuilder<SignUpCubit, SignUpState>(
                  builder: (context, state) => _GoogleButton(
                    isLoading: state is SignUpLoading,
                    label: 'التسجيل بحساب جوجل',
                    onTap: () => context.read<SignUpCubit>().signUpWithGoogle(),
                  ),
                ),

                const SizedBox(height: AppConstants.space3XL),

                // ── Login link ─────────────────────────────────────
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceXS),
                      GestureDetector(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRouter.login),
                        child: Text(
                          'تسجيل الدخول',
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

// ─── Header ───────────────────────────────────────────────────────────────────

class _SignUpHeader extends StatelessWidget {
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
            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
          ),
          child: Text(
            'حساب جديد',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceM),
        Text(
          'ابدأ رحلتك\nالآن 🔥',
          style: AppTextStyles.displayMedium.copyWith(
            color: const Color(0xFFF5F5F0),
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.spaceS),
        Text(
          'أنشئ حسابك وانضم لآلاف الرياضيين',
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }
}

// ─── Shared widgets (same style as login) ────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleSmall.copyWith(color: const Color(0xFFB0B0B0)),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textDirection = TextDirection.ltr,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextDirection textDirection;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textDirection: textDirection,
      style: AppTextStyles.bodyMedium.copyWith(
        color: const Color(0xFFF5F5F0),
        letterSpacing: obscureText ? 2.0 : 0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF3A3A3A)),
        prefixIcon: Icon(icon, color: const Color(0xFF4B4B4B), size: AppConstants.iconM),
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

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFF2A2A2A), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
          child: Text('أو',
              style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF4B4B4B))),
        ),
        Expanded(child: Divider(color: const Color(0xFF2A2A2A), thickness: 1)),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({
    required this.isLoading,
    required this.label,
    required this.onTap,
  });
  final bool isLoading;
  final String label;
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
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
              )
            else ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CustomPaint(painter: _GooglePainter()),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(color: const Color(0xFFB0B0B0)),
              ),
            ],
          ],
        ),
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
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -0.5, 3.8, false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      3.3, 1.0, false,
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

// ─── Helpers ─────────────────────────────────────────────────────────────────

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

void _showVerificationSheet(BuildContext context, {required String email}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusXL),
      ),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(AppConstants.spaceXXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            ),
          ),
          const SizedBox(height: AppConstants.spaceXXL),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mark_email_unread_rounded,
                color: AppColors.accent, size: AppConstants.iconXL),
          ),
          const SizedBox(height: AppConstants.spaceXL),
          Text(
            'تحقق من بريدك',
            style: AppTextStyles.headlineMedium.copyWith(
              color: const Color(0xFFF5F5F0),
            ),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            'أرسلنا رابط التفعيل إلى\n$email',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: AppConstants.space3XL),
          PPButton(
            label: 'تم، يمكنني تسجيل الدخول',
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRouter.login);
            },
          ),
          const SizedBox(height: AppConstants.spaceXL),
        ],
      ),
    ),
  );
}
