import 'package:flutter/material.dart';
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
    _Item('🏠', 'الرئيسية'),
    _Item('🏋️', 'التمارين'),
    _Item('🥗', 'التغذية'),
    _Item('📈', 'تقدمي'),
    _Item('👤', 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEFEFEF), width: 1),
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
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFF8A8A8A),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 4.r : 0,
                          height: active ? 4.r : 0,
                          decoration: const BoxDecoration(
                            color: Color(0xFFA8E063),
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