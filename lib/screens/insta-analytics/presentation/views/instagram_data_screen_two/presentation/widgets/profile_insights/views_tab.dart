import 'package:club/screens/insta-analytics/const/const.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/indicators/indicators.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_two/presentation/widgets/profile_insights/views_pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewsTab extends StatefulWidget {
  final int? totalViews;

  const ViewsTab({super.key, required this.totalViews});

  @override
  State<ViewsTab> createState() => _ViewsTabState();
}

class _ViewsTabState extends State<ViewsTab> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            height: 400.h,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 10,
                sectionsSpace: 4,
                centerSpaceColor: Colors.white,
                sections:
                    ViewsPieChart.section(touchedIndex, widget.totalViews, 0),
                pieTouchData: PieTouchData(
                  longPressDuration: const Duration(milliseconds: 500),
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 150),
              swapAnimationCurve: Curves.linear,
            ),
          ),
        ),
        SizedBox(width: 24.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 160.h),
            const Indicators(
              color: Colors.blue,
              text: 'Followers',
            ),
            SizedBox(height: 8.h),
            const Indicators(
              color: Colors.pink,
              text: 'Non-Followers',
            ),
            Padding(
              padding: EdgeInsets.only(top: 40.h),
              child: Text(
                'Total Views - ${widget.totalViews ?? 'NA'}  ',
                style: TextStyle(fontSize: 44.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ],
    );
  }
}
