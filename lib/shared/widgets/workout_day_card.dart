import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/navigation_utils.dart';

class WorkoutDayCard extends StatelessWidget {
  const WorkoutDayCard({
    super.key,
    required this.image,
    required this.text1,
    required this.text2,
    this.routeToNavigate,
  });

  final Widget? routeToNavigate;
  final String image;
  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: GestureDetector(
        onTap: () {
          if (routeToNavigate != null) {
            Navigator.push(
              context,
              NavigationUtils.fadeScaleRoute(routeToNavigate!),
            );
          }
        },
        child: Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Column(
                        children: [
                          Text(text1, style: AppTextStyles.cardTitle),
                          const SizedBox(height: 3),
                          Text(text2, style: AppTextStyles.cardSubtitle),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
