// import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/indicators/indicators.dart';
// import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/pie_chart_analytics/pie_chart_analytics.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class Comment extends StatefulWidget {
//   final int? totalComments;
//
//   const Comment({super.key, required this.totalComments});
//
//   @override
//   State<Comment> createState() => _CommentState();
// }
//
// class _CommentState extends State<Comment> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Comments Overview 💬',
//           style: TextStyle(fontSize: 66.sp, fontWeight: FontWeight.bold),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: SizedBox(
//                 height: 400.h,
//                 child: PieChart(
//                   PieChartData(
//                     centerSpaceRadius: 10,
//                     sectionsSpace: 4,
//                     centerSpaceColor: Colors.white,
//                     sections: PieChartAnalytics.section(),
//                     pieTouchData: PieTouchData(
//                       longPressDuration: const Duration(milliseconds: 500),
//                       touchCallback: (FlTouchEvent event, pieTouchResponse) {
//                         setState(() {
//                           if (!event.isInterestedForInteractions ||
//                               pieTouchResponse == null ||
//                               pieTouchResponse.touchedSection == null) {
//                             touchedIndex = -1;
//                             return;
//                           }
//                           touchedIndex = pieTouchResponse
//                               .touchedSection!.touchedSectionIndex;
//                         });
//                       },
//                     ),
//                     borderData: FlBorderData(
//                       show: true,
//                     ),
//                   ),
//                   swapAnimationDuration: const Duration(milliseconds: 150),
//                   swapAnimationCurve: Curves.linear,
//                 ),
//               ),
//             ),
//             SizedBox(width: 24.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 160.h),
//                   const Indicators(
//                     color: Colors.blue,
//                     text: 'Photo Comments',
//                   ),
//                   SizedBox(height: 8.h),
//                   const Indicators(
//                     color: Colors.pink,
//                     text: 'Video Comments',
//                   ),
//                   SizedBox(height: 8.h),
//                   const Indicators(
//                     color: Colors.green,
//                     text: 'Carousel Comments',
//                   ),
//                   SizedBox(height: 8.h),
//                   const Indicators(
//                     color: Colors.red,
//                     text: 'Reel Comments',
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(top: 40.h),
//                     child: Text(
//                       'Total Comments - ${widget.totalComments ?? 'NA'}',
//                       style: TextStyle(
//                           fontSize: 44.sp, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
