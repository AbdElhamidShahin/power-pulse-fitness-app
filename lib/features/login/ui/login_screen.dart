import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/auth/user_mode_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/pp_logo.dart';
import '../app_regex.dart';
import '../logic/cubit/login_cubit.dart';
import '../logic/cubit/login_state.dart';

// ─── Dark palette (matches onboarding / entry) ────────────────────────────────
const _kBg       = Color(0xFF0F0F0F);
const _kSurface  = Color(0xFF1A1A1A);
const _kBorder   = Color(0xFF2E2E2E);
const _kAccent   = Color(0xFFA8E063);
const _kAccentDim= Color(0x26A8E063);
const _kDanger   = Color(0xFFFF4C6A);
const _kSuccess  = Color(0xFF34D399);
const _kTextHigh = Color(0xFFFFFFFF);
const _kTextMid  = Color(0xFFAAAAAA);
const _kTextLow  = Color(0xFF555555);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _passHidden = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:          Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness:     Brightness.dark,
    ));
  }

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().loginUser(
      email: _emailCtrl.text.trim(), password: _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          _showSnack(context, message: 'مرحباً بعودتك ${state.name} 👋', isError: false);
          AppRouter.clearLocationCache();
          context.go(AppRouter.home);
        } else if (state is LoginGuestDataConflict) {
          _showConflictDialog(context, state);
        } else if (state is LoginError) {
          _showSnack(context, message: state.errorMessage, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPaddingH + 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.spaceXL),

                // Back button
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go(AppRouter.entry),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(color: _kBorder),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        color: _kTextMid, size: 16),
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXXL),

                // Logo + headline
                Row(children: [
                  const PPLogo(size: 32),
                  const SizedBox(width: AppConstants.spaceS),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kAccentDim,
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    ),
                    child: const Text('تسجيل الدخول',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11,
                        color: _kAccent, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: AppConstants.spaceXL),
                const Text('أهلاً بعودتك\nمجدداً 💪',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 32,
                    fontWeight: FontWeight.w900, color: _kTextHigh,
                    height: 1.15, letterSpacing: -0.5)),
                const SizedBox(height: AppConstants.spaceS),
                const Text('سجّل دخولك وواصل رحلتك نحو اللياقة',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: _kTextMid)),

                const SizedBox(height: AppConstants.space3XL),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('البريد الإلكتروني'),
                      const SizedBox(height: AppConstants.spaceS),
                      _DarkFormField(
                        controller: _emailCtrl,
                        hint: 'example@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.alternate_email_rounded,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'أدخل بريدك الإلكتروني';
                          if (!AppRegex.isEmailValid(v)) return 'بريد إلكتروني غير صحيح';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),
                      _FieldLabel('كلمة المرور'),
                      const SizedBox(height: AppConstants.spaceS),
                      _DarkFormField(
                        controller: _passCtrl,
                        hint: '••••••••',
                        obscureText: _passHidden,
                        icon: Icons.lock_outline_rounded,
                        suffix: GestureDetector(
                          onTap: () => setState(() => _passHidden = !_passHidden),
                          child: Icon(
                            _passHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: _kTextMid, size: AppConstants.iconM),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                          if (!AppRegex.hasMinLength(v)) return 'كلمة المرور قصيرة (8 أحرف على الأقل)';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.space3XL),

                // Login button
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (ctx, st) => _PrimaryButton(
                    label: 'تسجيل الدخول',
                    loading: st is LoginLoading,
                    onTap: _submit,
                  ),
                ),

                const SizedBox(height: AppConstants.spaceXL),

                // Divider
                Row(children: [
                  const Expanded(child: Divider(color: _kBorder, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                    child: const Text('أو', style: TextStyle(fontFamily: 'Cairo',
                        fontSize: 12, color: _kTextLow)),
                  ),
                  const Expanded(child: Divider(color: _kBorder, thickness: 1)),
                ]),

                const SizedBox(height: AppConstants.spaceXL),

                // Google
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (ctx, st) => _GoogleButton(
                    loading: st is LoginLoading,
                    onTap: () => ctx.read<LoginCubit>().loginWithGoogle(),
                  ),
                ),

                const SizedBox(height: AppConstants.space3XL),

                // Sign up link
                Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('ليس لديك حساب؟',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: _kTextMid)),
                  const SizedBox(width: AppConstants.spaceXS),
                  GestureDetector(
                    onTap: () => context.push(AppRouter.signUp),
                    child: const Text('إنشاء حساب',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                        color: _kAccent, fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: _kAccent)),
                  ),
                ])),

                const SizedBox(height: AppConstants.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared dark form widgets ─────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
        fontWeight: FontWeight.w600, color: _kTextMid, letterSpacing: 0.3));
}

class _DarkFormField extends StatelessWidget {
  const _DarkFormField({
    required this.controller, required this.hint, required this.icon,
    this.obscureText = false, this.keyboardType, this.suffix, this.validator,
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
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14,
          color: _kTextHigh, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: _kTextLow),
        prefixIcon: Icon(icon, color: _kTextLow, size: AppConstants.iconM),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(left: 8), child: suffix)
            : null,
        errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: _kDanger),
        filled: true, fillColor: _kSurface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceL, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: _kDanger, width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap, this.loading = false});
  final String label;
  final VoidCallback onTap;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: AppConstants.buttonHeightLarge,
        decoration: BoxDecoration(
          color: loading ? _kAccent.withOpacity(0.5) : _kAccent,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Center(child: loading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF0F0F0F)))
            : Text(label, style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 15, fontWeight: FontWeight.w800,
                color: Color(0xFF0F0F0F)))),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: AppConstants.buttonHeightLarge,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: _kBorder),
        ),
        child: Center(child: loading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('G', style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w700, color: Color(0xFF4285F4),
                    fontFamily: 'sans-serif')),
                const SizedBox(width: AppConstants.spaceM),
                const Text('الدخول بحساب جوجل',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14,
                      fontWeight: FontWeight.w600, color: _kTextMid)),
              ])),
      ),
    );
  }
}

// ─── Conflict dialog ──────────────────────────────────────────────────────────

void _showConflictDialog(BuildContext context, LoginGuestDataConflict state) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dCtx) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL)),
      title: const Text('تعارض في البيانات',
        style: TextStyle(fontFamily: 'Cairo', color: _kTextHigh,
            fontWeight: FontWeight.w800)),
      content: Text(
        'لديك بيانات محفوظة محليًا كضيف، وحسابك "${state.accountName}" '
        'يحتوي على بيانات في السحابة.\n\nاختر أيهما تريد الاحتفاظ به:',
        style: const TextStyle(fontFamily: 'Cairo', color: _kTextMid, height: 1.6),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dCtx).pop();
            context.read<LoginCubit>().resolveConflict(keepLocal: true);
          },
          child: const Text('بياناتي المحلية',
            style: TextStyle(fontFamily: 'Cairo', color: _kAccent,
                fontWeight: FontWeight.w700)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dCtx).pop();
            context.read<LoginCubit>().resolveConflict(keepLocal: false);
          },
          child: const Text('بيانات الحساب',
            style: TextStyle(fontFamily: 'Cairo', color: _kDanger,
                fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

// ─── Snackbar ─────────────────────────────────────────────────────────────────

void _showSnack(BuildContext context,
    {required String message, required bool isError}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message,
        style: const TextStyle(fontFamily: 'Cairo', color: _kTextHigh)),
    backgroundColor: isError ? _kDanger : _kSuccess,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM)),
    margin: const EdgeInsets.all(AppConstants.spaceL),
    duration: const Duration(seconds: 3),
  ));
}
