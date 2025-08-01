import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReservedPiaChart extends StatefulWidget {
  final data;
  const ReservedPiaChart({super.key, this.data});

  @override
  State<ReservedPiaChart> createState() => _ReservedPiaChartState();
}

class _ReservedPiaChartState extends State<ReservedPiaChart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PieChart(
        swapAnimationDuration: Duration(microseconds: 750),
        PieChartData(
          sections: [
            PieChartSectionData(
              value:   double.parse(widget.data['noOfReserved'].toString()),
        // "NoShow" : (prDetail[0]['userList'] as List).where((e)=>e['noShow'].toString() =='true').length.toDouble(),,
              color: Colors.green,
              // title: 'Reserved',
              titleStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              showTitle: true,
            ),
            PieChartSectionData(
              value: (widget.data['userList'] as List).where((e)=>e['noShow'].toString() =='true').length.toDouble(),
              color: Colors.blue,
              // title: 'No show',
              titleStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
              showTitle: true,
            ),
          ]
        )
      ),
    );
  }
}
