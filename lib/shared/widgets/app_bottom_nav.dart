import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _Item('🏠', context.l10n.home),
    _Item('🏋️', context.l10n.exercises),
    _Item('🥗', context.l10n.nutrition),
    _Item('📈', 'تقدمي'),
    _Item('👤', 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        border: Border(
          top: BorderSide(color: context.colors.borderSubtle, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final active = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _items[i].emoji,
                          style: TextStyle(fontSize: active ? 20.sp : 18.sp),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _items[i].label,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w400,
                            color: active
                                ? context.colors.textPrimary
                                : context.colors.textMuted,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 4.r : 0,
                          height: active ? 4.r : 0,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Item {
  const _Item(this.emoji, this.label);
  final String emoji;
  final String label;
}
