import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/components/pp_app_bar.dart';
import '../../../core/ui/components/pp_bottom_nav.dart';
import '../../../shared/bloc/app_cubit.dart';
import '../../../shared/bloc/app_states.dart';

class GimView extends StatelessWidget {
  const GimView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (_, __) {},
        builder: (context, state) {
          final cubit = AppCubit.get(context);
          // Home tab (index 0) gets a minimal branded app bar.
          // Other tabs get their own context-specific bars (set in each screen).
          return Scaffold(
            backgroundColor: AppColors.background,
            extendBody: true,
            appBar: cubit.currentIndex == 0
                ? const PpAppBar(
                    title: 'Power Pulse',
                    showNotification: false,
                    transparent: false,
                  )
                : null,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: KeyedSubtree(
                key: ValueKey<int>(cubit.currentIndex),
                child: cubit.screens[cubit.currentIndex],
              ),
            ),
            bottomNavigationBar: PpBottomNav(
              currentIndex: cubit.currentIndex,
              onTap: cubit.changeBottomNavBar,
            ),
          );
        },
      ),
    );
  }
}
