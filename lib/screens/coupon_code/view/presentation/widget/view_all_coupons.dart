// import 'package:club/screens/coupon_code/const/const.dart';
// import 'package:club/screens/coupon_code/controller/coupon_code_controller.dart';
// import 'package:club/screens/coupon_code/model/data/coupon_code_model.dart';
// import 'package:club/screens/refer/presentation/views/widgets/refer_info_card.dart';
// import 'package:club/screens/refer/presentation/views/widgets/refer_info_row.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class ViewAllCoupons extends StatefulWidget {
//   const ViewAllCoupons({super.key});
//
//   @override
//   State<ViewAllCoupons> createState() => _ViewAllCouponsState();
// }
//
// class _ViewAllCouponsState extends State<ViewAllCoupons>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List sharedCouponList = [];
//
//   @override
//   void initState() {
//     _tabController = TabController(
//         length: CouponCodeConst.sharedCouponTabList.length, vsync: this);
//     sharedCoupon();
//     super.initState();
//   }
//
//   void sharedCoupon() async {
//     sharedCouponList = (await CouponCodeController.savedCouponCodes() ?? []);
//     print('Shared Coupon List: $sharedCouponList');
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         TabBar(
//             controller: _tabController,
//             indicatorSize: TabBarIndicatorSize.tab,
//             isScrollable: false,
//             padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
//             indicator: BoxDecoration(
//               color: const Color(0xff451F55),
//               borderRadius: BorderRadius.circular(100),
//             ),
//             labelStyle: TextStyle(fontWeight: FontWeight.bold ,color: Colors.white, fontSize: 48.sp),
//             tabs: CouponCodeConst.sharedCouponTabList
//                 .map((String e) => Tab(text: e))
//                 .toList()),
//         Expanded(
//           child: TabBarView(
//               controller: _tabController,
//               children: CouponCodeConst.sharedCouponTabList.map((String e) {
//                 List selectedCouponList = sharedCouponList
//                     .where((data) => data.type == e.toLowerCase())
//                     .toList();
//                 if (selectedCouponList.isNotEmpty) {
//                   return Column(
//                     children: [
//                       Container(
//                         decoration: const BoxDecoration(color: Color(0xff451F55)),
//                         padding: const EdgeInsets.all(8.0),
//                         child: const Row(
//                           children: [
//                             ReferInfoRow(text: 'Name'),
//                             ReferInfoRow(text: 'Coupon Code'),
//                             ReferInfoRow(text: 'Duration'),
//                           ],
//                         ),
//                       ),
//                       ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: selectedCouponList.length,
//                         itemBuilder: (context, index) => ReferInfoCard(
//                           title: selectedCouponList[index].couponCode ?? 'NA',
//                           uid: selectedCouponList[index].type ?? 'NA',
//                           date:
//                               selectedCouponList[index].couponCategory ?? 'NA',
//                         ),
//                       ),
//                     ],
//                   );
//                 } else {
//                   return Center(
//                     child: Text(
//                       'No Coupon Codes found for $e',
//                       style: TextStyle(color: Colors.white, fontSize: 48.sp),
//                     ),
//                   );
//                 }
//               }).toList()),
//         ),
//       ],
//     );
//   }
// }
