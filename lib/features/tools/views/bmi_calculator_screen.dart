import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bmi_widget.dart';

/// BMI Calculator screen.
///
/// Previously lib/view/exercise regimens/Bmi_calcolator.dart.
/// Renamed class to BmiCalculatorScreen; uses BmiWidget (was Bmi).
class BmiCalculatorScreen extends StatelessWidget {
  const BmiCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              ' حساب  BMI',
              textDirection: TextDirection.rtl,
              style: GoogleFonts.changa(
                  color: Colors.green[100], fontSize: 40),
            ),
            BmiWidget(),
          ],
        ),
      ),
    );
  }
}
