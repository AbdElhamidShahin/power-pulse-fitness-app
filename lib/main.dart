import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/logic/cubit/settings_cubit.dart';
import 'features/profile/logic/cubit/settings_state.dart';
import 'firebase_options.dart';

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

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initDependencies();

  runApp(const PowerPulseApp());
}

class PowerPulseApp extends StatefulWidget {
  const PowerPulseApp({super.key});

  @override
  State<PowerPulseApp> createState() => _PowerPulseAppState();
}

class _PowerPulseAppState extends State<PowerPulseApp> {
  @override
  Widget build(BuildContext context) {
    // Provide the AppSettingsCubit singleton here, above MaterialApp.router,
    // so themeMode can react to dark-mode toggles. The ShellRoute reuses
    // this same instance via BlocProvider.value (no double-ownership).
    return BlocProvider<AppSettingsCubit>(
      create: (_) => sl<AppSettingsCubit>(),
      child: BlocBuilder<AppSettingsCubit, AppSettings>(
        builder: (context, settings) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, __) {
              return MaterialApp.router(
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: settings.isDarkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,
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
          );
        },
      ),
    );
  }
}
