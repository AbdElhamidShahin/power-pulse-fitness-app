import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/theme/app_colors.dart';

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  static const _items = [
    _QAItem('📈', 'تقدمي', 'عرض الإحصائيات', Color(0xFFE3F2FD), '/progress'),
    _QAItem('🥗', 'التغذية', 'تتبع وجباتك', Color(0xFFE8F5E9), '/nutrition'),
    _QAItem('🏋️', 'التمارين', 'استعرض المكتبة', Color(0xFFFCE4EC), '/exercises'),
    _QAItem('👤', 'حسابي', 'البيانات الشخصية', Color(0xFFFFF3E0), '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.45,
      children: _items
          .map(
            (item) => GestureDetector(
          onTap: () => context.go(item.route),
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
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  item.sublabel,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
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