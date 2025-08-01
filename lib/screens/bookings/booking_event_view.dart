import 'package:club/screens/bookings/booking_details.dart';
import 'package:club/utils/app_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingEventView extends StatefulWidget {
  final String bookingID;
  final bool isTableBooking;
  final List<TextEditingController> textController;

  const BookingEventView(
      {required this.bookingID,
      this.isTableBooking = false,
      Key? key,
      required this.textController})
      : super(key: key);

  @override
  State<BookingEventView> createState() => _BookingEventViewState();
}

class _BookingEventViewState extends State<BookingEventView> {
  final bookingController = Get.put(BookingController());
  late StreamBuilder entranceStream;

  @override
  void initState() {
    entranceStream = StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref('Bookings')
            .child(widget.bookingID)
            .child(widget.isTableBooking ? 'tableList' : 'entranceList')
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              color: Colors.orange,
            );
          } else if (!snapshot.hasData) {
            return SizedBox(
              child: Text(widget.isTableBooking
                  ? 'No Table Bookings'
                  : 'No Entrance Booking'),
            );
          } else {
            List entranceListTemp = snapshot.data?.snapshot.value != null
                ? (snapshot.data?.snapshot.value as List)
                : [];
            SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
              if (widget.isTableBooking) {
                bookingController.updateTableBookingList(entranceListTemp);
              } else {
                bookingController.updateBookingList(entranceListTemp);
              }
            });
            return Column(
              children: [
                if (entranceListTemp.isNotEmpty)
                  Text(
                    widget.isTableBooking ? 'Table List' : 'Entrance List',
                    style: GoogleFonts.ubuntu(
                        color: Colors.amber,
                        fontSize: 60.sp,
                        fontWeight: FontWeight.bold),
                  ),
                Column(
                  children: [
                    if (entranceListTemp.isNotEmpty)
                      Table(
                        border: customisedTableBorder(borderRadius: 5),
                        children: [
                          tableRow(
                              first: 'Name',
                              second: 'Amount',
                              third: 'Entered',
                              fourth: 'Remaining')
                        ],
                      ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: entranceListTemp.length,
                        itemBuilder: (context, index) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(
                              color: Colors.orange,
                            );
                          } else {
                            Map data = entranceListTemp[index] ?? {};
                            return Table(
                              border: customisedTableBorder(borderRadius: 5),
                              children: [
                                tableRow(
                                    first: data[widget.isTableBooking
                                            ? 'tableName'
                                            : 'categoryName']
                                        .toString(),
                                    second:
                                        '₹ ${widget.isTableBooking ? data['tablePrice'] : data['bookingAmount'].toString()}',
                                    third:
                                    ( data['tableNum']??0.0 - data['tableLeft']??0.0)
                                        .toString(),
                                    fourth: data['bookingCountLeft'].toString())
                              ],
                            );
                          }
                        })
                  ],
                ).paddingAll(40.w),
              ],
            );
          }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          entranceStream,
          Obx(() => ListView.builder(
              shrinkWrap: true,
              itemCount: (widget.isTableBooking
                      ? bookingController.getTableList
                      : bookingController.getEntranceList)
                  .length,
              itemBuilder: (context, index) {
                Map data = (widget.isTableBooking
                    ? bookingController.getTableList
                    : bookingController.getEntranceList)[index];
                if (data['bookingCountLeft']??1 > 0) {
                  return textField(
                      "Entry for ${data[(widget.isTableBooking ? "tableName" : "categoryName")]}",
                      widget.textController[index],
                      isNum: true);
                }else {
                  return const SizedBox();
                }
              })),
        ],
      ),
    );
  }
}
