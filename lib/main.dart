import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/auth/guest_migration_service.dart';
import 'core/data/app_data_bus.dart';
import 'features/pedometer/logic/cubit/pedometer_cubit.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/profile/logic/cubit/settings_cubit.dart';
import 'features/profile/logic/cubit/settings_state.dart';
import 'core/router/app_router.dart';
import 'core/startup.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';
import 'core/localization/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();

  // ─── Global error handlers ────────────────────────────────
  // Prevent raw Flutter framework exceptions from surfacing as
  // a red crash overlay in release or crashing the process.
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      // In debug: show full error in console as normal
      FlutterError.presentError(details);
    }
    // In release: swallow silently — user sees last good state.
    // TODO (Phase 9/10): forward to crash reporting here.
  };

  // Catches async/platform errors that escape the widget tree.
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Uncaught platform error: $error\n$stack');
    }
    return true; // Returning true marks the error as handled.
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // Register immediately after Supabase initialization so a password-reset
  // deep-link event is not missed before runApp().
  final authSubscription =
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      AppStartup.markPasswordRecoveryPending();
    }
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initDependencies();

  // ─── Init Notification Service ────────────────────────────
  await NotificationService.instance.init();

  // ─── Startup: determine initial route ─────────────────────
  await AppStartup.determine();

  runApp(PowerPulseApp(authSubscription: authSubscription));

  // بعد أول frame: نجدول الإشعارات المفعّلة ونبدأ عداد الخطوات
  // (الاتنين ممكن يطلبوا صلاحيات فمحتاجين الـ UI يكون ظهر).
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(
        NotificationService.instance.syncFromPrefs(sl<SharedPreferences>()));
    unawaited(sl<PedometerCubit>().start());
  });
}

class PowerPulseApp extends StatefulWidget {
  const PowerPulseApp({super.key, required this.authSubscription});

  final StreamSubscription<AuthState> authSubscription;

  @override
  State<PowerPulseApp> createState() => _PowerPulseAppState();
}

class _PowerPulseAppState extends State<PowerPulseApp>
    with WidgetsBindingObserver {
  StreamSubscription<void>? _busSub;
  Timer? _pushDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // أي تعديل في البيانات → نرفعه للسحابة (لو المستخدم مسجّل) بعد ثواني
    _busSub = AppDataBus.stream.listen((_) {
      _pushDebounce?.cancel();
      _pushDebounce = Timer(const Duration(seconds: 8), _pushToCloud);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.authSubscription.cancel();
    _busSub?.cancel();
    _pushDebounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _pushDebounce?.cancel();
        _pushToCloud();
      case AppLifecycleState.resumed:
        // المستخدم ممكن يكون منح الصلاحية من إعدادات الموبايل
        unawaited(sl<PedometerCubit>().retryIfUnavailable());
        unawaited(NotificationService.instance
            .syncFromPrefs(sl<SharedPreferences>()));
      default:
        break;
    }
  }

  Future<void> _pushToCloud() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await GuestMigrationService.pushLocalToCloud(
        prefs: sl<SharedPreferences>(),
        supabase: client,
        uid: uid,
      );
    } catch (_) {
      // أوفلاين — هيتعاد في المرة الجاية
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppSettingsCubit>.value(
      value: sl<AppSettingsCubit>(),
      child: BlocBuilder<AppSettingsCubit, AppSettings>(
        buildWhen: (prev, curr) =>
            prev.isDarkMode != curr.isDarkMode || prev.locale != curr.locale,
        builder: (context, settings) => ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) {
            final isAr = settings.locale == 'ar';
            return MaterialApp.router(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              routerConfig: AppRouter.router,
              locale: Locale(settings.locale),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('ar', 'EG'),
                Locale('en', 'US'),
              ],
              builder: (context, child) => Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: child!,
              ),
            );
          },
        ),
      ),
    );
  }
}
