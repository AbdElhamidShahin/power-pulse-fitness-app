import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/widgets/custom_app_bar.dart';
import 'five_day_split_screen.dart';
import 'push_pull_legs_screen.dart';
import 'your_exercise_screen.dart';

class ChooseWorkoutSystemScreen extends StatelessWidget {
  const ChooseWorkoutSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Container(
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage(
          //           'assets/images/f809e5a31e594e58b2f6f01f4eb68646.webp'),
          //       fit: BoxFit.cover, // تجعل الصورة تغطي الشاشة بالكامل
          //     ),
          //   ),
          // ),
          SizedBox(
            height: 30,
          ),
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PushPullLegsScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(width: 2, color: Colors.amber),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نظام دفع-سحب-أرجل',
                        style: GoogleFonts.changa(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FiveDaySplitScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(width: 2, color: Colors.amber),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نظام 5 أيام',
                        style: GoogleFonts.changa(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => YourExersize()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                        width: 2,
                        color: Colors.amber), // هنا تم تغيير اللون إلى الأبيض
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نظام التمارين الخاص',
                        style: GoogleFonts.changa(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .white, // تغيير لون النص إلى الأبيض إذا أردت
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors
                              .white), // هنا أيضًا تغيير لون الأيقونة إلى الأبيض
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
