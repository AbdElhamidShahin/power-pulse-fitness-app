import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../data/models/food_entity.dart';
import '../../logic/cubit/nutrition_cubit.dart';

class MealCard extends StatefulWidget {
  const MealCard({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddTap,
  });

  final MealType mealType;
  final List<MealEntry> entries;
  final VoidCallback onAddTap;

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _rotate = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  static const _meta = {
    MealType.breakfast: _M(icon: '🌅', name: 'الإفطار', bg: Color(0xFFFFF9E6)),
    MealType.lunch: _M(icon: '☀️', name: 'الغداء', bg: Color(0xFFFFF3CD)),
    MealType.snack: _M(icon: '🍎', name: 'وجبة خفيفة', bg: Color(0xFFFFE5E5)),
    MealType.dinner: _M(icon: '🌙', name: 'العشاء', bg: Color(0xFFE8F5FF)),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _meta[widget.mealType]!;
    final isDone = widget.entries.isNotEmpty;
    final totalKcal = widget.entries.fold<double>(0, (s, e) => s + e.calories);
    final names =
        widget.entries.map((e) => e.food.displayName).take(3).join('، ');
    final preview = isDone ? names : 'اضغط لإضافة وجبة';

    return Column(
      children: [
        GestureDetector(
          onTap: isDone ? _toggle : widget.onAddTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color:
                        isDone ? AppColors.accent.withOpacity(0.15) : meta.bg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(meta.icon, style: TextStyle(fontSize: 20.sp)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            meta.name,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isDone ? '${totalKcal.toInt()} سعرة' : '',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isDone
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        preview,
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
                isDone
                    ? RotationTransition(
                        turns: _rotate,
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textMuted, size: 20.r),
                      )
                    : GestureDetector(
                        onTap: widget.onAddTap,
                        child: Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.accent, size: 20.r),
                      ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _expanded && isDone
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: EdgeInsets.only(top: 4.h),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                ...widget.entries.map((entry) => _EntryRow(
                      entry: entry,
                      onDelete: () =>
                          context.read<NutritionCubit>().deleteEntry(entry.id),
                    )),
                InkWell(
                  onTap: widget.onAddTap,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.add_rounded,
                            color: AppColors.accent, size: 16.r),
                        SizedBox(width: 4.w),
                        Text(
                          'إضافة المزيد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.onDelete});
  final MealEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded,
                color: AppColors.danger, size: 18.r),
            SizedBox(width: 6.w),
            Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.bgSurface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r)),
                title: Text('حذف العنصر؟',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp)),
                content: Text(
                  'هل تريد حذف "${entry.food.displayName}"؟',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp),
                ),
                actionsAlignment: MainAxisAlignment.end,
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('إلغاء',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textMuted,
                            fontSize: 12.sp)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('حذف',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.food.displayName,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${entry.quantity.toInt()} ${entry.food.servingUnit}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.calories.toInt()} سعرة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'ب ${entry.protein.toInt()}g • ك ${entry.carbs.toInt()}g • د ${entry.fat.toInt()}g',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _M {
  const _M({required this.icon, required this.name, required this.bg});
  final String icon, name;
  final Color bg;
}

class MealSection extends StatelessWidget {
  const MealSection({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddTap,
    required this.onDeleteEntry,
  });

  final MealType mealType;
  final List<MealEntry> entries;
  final VoidCallback onAddTap;
  final ValueChanged<String> onDeleteEntry;

  @override
  Widget build(BuildContext context) => MealCard(
        mealType: mealType,
        entries: entries,
        onAddTap: onAddTap,
      );
}
