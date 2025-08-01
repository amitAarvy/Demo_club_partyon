import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../../utils/app_utils.dart';
import 'BookingInfo.dart';

class BookingList extends StatefulWidget {
  final String isOrganiser;
  const BookingList({super.key, required this.isOrganiser});

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> with SingleTickerProviderStateMixin{
List clubBookingList = [];
late TabController tabController;
ValueNotifier<bool> isLoadingBooking = ValueNotifier(false);
List currentEvent = [];
List upComingEvent = [];
List pastEvent = [];
ValueNotifier<bool> isLoading = ValueNotifier(false);


void fetchEventList() async{
  isLoading.value = true;
  var data =  await FirebaseFirestore.instance
      .collection("EventPromotion")
      .where('collabType', isEqualTo: 'promotor')
      .get();

  // List saveData = [];
  // for(var element in data.docs){
  //   saveData.add(element);
  // }
  clubBookingList = [];
  for(var element in data.docs){
    QuerySnapshot reqData = await FirebaseFirestore.instance
        .collection("PromotionRequest")
        .where('eventPromotionId', isEqualTo: element['id'])
        .where('influencerPromotorId', isEqualTo: uid())
        .get();

    if(4 == 4 && reqData.docs.isNotEmpty && reqData.docs[0]['status'] == 4){
      Map ele = {...element.data(), ...{'promotionId': element.id ,'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status']}};
      clubBookingList.add(ele);
    }
  }
  log('pending request is ${clubBookingList}');
  List<Future<void>> fetchEvents =clubBookingList.map((data) async {
    String? eventId = data['eventId'];
    print('event list is ${eventId}');
    if (eventId != null) {
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection("Events")
          .doc(eventId)
          .get();

      var eventData = eventDoc.data() as Map<String, dynamic>;
      if (eventData != null) {
        eventListData.add({
          ...eventData,
          "eventId":eventDoc.id
        });
        currentEvent = eventListData.where((element) {
          final eventDate = (element['date'] as Timestamp).toDate();
          return eventDate.year == DateTime.now().year &&
              eventDate.month == DateTime.now().month &&
              eventDate.day == DateTime.now().day;
        }).toList();
        upComingEvent = eventListData.where((element) =>(element['date'] as Timestamp).toDate().isAfter(DateTime.now())).toList();
        pastEvent = eventListData.where((element) {
          DateTime eventDate = (element['date'] as Timestamp).toDate();
          DateTime now = DateTime.now();
          DateTime eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
          DateTime todayDateOnly = DateTime(now.year, now.month, now.day);
          return eventDateOnly.isBefore(todayDateOnly);
        }).toList();
      }
    }
  }).toList();
  await Future.wait(fetchEvents);
  setState(() {});
  log('pending request is event list ${upComingEvent}');
  log('pending request is event list ${currentEvent}');
  log('pending request is event list ${pastEvent}');
  isLoading.value = false;
}
List eventListData = [];


  void fetchUpcomingMonthEventData() async{
    isLoadingBooking.value =true;
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('Events')
        .where(widget.isOrganiser == 'venue'?'clubUID':'organiserID', isEqualTo:uid() )
        .get();

    for(var data1 in data.docs){
      var eventData = data1.data() as Map<String, dynamic>;
      clubBookingList.add({
        ...eventData,
        "eventId":data1.id
      });
    }

     currentEvent = clubBookingList.where((e) {
      DateTime bookingDate = e['date'].toDate();
      DateTime now = DateTime.now();
      return bookingDate.year == now.year &&
          bookingDate.month == now.month &&
          bookingDate.day == now.day;
    }).toList();

     pastEvent = clubBookingList.where((e) {

       DateTime eventDate = (e['date'] as Timestamp).toDate();
       DateTime now = DateTime.now();
       DateTime eventDateOnly = DateTime(eventDate.year, eventDate.month, eventDate.day);
       DateTime todayDateOnly = DateTime(now.year, now.month, now.day);
      return eventDateOnly.isBefore(todayDateOnly);
    }).toList();

     upComingEvent = clubBookingList.where((e) {
      DateTime bookingDate = e['date'].toDate();
      return bookingDate.isAfter(DateTime.now());
    }).toList();



    setState(() {});
    isLoadingBooking.value =false;

    print('check booking event is ${clubBookingList}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    if(widget.isOrganiser =='venue'){
      fetchUpcomingMonthEventData();
    }else{
      fetchEventList();
    }
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: appBar(context, title: "Account",showBack:false,isBooking: true,
          tabController: tabController,),
        body: TabBarView(
          controller: tabController,
          children: [
            eventList('current',currentEvent),
            eventList('upcoming',upComingEvent),
            eventList('past',pastEvent),
          ],
        ),
      ),
    );
  }
  Widget eventList(
      String event,List data1
      ){
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, bool isLoading, child) {
        if(isLoading){
          return Center(
            child: CircularProgressIndicator(color: Colors.orangeAccent,),
          );
        }
        if(clubBookingList.isEmpty){
          return Center(
            child:  Text(
              'No Bookings found',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 60.sp,
              ),
            ),
          );
        }
        // List current = clubBookingList.where((e) {
        //   DateTime bookingDate = e['date'].toDate();
        //   DateTime now = DateTime.now();
        //   return bookingDate.year == now.year &&
        //       bookingDate.month == now.month &&
        //       bookingDate.day == now.day;
        // }).toList();
        //
        // List past = clubBookingList.where((e) {
        //   DateTime bookingDate = e['date'].toDate();
        //   return bookingDate.isBefore(DateTime.now());
        // }).toList();
        //
        // List upcoming = clubBookingList.where((e) {
        //   DateTime bookingDate = e['date'].toDate();
        //   return bookingDate.isAfter(DateTime.now());
        // }).toList();
        data1.sort((a, b) =>
            b['date'].toDate().compareTo(a['date'].toDate()));

        return  ListView.builder(
          // physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: data1.length,
          itemBuilder: (BuildContext context, int index) {
            var data = data1[index];
            DateTime date = data['date'].toDate();
            return
              GestureDetector(
                  onTap: () {
                    print('event id check ${data['eventId']}');
                    print('event id check ${widget.isOrganiser}');
                    Get.to(
                       BookingInfo(
                        eventName: data['title'],
                        eventId: data['eventId'],
                         eventType: event,
                         isVenue: widget.isOrganiser,
                      ),
                    );
                  },
                  child: SizedBox(
                    width: Get.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Expanded(
                        //   child: SizedBox(
                        //       child: Center(
                        //           child: CachedNetworkImage(
                        //             imageUrl: data[''],
                        //             fit: BoxFit.fill,
                        //           ))),
                        // ),
                        Expanded(
                          child: SizedBox(
                              child: Center(
                                  child: Text(
                                    "${data!["title"]}".toString().capitalizeFirstOfEach,
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white, fontWeight: FontWeight.bold),
                                  ))),
                        ),
                        Expanded(
                          child: SizedBox(
                              child: Center(
                                  child: Text(
                                    "${date.day}-${date.month}-${date.year}",
                                    style: GoogleFonts.ubuntu(color: Colors.white),
                                  ))),
                        ),
                      ],
                    ).paddingSymmetric(vertical: 60.h),
                  )
              );
          },
        );

      },
    );
  }
}