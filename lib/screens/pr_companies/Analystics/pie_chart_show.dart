import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pie Chart Example")),
      body: Center(
        child: PieChart(
          PieChartData(
            sectionsSpace: 4, // spacing between slices
            centerSpaceRadius: 0, // 0 = disc
            sections: [
              PieChartSectionData(
                value: 40,
                title: 'Reserved',
                color: Colors.green,
                radius: 100,
                titleStyle: TextStyle(fontSize: 16, color: Colors.white),
              ),
              PieChartSectionData(
                value: 20,
                title: 'NoShow',
                color: Color(0xff1f51ff),
                radius: 100,
                titleStyle: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
