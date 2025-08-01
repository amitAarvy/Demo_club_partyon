import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_utils.dart';

class PromotionBooking extends StatefulWidget {
  final String eventId;
  const PromotionBooking({super.key, required this.eventId});

  @override
  State<PromotionBooking> createState() => _PromotionBookingState();
}

class _PromotionBookingState extends State<PromotionBooking> {
  Widget titleWidget(String title) => Expanded(
      child: SizedBox(
          child: Center(
              child: Text(title,
                  style: GoogleFonts.ubuntu(
                    color: Colors.orange,
                    fontSize: 50.sp,
                  )))));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.black,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Bookings',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 60.sp,
              ),
            ),
          ],
        ),

      ),
      backgroundColor: Colors.black,
      body:SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              width: Get.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleWidget('Date'),
                  titleWidget('Name'),
                  titleWidget('BookingID'),
                  titleWidget('Customer'),

                ],
              ).paddingAll(20.h),
            ),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('PrAnalytics')
                  .where('prId', isEqualTo: uid())
                  .where('eventId', isEqualTo: widget.eventId)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  );
                }
                if (snapshot.data?.docs.isEmpty == true) {
                  return SizedBox(
                    height: Get.height,
                    width: Get.width,
                    child: Center(
                      child: Text(
                        'No Bookings found',
                        style: GoogleFonts.ubuntu(
                          color: Colors.white,
                          fontSize: 60.sp,
                        ),
                      ),
                    ),
                  );
                }
                var data1 = snapshot.data?.docs[0].data() as Map<String,dynamic>;

                if(data1.containsKey('userList') == false){
                  return Column(
                    children: [
                      SizedBox(height: 0.5.sh,),
                      Center(child: Text('No Booking available',style: TextStyle(fontSize: 14,color: Colors.white,fontWeight: FontWeight.w600),),),
                    ],
                  );
                }
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: (data1['userList'] as List).length,
                  itemBuilder: (BuildContext context, int index) {
                  var data =
                   (data1['userList'] as List)[index];
                    DateTime date = data?['creditAt'].toDate();
                    return GestureDetector(
                      onTap: () {
                      },
                      child: Container(
                        height: 300.h,
                        width: Get.width,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${date.day}-${date.month}-${date.year}',
                                        style: GoogleFonts.ubuntu(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "${date.hour}:${date.minute} ${date.hour < 12 ? 'A.M' : 'P.M'}",
                                        style: GoogleFonts.ubuntu(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                child: Center(
                                  child: Text(
                                    "${data?["name"]}",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                child: Center(
                                  child: Text(
                                    "${data?["bookingId"]}",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                child: Center(
                                  child: Text(
                                    "${data?["type"]== 'entry'?'Entry':'Table'}",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).paddingAll(20.h),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ) ,
    );
  }
}
