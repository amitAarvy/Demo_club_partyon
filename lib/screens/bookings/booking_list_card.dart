import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'booking_controller.dart';

class BookingListCard extends StatefulWidget {
  final String bookingID;
  final DateTime dateTime;
  final double amount;
  final int index;
  final String?eventId;

  const BookingListCard(
      {Key? key,
      required this.bookingID,
      required this.dateTime,
      required this.amount,
      required this.index, this.eventId})
      : super(key: key);

  @override
  State<BookingListCard> createState() => _BookingListCardState();
}

class _BookingListCardState extends State<BookingListCard> {
  bool isEntryCompleted = false;
  List? entranceList;
  List? tableList;

  @override
  void initState() {
    getEntryCompletedStatus();
    super.initState();
  }

  Map<String,dynamic> checkOut ={};
  void getEntryCompletedStatus() async {
    print('check booking id ${widget.bookingID}');
    await FirebaseDatabase.instance
        .ref('Bookings')
        .child(widget.bookingID)
        .child('tableList')
        .once()
        .then((value) =>  tableList  = value.snapshot.value as List?);
    await FirebaseDatabase.instance
        .ref('Bookings')
        .child(widget.bookingID)
        .child('entryList')
        .once()
        .then((value) => entranceList = value.snapshot.value as List?);
    print('check event id ${widget.eventId}');
    var data = await FirebaseFirestore.instance.collection('CheckInOut').doc(widget.eventId).get();
    print('check list ${data.data()}');
   if(data.data() != null) {
     print('check list ${data.data()}');
     checkOut = data.data() as Map<String, dynamic>;
   }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: checkOut.isNotEmpty && (checkOut['checkInList']as List).where((element) => element['bookingId'].toString() == widget.bookingID.toString(),).isNotEmpty?Colors.transparent:isRemainingEntries(
                      entranceList: entranceList ?? [],
                      tableList: tableList ?? [])
                  ? Colors.amber
                  : Colors.green),
          width: Get.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: Get.width,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                          child: Center(
                              child: Text(
                        "${widget.index + 1}",
                        style: GoogleFonts.ubuntu(color: Colors.white),
                      ))),
                    ),
                    Expanded(
                      child: SizedBox(
                          child: Center(
                              child: Text(
                        "Booking ID\n${widget.bookingID}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(color: Colors.white),
                      ))),
                    ),
                    Expanded(
                      child: SizedBox(
                          child: Center(
                              child: Text(
                        "${widget.dateTime.day}-${widget.dateTime.month}-${widget.dateTime.year}",
                        style: GoogleFonts.ubuntu(color: Colors.white),
                      ))),
                    ),
                    Expanded(
                      child: SizedBox(
                          child: Center(
                              child: Text(
                        "Amount\n₹ ${widget.amount}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(color: Colors.white),
                      ))),
                    ),
                  ],
                ).paddingSymmetric(vertical: 60.h),
              ),
            ],
          ),
        ),
      ],
    ).paddingAll(30.w);
  }
}
