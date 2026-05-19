import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/workout_day_button.dart';

class PushPullLegsScreen extends StatelessWidget {
  const PushPullLegsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text(
            'دفع-سحب-أرجل',
            style: GoogleFonts.changa(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // تعديل لون الأيقونات
          ),
        ),
        body:
        Container(

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WorkoutDayButton(
                  titlee: 'تمارين الدفع',
                  type: 'Push',
                ),
                WorkoutDayButton(
                  titlee: 'تمارين السحب',
                  type: 'Pull',
                ),
                WorkoutDayButton(
                  titlee: 'تمارين الأرجل',
                  type: 'Leg',
                ),
              ],
            ),
          ),
        ),
      );

  }
}
