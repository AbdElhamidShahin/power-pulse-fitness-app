import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/workout_day_button.dart';

class FiveDaySplitScreen extends StatelessWidget {
  const FiveDaySplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'برنامج تقسيم 5 أيام',
          style: GoogleFonts.changa(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // تعديل لون الأيقونات
        ),
      ),
      body: Container(
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WorkoutDayButton(
                titlee: 'اليوم 1 - صدر',
                type: 'Day 1',
              ),
              WorkoutDayButton(
                titlee: 'اليوم 2 - ظهر',
                type: 'Day 2',
              ),
              WorkoutDayButton(
                titlee: 'اليوم 3 - أكتاف',
                type: 'Day 3',
              ),
              WorkoutDayButton(
                titlee: 'اليوم 4 - ذراعين',
                type: 'Day 4',
              ),
              WorkoutDayButton(
                titlee: 'اليوم 5 - أرجل',
                type: 'Day 5',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
