
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


class CustomGauge extends StatelessWidget {
  final double caloriesValue;

  const CustomGauge({Key? key, required this.caloriesValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            showLabels: false,
            showTicks: false,
            startAngle: 0,
            endAngle: 360,
            radiusFactor: 0.7,
            canScaleToFit: true,
            axisLineStyle: AxisLineStyle(
              thickness: 0.1,
              color: Colors.yellow,
              thicknessUnit: GaugeSizeUnit.factor,
              cornerStyle: CornerStyle.startCurve,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: caloriesValue,
                width: 0.1,
                sizeUnit: GaugeSizeUnit.factor,
                cornerStyle: CornerStyle.bothCurve,
                gradient: const SweepGradient(
                  colors: <Color>[
                    Color(0xFF00a9b5),
                    Color(0xFFa4edeb),
                  ],
                  stops: <double>[0.25, 0.50],
                ),
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${caloriesValue.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'calories',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                horizontalAlignment: GaugeAlignment.center,
                verticalAlignment: GaugeAlignment.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}