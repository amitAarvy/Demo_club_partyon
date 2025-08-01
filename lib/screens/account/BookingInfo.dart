import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../../utils/app_utils.dart';
import 'BookingInfo.dart';

class BookingInfo extends StatefulWidget {
  final String eventName;
  final String eventId;
  final String eventType;
  final String isVenue;


  const BookingInfo({super.key,  required this.eventName, required this.eventId, required this.eventType, required this.isVenue});

  @override
  State<BookingInfo> createState() => _BookingInfoState();
}

class _BookingInfoState extends State<BookingInfo> {
  List clubBookingList = [];
  ValueNotifier<bool> isLoadingBooking = ValueNotifier(false);
  List mergeEventList = [];
  // double  =0 ;
  ValueNotifier<double> totalAmount = ValueNotifier(0);
  ValueNotifier<double> entryAmount = ValueNotifier(0);
  ValueNotifier<double> tableAmount = ValueNotifier(0);
  ValueNotifier<double> fillerAmount = ValueNotifier(0);
  ValueNotifier<double> totalDeduction = ValueNotifier(0);

  int totalQrScan = 0;

  Future fetchUpcomingMonthEventData() async{
    isLoadingBooking.value =true;
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('Bookings')
        .where('eventID', isEqualTo:widget.eventId )
        .get();

    if(widget.isVenue =='venue'){
      print('yes check venue');
      clubBookingList = data.docs;
    }else{
      clubBookingList = data.docs.where((element) => element['promoterID'].toString()==uid(),).toList();
    }

    bool isCheck = false;
    Map<String,dynamic> checkData = {};
    // if(widget.isVenue != 'venue'){
      final docSnapshot = await FirebaseFirestore.instance
          .collection('CheckInOut')
          .doc(widget.eventId.toString())
          .get();
      if (docSnapshot.exists) {
        print('chekc is exist');
        checkData= docSnapshot.data() as Map<String,dynamic>;
        isCheck = true;
      } else {
        isCheck = false;
        print('No data found for eventId: ${widget.eventId}');
      }
    // }

    print('check list ${clubBookingList.length}');
    mergeEventList = clubBookingList.expand((e) {
      var data = e.data() as Map<String, dynamic>?;
       List<dynamic> tableList =[];
       List<dynamic> eventList = [];
       if(data!.containsKey('entryList')){
         print('test event is entry');
         if(isCheck){
           if(data['type'].toString() == 'filler'){
               for (var checkIn in (checkData['checkInList'] as List)) {
                 if(checkIn['bookingId'].toString() == data['bookingID'].toString()){
                   tableList = List.from(e['tableList'] ?? []);
                   eventList = List.from(e['entryList'] ?? []);
                 }
             };
           }else{
             tableList = List.from(e['tableList'] ?? []);
             eventList = List.from(e['entryList'] ?? []);
           }
         }else{
           print('venue list is }');
           if(data['type'].toString() != 'filler'){
             tableList = List.from(e['tableList'] ?? []);
             eventList = List.from(e['entryList'] ?? []);
           }
         }
       }else{
         print('test event is table');
         tableList = List.from(e['tableList'] ?? []);
       }

      List tableObjects = tableList.map((item) => {
        'id': e,
        'type': 'table',
        'data': item
      }).toList();

      List eventObjects =
            eventList.map((item) =>
            {
              'id': e,
              'type': 'event',
              'data': item
            }).toList();

      // Map bookingData = {"booking":data};

      return [...tableObjects, ...eventObjects]; // Merge both lists and return
    }).toList();
    if(widget.isVenue =='venue'){

      for (int i = 0; i < mergeEventList.length; i++) {
        print('booking detail is  ${mergeEventList[i]['id']}');
        double bookingAmount = 0.0;
        double deduction = 0.0;
        int bookingCount = 0;
        if(mergeEventList[i]['type'].toString() == 'table'){
          // bookingAmount = (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble();
          bookingAmount = (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble() ;
              // *
              // (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionTablePr'].toString()) / 100);
          deduction = (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble()
              *
              (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionTablePr'].toString()) / 100);
          tableAmount.value += (mergeEventList[i]['id'].data()['amount'] ?? 0)
              .toDouble() ;
              // * (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionTablePr'].toString()) / 100);
          // bookingCount = (mergeEventList[i]['data']['tableNum'] ?? 1).toInt();
        }else{
          if(mergeEventList[i]['id'].data()['type'].toString() == 'filler'){
            // bookingAmount = double.parse(couponDetail[0]['data']['pomotionData']['budget'].toString());
            bookingAmount = double.parse(widget.isVenue =='venue'?'800':'600');
            fillerAmount.value += double.parse(widget.isVenue =='venue'?'800':'600');

          }else{
            // print('check pr detail is ${couponDetail}');
            bookingAmount = (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble();
                // *
                // (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100);
            deduction = (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble()
                *
                (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100);
            entryAmount.value += (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble();
                // *
                // (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100);
          }

          // bookingCount = (mergeEventList[i]['data']['bookingCount'] ?? 1).toInt();
        }

        totalAmount.value += bookingAmount ;
        totalDeduction.value += deduction;

        print('check total amount is ${totalAmount.value}');
      }

    }else{
      for (int i = 0; i < mergeEventList.length; i++) {
        print('booking detail is  ${mergeEventList[i]['id']}');
        double bookingAmount = 0.0;
        int bookingCount = 0;
        if(mergeEventList[i]['type'].toString() == 'table'){
          // bookingAmount = (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble();
          bookingAmount = (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble() *
              (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionTablePr'].toString()) / 100);
          tableAmount.value += (mergeEventList[i]['id'].data()['amount'] ?? 0)
              .toDouble() * (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionTablePr'].toString()) / 100);
          // bookingCount = (mergeEventList[i]['data']['tableNum'] ?? 1).toInt();
        }else{
          if(mergeEventList[i]['id'].data()['type'].toString() == 'filler'){
            // bookingAmount = double.parse(couponDetail[0]['data']['pomotionData']['budget'].toString());
            bookingAmount = double.parse(widget.isVenue =='venue'?'800':'600');
            fillerAmount.value += double.parse(widget.isVenue =='venue'?'800':'600');

          }else{
            // print('check pr detail is ${couponDetail}');
            bookingAmount = (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble() *
                (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100);
            entryAmount.value += (mergeEventList[i]['id'].data()['amount'] ?? 0).toDouble() *
                (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100);
          }

          // bookingCount = (mergeEventList[i]['data']['bookingCount'] ?? 1).toInt();
        }

        totalAmount.value += bookingAmount ;
        print('check total amount is ${totalAmount.value}');
      }
    }

    // setState(() {});
    // print('total amount check is ${totalAmount.value}');
    isLoadingBooking.value =false;
    print('check booking event is ${mergeEventList}');
  }

  List couponDetail = [];

  void fetchQrScan() async{
    isLoadingBooking.value =true;
    var data = await FirebaseFirestore.instance
        .collection('CouponPR')
        .get();
if(widget.isVenue.toString() == 'venue'){
  couponDetail = data.docs
      .where((e) => e['eventId'].toString() == widget.eventId.toString() &&
      e['clubUID'].toString() == uid()  )
      .toList();
}else{
  print('check list is data is correct');
  couponDetail = data.docs
      .where((e) => e['eventId'].toString() == widget.eventId.toString() &&
      e['prId'].toString() == uid() && e['isInf'].toString() =='false' )
      .toList();
       print('check list is ${couponDetail}');
}



    setState(() {});
    await fetchUpcomingMonthEventData();
    // await fetchUpcomingMonthEventData();
    // print('total amount check is ${totalAmount}');

    // print('check booking event is ${clubBookingList}');
  }

  void fetchCouponDetail() async{
    isLoadingBooking.value =true;
    var data = await FirebaseFirestore.instance
        .collection('CheckInOut')
        .doc(widget.eventId)
        .get();
    if(data.data() != null){
    totalQrScan = ((data.data() as Map<String,dynamic>)['checkInList']as List).length;
    }

    setState(() {});
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetchUpcomingMonthEventData();
    print('check type is${widget.eventType}');
    fetchCouponDetail();
    fetchQrScan();
  }




    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: appBar(context, title: "${widget.eventName}",showBack:true),
          bottomNavigationBar: widget.isVenue != 'venue'?widget.eventType.toString() !='past'?Offstage():Padding(
            padding: const EdgeInsets.all(20),
            child:StreamBuilder(
              stream:  FirebaseFirestore.instance
                  .collection('RequestPayoutPromoter')
                  .where('prId', isEqualTo: uid())
                  .where('eventId', isEqualTo: widget.eventId)
                  .snapshots(),
              builder: (context, snapshot) {
                var alreadyRequested ;
                if(snapshot.data ==null){
                  alreadyRequested = true;
                }
                // handle loading, data, and errors
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return CircularProgressIndicator(); // or SizedBox.shrink();
                // }
                //   print('check is t${(snapshot.data! as QuerySnapshot).docs.isNotEmpty}');
                alreadyRequested = snapshot.data==null?false:(snapshot.data as QuerySnapshot).docs.isNotEmpty;

                return GestureDetector(
                  onTap: alreadyRequested
                      ? null
                      : () async {
                    await FirebaseFirestore.instance
                        .collection('RequestPayoutPromoter')
                        .add({
                      "prId": uid(),
                      "newNotification": true,
                      "isPayment":0,
                      "entryAmount": entryAmount.value,
                      "tableAmount": tableAmount.value,
                      "fillerAmount": fillerAmount.value,
                      "totalAmount": totalAmount.value,
                      "eventName": widget.eventName,
                      "eventId": widget.eventId,
                      "eventType": widget.eventType,
                      "status": 'Pending'
                    }).catchError((e){
                      print('error is check $e');
                    }).whenComplete(() {
                      Fluttertoast.showToast(msg: 'Requested Successful');
                    },);
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: alreadyRequested ? Colors.grey : Color(0xff1f51ff),
                      borderRadius: BorderRadius.all(Radius.circular(11)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        alreadyRequested ? (snapshot.data as QuerySnapshot).docs[0]['isPayment'].toString()=='1'?'Paid Successful':'Payout Requested' : 'Request Payout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ):Offstage(),
          body:
          ValueListenableBuilder(
            valueListenable: isLoadingBooking,
            builder: (context, bool isLoading, child) {
              if(isLoading){
                return Center(
                  child: CircularProgressIndicator(color: Colors.orangeAccent,),
                );
              }
              if(mergeEventList.isEmpty){
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
              return  SingleChildScrollView(
                child: Column(
                  children: [

                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: mergeEventList.length,
                      itemBuilder: (BuildContext context, int index) {
                        var data = mergeEventList[index];
                        QueryDocumentSnapshot<Object?>? data1 =
                        mergeEventList[index]['id'];
                        print('check event list is ${data}');
                        DateTime date = data1?['date'].toDate();
                        if(data['type']=='table')
                          return GestureDetector(
                              onTap: () {
                                // Get.to(
                                //   BookingInfo(
                                //     bookingID: data?['bookingID'],
                                //     clubUID: data?['clubUID'],
                                //     clubID: data?['clubID'],
                                //     userID: data?['userID'],
                                //   ),
                                // );
                              },
                              child: Container(
                                // height: 30.h,
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                                child:

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        child: Center(
                                          child: Text(
                                            '${index+1}',
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
                                        child: Column(
                                          children: [
                                            Center(
                                              child:  Text(
                                                '${data!['data']['tableName']}',
                                                style: GoogleFonts.ubuntu(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if(widget.isVenue == 'venue' )
                                              Center(
                                                child:  Text(
                                                  'Commission',
                                                  style: GoogleFonts.ubuntu(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        child: Column(
                                          children: [
                                            Center(
                                              child: widget.isVenue =='venue'?
                                              Text(
                                                "₹ ${data['type'].toString() == 'filler'?'800':(
                                                    double.parse(data!['id']['amount'].toString())
                                                ).toStringAsFixed(2)}",
                                                style: GoogleFonts.ubuntu(
                                                  color: Colors.white,
                                                ),
                                              )
                                                  :  Text(
                                                "₹ ${data['type'].toString() == 'filler'?'600':(
                                                    double.parse(data!['id']['amount'].toString()) * (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionTablePr'].toString()) / 100)
                                                ).toStringAsFixed(2)}",
                                                style: GoogleFonts.ubuntu(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if(widget.isVenue == 'venue' )
                                              Center(child: Text(
                                                "₹ ${(
                                                    double.parse(data!['id']['amount'].toString()) * (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionTablePr'].toString()) / 100)
                                                ).toStringAsFixed(2)}",
                                                style: GoogleFonts.ubuntu(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: SizedBox(
                                    //     child: Center(
                                    //       child: Text(
                                    //         "${data?["bookingID"]}",
                                    //         style: GoogleFonts.ubuntu(
                                    //           color: Colors.white,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),

                                  ],
                                ),
                              ).paddingAll(20.h)
                          );
                        if(data['type']!='table')
                          return GestureDetector(
                              onTap: () {
                                // Get.to(
                                //   BookingInfo(
                                //     bookingID: data?['bookingID'],
                                //     clubUID: data?['clubUID'],
                                //     clubID: data?['clubID'],
                                //     userID: data?['userID'],
                                //   ),
                                // );
                              },
                              child: Container(
                                // height: 30.h,
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                                child:
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        child: Center(
                                          child: Text(
                                            '${index+1}',
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
                                        child: Column(
                                          children: [
                                            Center(
                                              child:  Text(
                                                '${data!['data']['categoryName']}',
                                                style: GoogleFonts.ubuntu(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if(widget.isVenue == 'venue'   )
                                              data['id'].data().containsKey('type') == false?
                                              Center(
                                                child:  Text(
                                                  'Commission',
                                                  style: GoogleFonts.ubuntu(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ):data['id'].data()['type'].toString() != 'filler'?Center(
                                                child:  Text(
                                                  'Commission',
                                                  style: GoogleFonts.ubuntu(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ):  data!['data']['couponCode'] == null?Offstage():Offstage(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        child: Column(
                                          children: [
                                            Center(
                                              child: widget.isVenue=='venue'?
                                              Text(
                                                "₹ ${data['id'].data().containsKey('type')==true? data['id']['type'].toString() == 'filler'?'800.0':(
                                                    double.parse(data!['id']['amount'].toString())
                                                ).toStringAsFixed(2):(
                                                    double.parse(data!['id']['amount'].toString())
                                                ).toStringAsFixed(2)}",
                                                style: GoogleFonts.ubuntu(
                                                  color: Colors.white,
                                                ),
                                              ):
                                              Text(
                                                "₹ ${data['id'].data().containsKey('type')==true? data['id']['type'].toString() == 'filler'?'600.0':(
                                                    double.parse(data!['id']['amount'].toString()) *
                                                        (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100)
                                                ).toStringAsFixed(2):(
                                                    double.parse(data!['id']['amount'].toString()) *
                                                        (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100)
                                                ).toStringAsFixed(2)}",
                                                style: GoogleFonts.ubuntu(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),

                                            if(widget.isVenue == 'venue'   )
                                              data['id'].data().containsKey('type') == false?
                                              Center(child: Text(
                                                "₹ ${data['id'].data().containsKey('type')==true? data['id']['type'].toString() == 'filler'?'600.0':(
                                                    double.parse(data!['id']['amount'].toString()) *
                                                        (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100)
                                                ).toStringAsFixed(2):(
                                                    double.parse(data!['id']['amount'].toString()) *
                                                        (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100)
                                                ).toStringAsFixed(2)}",
                                                style: GoogleFonts.ubuntu(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              ):data['id'].data()['type'].toString() != 'filler'?Center(child: Text(
                                                "₹ ${data['id'].data().containsKey('type')==true? data['id']['type'].toString() == 'filler'?'600.0':(
                                                    double.parse(data!['id']['amount'].toString()) *
                                                        (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100)
                                                ).toStringAsFixed(2):(
                                                    double.parse(data!['id']['amount'].toString()) *
                                                        (int.parse(couponDetail[0]['data']['pomotionData']['offeredCommissionPr'].toString()) / 100)
                                                ).toStringAsFixed(2)}",
                                                style: GoogleFonts.ubuntu(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              ):Offstage()



                                          ],
                                        ),
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: SizedBox(
                                    //     child: Center(
                                    //       child: Text(
                                    //         "${data?["bookingID"]}",
                                    //         style: GoogleFonts.ubuntu(
                                    //           color: Colors.white,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),

                                  ],
                                ),
                              ).paddingAll(20.h)
                          );

                      },
                    ),
                    SizedBox(height: 10,),
                    Divider(color: Colors.grey,),
                    SizedBox(height: 10,),
                    if(widget.isVenue != 'venue')
                      ...[
                        ValueListenableBuilder(
                            valueListenable: entryAmount,
                            builder: (context, double amount, child) {
                              if(amount == 0){
                                return Offstage();
                              }
                              return amountWidget('Entry Amount:',amount.toString(),Colors.white);
                            }),
                        ValueListenableBuilder(
                            valueListenable: tableAmount,
                            builder: (context, double amount, child) {
                              if(amount == 0){
                                return Offstage();
                              }
                              return amountWidget('Table Amount:',amount.toString(),Colors.white);
                            }),
                        ValueListenableBuilder(
                            valueListenable: fillerAmount,
                            builder: (context, double amount, child) {
                              if(amount == 0){
                                return Offstage();
                              }
                              return amountWidget('Filler Amount:',amount.toString(),Colors.white);
                            }),
                        ValueListenableBuilder(
                            valueListenable: totalAmount,
                            builder: (context, double amount, child) {
                              if(amount == 0){
                                return Offstage();
                              }
                              return amountWidget('Payable Amount:',amount.toString(),Colors.white);
                            }),
                      ],

                    if(widget.isVenue == 'venue')
                      ...[
                        ValueListenableBuilder(
                            valueListenable: entryAmount,
                            builder: (context, double amount, child) {
                              if(amount == 0){
                                return Offstage();
                              }
                              return amountWidget('Entry Amount:',amount.toString(),Colors.white);
                            }),
                        ValueListenableBuilder(
                            valueListenable: tableAmount,
                            builder: (context, double amount, child) {
                              if(amount == 0){
                                return Offstage();
                              }
                              return amountWidget('Table Amount:',amount.toString(),Colors.white);
                            }),


                        ValueListenableBuilder(
                          valueListenable: totalDeduction,
                          builder: (context, double deductAmount, child) =>
                              ValueListenableBuilder(
                                valueListenable:entryAmount,
                                builder: (context,double entry, child) =>
                                    ValueListenableBuilder(
                                      valueListenable: tableAmount,
                                      builder: (context,double table, child) =>
                                          ValueListenableBuilder(valueListenable: fillerAmount,
                                            builder: (context,double filler, child) =>
                                                Column(
                                                    children:[
                                                      amountWidget('Filler Amount:',filler.toString(),Colors.white),
                                                      SizedBox(height: 10,),
                                                      Divider(color: Colors.grey,),
                                                      amountWidget('Total:','${entry+table+filler}',Colors.white),
                                                      amountWidget('Commission Amount(Deduction):',deductAmount.toString(),Colors.white),

                                                      SizedBox(height: 10,),
                                                      Divider(color: Colors.grey,),
                                                      amountWidget('Payable Amount:','${entry+table +filler-deductAmount}',Colors.white),
                                                    ]
                                                )

                                            ,),)

                                ,),
                        ),

                      ],
                    SizedBox(height: 10,),
                    // // amountWidget('Total Qr Scan:',totalQrScan.toString(),Colors.orangeAccent),
                    // // SizedBox(height: 10,),
                    // amountWidget('Amount @ INR 50.00:',(totalQrScan * 50).toString(),Colors.white),
                    // SizedBox(height: 10,),
                    // // amountWidget('GST@ 18%:','${totalAmount *0.18}',Colors.white),
                    // // SizedBox(height: 10,),
                    // // amountWidget('GateWayLess@ 2%:','${totalAmount *0.02}',Colors.white),
                    // // SizedBox(height: 10,),
                    // amountWidget('CommisionLess@ 4%:','${totalAmount *0.04}',Colors.white),
                    // SizedBox(height: 10,),
                    // amountWidget('Amount to be Paid','${totalAmount -totalAmount *0.18-totalAmount *0.02-totalAmount *0.04}',Colors.white),
                    // SizedBox(height: 20,),
                    // if(widget.eventType =='past')
                    //   SizedBox(
                    //     height: 70,
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.all(Radius.circular(11)),
                    //             color: Colors.orangeAccent
                    //         ),
                    //         child: const Center(child: Text('Withdrawal Request',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),)),
                    //       ),
                    //     ),
                    //   ),
                    // SizedBox(height: 20,),
                  ],
                ),
              );

            },
          )
      );
    }
  }
  Widget amountWidget(String text, String text1,Color colorCode ){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(text,style: TextStyle(fontWeight: FontWeight.w600,color: colorCode),),
          SizedBox(width: 10,),
          Text(double.tryParse(text1.toString())!.toStringAsFixed(2),style: TextStyle(fontWeight: FontWeight.w600,color: colorCode),)
        ],
      ),
    );

}