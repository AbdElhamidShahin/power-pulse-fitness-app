import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../data/models/food_entity.dart';

/// MealCard — كل النصوص عربية 100%
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

  // ✅ كل الأسماء والأوقات عربية
  static const _meta = {
    MealType.breakfast: _M(icon:'🌅', name:'الإفطار',        time:'8:00 ص',  bg:Color(0xFFFFF9E6)),
    MealType.lunch:     _M(icon:'☀️', name:'الغداء',          time:'1:00 م',  bg:Color(0xFFFFF3CD)),
    MealType.snack:     _M(icon:'🍎', name:'وجبة خفيفة',      time:'4:00 م',  bg:Color(0xFFFFE5E5)),
    MealType.dinner:    _M(icon:'🌙', name:'العشاء',           time:'7:30 م',  bg:Color(0xFFE8F5FF)),
  };

  double _defaultKcal(MealType t) => switch(t) {
    MealType.breakfast => 520,
    MealType.lunch     => 680,
    MealType.snack     => 180,
    MealType.dinner    => 620,
  };

  List<String> _defaultItems(MealType t) => switch(t) {
    MealType.breakfast => ['شوفان', 'موز', 'بروتين شيك'],
    MealType.lunch     => ['صدر دجاج', 'أرز بني', 'سلطة'],
    MealType.snack     => ['لوز', 'تفاحة'],
    MealType.dinner    => ['سلمون', 'بطاطا حلوة', 'بروكلي'],
  };

  @override
  Widget build(BuildContext context) {
    final meta        = _meta[mealType]!;
    final displayKcal = kcal > 0 ? kcal : _defaultKcal(mealType);
    final displayItems = items.isNotEmpty ? items : _defaultItems(mealType);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDone ? 1.0 : 0.8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              // ✅ علامة صح يسار
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.accent : AppColors.bgElevated,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 14, color: AppColors.bgDark)
                    : null,
              ),
              const SizedBox(width: 12),

              // ✅ المعلومات وسط
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${displayKcal.toInt()} سعرة',
                          style: TextStyle(
                            fontFamily:'Cairo', fontSize:13, fontWeight:FontWeight.w700,
                            color: isDone ? AppColors.accent : AppColors.textMuted,
                          ),
                        ),
                        Text(meta.name,
                            style: const TextStyle(
                              fontFamily:'Cairo', fontSize:15,
                              fontWeight:FontWeight.w800, color:AppColors.textPrimary,
                            )),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${meta.time} · ${displayItems.join('، ')}',
                      style: const TextStyle(fontFamily:'Cairo', fontSize:11,
                          color:AppColors.textMuted),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ✅ أيقونة يمين
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.accent.withOpacity(0.15) : meta.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(meta.icon, style: const TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _M {
  const _M({required this.icon, required this.name, required this.time, required this.bg});
  final String icon, name, time;
  final Color bg;
}

// backward compat
class MealSection extends StatelessWidget {
  const MealSection({super.key, required this.mealType, required this.entries,
      required this.onAddTap, required this.onDeleteEntry});
  final MealType mealType;
  final List<dynamic> entries;
  final VoidCallback onAddTap;
  final ValueChanged<String> onDeleteEntry;

  @override
  Widget build(BuildContext context) {
    final kcal  = (entries as List).fold<double>(0, (s,e) => s + (e.calories as double));
    final items = (entries as List).map((e) {
      final food = e.food;
      return (food.nameAr as String).isNotEmpty ? food.nameAr as String : food.name as String;
    }).toList();
    return MealCard(mealType:mealType, kcal:kcal, items:items,
        isDone:entries.isNotEmpty, onTap:onAddTap);
  }
}
