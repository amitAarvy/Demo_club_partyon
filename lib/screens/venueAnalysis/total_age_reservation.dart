import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TotalAgeReservation extends StatefulWidget {
  final List data;

  const TotalAgeReservation({super.key, required this.data});

  @override
  State<TotalAgeReservation> createState() => _TotalAgeReservationState();
}

class _TotalAgeReservationState extends State<TotalAgeReservation> {
  List<Map<String, dynamic>> ageGroupData = [];
  double dynamicValue = 0.0;

  @override
  void initState() {
    super.initState();
    ageGroupData = generateAgeGroups(widget.data);
    dynamicValue = calculateDynamicMaxY(ageGroupData);
  }

  List<Map<String, dynamic>> generateAgeGroups(List reservations) {
    final Map<String, Map<String, int>> ageCounts = {
      '---': {'male': 0, 'female': 0},
      '18-22y': {'male': 0, 'female': 0},
      '23-27y': {'male': 0, 'female': 0},
      '28-32y': {'male': 0, 'female': 0},
      '33-37y': {'male': 0, 'female': 0},
      '38-42y': {'male': 0, 'female': 0},
      '42+': {'male': 0, 'female': 0},
    };

    for (var reservation in reservations) {
      var data = reservation.data() as Map<String,dynamic>;
      print('check reservation list is ${ data}');
      if(data.containsKey('userList')){
        final userList = reservation['userList'] as List? ?? [];
        for (var user in userList) {
          final int? age = user['age'] as int?;
          final String gender = (user['gender'] ?? '').toString().toLowerCase();

          if (age == null || (gender != 'male' && gender != 'female')) continue;

          String group;
          if (age < 18) {
            group = '---';
          } else if (age <= 22) {
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
      }

    }

    return ageCounts.entries.map((entry) {
      return {
        'label': entry.key,
        'male': entry.value['male'],
        'female': entry.value['female'],
      };
    }).toList();
  }

  double calculateDynamicMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 10.0;

    final maxMale = data.map((e) => e['male'] as int).reduce((a, b) => a > b ? a : b);
    final maxFemale = data.map((e) => e['female'] as int).reduce((a, b) => a > b ? a : b);
    final maxValue = maxMale > maxFemale ? maxMale : maxFemale;

    if (maxValue < 10) return 10.0;
    if (maxValue < 20) return 20.0;
    if (maxValue < 50) return 50.0;
    if (maxValue < 100) return 100.0;
    if (maxValue < 1000) return 1000.0;

    return maxValue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1f51ff),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const RotatedBox(
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
                                  borderRadius: BorderRadius.zero,
                                  fromY: 0,
                                ),
                                BarChartRodData(
                                  toY: (data['female'] ?? 0).toDouble(),
                                  color: Colors.purple,
                                  width: 7,
                                  borderRadius: BorderRadius.zero,
                                  fromY: 0,
                                ),
                              ],
                              barsSpace: 0,
                            );
                          }).toList(),
                          maxY: dynamicValue,
                          minY: 0,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= ageGroupData.length) return Container();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      ageGroupData[index]['label'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                    const SizedBox(height: 10),
                    const Text(
                      'Age Groups',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
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
