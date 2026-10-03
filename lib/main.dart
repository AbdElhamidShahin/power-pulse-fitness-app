import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/notifications/notification_service.dart';
import 'features/profile/logic/cubit/settings_cubit.dart';
import 'features/profile/logic/cubit/settings_state.dart';
import 'core/router/app_router.dart';
import 'core/startup.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await NotificationService.instance.init();
  // statusBarIconBrightness بيتحدث تلقائياً من AppBarTheme في كل theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  // if (!AppConstants.isSupabaseConfigured) {
  //   throw StateError(
  //     'Supabase غير مُهيّأ. شغّل التطبيق بـ:\n'
  //     '  flutter run --dart-define-from-file=dart_defines.json\n'
  //     'أو مرّر --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...\n'
  //     '(شوف dart_defines.example.json)',
  //   );
  // }
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initDependencies();

  // Startup check مرة واحدة — الـ router بعد كده بيقرا النتيجة من الذاكرة فقط
  await AppStartup.determine();

  runApp(const PowerPulseApp());
}

class PowerPulseApp extends StatelessWidget {
  const PowerPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppSettingsCubit>(
      create: (_) => sl<AppSettingsCubit>(),
      child: BlocBuilder<AppSettingsCubit, AppSettings>(
        buildWhen: (prev, curr) => prev.isDarkMode != curr.isDarkMode,
        builder: (context, settings) => ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) {
            return MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              routerConfig: AppRouter.router,
          locale: const Locale('ar', 'EG'),
          localizationsDelegates:  const [

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
      ),
    );
  }
}