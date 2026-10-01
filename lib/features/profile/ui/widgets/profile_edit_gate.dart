import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';
import '../screens/edit_profile_screen.dart';

/// Gate widget لشاشة تعديل البروفايل.
/// بتشيك إن الـ ProfileCubit فيه بيانات قبل ما تفتح الـ EditProfileScreen.
/// انتقلت من app_router.dart (P3 fix).
class ProfileEditGate extends StatefulWidget {
  const ProfileEditGate({super.key});

  @override
  State<ProfileEditGate> createState() => _ProfileEditGateState();
}

class _ProfileEditGateState extends State<ProfileEditGate> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>();
    if (cubit.state is! ProfileLoaded) {
      cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return BlocProvider(
            create: (_) => sl<ProfileSaveCubit>(),
            child: EditProfileScreen(profile: state.profile),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            backgroundColor: context.colors.bgDark,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.accent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تعذّر تحميل البيانات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.textOnDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.read<ProfileCubit>().load(),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ProfileLoading أو ProfileInitial
        return   Scaffold(
          backgroundColor: context.colors.bgDark,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        );
      },
    );
  }
}
