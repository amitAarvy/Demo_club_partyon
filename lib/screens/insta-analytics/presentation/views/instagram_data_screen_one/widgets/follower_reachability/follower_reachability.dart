// import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
// import 'package:club/screens/insta-analytics/models/get_public_analytics_of_a_profile_data_model.dart';
// import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/age_wise_engagement/engagement_percent.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:club/screens/insta-analytics/models/get_public_analytics_of_a_profile_data_model.dart'
//     as publicAnalytics;
//
// class FollowerReachData extends StatefulWidget {
//   // final  audienceData;
//
//   final GetPublicAnalyticsOfAProfileDataModel? phylloData;
//
//   const FollowerReachData({super.key, this.phylloData});
//
//   @override
//   State<FollowerReachData> createState() => _FollowerReachDataState();
// }
//
// class _FollowerReachDataState extends State<FollowerReachData> {
//   final PhylloController controller = Get.put(PhylloController());
//
//   @override
//   Widget build(BuildContext context) {
//     List<publicAnalytics.FollowerReachability>? followerReach =
//         widget.phylloData?.profile?.audience?.followerReachability;
//     if (followerReach != null) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Follower Reachability',
//             style: TextStyle(
//                 fontSize: 66.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white),
//           ),
//           SizedBox(height: 20.h),
//           Column(
//               children: followerReach
//                       ?.map((e) => EngagementData(
//                             name: e.followingRange ?? '',
//                             value: e.value?.toDouble().toPrecision(2) ?? 0,
//                           ))
//                       .toList() ??
//                   []),
//           SizedBox(height: 20.h),
//         ],
//       );
//     } else {
//       return Text(
//         'No Follower Reach Data Available!',
//         style: TextStyle(color: Colors.white, fontSize: 52.sp),
//       );
//     }
//   }
// }
