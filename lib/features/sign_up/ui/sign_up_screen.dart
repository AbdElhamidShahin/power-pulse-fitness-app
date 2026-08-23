import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/pp_logo.dart';
import '../../login/app_regex.dart';
import '../logic/cubit/sign_up_cubit.dart';
import '../logic/cubit/sign_up_state.dart';

const _kBg = Color(0xFF0F0F0F);
const _kSurface = Color(0xFF1A1A1A);
const _kBorder = Color(0xFF2E2E2E);
const _kAccent = Color(0xFFA8E063);
const _kAccentDim = Color(0x26A8E063);
const _kDanger = Color(0xFFFF4C6A);
const _kSuccess = Color(0xFF34D399);
const _kTextHigh = Color(0xFFFFFFFF);
const _kTextMid = Color(0xFFAAAAAA);
const _kTextLow = Color(0xFF555555);

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
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

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
              message: '🎉 مرحباً ${state.name}! حسابك جاهز', isError: false);
          // Profile was already collected during onboarding → go straight to home
          AppRouter.clearLocationCache();
          context.go(AppRouter.home);
        } else if (state is SignUpError) {
          _showSnack(context, message: state.errorMessage, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPaddingH + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.spaceXL),

                // Back
                GestureDetector(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRouter.login),
                  child: Container(
                    width: 38,
                    height: 38,
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

                // Logo + tag
                Row(children: [
                  const PPLogo(size: 32),
                  const SizedBox(width: AppConstants.spaceS),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kAccentDim,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                    ),
                    child: const Text('إنشاء حساب جديد',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: _kAccent,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: AppConstants.spaceXL),
                const Text('انضم إلى\nمجتمع الفائزين 🏆',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _kTextHigh,
                        height: 1.15,
                        letterSpacing: -0.5)),
                const SizedBox(height: AppConstants.spaceS),
                const Text('أنشئ حسابك وابدأ رحلتك مع Power Pulse',
                    style: TextStyle(
                        fontFamily: 'Cairo', fontSize: 13, color: _kTextMid)),

                const SizedBox(height: AppConstants.space3XL),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('الاسم الكامل'),
                      const SizedBox(height: AppConstants.spaceS),
                      _DarkFormField(
                        controller: _nameCtrl,
                        hint: 'اسمك الكريم',
                        icon: Icons.person_outline_rounded,
                        textDirection: TextDirection.rtl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'أدخل اسمك'
                            : null,
                      ),
                      const SizedBox(height: AppConstants.spaceXL),
                      _FieldLabel('البريد الإلكتروني'),
                      const SizedBox(height: AppConstants.spaceS),
                      _DarkFormField(
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
                      _DarkFormField(
                        controller: _passCtrl,
                        hint: '8 أحرف على الأقل',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _passHidden,
                        suffix: GestureDetector(
                          onTap: () =>
                              setState(() => _passHidden = !_passHidden),
                          child: Icon(
                              _passHidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _kTextMid,
                              size: AppConstants.iconM),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                          if (!AppRegex.hasMinLength(v))
                            return 'كلمة المرور قصيرة (8 أحرف على الأقل)';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),
                      _FieldLabel('تأكيد كلمة المرور'),
                      const SizedBox(height: AppConstants.spaceS),
                      _DarkFormField(
                        controller: _confirmPassCtrl,
                        hint: 'أعد كتابة كلمة المرور',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _confirmPassHidden,
                        suffix: GestureDetector(
                          onTap: () => setState(
                              () => _confirmPassHidden = !_confirmPassHidden),
                          child: Icon(
                              _confirmPassHidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _kTextMid,
                              size: AppConstants.iconM),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'أعد كتابة كلمة المرور';
                          if (v != _passCtrl.text)
                            return 'كلمتا المرور غير متطابقتين';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.space3XL),

                // Submit
                BlocBuilder<SignUpCubit, SignUpState>(
                  builder: (ctx, st) => _PrimaryButton(
                    label: 'إنشاء الحساب',
                    loading: st is SignUpLoading,
                    onTap: _submit,
                  ),
                ),

                const SizedBox(height: AppConstants.space3XL),

                // Login link
                Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('لديك حساب بالفعل؟',
                      style: TextStyle(
                          fontFamily: 'Cairo', fontSize: 13, color: _kTextMid)),
                  const SizedBox(width: AppConstants.spaceXS),
                  GestureDetector(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRouter.login),
                    child: const Text('تسجيل الدخول',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: _kAccent,
                            fontWeight: FontWeight.w700,
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _kTextMid,
          letterSpacing: 0.3));
}

class _DarkFormField extends StatelessWidget {
  const _DarkFormField({
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
      textDirection: textDirection,
      validator: validator,
      style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: _kTextHigh,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 13, color: _kTextLow),
        prefixIcon: Icon(icon, color: _kTextLow, size: AppConstants.iconM),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(left: 8), child: suffix)
            : null,
        errorStyle:
            const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: _kDanger),
        filled: true,
        fillColor: _kSurface,
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
  const _PrimaryButton(
      {required this.label, required this.onTap, this.loading = false});
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
        child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF0F0F0F)))
                : Text(label,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F0F0F)))),
      ),
    );
  }
}

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
