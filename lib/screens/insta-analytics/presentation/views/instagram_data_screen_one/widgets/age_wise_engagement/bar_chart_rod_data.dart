import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<Map> barRodList = [
  {"toY": 30},
  {"toY": 50},
  {"toY": 100},
  {"toY": 100},
  {"toY": 200},
  {"toY": 350},
  {"toY": 420}
];

class BarChartRodAnalytics {
  static List<BarChartRodData> barRods() {
    return barRodList
        .map((e) => BarChartRodData(
              toY: (e["toY"] as int).toDouble(),
              color: Colors.blue,
              width: 28,
              borderRadius: BorderRadius.circular(16),
            ))
        .toList();
  }
}
