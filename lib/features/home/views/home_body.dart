import 'package:flutter/material.dart';
import 'package:task/features/home/views/widget/home_header.dart';
import 'package:task/features/home/views/widget/home_today_hero.dart';
import 'package:task/features/home/views/widget/streak_card.dart';
import 'package:task/features/home/views/widget/this_week_list.dart';
import '../../../core/theme/app_spacing.dart';
import '../repo/data/home_data.dart';


class HomeBody extends StatelessWidget {
  const HomeBody({super.key, required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(trainedToday: data.trainedToday),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile),
            child: TodayHeroCard(data: data),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile),
            child: StreakCard(data: data),
          ),
          const SizedBox(height: AppSpacing.lg),
          ThisWeekList(data: data),
          SizedBox(height: AppSpacing.bottomNavHeight + AppSpacing.lg),
        ],
      ),
    );
  }
}