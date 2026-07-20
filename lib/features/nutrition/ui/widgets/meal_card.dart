import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../data/models/food_entity.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.mealType,
    required this.kcal,
    required this.items,
    required this.isDone,
    this.onTap,
  });

  final MealType mealType;
  final double kcal;
  final List<String> items;
  final bool isDone;
  final VoidCallback? onTap;

  static const _meta = {
    MealType.breakfast:
    _M(icon: '🌅', name: 'الإفطار', time: '8:00 ص', bg: Color(0xFFFFF9E6)),
    MealType.lunch:
    _M(icon: '☀️', name: 'الغداء', time: '1:00 م', bg: Color(0xFFFFF3CD)),
    MealType.snack:
    _M(icon: '🍎', name: 'وجبة خفيفة', time: '4:00 م', bg: Color(0xFFFFE5E5)),
    MealType.dinner:
    _M(icon: '🌙', name: 'العشاء', time: '7:30 م', bg: Color(0xFFE8F5FF)),
  };

  double _defaultKcal(MealType t) => switch (t) {
    MealType.breakfast => 520,
    MealType.lunch => 680,
    MealType.snack => 180,
    MealType.dinner => 620,
  };

  List<String> _defaultItems(MealType t) => switch (t) {
    MealType.breakfast => ['شوفان', 'موز', 'بروتين شيك'],
    MealType.lunch => ['صدر دجاج', 'أرز بني', 'سلطة'],
    MealType.snack => ['لوز', 'تفاحة'],
    MealType.dinner => ['سلمون', 'بطاطا حلوة', 'بروكلي'],
  };

  @override
  Widget build(BuildContext context) {
    final meta = _meta[mealType]!;
    final displayKcal = kcal > 0 ? kcal : _defaultKcal(mealType);
    final displayItems = items.isNotEmpty ? items : _defaultItems(mealType);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isDone ? 1.0 : 0.85,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              // 1. أيقونة الوجبة في أقصى اليمين (البداية الطبيعية للعين)
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.accent.withOpacity(0.15) : meta.bg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.center,
                child: Text(meta.icon, style: TextStyle(fontSize: 20.sp)),
              ),
              SizedBox(width: 12.w),

              // 2. تفاصيل الوجبة (اسم الوجبة + التفاصيل)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.name,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${meta.time} · ${displayItems.join('، ')}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),

              // 3. السعرات وعلامة الإنجاز (Done Check) في أقصى اليسار
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${displayKcal.toInt()} سعرة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isDone ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.accent : AppColors.bgElevated,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: isDone
                        ? Icon(
                      Icons.check_rounded,
                      size: 12.r,
                      color: AppColors.bgDark,
                    )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _M {
  const _M({
    required this.icon,
    required this.name,
    required this.time,
    required this.bg,
  });
  final String icon, name, time;
  final Color bg;
}