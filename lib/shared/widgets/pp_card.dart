import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// كارد سطح عادي
class PPCard extends StatelessWidget {
  const PPCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.bgSurface,
        borderRadius: BorderRadius.circular(radius ?? AppConstants.radiusL),
        border: Border.all(color: borderColor ?? AppColors.borderSubtle),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.spaceL),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }
    return container;
  }
}

/// كارد Hero كبير بصورة خلفية + overlay
class PPHeroCard extends StatelessWidget {
  const PPHeroCard({
    super.key,
    required this.title,
    this.subtitle,
    this.tag,
    this.tagColor,
    this.imageUrl,
    this.imageWidget,
    this.height = AppConstants.cardHeightHero,
    this.onTap,
    this.bottomWidget,
  });

  final String title;
  final String? subtitle;
  final String? tag;
  final Color? tagColor;
  final String? imageUrl;
  final Widget? imageWidget;
  final double height;
  final VoidCallback? onTap;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : imageWidget ?? _placeholder(),

              // Gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tag != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: AppConstants.spaceS),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceM,
                            vertical: AppConstants.spaceXXS + 2,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor ?? AppColors.accent,
                            borderRadius: BorderRadius.circular(AppConstants.radiusPill),
                          ),
                          child: Text(
                            tag!,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: tagColor != null
                                  ? Colors.white
                                  : AppColors.textOnAccent,
                            ),
                          ),
                        ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppConstants.spaceXS),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                      if (bottomWidget != null) ...[
                        const SizedBox(height: AppConstants.spaceS),
                        bottomWidget!,
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.bgElevated,
        child: const Icon(Icons.fitness_center, color: AppColors.bgHighest, size: 48),
      );
}

/// كارد إحصائية صغيرة
class PPStatCard extends StatelessWidget {
  const PPStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.trend,
    this.trendUp,
    this.bottomWidget,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final String? trend;
  final bool? trendUp;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.accent;
    return PPCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(icon, color: color, size: AppConstants.iconS),
          ),
          const SizedBox(height: AppConstants.spaceM),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXS),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: AppConstants.spaceS),
            Text(
              '${(trendUp ?? true) ? '▲' : '▼'} $trend',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: (trendUp ?? true) ? AppColors.success : AppColors.danger,
              ),
            ),
          ],
          if (bottomWidget != null) ...[
            const SizedBox(height: AppConstants.spaceS),
            bottomWidget!,
          ],
        ],
      ),
    );
  }
}
