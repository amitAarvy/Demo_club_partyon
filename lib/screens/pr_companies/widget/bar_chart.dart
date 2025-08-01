import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarChartSample extends StatefulWidget {
  final data;

  const BarChartSample({super.key, this.data});

  @override
  State<BarChartSample> createState() => _BarChartSampleState();
}

class _BarChartSampleState extends State<BarChartSample> {
  double calculateMaxY(List<dynamic> data) {
    final clicks = data.map((e) => (e['click'] ?? 0) as int).toList();
    final maxClick = clicks.isEmpty ? 0 : clicks.reduce((a, b) => a > b ? a : b);

    if (maxClick == 0) return 10; // fallback if all values are zero

    // Round up to nearest 1000 and add 20% headroom
    double base = (maxClick / 1000).ceil() * 1000;
    return base + (base * 0.2);
  }

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

    int number = data
        .map((e) => (e['click'] ?? 0) as int)
        .reduce((a, b) => a > b ? a : b); // Get the max click value

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
    super.initState();
    dynamicValue = valueChange(widget.data['noOfClickList'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
        child: Row(

          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: RotatedBox(
                quarterTurns: -1,
                child: Text(
                  'Number of click',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: dynamicValue,  // Dynamically set the maxY value for the chart
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                // Format the left Y-axis labels based on the dynamic Y value
                                return Text(
                                  formatYLabel(value), // Format the Y-axis value to handle K, M, B
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final labels = (widget.data['noOfClickList'] as List)
                                    .where((e) => e['date'] != null)
                                    .toList();

                                int index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const Text('');
                                }

                                Timestamp timestamp = labels[index]['date'];
                                DateTime date = timestamp.toDate();

                                String dayLabel = DateFormat('dd/MM').format(date); // Format to get day of the month

                                return Text(
                                  dayLabel,
                                  style: const TextStyle(color: Colors.white),
                                );
                              },
                              reservedSize: 32,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        barGroups: (widget.data['noOfClickList'] as List).asMap().entries.map((entry) {
                          int index = entry.key;
                          var e = entry.value;
                          return BarChartGroupData(
                            x: index,  // X position (index)
                            barRods: [
                              BarChartRodData(toY: (e['click'] ?? 0).toDouble(), color: Colors.blue, width: 10),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // SizedBox(height: 10),
                  Text(
                    'Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Number of clicks :',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        Text(
                          '${widget.data['noOfClick']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
