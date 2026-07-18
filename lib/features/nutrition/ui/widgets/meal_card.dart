import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../data/models/food_entity.dart';

// ════════════════════════════════════════════════════════════════
// MealCard — بطاقة وجبة واحدة
// مطابق للصورة:
//   - أيقونة ملونة يمين
//   - اسم الوجبة + الكالوري
//   - الوقت + محتويات الوجبة
//   - علامة صح خضراء يسار (إذا مكتملة)
// ════════════════════════════════════════════════════════════════
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

  // ─── بيانات ثابتة لكل نوع وجبة (مطابقة الصورة) ───────────
  static const _mealData = {
    MealType.breakfast: _MealMeta(
      icon: '🌅',
      nameEn: 'Breakfast',
      time: '8:00 AM',
      bgColor: Color(0xFFFFF9E6),
    ),
    MealType.lunch: _MealMeta(
      icon: '☀️',
      nameEn: 'Lunch',
      time: '1:00 PM',
      bgColor: Color(0xFFFFF3CD),
    ),
    MealType.snack: _MealMeta(
      icon: '🍎',
      nameEn: 'Snack',
      time: '4:00 PM',
      bgColor: Color(0xFFFFE5E5),
    ),
    MealType.dinner: _MealMeta(
      icon: '🌙',
      nameEn: 'Dinner',
      time: '7:30 PM',
      bgColor: Color(0xFFE8F5FF),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _mealData[mealType]!;
    final hasItems = items.isNotEmpty;
    final displayKcal = kcal > 0 ? kcal : _defaultKcal(mealType);
    final displayItems = hasItems ? items : _defaultItems(mealType);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDone ? 1.0 : 0.8,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceL,
              vertical: AppConstants.spaceM + 2),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          ),
          child: Row(
            children: [

              // ─── علامة الصح (يسار) ───────────────────────
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.accent
                      : AppColors.bgElevated,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: AppColors.bgDark)
                    : null,
              ),

              const SizedBox(width: AppConstants.spaceM),

              // ─── المحتوى الرئيسي ─────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صف: اسم الوجبة + الكالوري
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // الكالوري
                        Text(
                          '${displayKcal.toInt()} kcal',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDone
                                ? AppColors.accent
                                : AppColors.textMuted,
                          ),
                        ),
                        // اسم الوجبة
                        Text(
                          meta.nameEn,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // الوقت + المحتويات
                    Text(
                      '${meta.time} · ${displayItems.join(', ')}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppConstants.spaceM),

              // ─── أيقونة الوجبة (يمين) ────────────────────
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.accent.withOpacity(0.15)
                      : meta.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(meta.icon,
                    style: const TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _defaultKcal(MealType t) => switch (t) {
        MealType.breakfast => 520,
        MealType.lunch     => 680,
        MealType.snack     => 180,
        MealType.dinner    => 620,
      };

  List<String> _defaultItems(MealType t) => switch (t) {
        MealType.breakfast => ['Oats', 'Banana', 'Protein Shake'],
        MealType.lunch     => ['Chicken Breast', 'Brown Rice', 'Salad'],
        MealType.snack     => ['Almonds', 'Apple'],
        MealType.dinner    => ['Salmon', 'Sweet Potato', 'Broccoli'],
      };
}

// ─── بيانات ثابتة ─────────────────────────────────────────────
class _MealMeta {
  const _MealMeta({
    required this.icon,
    required this.nameEn,
    required this.time,
    required this.bgColor,
  });
  final String icon, nameEn, time;
  final Color bgColor;
}

// ════════════════════════════════════════════════════════════════
// MealSection — نسخة متوافقة مع الـ Cubit القديم
// (تحتفظ بنفس الـ API حتى لا تكسر باقي الكود)
// ════════════════════════════════════════════════════════════════
class MealSection extends StatelessWidget {
  const MealSection({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddTap,
    required this.onDeleteEntry,
  });

  final MealType mealType;
  final List<dynamic> entries; // List<MealEntry>
  final VoidCallback onAddTap;
  final ValueChanged<String> onDeleteEntry;

  double get _totalKcal =>
      (entries as List).fold(0.0, (s, e) => s + (e.calories as double));

  List<String> get _items =>
      (entries as List).map((e) => e.food.name as String).toList();

  @override
  Widget build(BuildContext context) {
    return MealCard(
      mealType: mealType,
      kcal:     _totalKcal,
      items:    _items,
      isDone:   entries.isNotEmpty,
      onTap:    onAddTap,
    );
  }
}
