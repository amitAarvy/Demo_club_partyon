import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/pie_chart_analytics/pie_chart_analytics.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:club/screens/insta-analytics/models/retrieve_all_content_items.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/indicators/indicators.dart';

class Likes extends StatefulWidget {
  final int? totalLikes;
  final int? totalComments;
  final int? saveCount;
  final int? shareCount;
  final int? viewCount;
  final int? impressionOrganicCount;
  final int? reachOrganicCount;
  final UserData? mediaData;
  final int? replayCount;

  const Likes(
      {super.key,
      this.totalLikes,
      this.totalComments,
      this.saveCount,
      this.shareCount,
      this.viewCount,
      this.impressionOrganicCount,
      this.reachOrganicCount,
      this.mediaData,
      this.replayCount});

  @override
  State<Likes> createState() => _LikesState();
}

class _LikesState extends State<Likes> {
  late List<Map> pieChartData;
  late List<Map> reputationHistory;

  @override
  void initState() {
    pieChartData = [
      {"values": widget.totalLikes, "color": const Color(0xff8093F1)},
      {"values": widget.totalComments, "color": const Color(0xffE5A4CB)},
      {"values": widget.saveCount, "color": const Color(0xff939F5C)},
      {"values": widget.shareCount, "color": Colors.yellow},
      {"values": widget.viewCount, "color": Colors.purple},
      {
        "values": widget.impressionOrganicCount,
        "color": const Color(0xff72DDF7)
      },
      {"values": widget.reachOrganicCount, "color": const Color(0xffC792DF)},
      {"values": widget.replayCount, "color": Colors.lightBlue},
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Engagement Overview ❤️',
          style: TextStyle(
              fontSize: 66.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        SizedBox(height: 300.h),
        SizedBox(
          height: 400.h,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 20,
              sectionsSpace: pieChartData.length.toDouble(),
              centerSpaceColor: Colors.white,
              sections: PieChartAnalytics.section(pieChartData),
            ),
          ),
        ),
        SizedBox(height: 240.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            const Indicators(
              color: Color(0xff72DDF7),
              text: 'Impression Organic Count',
            ),
            SizedBox(height: 12.h),
            const Indicators(
              color: Color(0xffC792DF),
              text: 'Reach Organic Count',
            ),
            SizedBox(height: 12.h),
            const Indicators(
              color: Color(0xffE5A4CB),
              text: 'Comments',
            ),
            SizedBox(height: 12.h),
            const Indicators(
              color: Color(0xff939F5C),
              text: 'Save Count',
            ),
            SizedBox(height: 12.h),
            const Indicators(
              color: Colors.yellow,
              text: 'Share Count',
            ),
            SizedBox(height: 12.h),
            const Indicators(
              color: Colors.purple,
              text: 'Views Count',
            ),
            SizedBox(height: 12.h),
            const Indicators(
              color: Color(0xff8093F1),
              text: 'Likes',
            ),
            SizedBox(height: 12.h),
            const Indicators(
              color: Colors.lightBlue,
              text: 'Replay Count',
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ],
    );
  }
}
