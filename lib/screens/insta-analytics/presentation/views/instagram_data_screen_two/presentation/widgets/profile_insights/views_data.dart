// import 'package:club/screens/insta-analytics/models/get_public_analytics_of_a_profile_data_model.dart';
// import 'package:club/screens/insta-analytics/models/get_public_analytics_of_a_profile_data_model.dart';
// import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/indicators/indicators.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:club/screens/insta-analytics/models/get_public_analytics_of_a_profile_data_model.dart'
// as publicAnalytics;
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class ViewsData extends StatefulWidget {
//   final GetPublicAnalyticsOfAProfileDataModel? phylloData;
//   final publicAnalytics.TopContents? recentContent;
//   final int viewCount;
//
//
//   const ViewsData(
//       {super.key, this.phylloData, this.recentContent, required this.viewCount});
//
//   @override
//   State<ViewsData> createState() => _ViewsDataState();
// }
//
// class _ViewsDataState extends State<ViewsData> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Views Overview 👁️',
//           style: TextStyle(fontSize: 66.sp, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 40.h),
//         Align(
//           alignment: Alignment.center,
//           child: Text(
//             '${widget.viewCount ?? 0}',
//             style: TextStyle(fontSize: 80.sp, fontWeight: FontWeight.bold),
//           ),
//         ),
//         SizedBox(height: 12.h),
//         // Align(
//         //   alignment: Alignment.center,
//         //   child: Text(
//         //     'Total Followers',
//         //     style: TextStyle(fontSize: 58.sp, fontWeight: FontWeight.bold),
//         //   ),
//         // ),
//         // SizedBox(height: 12.h),
//         // Align(
//         //   alignment: Alignment.center,
//         //   child: Text(
//         //     '-1.6% vs Sep 29',
//         //     style: TextStyle(fontSize: 40.sp, color: Colors.black54),
//         //   ),
//         // ),
//         SizedBox(height: 40.h),
//         Divider(
//           height: 40.h,
//           thickness: 4,
//           color: Colors.black12,
//           indent: 0,
//           endIndent: 0,
//         ),
//         SizedBox(height: 40.h),
//         Text(
//           'Views Breakdown',
//           style: TextStyle(
//             fontSize: 52.sp,
//           ),
//         ),
//         SizedBox(height: 20.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             GenderViewsFilter(text: 'Post', onPressed: () {}),
//             SizedBox(width: 20.w),
//             GenderViewsFilter(text: 'Story', onPressed: () {}),
//             SizedBox(width: 20.w),
//             GenderViewsFilter(text: 'Reel', onPressed: () {})
//           ],
//         ),
//         SizedBox(height: 40.h),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Expanded(
//               child: SizedBox(
//                 height: 400.h,
//                 child: PieChart(
//                   PieChartData(
//                     centerSpaceRadius: 10,
//                     sectionsSpace: 4,
//                     centerSpaceColor: Colors.white,
//                     sections: ViewsPieChart.section(touchedIndex),
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
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 160.h),
//                 const Indicators(
//                   color: Colors.blue,
//                   text: 'Followers Views',
//                 ),
//                 SizedBox(height: 8.h),
//                 const Indicators(
//                   color: Colors.pink,
//                   text: 'Non-Follower Views',
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(top: 40.h),
//                   child: Text(
//                     'Total Views - 66',
//                     style: TextStyle(
//                         fontSize: 44.sp, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
