import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_constants.dart';

// ════════════════════════════════════════════════════════════════
// WaterCard — بطاقة الماء
// مطابق للصورة:
//   - يسار: 5 أعمدة زرقاء (3 مليانة + 2 فارغة)
//   - يمين: "💧 WATER" + "1.8L / 2.5L"
// ════════════════════════════════════════════════════════════════
class WaterCard extends StatelessWidget {
  const WaterCard({
    super.key,
    required this.current, // باللتر
    required this.goal,    // باللتر
  });

  final double current;
  final double goal;

  static const int _totalBars = 5;

  int get _filledBars =>
      (current / goal * _totalBars).round().clamp(0, _totalBars);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceL, vertical: AppConstants.spaceM + 2),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // ─── الأعمدة الزرقاء (يسار) ──────────────────────
          Row(
            children: List.generate(_totalBars, (i) {
              final isFilled = i < _filledBars;
              return Container(
                margin: const EdgeInsets.only(right: 6),
                width:  18,
                height: 40,
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppColors.info
                      : AppColors.info.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),

          // ─── النص (يمين) ─────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // "💧 WATER"
              const Row(
                children: [
                  Text(
                    'الماء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('💧', style: TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),

              // "1.8L / 2.5L"
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Cairo'),
                  children: [
                    TextSpan(
                      text: '${current}L',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.info,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${goal}L',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
