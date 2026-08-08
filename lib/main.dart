import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/nutrition/ui/screens/nutrition_screen.dart';
import 'features/profile/logic/cubit/settings_cubit.dart';
import 'features/profile/logic/cubit/settings_state.dart';
import 'features/workout_plan/logic/cubit/workout_plan_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initDependencies();

  // WorkoutPlanCubit singleton — يتحمل مرة واحدة طول عمر الـ app
  sl<WorkoutPlanCubit>().load();

  runApp(const PowerPulseApp());
}

class PowerPulseApp extends StatelessWidget {
  const PowerPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit في الخارج — يحتاج يكون parent لكل شيء
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        // MultiBlocProvider مباشرة جوا ScreenUtilInit
        // BlocProvider.value = لا يعمل dispose على الـ singleton
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<AppSettingsCubit>()),
            BlocProvider.value(value: sl<WorkoutPlanCubit>()),
          ],
          child: BlocBuilder<AppSettingsCubit, AppSettings>(
            buildWhen: (prev, curr) => prev.isDarkMode != curr.isDarkMode,
            builder: (context, settings) {
              return MaterialApp.router(
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode:
                settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                routerConfig: AppRouter.router,
                locale: const Locale('ar', 'EG'),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('ar', 'EG')],
                builder: (context, child) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
