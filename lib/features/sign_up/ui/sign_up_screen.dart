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
          _showSnack(context,
              isError: false, message: '🎉 مرحباً ${state.name}! أكمل إعداد حسابك');
          // New accounts go to onboarding so the user fills their real profile.
          // Onboarding navigates to /home on completion.
          AppRouter.clearLocationCache();
          context.go(AppRouter.onboarding);
        } else if (state is SignUpError) {
          _showSnack(context, isError: true, message: state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
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

                // ── Back button ────────────────────────────────────
                GestureDetector(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRouter.login),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXXL),

                // ── Header ─────────────────────────────────────────
                _buildHeader(),

                const SizedBox(height: AppConstants.space3XL),

                // ── Form ───────────────────────────────────────────
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
                        icon: Icons.lock_outline_rounded,
                        obscureText: _passHidden,
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
                            return '8 أحرف على الأقل';
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
                          onTap: () => setState(
                                  () => _confirmPassHidden = !_confirmPassHidden),
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
                          if (v != _passCtrl.text)
                            return 'كلمتا المرور غير متطابقتين';
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
                Row(
                  children: [
                    const Expanded(
                        child: Divider(
                            color: AppColors.borderSubtle, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceM),
                      child: Text('أو', style: AppTextStyles.bodySmall),
                    ),
                    const Expanded(
                        child: Divider(
                            color: AppColors.borderSubtle, thickness: 1)),
                  ],
                ),

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
                      Text('لديك حساب بالفعل؟',
                          style: AppTextStyles.bodyMedium),
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

  Widget _buildHeader() {
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceM),
        Text(
          'ابدأ رحلتك\nالآن 🔥',
          style: AppTextStyles.displayMedium.copyWith(height: 1.25),
        ),
        const SizedBox(height: AppConstants.spaceS),
        Text(
          'أنشئ حسابك وانضم لآلاف الرياضيين',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.titleSmall.copyWith(
      color: AppColors.textSecondary,
    ),
  );
}

// ─── Auth Text Field ──────────────────────────────────────────────────────────

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
        color: AppColors.textPrimary,
        letterSpacing: obscureText ? 2.0 : 0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        prefixIcon:
        Icon(icon, color: AppColors.textMuted, size: AppConstants.iconM),
        suffixIcon: suffix != null
            ? Padding(
          padding: const EdgeInsets.only(left: AppConstants.spaceM),
          child: suffix,
        )
            : null,
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
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

// ─── Google Button ────────────────────────────────────────────────────────────

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
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.borderMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.accent),
              )
            else ...[
              const SizedBox(
                width: 22,
                height: 22,
                child: _GoogleLetterG(),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Text(label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoogleLetterG extends StatelessWidget {
  const _GoogleLetterG();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'G',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
          fontFamily: 'sans-serif',
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

void _showSnack(BuildContext context,
    {required String message, required bool isError}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
      backgroundColor: isError ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      margin: const EdgeInsets.all(AppConstants.spaceL),
      duration: const Duration(seconds: 3),
    ),
  );
}

void _showVerificationSheet(BuildContext context, {required String email}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.bgSurface,
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
          // Handle bar
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderMedium,
              borderRadius: BorderRadius.circular(AppConstants.radiusPill),
            ),
          ),
          const SizedBox(height: AppConstants.spaceXXL),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.accentDim,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_unread_rounded,
                color: AppColors.accent, size: AppConstants.iconXL),
          ),
          const SizedBox(height: AppConstants.spaceXL),
          Text('تحقق من بريدك', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppConstants.spaceS),
          Text(
            'أرسلنا رابط التفعيل إلى\n$email',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
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
