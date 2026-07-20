import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Bottom Nav — مطابق للتصميم
/// الترتيب RTL: الرئيسية يمين ← التمارين ← التغذية ← تقدمي ← حسابي يسار
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  // نفس ترتيب الـ routes في GoRouter
  static const _items = [
    _Item('🏠', 'الرئيسية'),
    _Item('🏋️', 'التمارين'),
    _Item('🥗', 'التغذية'),
    _Item('📈', 'تقدمي'),
    _Item('👤', 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEFEFEF), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            // RTL: الرئيسية على اليمين
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final active = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_items[i].emoji,
                          style: TextStyle(fontSize: active ? 22 : 20)),
                      const SizedBox(height: 2),
                      Text(
                        _items[i].label,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: active
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFF8A8A8A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: active ? 4 : 0,
                        height: active ? 4 : 0,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA8E063),
                          shape: BoxShape.circle,
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

class _Item {
  const _Item(this.emoji, this.label);
  final String emoji;
  final String label;
}
