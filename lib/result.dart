import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ResultAlzAware extends StatefulWidget {
  final String alzValue;
  const ResultAlzAware(this.alzValue, {super.key});

  @override
  State<ResultAlzAware> createState() => _ResultAlzAwareState();
}

class _ResultAlzAwareState extends State<ResultAlzAware> {
  double predictionAvgValue = 0.0;
  FirebaseDatabase fbData = FirebaseDatabase.instance;

  Future<void> saveDataInDB() async {
    if (widget.alzValue == "500") {
      return;
    }

    await fbData
        .ref()
        .child("${FirebaseAuth.instance.currentUser?.uid}")
        .child("results")
        .update({
      DateTime.now().millisecondsSinceEpoch.toString():
          widget.alzValue == "200" ? 1 : 0.2
    });
  }

  @override
  void initState() {
    saveDataInDB();
    // TODO: implement initState
    if (widget.alzValue == "200") {
      predictionAvgValue = 0.0;
    }
    if (widget.alzValue == "400") {
      predictionAvgValue = 200.0;
    }

    if (widget.alzValue == "500") {
      predictionAvgValue = 50;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alzheimer's Prediction"),
      ),
      body: widget.alzValue != "500"
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      axisLineStyle: const AxisLineStyle(
                        thickness: 0.25,
                        thicknessUnit: GaugeSizeUnit.factor,
                        gradient: SweepGradient(colors: <Color>[
                          Color(0XFFD21404),
                          Color(0XFF03C04A)
                        ], stops: <double>[
                          0.40,
                          0.60
                        ]),
                      ),
                      pointers: [
                        RangePointer(
                            width: 40,
                            value: 100,
                            gradient: SweepGradient(colors: <Color>[
                              Colors.red,
                              Colors.red,
                              Colors.green.withOpacity(0.5),
                              Colors.green,
                              Colors.green,
                            ], stops: <double>[
                              0,
                              0.25,
                              0.5,
                              0.75,
                              1
                            ])),
                        NeedlePointer(
                          value: predictionAvgValue,
                          needleEndWidth: 20,
                          needleLength: 0.8,
                        ),
                      ],
                      showLabels: false,
                      showTicks: false,
                    ),
                  ],
                ),
                Text(
                  widget.alzValue == "200"
                      ? "The given sample has high probability of Alzheimer "
                      : "The given sample has minimal probability of Alzheimer",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      axisLineStyle: const AxisLineStyle(
                        thickness: 0.25,
                        gradient: SweepGradient(
                            colors: <Color>[Colors.grey, Colors.grey],
                            stops: <double>[0.40, 0.60]),
                      ),
                      pointers: [
                        RangePointer(
                            width: 40,
                            value: 100,
                            gradient: SweepGradient(colors: <Color>[
                              Colors.red,
                              Colors.red,
                              Colors.green.withOpacity(0.5),
                              Colors.green,
                              Colors.green,
                            ], stops: const <double>[
                              0,
                              0.25,
                              0.5,
                              0.75,
                              1
                            ])),
                        const NeedlePointer(
                          value: 50,
                          needleEndWidth: 20,
                          needleLength: 0.8,
                        ),
                      ],
                      showLabels: false,
                      showTicks: false,
                    ),
                  ],
                ),
                Text(
                  "There was an internal error. Please Try again!",
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}
