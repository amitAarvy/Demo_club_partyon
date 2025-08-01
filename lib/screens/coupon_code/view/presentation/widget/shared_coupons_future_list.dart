// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../../controller/coupon_code_controller.dart';
// import '../../../model/data/coupon_code_model.dart';
//
// class SharedCouponsFutureList extends StatefulWidget {
//   final String couponCategory;
//   final String eventId;
//   final String? couponCode;
//   final String discount;
//   final VoidCallback voidCallback;
//
//   const SharedCouponsFutureList({super.key,
//     required this.couponCategory,
//     required this.eventId,
//     required this.couponCode,
//     required this.discount,
//     required this.voidCallback});
//
//   @override
//   State<SharedCouponsFutureList> createState() =>
//       _SharedCouponsFutureListState();
// }
//
// class _SharedCouponsFutureListState extends State<SharedCouponsFutureList> {
//   late Future<List<CouponModel>> sharedCouponList;
//
//   @override
//   void initState() {
//     super.initState();
//     sharedCoupon();
//   }
//
//   void sharedCoupon() async {
//     sharedCouponList = (CouponCodeController.savedCouponCodes());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<CouponModel>>(
//         future: sharedCouponList,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             final data = snapshot.data ?? [];
//
//             if (data.isNotEmpty) {
//               return ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: data.length,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemBuilder: (BuildContext context, int index) {
//                     final coupon = data[index];
//                     final discount = coupon.discount;
//                     return Column(
//                       children: [
//                         if (coupon.couponCode!.isEmpty)
//                           Padding(
//                             padding: const EdgeInsets.all(0.0).copyWith(
//                                 left: 52.w),
//                             child: Align(
//                               alignment: Alignment.bottomLeft,
//                               child: Text(
//                                 'Choose Entry Coupon',
//                                 style: TextStyle(
//                                     color: Colors.white, fontSize: 40.sp),
//                               ),
//                             ),
//                           )
//                         ,
//                         if (coupon.couponCode!.isNotEmpty)
//                           Padding(
//                             padding:
//                             const EdgeInsets.all(8.0).copyWith(
//                                 left: 52.w, top: 0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Card(
//                                   color: const Color(0xff451F55),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(12.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment
//                                           .start,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Text('Active Coupon: ${coupon
//                                             .couponCode}',
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 40.sp)),
//                                         Text('Category: ${coupon
//                                             .couponCategory}',
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 40.sp)),
//                                         Text('Discount: ${coupon.discount}%',
//                                             style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 40.sp)),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                     );
//                         // ElevatedButton(
//                         //   onPressed: () async {
//                         //     print("Event Id: ${widget.eventId}");
//                         //     try {
//                         //       if (coupon.couponCategory == 'Table Management') {
//                         //         await FirebaseFirestore.instance
//                         //             .collection('Events')
//                         //             .doc(widget.eventId)
//                         //             .set({
//                         //           'tableManagementCouponList': coupon.toJson()
//                         //         }, SetOptions(merge: true)).whenComplete(
//                         //                 () {
//                         //               widget.voidCallback();
//                         //             });
//                         //       } else
//                         //       if (coupon.couponCategory == 'Entry Management') {
//                         //         await FirebaseFirestore.instance
//                         //             .collection('Events')
//                         //             .doc(widget.eventId)
//                         //             .set({
//                         //           'entryManagementCouponList': coupon.toJson()
//                         //         }, SetOptions(merge: true)).whenComplete(
//                         //                 () {
//                         //               widget.voidCallback();
//                         //             });
//                         //       }
//                         //       else {
//                         //         print('Error is occurring');
//                         //       }
//                         //     } catch (e) {
//                         //       throw Exception('Error is $e');
//                         //     }
//                         //   },
//                         //   style: ElevatedButton.styleFrom(
//                         //     backgroundColor: Colors.white,
//                         //     foregroundColor: const Color(0xff451F55),
//                         //     shadowColor: Colors.blueGrey,
//                         //     elevation: 10,
//                         //     shape: RoundedRectangleBorder(
//                         //       borderRadius:
//                         //       BorderRadius.circular(30), //
//                         //     ),
//                         //     padding: EdgeInsets.symmetric(
//                         //       horizontal: 24.w,
//                         //       vertical: 12.h,
//                         //     ),
//                         //   ),
//                         //   child: const Text(
//                         //     'Pick Me!',
//                         //     style: TextStyle(
//                         //       fontSize: 18,
//                         //       fontWeight: FontWeight.bold,
//                         //     ),
//                         //   ),
//                         // )
//           );
//                   }
//               else {
//               return Center(
//                 child: Card(
//                   color: const Color(0xff451F55),
//                   margin: const EdgeInsets.all(16),
//                   child: Text(
//                     'No Saved Coupons found!',
//                     style: TextStyle(color: Colors.white, fontSize: 48.sp),
//                   ),
//                 ),
//               );
//             }
//           }
//         });
//   }
// }
