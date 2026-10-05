import 'package:flutter/material.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      _QAItem('📈', l10n.qaMyProgress,    l10n.qaViewStats,     const Color(0xFFE3F2FD), '/progress'),
      _QAItem('🥗', l10n.qaNutrition,     l10n.qaTrackMeals,    const Color(0xFFE8F5E9), '/nutrition'),
      _QAItem('🏋️', l10n.qaExercises,    l10n.qaBrowseLibrary,  const Color(0xFFFCE4EC), '/exercises'),
      _QAItem('👤', l10n.qaMyAccount,     l10n.qaPersonalData,   const Color(0xFFFFF3E0), '/profile'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.45,
      children: items
          .map(
            (item) => GestureDetector(
          onTap: () => context.push(item.route),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.emoji, style: TextStyle(fontSize: 22.sp)),
                SizedBox(height: 6.h),
                Text(
                  item.label,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  item.sublabel,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

class _QAItem {
  const _QAItem(this.emoji, this.label, this.sublabel, this.color, this.route);
  final String emoji;
  final String label;
  final String sublabel;
  final String route;
  final Color color;
}
