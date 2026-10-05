import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/startup.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_regex.dart';
import '../logic/cubit/reset_password_cubit.dart';
import '../logic/cubit/reset_password_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hidden = true;
  bool _confirmHidden = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(),
      child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordSuccess) {
            AppStartup.clearPasswordRecoveryPending();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.passwordChangedSuccess)),
            );
            context.go(AppRouter.login);
          } else if (state is ResetPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(context.l10n.changePassword)),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.screenPaddingH),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppConstants.space3XL),
                    Text(
                      context.l10n.createNewPassword,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppConstants.spaceS),
                    Text(context.l10n.useStrongPassword),
                    const SizedBox(height: AppConstants.spaceXXL),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidden,
                      decoration: InputDecoration(
                        labelText: context.l10n.newPassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _hidden = !_hidden),
                          icon: Icon(_hidden ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return context.l10n.enterPassword;
                        if (!AppRegex.hasMinLength(value)) return context.l10n.atLeast8Chars;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceL),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _confirmHidden,
                      decoration: InputDecoration(
                        labelText: context.l10n.confirmPassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _confirmHidden = !_confirmHidden),
                          icon: Icon(_confirmHidden ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) return context.l10n.passwordsMismatch;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceXXL),
                    BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
                      builder: (context, state) => FilledButton(
                        onPressed: state is ResetPasswordLoading
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) return;
                                context.read<ResetPasswordCubit>().updatePassword(
                                      password: _passwordController.text,
                                    );
                              },
                        child: state is ResetPasswordLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(context.l10n.savePassword),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
