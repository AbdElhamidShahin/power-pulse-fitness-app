import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'shared/bloc/app_cubit.dart';
import 'shared/bloc/app_states.dart';
import 'shared/providers/item_provider.dart';
import 'features/exercises/views/gim_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: GimView(),
            ),
          );
        },
        listener: (context, state) {},
      ),
    );
  }
}
