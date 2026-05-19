import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../views/exercise_screen.dart';

class WorkoutDayButton extends StatelessWidget {
  final String titlee;
  final String type;

  const WorkoutDayButton(
      {Key? key, required this.titlee, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(width: 2, color: Colors.amber),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExerciseScreen(
                              currentDay: type,
                            )),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titlee,
                          style: GoogleFonts.changa(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Tap To View exercises",
                          style: GoogleFonts.changa(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
