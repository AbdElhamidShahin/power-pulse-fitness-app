import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/dark_field_label.dart';
import '../../../../shared/widgets/dark_primary_button.dart';
import '../../../../shared/widgets/dark_form_field.dart';
import '../../../../shared/widgets/pp_logo.dart';
import '../../login/app_regex.dart';
import '../logic/cubit/sign_up_cubit.dart';
import '../logic/cubit/sign_up_state.dart';

const _kBg = Color(0xFF0F0F0F);
const _kSurface = Color(0xFF1A1A1A);
const _kBorder = Color(0xFF2A2A2A);
const _kAccent = Color(0xFFA8E063);
const _kAccentDim = Color(0x1AA8E063);
const _kDanger = Color(0xFFFF4C6A);
const _kSuccess = Color(0xFF34D399);
const _kTextHigh = Color(0xFFFFFFFF);
const _kTextMid = Color(0xFF888888);

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
  bool _confirmHidden = true;

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
            padding: EdgeInsets.symmetric(
                horizontal: (AppConstants.screenPaddingH + 2).w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // Back
                GestureDetector(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRouter.login),
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: _kTextMid, size: 16.sp),
                  ),
                ),

                SizedBox(height: 28.h),

                // Logo + badge
                Row(children: [
                  const PPLogo(size: 30),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _kAccentDim,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusPill),
                      border: Border.all(color: _kAccent.withOpacity(0.3)),
                    ),
                    child: Text(AppStrings.signUpTag,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            color: _kAccent,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),

                SizedBox(height: 18.h),

                Text(AppStrings.signUpTitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w900,
                      color: _kTextHigh,
                      height: 1.15,
                      letterSpacing: -0.5,
                    )),
                SizedBox(height: 6.h),
                Text(AppStrings.signUpSubtitle,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        color: _kTextMid,
                        height: 1.5)),

                SizedBox(height: 28.h),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      DarkFieldLabel(AppStrings.fieldName),
                      SizedBox(height: 8.h),
                      DarkFormField(
                        controller: _nameCtrl,
                        hint: AppStrings.fieldNameHint,
                        icon: Icons.person_outline_rounded,
                        textDirection: TextDirection.rtl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'أدخل اسمك'
                            : null,
                      ),
                      SizedBox(height: 16.h),

                      // Email
                      DarkFieldLabel(AppStrings.fieldEmail),
                      SizedBox(height: 8.h),
                      DarkFormField(
                        controller: _emailCtrl,
                        hint: AppStrings.loginEmailHint,
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return AppStrings.errEnterEmail;
                          if (!AppRegex.isEmailValid(v))
                            return AppStrings.errInvalidEmail;
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Password
                      DarkFieldLabel(AppStrings.fieldPass),
                      SizedBox(height: 8.h),
                      DarkFormField(
                        controller: _passCtrl,
                        hint: AppStrings.fieldPassHint,
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
                          if (v == null || v.isEmpty)
                            return AppStrings.errEnterPass;
                          if (!AppRegex.hasMinLength(v))
                            return AppStrings.errPassShort;
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Confirm password
                      DarkFieldLabel(AppStrings.fieldPassConfirm),
                      SizedBox(height: 8.h),
                      DarkFormField(
                        controller: _confirmPassCtrl,
                        hint: AppStrings.fieldPassConfirmH,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _confirmHidden,
                        suffix: GestureDetector(
                          onTap: () =>
                              setState(() => _confirmHidden = !_confirmHidden),
                          child: Icon(
                              _confirmHidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _kTextMid,
                              size: AppConstants.iconM),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return AppStrings.errEnterPassConf;
                          if (v != _passCtrl.text)
                            return AppStrings.errPassMismatch;
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // Submit
                BlocBuilder<SignUpCubit, SignUpState>(
                  builder: (ctx, st) => DarkPrimaryButton(
                    label: AppStrings.signUpBtn,
                    loading: st is SignUpLoading,
                    onTap: _submit,
                  ),
                ),

                SizedBox(height: 24.h),

                // Login link
                Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(AppStrings.signUpHasAccount,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          color: _kTextMid)),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRouter.login),
                    child: Text(AppStrings.signUpLogin,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          color: _kAccent,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: _kAccent,
                        )),
                  ),
                ])),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
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
