import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PpBottomNav extends StatelessWidget {
  const PpBottomNav({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(icon: Icons.home_outlined,           activeIcon: Icons.home_rounded,         label: 'الرئيسية'),
    _NavItem(icon: Icons.calculate_outlined,       activeIcon: Icons.calculate_rounded,    label: 'الأدوات'),
    _NavItem(icon: Icons.bar_chart_outlined,       activeIcon: Icons.bar_chart_rounded,    label: 'التقدم'),
    _NavItem(icon: Icons.settings_outlined,        activeIcon: Icons.settings_rounded,     label: 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            children: List.generate(_items.length, (i) {
              final active = i == currentIndex;
              final item = _items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                        ),
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          color: active ? AppColors.primary : AppColors.outline,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTextStyles.labelCaps.copyWith(
                          color: active ? AppColors.primary : AppColors.outline,
                          fontSize: 10,
                        ),
                      ),
                    ],
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

class _NavItem {
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
  final IconData icon, activeIcon;
  final String label;
}
