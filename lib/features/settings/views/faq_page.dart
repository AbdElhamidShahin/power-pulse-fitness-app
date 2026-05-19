import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "ما هي أفضل طريقة لبدء ممارسة التمارين الرياضية في الجيم؟",
      "answer":
          "أفضل طريقة لبدء ممارسة التمارين الرياضية هي تحديد أهدافك أولاً، سواء كانت لبناء العضلات، فقدان الوزن، أو تحسين اللياقة العامة. بعد ذلك، قم بإنشاء برنامج تدريبي يناسب هذه الأهداف. يمكنك أيضًا استشارة مدرب شخصي لمساعدتك في وضع خطة تدريبية مناسبة."
    },
    {
      "question": "كم مرة يجب أن أتمرن في الأسبوع؟",
      "answer":
          "يعتمد ذلك على أهدافك ومستوى لياقتك البدنية الحالي. بشكل عام، يوصى بممارسة التمارين من 3 إلى 5 مرات في الأسبوع. يجب أن تتضمن هذه الجلسات تمارين القوة وتمارين الكارديو."
    },
    {
      "question": "ما هي أفضل التمارين لبناء العضلات؟",
      "answer":
          "هناك العديد من التمارين الفعالة لبناء العضلات، مثل تمارين القرفصاء (Squats)، والرفعة الميتة (Deadlifts)، وتمارين الصدر بالدمبل (Dumbbell Bench Press)، وتمارين الباي سيبس بالدمبل (Dumbbell Bicep Curls)."
    },
    {
      "question": "هل يجب أن أتناول مكملات غذائية؟",
      "answer":
          "المكملات الغذائية ليست ضرورية لجميع الأشخاص. يمكن الحصول على جميع العناصر الغذائية اللازمة من نظام غذائي متوازن. إذا كنت تشعر بأنك لا تحصل على كمية كافية من بعض العناصر الغذائية، يمكنك استشارة أخصائي تغذية للنظر في إمكانية تناول مكملات غذائية."
    },
    {
      "question": "ما هي التمارين التي يمكنني القيام بها لتحسين مرونتي؟",
      "answer":
          "لتحسين المرونة، يمكنك ممارسة تمارين التمدد (Stretching) مثل تمرين الكوبرا (Cobra Stretch)، وتمرين الهمسترينغ (Hamstring Stretch)، وتمارين اليوغا مثل وضعية الطفل (Child's Pose) ووضعية المحارب (Warrior Pose)."
    },
    {
      "question": "كيف يمكنني تجنب الإصابات أثناء التمرين؟",
      "answer":
          "لتجنب الإصابات، تأكد من القيام بالإحماء الجيد قبل بدء التمرين، وتعلم التقنية الصحيحة لكل تمرين، ولا ترفع أوزاناً ثقيلة جداً بالنسبة لمستوى قوتك. كما يجب أن تأخذ فترات راحة كافية بين الجلسات وتستمع لجسمك."
    },
    {
      "question": "هل يمكنني ممارسة التمارين الرياضية إذا كنت مريضاً؟",
      "answer":
          "إذا كنت تعاني من مرض خفيف مثل نزلة برد، يمكنك ممارسة التمارين بانتظام ولكن بخفة. إذا كنت تعاني من مرض شديد أو حمى، فمن الأفضل أخذ راحة حتى تتعافى تماماً."
    },
  ];

    FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الأسئلة الشائعة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: AnimationLimiter(
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OpenContainer(
                      transitionType: ContainerTransitionType.fade,
                      openBuilder: (context, _) => _buildAnswerPage(context,
                          faqs[index]['question']!, faqs[index]['answer']!),
                      closedElevation: 0,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      closedBuilder: (context, openContainer) {
                        return GestureDetector(
                          onTap: openContainer,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.help_outline,
                                    color: Colors.blueAccent),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    faqs[index]['question']!,
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnswerPage(
      BuildContext context, String question, String answer) {
    return Scaffold(
      appBar: AppBar(
        title: Text(question,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            answer,
            style: GoogleFonts.cairo(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }
}
