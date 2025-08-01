import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/bookings/booking_details.dart';
import 'package:club/screens/bookings/booking_list_card.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PromotionBookingList extends StatefulWidget {
  final bool isOrganiser;
  final bool isClub;
  final bool isPromoter;
  final String eventID;

  const PromotionBookingList(
      {Key? key,
      this.isOrganiser = false,
      this.isPromoter = false,
      required this.eventID,
      this.isClub = false})
      : super(key: key);

  @override
  State<PromotionBookingList> createState() => _PromotionBookingListState();
}

class _PromotionBookingListState extends State<PromotionBookingList> {

  Future<void> markNotificationsAsSeen() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Bookings')
        .where('eventID', isEqualTo: widget.eventID)
        .where('newNotification', isEqualTo: true)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'newNotification': false});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    markNotificationsAsSeen();
  }
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(widget.eventID);
      print(widget.isPromoter);
    }
    return Scaffold(
      appBar: appBar(context, title: "Booking List"),
      drawer: drawer(context: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 50.h,
            ),
            FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("Bookings")
                    .where(
                        widget.isClub
                            ? 'clubUID'
                            : widget.isOrganiser
                                ? 'organiserID':
                                widget.isPromoter?'promoterID':'',
                        isEqualTo: uid())
                    .where('eventID', isEqualTo: widget.eventID)
                    .orderBy('date', descending: true)
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (kDebugMode) {
                    print(snapshot.data?.docs.length);
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: Get.height - 500.h,
                      width: Get.width,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.data?.docs.length == null ||
                      snapshot.data?.docs.isEmpty == true) {
                    return SizedBox(
                      height: Get.height - 500.h,
                      width: Get.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No Bookings found",
                            style:
                                TextStyle(color: Colors.white, fontSize: 70.sp),
                          ),
                        ],
                      ),
                    );
                  } else {
                    if (kDebugMode) {
                      print(snapshot.data?.docs.length);
                    }
                    return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          try {
                            var data = snapshot.data?.docs[index];
                            final amount = data?["amount"] ?? 'N/A';
                            final bookingID = data?["bookingID"] ?? 'N/A';
                            DateTime date = data?["date"].toDate();
                            return GestureDetector(
                                onTap: () {
                                  if (widget.isClub || widget.isOrganiser) {
                                    Get.to(
                                        BookingDetails(bookingID: bookingID,eventId: data?['eventID'].toString(),));
                                  }
                                },
                                child: BookingListCard(
                                    bookingID: bookingID,
                                    dateTime: date,
                                    amount: amount,
                                    eventId: data?['eventID'].toString(),
                                    index: index));
                          } catch (e) {
                            return Container();
                          }
                        });
                  }
                })
          ],
        ),
      ),
    );
  }
}
