import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../shared/bloc/app_cubit.dart';
import '../../../shared/bloc/app_states.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/number_input_field.dart';

/// BMI input form + gauge result widget.
///
/// Previously lib/view/wedget/CustomBmi.dart (`class Bmi`).
/// Renamed to BmiWidget; updated imports. No logic changes.
class BmiWidget extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  BmiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (_, __) {},
        builder: (context, state) {
          final cubit = AppCubit.get(context);

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      NumberInputField(
                        hintText: 'أدخل طولك',
                        title: 'الطول',
                        onChanged: (v) =>
                            cubit.height1 = double.tryParse(v) ?? 0,
                      ),
                      NumberInputField(
                        title: 'الوزن  ',
                        hintText: 'أدخل وزنك',
                        onChanged: (v) =>
                            cubit.weight1 = double.tryParse(v) ?? 0,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        child: PrimaryButton(
                          text: 'احسب BMI',
                          width: double.infinity,
                          height: 71,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              cubit.calculatedBMI = cubit.weight1 /
                                  (cubit.height1 * cubit.height1) *
                                  10000;
                              cubit.emit(AppStateUpdatedState());
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // BMI Gauge
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SfRadialGauge(
                          axes: <RadialAxis>[
                            RadialAxis(
                              minimum: 0,
                              maximum: 55,
                              ranges: <GaugeRange>[
                                GaugeRange(
                                    startValue: 0,
                                    endValue: 18.5,
                                    color: AppColors.bmiUnderweight),
                                GaugeRange(
                                    startValue: 18.5,
                                    endValue: 24.9,
                                    color: AppColors.bmiNormal),
                                GaugeRange(
                                    startValue: 25,
                                    endValue: 29.9,
                                    color: AppColors.bmiOverweight),
                                GaugeRange(
                                    startValue: 30,
                                    endValue: 40,
                                    color: AppColors.bmiObese),
                                GaugeRange(
                                    startValue: 40,
                                    endValue: 55,
                                    color: AppColors.bmiMorbidObese),
                              ],
                              pointers: <GaugePointer>[
                                NeedlePointer(
                                  value: cubit.calculatedBMI,
                                  enableAnimation: true,
                                  animationDuration: 1000,
                                ),
                              ],
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                  widget: Text(
                                    cubit.calculatedBMI.toStringAsFixed(1),
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  angle: 90,
                                  positionFactor: 0.8,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 8),
                        child: Text(
                          'مؤشر كتلة الجسم:',
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.changa(
                              color: AppColors.textWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          'BMI: ${cubit.calculatedBMI.toStringAsFixed(2)}',
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.changa(
                              color: AppColors.textGreenAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 8),
                        child: Text(
                          'النتيجة:',
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.changa(
                              color: AppColors.textWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          cubit.getResultText(),
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.changa(
                              color: AppColors.textGreenAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
