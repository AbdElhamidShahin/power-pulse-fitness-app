import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/user_mode_service.dart';
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
          _showSnack(context, isError: false, message: 'مرحباً بعودتك ${state.name} 👋');
          AppRouter.clearLocationCache();
          context.go(AppRouter.home);
        } else if (state is LoginGuestDataConflict) {
          _showConflictDialog(context, state);
        } else if (state is LoginError) {
          _showSnack(context,  isError: true, message: state.errorMessage);
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
                const SizedBox(height: AppConstants.space3XL),

                // ── Header ──────────────────────────────────────
                _buildHeader(),

                const SizedBox(height: AppConstants.space4XL),

                // ── Form ────────────────────────────────────────
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

                // ── Login button ─────────────────────────────────
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) => PPButton(
                    label: 'تسجيل الدخول',
                    onPressed: _submit,
                    isLoading: state is LoginLoading,
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXL),

                // ── Divider ──────────────────────────────────────
                _OrDivider(),

                const SizedBox(height: AppConstants.spaceXL),

                // ── Google ───────────────────────────────────────
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (context, state) => _GoogleButton(
                    isLoading: state is LoginLoading,
                    onTap: () => context.read<LoginCubit>().loginWithGoogle(),
                  ),
                ),

                const SizedBox(height: AppConstants.space4XL),

                // ── Sign up link ─────────────────────────────────
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ليس لديك حساب؟', style: AppTextStyles.bodyMedium),
                      const SizedBox(width: AppConstants.spaceXS),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.signUp),
                        child: Text('إنشاء حساب',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spaceL),

                // ── Guest link ───────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await UserModeService.setGuest(prefs);
                      if (context.mounted) context.go(AppRouter.home);
                    },
                    child: Text(
                      'متابعة كضيف بدون حساب',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textMuted,
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand pill
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceM),
        Text(
          'أهلاً بعودتك\nمجدداً 💪',
          style: AppTextStyles.displayMedium.copyWith(height: 1.25),
        ),
        const SizedBox(height: AppConstants.spaceS),
        Text(
          'سجّل دخولك وواصل رحلتك نحو اللياقة',
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

// ─── Or Divider ───────────────────────────────────────────────────────────────

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
            child: Divider(color: AppColors.borderSubtle, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
          child: Text('أو', style: AppTextStyles.bodySmall),
        ),
        const Expanded(
            child: Divider(color: AppColors.borderSubtle, thickness: 1)),
      ],
    );
  }
}

// ─── Google Button ────────────────────────────────────────────────────────────

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
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            else ...[
              _GoogleIcon(),
              const SizedBox(width: AppConstants.spaceM),
              Text('الدخول بحساب جوجل',
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

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 22,
        height: 22,
        child: _GoogleLetterG(),
      );
}

class _GoogleLetterG extends StatelessWidget {
  const _GoogleLetterG();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Colored G using text (simple & crisp)
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'sans-serif',
            ),
            children: [
              TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Guest conflict dialog ─────────────────────────────────────────────────────
//
// Shown when a guest with local profile data logs into an existing account.
// The user chooses whether to keep their local data or use their account data.

void _showConflictDialog(BuildContext context, LoginGuestDataConflict state) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        'تعارض في البيانات',
        style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
      content: Text(
        'لديك بيانات محفوظة محليًا كضيف، وحسابك "${state.accountName}" '
        'يحتوي على بيانات في السحابة.\n\n'
        'ماذا تريد أن تفعل؟',
        style: const TextStyle(
            fontFamily: 'Cairo', color: Colors.white70, height: 1.5),
      ),
      actions: [
        // Keep local — discard cloud profile/plan; keep what was entered as guest
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            context.read<LoginCubit>().resolveConflict(keepLocal: true);
          },
          child: const Text(
            'احتفظ ببياناتي المحلية',
            style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFBFFF00)),
          ),
        ),
        // Use account — restore cloud data (original behavior)
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            context.read<LoginCubit>().resolveConflict(keepLocal: false);
          },
          child: const Text(
            'استخدم بيانات الحساب',
            style: TextStyle(fontFamily: 'Cairo', color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}

// ─── Snackbar ─────────────────────────────────────────────────────────────────

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
