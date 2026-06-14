import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Full-bleed workout image card with gradient overlay — RTL safe
class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.image,
    required this.dayLabel,
    required this.muscleLabel,
    this.onTap,
    this.height = 190.0,
    this.isRest = false,
    this.badge,
  });

  final String image, dayLabel, muscleLabel;
  final VoidCallback? onTap;
  final double height;
  final bool isRest;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(image, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1E2438), Color(0xFF0B0F1A)],
                    ),
                  ),
                  child: const Center(child: Icon(Icons.fitness_center, color: AppColors.outline, size: 48)),
                ),
              ),
              // Gradient overlay (dark right for RTL)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft, end: Alignment.centerRight,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.82)],
                    ),
                  ),
                ),
              ),
              // Bottom info
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(dayLabel, style: AppTextStyles.labelCaps.copyWith(color: AppColors.primary, letterSpacing: 1.5), textAlign: TextAlign.end),
                      const SizedBox(height: 2),
                      Text(muscleLabel, style: AppTextStyles.headlineMd.copyWith(fontSize: 19), textAlign: TextAlign.end),
                    ],
                  ),
                ),
              ),
              // Badge
              if (badge != null)
                Positioned(
                  top: AppSpacing.xs, right: AppSpacing.xs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(badge!, style: AppTextStyles.labelCaps.copyWith(fontSize: 10, color: AppColors.onPrimary)),
                  ),
                ),
              // Rest overlay
              if (isRest)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.self_improvement, color: AppColors.success.withOpacity(0.9), size: 44),
                        const SizedBox(height: 8),
                        Text('يوم راحة', style: AppTextStyles.headlineMd.copyWith(color: AppColors.success)),
                      ]),
                    ),
                  ),
                ),
              // Ripple
              if (onTap != null)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
