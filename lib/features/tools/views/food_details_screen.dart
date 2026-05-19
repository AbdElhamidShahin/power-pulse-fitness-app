import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../shared/bloc/app_cubit.dart';
import '../../../shared/bloc/app_states.dart';

class FoodDetailsScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(),
      child: BlocConsumer<AppCubit, AppState>(
        listener: (BuildContext context, state) {},
        builder: (BuildContext context, state) {
          var cubit = AppCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'تفاصيل الطعام',
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TextField لإدخال اسم الطعام
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'أدخل اسم الطعام بالإنجليزية',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: Icon(Icons.fastfood, color: Colors.teal),
                      ),
                      style: TextStyle(
                          color: Colors.black), // تغيير اللون حسب الحاجة
                    ),

                    SizedBox(height: 20),

                    // زر للحصول على تفاصيل الطعام
                    ElevatedButton(
                      onPressed: () {
                        cubit.getFoodDetails(
                            _controller.text); // إرسال النص للمتحكم
                      },
                      child: Text(
                        'احصل على تفاصيل الطعام',
                        style: GoogleFonts.changa(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),

                    if (cubit.isLoading)
                      Center(child: CircularProgressIndicator()),

                    if (cubit.errorMessage.isNotEmpty)
                      Center(
                        child: Text(
                          cubit.errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    if (cubit.label.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              ':اسم الطعام',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              cubit.label,
                              style: GoogleFonts.changa(
                                  fontSize: 24, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    if (cubit.calories > 0 &&
                        !cubit.isLoading &&
                        cubit.errorMessage.isEmpty)
                      Column(
                        children: [
                          // مقياس السعرات الحرارية
                          SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 600,
                                ranges: <GaugeRange>[
                                  GaugeRange(
                                      startValue: 0,
                                      endValue: 100,
                                      color: Colors.green),
                                  GaugeRange(
                                      startValue: 100,
                                      endValue: 300,
                                      color: Colors.orange),
                                  GaugeRange(
                                      startValue: 300,
                                      endValue: 600,
                                      color: Colors.red),
                                ],
                                pointers: <GaugePointer>[
                                  NeedlePointer(value: cubit.calories),
                                ],
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    widget: Text(
                                      '${cubit.calories.toStringAsFixed(0)} Cal',
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    angle: 90,
                                    positionFactor: 0.5,
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // قسم الماكرو
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buildNutrientCircle(
                                  'PROTEIN', cubit.protein, Colors.green),
                              buildNutrientCircle(
                                  'CARBS', cubit.carbs, Colors.orange),
                              buildNutrientCircle('FAT', cubit.fat, Colors.red),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNutrientCircle(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 200,
                    showLabels: false,
                    showTicks: false,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.1,
                      thicknessUnit: GaugeSizeUnit.factor,
                      color: color.withOpacity(0.2),
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: value,
                        width: 0.1,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)} g',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}
