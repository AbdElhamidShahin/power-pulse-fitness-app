import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Standard surface card — #151A26 + 1px divider border
class PpCard extends StatelessWidget {
  const PpCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.onTap,
    this.color,
    this.borderColor,
    this.glowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius ?? AppSpacing.radiusLg);
    final bg = color ?? AppColors.surface;
    final border = borderColor ?? AppColors.cardBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: br,
        border: Border.all(color: border, width: 1),
        boxShadow: glowColor != null
            ? [BoxShadow(color: glowColor!.withOpacity(0.18), blurRadius: 24, spreadRadius: 0)]
            : null,
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: br,
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
                  child: child,
                ),
              ),
            )
          : Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
              child: child,
            ),
    );
  }
}

/// Section header with optional "see all" action
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.actionLabel = 'عرض الكل'});
  final String title;
  final VoidCallback? action;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (action != null)
          GestureDetector(
            onTap: action,
            child: Text(
              actionLabel,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
