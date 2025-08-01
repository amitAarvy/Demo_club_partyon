// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
//
// class EntranceDataWidget extends StatefulWidget {
//   final String eventID;
//
//   const EntranceDataWidget({required this.eventID, Key? key}) : super(key: key);
//
//   @override
//   State<EntranceDataWidget> createState() => _EntranceDataWidgetState();
// }
//
// class _EntranceDataWidgetState extends State<EntranceDataWidget> {
//   late Stream<List<dynamic>> entranceListStream;
//
//   @override
//   void initState() {
//     super.initState();
//     entranceListStream = getEntranceListStream(widget.eventID);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   Map<dynamic, dynamic>? _nextAvailableSubCategory(
//       List<dynamic> subCategories) =>
//       subCategories.firstWhere(
//             (subCategory) =>
//         int.parse(subCategory['categoryEntryLeft'].toString()) > 0,
//         orElse: () => null,
//       );
//
//   @override
//   Widget build(BuildContext context) => StreamBuilder<List<dynamic>>(
//     stream: entranceListStream,
//     builder: (context, snapshot) {
//       if (!snapshot.hasData) {
//         return const CircularProgressIndicator();
//       } else {
//         final entranceList = snapshot.data!;
//
//         return ListView.builder(
//           itemCount: entranceList.length,
//           physics: NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           itemBuilder: (context, index) {
//             final entrance = entranceList[index];
//             final categoryName = entrance['categoryName'];
//             List subCategories = entrance['subCategory'];
//
//             // Find the next available subcategory
//
//             final availableSubCategory =
//             _nextAvailableSubCategory(subCategories);
//
//             if (availableSubCategory != null) {
//               final entryCategoryName =
//               availableSubCategory['entryCategoryName'];
//               final entryCategoryPrice = int.parse(
//                   availableSubCategory['entryCategoryPrice'].toString());
//               final categoryEntryLeft = int.parse(
//                   availableSubCategory['categoryEntryLeft'].toString());
//
//               SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
//                 if (bookingProvider.getBookingCount(index) >
//                     categoryEntryLeft) {
//                   bookingProvider.changeBookingCount(
//                       index, categoryEntryLeft);
//                 }
//                 updateBookingList(index, subCategories,
//                     entryCategoryPrice.toDouble(), bookingProvider,
//                     categoryName: categoryName);
//                 Provider.of<EntryController>(context, listen: false)
//                     .updatePriceEntryList(bookingProvider.getBookingList);
//               });
//
//               if (categoryEntryLeft > 0)
//                 return Column(
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           categoryName.toString().capitalizeFirstOfEach,
//                           style: const TextStyle(color: Colors.orange),
//                         ),
//                       ],
//                     ).paddingOnly(top: 30.h, left: 30.w),
//                     SizedBox(
//                       height: 200.h,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             width: Get.width / 4.5,
//                             child: Center(
//                               child: Text(
//                                 '$entryCategoryName',
//                                 textAlign: TextAlign.center,
//                                 style: GoogleFonts.ubuntu(
//                                   color: Colors.white,
//                                   fontSize: 45.sp,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: Get.width / 4.5,
//                             child: categoryEntryLeft == 0
//                                 ? Center(
//                               child: Text(
//                                 'Sold Out',
//                                 style: GoogleFonts.ubuntu(
//                                   color: Colors.red,
//                                   fontSize: 45.sp,
//                                 ),
//                               ),
//                             )
//                                 : Center(
//                               child: Text(
//                                 '$categoryEntryLeft left',
//                                 style: GoogleFonts.ubuntu(
//                                   color: Colors.red,
//                                   fontSize: 45.sp,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: Get.width / 4.5,
//                             child: Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   if (entryCategoryPrice == 0)
//                                     Text(
//                                       'Free',
//                                       style: GoogleFonts.ubuntu(
//                                         color: Colors.green,
//                                         fontSize: 45.sp,
//                                       ),
//                                     )
//                                   else
//                                     Text(
//                                       '₹ $entryCategoryPrice',
//                                       style: GoogleFonts.ubuntu(
//                                         color: Colors.white,
//                                         fontSize: 45.sp,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             height: Get.width / 4.5,
//                             child: Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                     MainAxisAlignment.center,
//                                     children: [
//                                       GestureDetector(
//                                         onTap: () {
//                                           if (bookingProvider
//                                               .getBookingCount(index) >
//                                               0) {
//                                             bookingProvider
//                                                 .decBookingCount(index);
//                                           }
//
//                                           updateBookingList(
//                                               index,
//                                               subCategories,
//                                               entryCategoryPrice.toDouble(),
//                                               bookingProvider,
//                                               categoryName: categoryName);
//
//                                           Provider.of<EntryController>(
//                                               context,
//                                               listen: false)
//                                               .updatePriceEntryList(
//                                               bookingProvider
//                                                   .getBookingList);
//                                           print(
//                                               Provider.of<EntryController>(
//                                                   context,
//                                                   listen: false)
//                                                   .entryList);
//                                         },
//                                         child: Icon(
//                                           Icons.remove,
//                                           size: 70.sp,
//                                           color: Colors.orange,
//                                         ),
//                                       ).paddingOnly(
//                                         left: 20.w,
//                                         right: 10.w,
//                                       ),
//                                       Obx(
//                                             () => Text(
//                                           '${bookingProvider.getBookingCount(index)}',
//                                           style: GoogleFonts.ubuntu(
//                                               color: Colors.white,
//                                               fontSize: 45.sp),
//                                         ),
//                                       ),
//                                       GestureDetector(
//                                         onTap: () {
//                                           if (categoryEntryLeft != 0 &&
//                                               bookingProvider
//                                                   .getBookingCount(
//                                                   index) <
//                                                   categoryEntryLeft) {
//                                             bookingProvider
//                                                 .incBookingCount(index);
//
//                                             updateBookingList(
//                                                 index,
//                                                 subCategories,
//                                                 entryCategoryPrice
//                                                     .toDouble(),
//                                                 bookingProvider,
//                                                 categoryName: categoryName);
//                                             Provider.of<EntryController>(
//                                                 context,
//                                                 listen: false)
//                                                 .updatePriceEntryList(
//                                                 bookingProvider
//                                                     .getBookingList);
//                                           }
//                                         },
//                                         child: Icon(
//                                           Icons.add,
//                                           size: 70.sp,
//                                           color: Colors.orange,
//                                         ),
//                                       ).paddingOnly(
//                                         left: 20.w,
//                                         right: 10.w,
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                         ],
//                       ).paddingAll(30.w),
//                     )
//                   ],
//                 );
//             } else {
//               SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
//                 bookingProvider.changeBookingCount(index, 0);
//                 updateBookingList(index, subCategories, 0, bookingProvider,
//                     categoryName: categoryName);
//                 Provider.of<EntryController>(context, listen: false)
//                     .updatePriceEntryList(bookingProvider.getBookingList);
//               });
//             }
//           },
//         );
//       }
//     },
//   );
// }
//
// class TableList extends StatefulWidget {
//   final tableData, index;
//
//   TableList({required this.index, required this.tableData, Key? key})
//       : super(key: key);
//
//   @override
//   State<TableList> createState() => _TableListState();
// }
//
// class _TableListState extends State<TableList> {
//   @override
//   Widget build(BuildContext context) => Consumer<EntryTableController>(
//     builder: (BuildContext context, EntryTableController data,
//         Widget? child) =>
//     widget.tableData?['tableAvail'] != 0
//         ? SizedBox(
//       height: 200.h,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           GestureDetector(
//             onTap: () {
//               Get.defaultDialog(
//                 title: 'Includes',
//                 content: Container(
//                   child: Text(
//                     '${widget.tableData?["tableInclusion"] != '' ? widget.tableData["tableInclusion"] : 'Only Entry'}',
//                     style:
//                     GoogleFonts.ubuntu(color: Colors.black),
//                   ),
//                 ),
//               );
//             },
//             child: SizedBox(
//               width: Get.width / 4.5,
//               child: Center(
//                 child: Text(
//                   widget.tableData?['tableName'],
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.ubuntu(
//                     color: Colors.white,
//                     fontSize: 45.sp,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: Get.width / 4.5,
//             child: widget.tableData?['tableLeft'] != 0
//                 ? Center(
//               child: Text(
//                 "${widget.tableData?["tableLeft"]} left",
//                 style: GoogleFonts.ubuntu(
//                   color: Colors.red,
//                   fontSize: 45.sp,
//                 ),
//               ),
//             )
//                 : Center(
//               child: Text(
//                 'Sold Out',
//                 style: GoogleFonts.ubuntu(
//                   color: Colors.red,
//                   fontSize: 45.sp,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: Get.width / 4.5,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "Seats: ${widget.tableData?["seatsAvail"]}",
//                   style: GoogleFonts.ubuntu(
//                     color: Colors.white,
//                     fontSize: 45.sp,
//                   ),
//                 ),
//                 if (widget.tableData?['tablePrice'] != 0)
//                   Text(
//                     "₹ ${widget.tableData?["tablePrice"]}",
//                     style: GoogleFonts.ubuntu(
//                       color: Colors.white,
//                       fontSize: 45.sp,
//                     ),
//                   )
//                 else
//                   Text(
//                     'Free',
//                     style: GoogleFonts.ubuntu(
//                       color: Colors.green,
//                       fontSize: 45.sp,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           SizedBox(
//             width: Get.width / 4.5,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         if (data.numTable[widget.index] > 0) {
//                           data.updateNumTable(
//                             widget.index,
//                             data.numTable[widget.index] - 1,
//                           );
//                         }
//                       },
//                       child: Center(
//                         child: Icon(
//                           Icons.remove,
//                           size: 70.sp,
//                           color: Colors.orange,
//                         ),
//                       ).paddingOnly(left: 20.w, right: 15.w),
//                     ),
//                     Text(
//                       '${data.numTable[widget.index]}',
//                       style: GoogleFonts.ubuntu(
//                         color: Colors.white,
//                         fontSize: 45.sp,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         if (widget.tableData?['tableLeft'] != 0 &&
//                             data.numTable[widget.index] <
//                                 widget.tableData?['tableLeft']) {
//                           data.updateNumTable(
//                             widget.index,
//                             data.numTable[widget.index] + 1,
//                           );
//                         }
//                         print(data.tableName);
//                       },
//                       child: Center(
//                         child: Icon(
//                           Icons.add,
//                           size: 70.sp,
//                           color: Colors.orange,
//                         ),
//                       ),
//                     ).paddingOnly(left: 20.w, right: 15.w)
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ).paddingOnly(left: 30.w, right: 30.w)
//         : Container(),
//   );
// }
//
// Stream<List<dynamic>> getEntranceListStream(String eventID) {
//   final _rtdb = FirebaseDatabase.instance.ref();
//   final _entranceListRef = _rtdb.child('Events/$eventID/entranceList');
//
//   return _entranceListRef.onValue.map((event) {
//     final data = event.snapshot.value as List<dynamic>;
//     return data;
//   });
// }
//
// Future<void> updateAsTransaction(String eventID, String categoryId,
//     String subcategoryId, int increment) async {
//   try {
//     DatabaseReference ref = FirebaseDatabase.instance.ref().child(
//         'Events/$eventID/entranceList/$categoryId/subCategory/$subcategoryId/categoryEntryLeft');
//     final transactionResult = await ref.runTransaction((mutableData) {
//       return Transaction.success(((mutableData) as int? ?? 0) + increment);
//       // else return Transaction.abort();
//     });
//   } on FirebaseException catch (e) {
//     print(e.message);
//   }
// }
//
// void updateBookingList(int index, List subCategories, double bookingAmount,
//     BookingProvider bookingProvider,
//     {required String categoryName}) {
//   int subIndex = 0;
//   for (int i = 0; i < subCategories.length; i++) {
//     if (int.parse(subCategories[i]['categoryEntryLeft'].toString()) > 0) {
//       subIndex = i;
//     }
//   }
//   bookingProvider.modifyBookingList(
//       index, subIndex, bookingProvider.getBookingCount(index), bookingAmount,
//       subCategoryName: subCategories[subIndex]['entryCategoryName'],
//       categoryName: categoryName);
// }
//
// // Future<void> updateCategoryEntryLeft(
// //     String eventID, int categoryId, int subcategoryID, int currentValue,
// //     {int increment = 0}) async {
// //   final _rtdb = FirebaseDatabase.instance.ref();
// //   try {
// //     await _rtdb
// //         .child(
// //             'Events/$eventID/entranceList/$categoryId/subCategory/$subcategoryID')
// //         .update({'categoryEntryLeft': currentValue + increment});
// //   } catch (error) {
// //     print('Error decrementing categoryEntryLeft: $error');
// //   }
// // }
