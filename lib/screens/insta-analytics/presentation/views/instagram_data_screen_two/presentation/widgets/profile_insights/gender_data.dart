import 'package:club/screens/insta-analytics/models/audience_demographics.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/indicators/indicators.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/pie_chart_analytics/pie_chart_analytics.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GenderData extends StatefulWidget {
  final RetrieveAudienceDemographics? audienceDemographics;

  const GenderData({super.key, this.audienceDemographics});

  @override
  State<GenderData> createState() => _GenderDataState();
}

class _GenderDataState extends State<GenderData> {
  late List<Map> pieChartData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<GenderAgeDistribution>? ageResults =
        widget.audienceDemographics?.genderAgeDistribution;

    final List? malesList = ageResults
        ?.where((e) => e.gender == 'MALE')
        .toList()
        .map((e) => e.value)
        .toList();
    final double? malesTotalEngagement =
        malesList?.fold(0.0, (sum, value) => sum! + value);

    final List? femalesList = ageResults
        ?.where((e) => e.gender == 'FEMALE')
        .toList()
        .map((e) => e.value)
        .toList();
    final double? femalesTotalEngagement =
        femalesList?.fold(0.0, (sum, value) => sum! + value);

    final List? othersList = ageResults
        ?.where((e) => e.gender == 'OTHER')
        .toList()
        .map((e) => e.value)
        .toList();

    final double? othersTotalEngagement =
        othersList?.fold(0.0, (sum, value) => sum! + value);

    pieChartData = [
      {
        "values": malesTotalEngagement?.toPrecision(1),
        "color": const Color(0xff72DDF7)
      },
      {
        "values": femalesTotalEngagement?.toPrecision(1),
        "color": Colors.purpleAccent
      },
      {
        "values": othersTotalEngagement?.toPrecision(1),
        "color": const Color(0xff8093F1)
      },
    ];

    if (ageResults != null && ageResults.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender-wise Engagement %',
            style: TextStyle(
                fontSize: 66.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          SizedBox(height: 300.h),
          SizedBox(
            height: 400.h,
            child: PieChart(PieChartData(
              centerSpaceRadius: 20,
              sectionsSpace: pieChartData.length.toDouble(),
              startDegreeOffset: 180,
              centerSpaceColor: Colors.white,
              sections: PieChartAnalytics.section(pieChartData),
            )),
          ),
          SizedBox(height: 240.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              const Indicators(
                color: Color(0xff72DDF7),
                text: 'Total Males Engagement %',
              ),
              SizedBox(height: 12.h),
              const Indicators(
                color: Colors.purpleAccent,
                text: 'Total Females Engagement %',
              ),
              SizedBox(height: 12.h),
              const Indicators(
                color: Color(0xff8093F1),
                text: 'Total Others Engagement %',
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ],
      );
    } else {
      return Text(
        'No Gender Engagement Data Available!',
        style: TextStyle(color: Colors.white, fontSize: 52.sp),
      );
    }
  }
}
