import 'package:flutter/material.dart';
import 'package:power_pulse/core/router/route_observers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:power_pulse/core/theme/app_colors.dart';
import 'package:power_pulse/core/localization/app_localizations.dart';
import 'package:power_pulse/core/theme/app_theme_colors.dart';
import '../../logic/cubit/nutrition_cubit.dart';
import '../../logic/cubit/nutrition_state.dart';
import '../widgets/nutrition_body.dart';


class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<NutritionCubit>().loadToday();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      nutritionRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    nutritionRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<NutritionCubit>().reloadSelectedDate();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.colors.bgDeep,
        body: SafeArea(
          child: BlocConsumer<NutritionCubit, NutritionState>(
            listener: (context, state) {
              if (state is NutritionError) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(
                      state.message,
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
                    ),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    margin: EdgeInsets.all(16.r),
                  ));
                // Keep the selected date when a read fails. Automatically
                // calling loadToday() here made previous-day navigation appear
                // broken by silently jumping back to today.
              }
            },
            builder: (context, state) => switch (state) {
              NutritionInitial() || NutritionLoading() => const _Loader(),
              NutritionError(:final message) => _NutritionErrorView(
                  message: message,
                  onRetry: () => context.read<NutritionCubit>().reloadSelectedDate(),
                ),
              NutritionLoaded(:final daily) => NutritionBody(daily: daily),
            },
          ),
        ),
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: AppColors.accent),
  );
}


class _NutritionErrorView extends StatelessWidget {
  const _NutritionErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 38, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(Localizations.localeOf(context).languageCode == 'ar'
                    ? 'إعادة المحاولة'
                    : 'Retry'),
              ),
            ],
          ),
        ),
      );
}
