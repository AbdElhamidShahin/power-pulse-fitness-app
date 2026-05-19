import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/workout_day_card.dart';
import '../../exercises/views/muscle_group_screen.dart';

/// Home tab — displays the weekly workout plan.
///
/// Previously lib/view/views/Home_veiw.dart.
/// Uses WorkoutDayCard (was CustomTextField) and AppConstants for image paths.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          WorkoutDayCard(
            image: AppConstants.imgChest,
            text1: ' اليوم الاول:',
            text2: 'عضلات الصدر',
            routeToNavigate: MuscleGroupScreen(
              pageId: AppConstants.pageIdChest,
              title: 'تمارين الصدر',
              itemCount: 6,
            ),
          ),
          WorkoutDayCard(
            image: AppConstants.imgLates,
            text1: 'اليوم الثاني:',
            text2: 'عضلات الظهر',
            routeToNavigate: MuscleGroupScreen(
              pageId: AppConstants.pageIdLates,
              title: 'تمارين الظهر',
              itemCount: 6,
            ),
          ),
          WorkoutDayCard(
            image: AppConstants.imgShoulder,
            text1: ' اليوم الثالث:',
            text2: 'عضلات الكتفين',
            routeToNavigate: MuscleGroupScreen(
              pageId: AppConstants.pageIdShoulder,
              title: 'تمارين الكتف',
              itemCount: 6,
            ),
          ),
          const WorkoutDayCard(
            image: AppConstants.imgRest,
            text1: ' اليوم الرابع:',
            text2: 'راحه',
          ),
          WorkoutDayCard(
            image: AppConstants.imgHands,
            text1: ' اليوم الخامس:',
            text2: 'عضلات الذراع',
            routeToNavigate: MuscleGroupScreen(
              pageId: AppConstants.pageIdHands,
              title: 'تمارين الذراع',
              itemCount: 6,
            ),
          ),
          WorkoutDayCard(
            image: AppConstants.imgLegs,
            text1: ' اليوم السادس:',
            text2: 'الارجل',
            routeToNavigate: MuscleGroupScreen(
              pageId: AppConstants.pageIdLegs,
              title: 'تمارين الأرجل',
              itemCount: 6,
            ),
          ),
          WorkoutDayCard(
            image: AppConstants.imgBelly,
            text1: ' اليوم السابع:',
            text2: 'عضلات البطن',
            routeToNavigate: MuscleGroupScreen(
              pageId: AppConstants.pageIdBelly,
              title: 'تمارين البطن',
              itemCount: 6,
            ),
          ),
        ],
      ),
    );
  }
}
