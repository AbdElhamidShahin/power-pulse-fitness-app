import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'pp_button.dart';

/// Premium motivational empty state.
/// Every empty state is a retention moment — not a dead end.
class PpEmptyState extends StatelessWidget {
  const PpEmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
    this.imageUrl,
  });

  final String emoji, title, subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji in a premium container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              title,
              style: AppTextStyles.headlineMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),

            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PpButton(
                label: ctaLabel!,
                onPressed: onCta,
                width: 200,
                height: 48,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
