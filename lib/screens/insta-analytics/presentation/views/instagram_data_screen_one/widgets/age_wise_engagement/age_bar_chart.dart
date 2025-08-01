import 'package:fl_chart/fl_chart.dart';

import 'bar_chart_rod_data.dart';

List<Map> barChartGroupData = [
  {
    "age_group": 13-17,
  },
  {
    "age_group": 18-24,
  },
  {
    "age_group": 25-34,
  },
  {
    "age_group": 35-44,
  },
  {
    "age_group": 45-54,
  },
  {
    "age_group": 55-64,
  },
  {
    "age_group": 65-80,
  },
];

class AgeBarChart {
  static List<BarChartGroupData> barGroups() {
    return barChartGroupData
        .map((e) => BarChartGroupData(
              x: (e["age_group"]),
              groupVertically: true,
              barsSpace: 20,
              barRods: BarChartRodAnalytics.barRods(),
            ))
        .toList();
  }
}
