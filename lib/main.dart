import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'core/services/user_profile_service.dart';
import 'core/theme/app_theme.dart';
import 'shared/bloc/app_cubit.dart';
import 'shared/bloc/app_states.dart';
import 'shared/providers/item_provider.dart';
import 'features/exercises/views/gim_view.dart';
import 'features/onboarding/views/onboarding_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0B0F1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await setupDi();

  await UserProfileService.instance.init();

  final showOnboarding = !UserProfileService.instance.onboardingDone;

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ItemProvider())],
      child: MyApp(showOnboarding: showOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.showOnboarding});
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (_, __) {},
        builder: (context, state) {
          return MaterialApp(
            theme: AppTheme.dark,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            debugShowCheckedModeBanner: false,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: showOnboarding ? const OnboardingFlow() : const GimView(),
            ),
          );
        },
      ),
    );
  }
}
