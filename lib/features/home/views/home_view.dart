import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/services/user_profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';
import '../repo/data/home_repository.dart';
import 'home_body.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        HomeRepositoryImpl(GetIt.instance<UserProfileService>()),
      )..load(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          HomeError(:final message) =>
              Center(child: Text(message, style: AppTextStyles.bodyMuted)),
          HomeLoaded(:final data) => HomeBody(data: data),
        },
      ),
    );
  }
}