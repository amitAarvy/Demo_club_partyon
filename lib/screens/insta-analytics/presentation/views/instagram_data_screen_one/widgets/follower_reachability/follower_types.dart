// import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
// import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/age_wise_engagement/engagement_percent.dart';
// import 'package:club/utils/app_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
//
// class FollowerTypesData extends StatefulWidget {
//   // final  audienceData;
//
//   final GetPublicAnalyticsOfAProfileDataModel? phylloData;
//
//   const FollowerTypesData({super.key, this.phylloData});
//
//   @override
//   State<FollowerTypesData> createState() => _FollowerTypesDataState();
// }
//
// class _FollowerTypesDataState extends State<FollowerTypesData> {
//   final PhylloController controller = Get.put(PhylloController());
//
//   @override
//   Widget build(BuildContext context) {
//     List<publicAnalytics.FollowerTypes>? followerTypes =
//         widget.phylloData?.profile?.audience?.followerTypes;
//     if (followerTypes != null) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Follower Types',
//             style: TextStyle(
//                 fontSize: 66.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white),
//           ),
//           SizedBox(height: 20.h),
//           Column(
//               children: followerTypes
//                       .map((e) => EngagementData(
//                             name: e.name?.capitalizeFirstOfEach ?? '',
//                             value: e.value?.toDouble().toPrecision(2) ?? 0,
//                           ))
//                       .toList() ??
//                   []),
//           SizedBox(height: 20.h),
//         ],
//       );
//     } else {
//       return Text(
//         'No Follower Type Data Available',
//         style: TextStyle(color: Colors.white, fontSize: 52.sp),
//       );
//     }
//   }
// }
