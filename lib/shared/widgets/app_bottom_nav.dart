import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// AppBottomNav — ✅ مطابق للصورة تماماً
/// أيقونات Emoji مثل الصورة + نقطة خضراء للعنصر المحدد
/// الترتيب RTL: حسابي | تقدمي | التغذية | التمارين | الرئيسية
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  // ✅ أيقونات مطابقة للصورة — Icons بدل Emoji لوضوح أفضل
  static const _items = [
    _NavItem(icon: Icons.home_rounded,            emoji: '🏠', label: 'الرئيسية'),
    _NavItem(icon: Icons.fitness_center_rounded,  emoji: '🏋️', label: 'التمارين'),
    _NavItem(icon: Icons.restaurant_menu_rounded, emoji: '🍽️', label: 'التغذية'),
    _NavItem(icon: Icons.bar_chart_rounded,       emoji: '📊', label: 'تقدمي'),
    _NavItem(icon: Icons.person_rounded,          emoji: '👤', label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 0.5),
        ),
      ),
      // ✅ Row عادي — Directionality الخارجي يعكسه تلقائياً RTL
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) => _NavButton(
          item: _items[i],
          isActive: currentIndex == i,
          onTap: () => onTap(i),
        )),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.emoji, required this.label});
  final IconData icon;
  final String emoji, label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ أيقونة Material — واضحة ومتسقة
            Icon(
              item.icon,
              size: 22,
              // ✅ المحدد: accent أخضر | غير محدد: رمادي
              color: isActive ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            // ✅ نقطة خضراء تحت المحدد
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
