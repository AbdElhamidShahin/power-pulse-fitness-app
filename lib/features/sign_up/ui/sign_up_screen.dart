import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/dark_field_label.dart';
import '../../../../shared/widgets/dark_primary_button.dart';
import '../../../../shared/widgets/dark_form_field.dart';
import '../../../../shared/widgets/pp_logo.dart';
import '../../login/app_regex.dart';
import '../logic/cubit/sign_up_cubit.dart';
import '../logic/cubit/sign_up_state.dart';

// ─── Dark palette ─────────────────────────────────────────────────────────────
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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _nameCtrl         = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passCtrl         = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();
  bool _passHidden        = true;
  bool _confirmPassHidden = true;

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
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SignUpCubit>().signUpUser(
      name:            _nameCtrl.text.trim(),
      email:           _emailCtrl.text.trim(),
      password:        _passCtrl.text,
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

                // Logo + tag
                Row(children: [
                  const PPLogo(size: 32),
                  const SizedBox(width: AppConstants.spaceS),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kAccentDim,
                      borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                    ),
                    child: const Text(AppStrings.signUpTag,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11,
                        color: _kAccent, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: AppConstants.spaceXL),
                Text(AppStrings.signUpTitle,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 32,
                    fontWeight: FontWeight.w900, color: _kTextHigh,
                    height: 1.15, letterSpacing: -0.5)),
                const SizedBox(height: AppConstants.spaceS),
                const Text(AppStrings.signUpSubtitle,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                      color: _kTextMid)),

                const SizedBox(height: AppConstants.space3XL),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DarkFieldLabel(AppStrings.fieldName),
                      const SizedBox(height: AppConstants.spaceS),
                      DarkFormField(
                        controller: _nameCtrl,
                        hint: AppStrings.fieldNameHint,
                        icon: Icons.person_outline_rounded,
                        textDirection: TextDirection.rtl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'أدخل اسمك' : null,
                      ),
                      const SizedBox(height: AppConstants.spaceXL),

                      DarkFieldLabel(AppStrings.fieldEmail),
                      const SizedBox(height: AppConstants.spaceS),
                      DarkFormField(
                        controller: _emailCtrl,
                        hint: AppStrings.loginEmailHint,
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return AppStrings.errEnterEmail;
                          if (!AppRegex.isEmailValid(v)) return AppStrings.errInvalidEmail;
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),

                      DarkFieldLabel(AppStrings.fieldPass),
                      const SizedBox(height: AppConstants.spaceS),
                      DarkFormField(
                        controller: _passCtrl,
                        hint: AppStrings.fieldPassHint,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _passHidden,
                        suffix: GestureDetector(
                          onTap: () => setState(() => _passHidden = !_passHidden),
                          child: Icon(
                            _passHidden ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                            color: _kTextMid, size: AppConstants.iconM),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return AppStrings.errEnterPass;
                          if (!AppRegex.hasMinLength(v)) return AppStrings.errPassShort;
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spaceXL),

                      DarkFieldLabel(AppStrings.fieldPassConfirm),
                      const SizedBox(height: AppConstants.spaceS),
                      DarkFormField(
                        controller: _confirmPassCtrl,
                        hint: AppStrings.fieldPassConfirmH,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _confirmPassHidden,
                        suffix: GestureDetector(
                          onTap: () => setState(
                              () => _confirmPassHidden = !_confirmPassHidden),
                          child: Icon(
                            _confirmPassHidden ? Icons.visibility_off_outlined
                                               : Icons.visibility_outlined,
                            color: _kTextMid, size: AppConstants.iconM),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return AppStrings.errEnterPassConf;
                          if (v != _passCtrl.text) return AppStrings.errPassMismatch;
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.space3XL),

                // Submit
                BlocBuilder<SignUpCubit, SignUpState>(
                  builder: (ctx, st) => DarkPrimaryButton(
                    label: AppStrings.signUpBtn,
                    loading: st is SignUpLoading,
                    onTap: _submit,
                  ),
                ),

                const SizedBox(height: AppConstants.space3XL),

                // Login link
                Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text(AppStrings.signUpHasAccount,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
                        color: _kTextMid)),
                  const SizedBox(width: AppConstants.spaceXS),
                  GestureDetector(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRouter.login),
                    child: Text(AppStrings.signUpLogin,
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

// ─── Widgets ──────────────────────────────────────────────────────────────────
