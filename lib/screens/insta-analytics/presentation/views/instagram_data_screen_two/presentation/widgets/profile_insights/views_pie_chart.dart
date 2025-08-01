import 'package:club/screens/insta-analytics/const/const.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewsPieChart {
  static List<PieChartSectionData> section(
      int touchedIndex, int? followCount, int? nonFollowCount) {
    double radius = touchedIndex == 3 ? 100.0 : 80.0;
    double fontSize = touchedIndex == 0 ? 52.sp : 44.sp;
    return InstagramDataConst.viewsData(followCount ?? 0, nonFollowCount ?? 0)
        .map((e) => PieChartSectionData(
              value: (e['views'] as int).toDouble(),
              color: e['color'],
              title: '${e['views']} ',
              radius: radius,
              showTitle: true,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ))
        .toList();
  }
}
