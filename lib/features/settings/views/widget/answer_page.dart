import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/ui/components/pp_app_bar.dart';
import '../../../../core/ui/components/pp_card.dart';

class AnswerPage extends StatelessWidget {
  const AnswerPage({super.key, required this.question, required this.answer});
  final String question, answer;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PpBackBar(title: 'الإجابة'),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PpCard(
                borderColor: AppColors.primary.withOpacity(0.3),
                padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                child: Text(question,
                    style: AppTextStyles.headingSmall,
                    textAlign: TextAlign.end),
              ),
              const SizedBox(height: AppSpacing.sm),
              PpCard(
                padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                child: Text(answer,
                    style: AppTextStyles.bodyLg.copyWith(height: 1.8),
                    textAlign: TextAlign.end),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
