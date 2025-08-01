import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AgeBarCharts extends StatefulWidget {
  final data;
  const AgeBarCharts({super.key, this.data});

  @override
  State<AgeBarCharts> createState() => _AgeBarChartsState();
}

class _AgeBarChartsState extends State<AgeBarCharts> {

  List<Map<String, dynamic>> generateAgeGroups(List<Map<String, dynamic>> users) {
    Map<String, Map<String, int>> ageCounts = {
      '---': {'male': 0, 'female': 0},
      '18-22y': {'male': 0, 'female': 0},
      '23-27y': {'male': 0, 'female': 0},
      '28-32y': {'male': 0, 'female': 0},
      '33-37y': {'male': 0, 'female': 0},
      '38-42y': {'male': 0, 'female': 0},
      '42+': {'male': 0, 'female': 0},
    };

    for (var user in users) {
      int? age = user['age'];
      String gender = (user['gender'] ?? '').toLowerCase();

      if (age == null || (gender != 'male' && gender != 'female')) continue;

      String group;
      if (age < 18) {
        group = '---';
      } else
        if (age <= 22) {
        group = '18-22y';
      } else if (age <= 27) {
        group = '23-27y';
      } else if (age <= 32) {
        group = '28-32y';
      } else if (age <= 37) {
        group = '33-37y';
      } else if (age <= 42) {
        group = '38-42y';
      } else {
        group = '42+';
      }

      ageCounts[group]![gender] = ageCounts[group]![gender]! + 1;
    }

    return ageCounts.entries.map((e) => {
      'label': e.key,
      'male': e.value['male'],
      'female': e.value['female'],
    }).toList();
  }

  List<Map<String,dynamic>> ageGroupData =[];

  // Function to calculate maxY based on the data
  double calculateMaxY(List<dynamic> data) {
    final clicks = data.map((e) => (e['click'] ?? 0) as int).toList();
    final maxClick = clicks.isEmpty ? 0 : clicks.reduce((a, b) => a > b ? a : b);

    if (maxClick == 0) return 10; // fallback if all values are zero

    // Round up to nearest 1000 and add 20% headroom
    double base = (maxClick / 1000).ceil() * 1000;
    return base + (base * 0.2);
  }

  // Format Y-axis labels (e.g., 1K, 2.5K)
  String formatYLabel(double value) {
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(1)}B';  // Format Billion
    }
    if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(1)}M';  // Format Million
    }
    if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(1)}K';  // Format Thousand
    }
    return value.toInt().toString();  // Return the number as is for smaller values
  }

  // Function to calculate max value and return formatted value for larger numbers
  valueChange(List data) {
    if (data.isEmpty) return 1000.0; // Default value if empty

    int number2 = data
        .map((e) => (e['male'] ?? 0) as int)
        .reduce((a, b) => a > b ? a : b);
    int number1 = data
        .map((e) => (e['female'] ?? 0) as int)
        .reduce((a, b) => a > b ? a : b);
    int number = number2 > number1 ? number2 : number1;

    print('check value is ${number}');
    if (number < 10) {
      return 10.0;  // Return 100 if value is less than 100
    }
    if (number < 20) {
      return 20.0;  // Return 100 if value is less than 100
    }
    if (number < 50) {
      return 50.0;  // Return 100 if value is less than 100
    }
    if (number < 100) {
      return 100.0;  // Return 100 if value is less than 100
    }
    if (number < 1000) {
      return 1000.0;
    }

    // Handle larger values and return in K, M, B format for Y-axis labels, but keep maxY numeric.
    if (number >= 1e9) {
      return number.toDouble();  // For Billion values, just return the number
    }
    if (number >= 1e6) {
      return number.toDouble();  // For Million values, just return the number
    }
    if (number >= 1e3) {
      return number.toDouble();  // For Thousand values, just return the number
    }
    return number.toDouble(); // Default return the raw number
  }

  double dynamicValue = 0.0;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ageGroupData = generateAgeGroups((widget.data['userList'] as List).cast<Map<String, dynamic>>());
    dynamicValue = valueChange(ageGroupData);
    print('check it is age data ${ageGroupData}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xff1f51ff),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RotatedBox(
                quarterTurns: -1,
                child: Text(
                  ' Number of Reservation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 0.9,
                      child: BarChart(
                        BarChartData(
                          barGroups: ageGroupData.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: (data['male'] ?? 0).toDouble(),
                                  color: Colors.blue,
                                  width: 7,
                                  borderRadius: BorderRadius.circular(0),
                                  fromY: 0,
                                ),
                                BarChartRodData(
                                  toY: (data['female'] ?? 0).toDouble(),
                                  color: Colors.purple,
                                  width: 7,
                                  borderRadius: BorderRadius.circular(0),
                                  fromY: 0,
                                ),
                              ],
                              barsSpace: 0,
                            );
                          }).toList(),
                          // groupsSpace: 80,
                          maxY: dynamicValue,
                          minY: 0,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= ageGroupData.length) return Container();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      ageGroupData[index]['label'],
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10),
                                    ),
                                  );
                                },
                                reservedSize: 36,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 20,
                                // interval: 10,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                      // SizedBox(height: 10),
                      Text(
                      'Age Groups',
                      style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      ),)
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
