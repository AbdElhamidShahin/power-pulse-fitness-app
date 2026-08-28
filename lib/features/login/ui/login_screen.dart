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
import '../app_regex.dart';
import '../logic/cubit/login_cubit.dart';
import '../logic/cubit/login_state.dart';

const _kBg = Color(0xFF0F0F0F);
const _kSurface = Color(0xFF1A1A1A);
const _kBorder = Color(0xFF2A2A2A);
const _kAccent = Color(0xFFA8E063);
const _kAccentDim = Color(0x1AA8E063);
const _kDanger = Color(0xFFFF4C6A);
const _kSuccess = Color(0xFF34D399);
const _kTextHigh = Color(0xFFFFFFFF);
const _kTextMid = Color(0xFF888888);
const _kTextLow = Color(0xFF444444);

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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context
        .read<LoginCubit>()
        .loginUser(email: _emailCtrl.text.trim(), password: _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          _showSnack(context,
              message: 'مرحباً بعودتك ${state.name} 👋', isError: false);
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
            padding: EdgeInsets.symmetric(
                horizontal: (AppConstants.screenPaddingH + 2).w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // Back button
                GestureDetector(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRouter.entry),
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
                    child: Text(AppStrings.loginTag,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            color: _kAccent,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),

                SizedBox(height: 18.h),

                // Title
                Text(AppStrings.loginTitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w900,
                      color: _kTextHigh,
                      height: 1.15,
                      letterSpacing: -0.5,
                    )),
                SizedBox(height: 6.h),
                Text(AppStrings.loginSubtitle,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        color: _kTextMid,
                        height: 1.5)),

                SizedBox(height: 32.h),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DarkFieldLabel(AppStrings.fieldEmail),
                      SizedBox(height: 8.h),
                      DarkFormField(
                        controller: _emailCtrl,
                        hint: AppStrings.loginEmailHint,
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
                      SizedBox(height: 16.h),
                      DarkFieldLabel(AppStrings.fieldPass),
                      SizedBox(height: 8.h),
                      DarkFormField(
                        controller: _passCtrl,
                        hint: AppStrings.loginPassHint,
                        obscureText: _passHidden,
                        icon: Icons.lock_outline_rounded,
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
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // Login button
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (ctx, st) => DarkPrimaryButton(
                    label: AppStrings.loginTag,
                    loading: st is LoginLoading,
                    onTap: _submit,
                  ),
                ),

                SizedBox(height: 20.h),

                // Divider
                Row(children: [
                  Expanded(child: Divider(color: _kBorder, thickness: 1)),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppConstants.spaceM.w),
                    child: Text(AppStrings.loginOr,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: _kTextLow)),
                  ),
                  Expanded(child: Divider(color: _kBorder, thickness: 1)),
                ]),

                SizedBox(height: 16.h),

                // Google button
                BlocBuilder<LoginCubit, LoginState>(
                  builder: (ctx, st) => _GoogleButton(
                    loading: st is LoginLoading,
                    onTap: () => ctx.read<LoginCubit>().loginWithGoogle(),
                  ),
                ),

                SizedBox(height: 28.h),

                // Sign up link
                Center(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(AppStrings.loginNoAccount,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          color: _kTextMid)),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () => context.push(AppRouter.signUp),
                    child: Text(AppStrings.loginCreateAccount,
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

// ─── Google button ────────────────────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onTap, this.loading = false});
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
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _kAccent),
                ),
              )
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                // Google G letter as icon (no asset needed)
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text('G',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4285F4),
                          height: 1,
                        )),
                  ),
                ),
                SizedBox(width: AppConstants.spaceM.w),
                Text(AppStrings.loginGoogle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      color: _kTextHigh,
                      fontWeight: FontWeight.w600,
                    )),
              ]),
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
      title: const Text(AppStrings.conflictTitle,
          style: TextStyle(
              fontFamily: 'Cairo',
              color: _kTextHigh,
              fontWeight: FontWeight.w800)),
      content: Text(
        'لديك بيانات محفوظة محليًا كضيف، وحسابك "${state.accountName}" '
        'يحتوي على بيانات في السحابة.\n\nاختر أيهما تريد الاحتفاظ به:',
        style:
            const TextStyle(fontFamily: 'Cairo', color: _kTextMid, height: 1.6),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dCtx).pop();
            context.read<LoginCubit>().resolveConflict(keepLocal: true);
          },
          child: const Text(AppStrings.conflictLocal,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  color: _kAccent,
                  fontWeight: FontWeight.w700)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dCtx).pop();
            context.read<LoginCubit>().resolveConflict(keepLocal: false);
          },
          child: const Text(AppStrings.conflictCloud,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  color: _kDanger,
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
