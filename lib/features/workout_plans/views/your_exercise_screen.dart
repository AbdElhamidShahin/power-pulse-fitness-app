import 'package:flutter/material.dart';

import '../widgets/workout_day_button.dart';

class YourExersize extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('برنامج تقسيم 7 أيام'),
      ),
      body: Container(
        child: const SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WorkoutDayButton(
                  titlee: 'اليوم 1',
                  type: 'Day 1',
                ),
                WorkoutDayButton(
                  titlee: 'اليوم 2',
                  type: 'Day 2',
                ),
                WorkoutDayButton(
                  titlee: 'اليوم 3',
                  type: 'Day 3',
                ),
                WorkoutDayButton(
                  titlee: 'اليوم 4',
                  type: 'Day 4',
                ),
                WorkoutDayButton(
                  titlee: 'اليوم 5',
                  type: 'Day 5',
                ),
                WorkoutDayButton(
                  titlee: 'اليوم 6',
                  type: 'Day 6',
                ),
                WorkoutDayButton(
                  titlee: 'اليوم 7',
                  type: 'Day 7',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
