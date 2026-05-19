import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/bloc/app_cubit.dart';
import '../../../shared/bloc/app_states.dart';

/// App shell — bottom nav + body switcher.
///
/// Previously lib/view/views/Gim_view.dart (`class Gim_view`).
/// Renamed to GimView. Uses AppConstants.appName and AppTextStyles.appBarTitle.
class GimView extends StatelessWidget {
  const GimView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(
        builder: (context, state) {
          final cubit = AppCubit.get(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppConstants.appName,
                style: AppTextStyles.appBarTitle,
              ),
            ),
            body: cubit.screens[cubit.currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              items: cubit.bottomItems,
              currentIndex: cubit.currentIndex,
              onTap: cubit.changeBottomNavBar,
            ),
          );
        },
        listener: (context, state) {},
      ),
    );
  }
}
