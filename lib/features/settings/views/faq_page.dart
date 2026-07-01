import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:task/features/settings/views/widget/answer_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/ui/components/pp_app_bar.dart';

class FAQPage extends StatelessWidget {
  FAQPage({super.key});

  static const _faqs = [
    (
      'ما هي أفضل طريقة لبدء ممارسة التمارين؟',
      'أفضل طريقة لبدء ممارسة التمارين الرياضية هي تحديد أهدافك أولاً، سواء كانت لبناء العضلات، فقدان الوزن، أو تحسين اللياقة العامة. بعد ذلك، قم بإنشاء برنامج تدريبي يناسب هذه الأهداف.'
    ),
    (
      'كم مرة يجب أن أتمرن في الأسبوع؟',
      'يوصى بممارسة التمارين من 3 إلى 5 مرات في الأسبوع. يجب أن تتضمن هذه الجلسات تمارين القوة وتمارين الكارديو.'
    ),
    (
      'ما هي أفضل التمارين لبناء العضلات؟',
      'تمارين القرفصاء والرفعة الميتة وتمارين الصدر والبايسيبس من أفضل التمارين لبناء العضلات.'
    ),
    (
      'هل يجب أن أتناول مكملات غذائية؟',
      'المكملات الغذائية ليست ضرورية. يمكن الحصول على العناصر الغذائية من نظام غذائي متوازن. استشر أخصائي تغذية.'
    ),
    (
      'ما هي التمارين التي تحسن المرونة؟',
      'تمارين التمدد واليوغا مثل وضعية الطفل والمحارب تحسن المرونة بشكل فعال.'
    ),
    (
      'كيف أتجنب الإصابات أثناء التمرين؟',
      'قم بالإحماء الجيد، تعلم التقنية الصحيحة، لا ترفع أوزاناً ثقيلة، خذ راحة كافية واستمع لجسمك.'
    ),
    (
      'هل يمكنني التمرين وأنا مريض؟',
      'مرض خفيف: يمكن التمرين بخفة. مرض شديد أو حمى: خذ راحة حتى تتعافى تماماً.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PpBackBar(title: 'الأسئلة الشائعة'),
        body: AnimationLimiter(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
            itemCount: _faqs.length,
            itemBuilder: (context, i) {
              return AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 350),
                child: SlideAnimation(
                  verticalOffset: 40,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: OpenContainer(
                        transitionType: ContainerTransitionType.fade,
                        transitionDuration: const Duration(milliseconds: 350),
                        openColor: AppColors.background,
                        closedColor: AppColors.surface,
                        closedElevation: 0,
                        closedShape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          side: const BorderSide(
                              color: AppColors.cardBorder, width: 1),
                        ),
                        openBuilder: (context, _) => AnswerPage(
                          question: _faqs[i].$1,
                          answer: _faqs[i].$2,
                        ),
                        closedBuilder: (context, open) => InkWell(
                          onTap: open,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppSpacing.cardPadding),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 14, color: AppColors.outline),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(_faqs[i].$1,
                                      style: AppTextStyles.headingSmall,
                                      textAlign: TextAlign.end),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusMd),
                                    border: Border.all(
                                        color: AppColors.primary
                                            .withOpacity(0.25)),
                                  ),
                                  child: const Icon(Icons.help_outline_rounded,
                                      color: AppColors.primary, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
