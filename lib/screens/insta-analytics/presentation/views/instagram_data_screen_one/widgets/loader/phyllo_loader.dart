import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class PhylloLoader extends StatelessWidget {
  const PhylloLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingIndicator(
        indicatorType: Indicator.ballSpinFadeLoader,
        colors: [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.indigo,
          Colors.purple,
        ],
        strokeWidth: 2,
        backgroundColor: Colors.transparent,
        pathBackgroundColor: Colors.black);
  }
}
