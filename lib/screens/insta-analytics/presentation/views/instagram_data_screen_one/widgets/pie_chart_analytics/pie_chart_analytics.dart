import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PieChartAnalytics {
  static List<PieChartSectionData> section(List<Map> pieChartData) {
    return pieChartData
        .map((e) => PieChartSectionData(
              radius: 120,
              value: e['values'] is double
                  ? (e['values'] as double)
                  : (e['values'] as int).toDouble(),
              color: e['color'],
              title: '${e['values']}',
              showTitle: true,
              titlePositionPercentageOffset: 0.5,
              titleStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 40.sp),
            ))
        .toList();
  }
}
