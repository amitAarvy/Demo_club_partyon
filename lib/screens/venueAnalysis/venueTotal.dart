import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/pr_companies/Analystics/reserved%20page.dart';
import 'package:club/screens/venueAnalysis/total_age_reservation.dart';
import 'package:club/screens/venueAnalysis/total_noOfClick.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';

import '../pr_companies/widget/age_bar_chart.dart';
import '../pr_companies/widget/bar_chart.dart';


class VenueTotal extends StatefulWidget {
  final String eventId;
  final eventData;
  final String? venuePr;
  final String? prId;

  const VenueTotal({super.key, required this.eventId, required this.eventData, this.venuePr, this.prId});

  @override
  State<VenueTotal> createState() => _VenueTotalState();
}

class _VenueTotalState extends State<VenueTotal> {

  double totalAmount = 0.0;
  double totalEntryCommission = 0.0;
  double totalTableCommissions = 0.0;
  double totalMale = 0.0;
  double totalFemale = 0.0;
  double totalReserved = 0.0;
  double totalFillerAmount = 0.0;
  double totalNoshow = 0.0;
  fetchPromotionDetails()async{
    print('check it ${widget.prId}');
    isLoadingEvent.value =true;
    print('check event id ${widget.eventId}');
    try {
      var data = await FirebaseFirestore.instance
          .collection('PrAnalytics')
          .get();

      var checkInOut = await FirebaseFirestore.instance
          .collection('CheckInOut').doc(widget.eventId.toString()).get();

      List checkOutList  = [];

      if(checkInOut.data() != null){
        checkOutList =  checkInOut.data()!['checkInList'];
      }


      detail.value = data.docs
          .where((e) => (e.data() as Map<String, dynamic>)['eventId'].toString() == widget.eventId.toString())
          .toList();
      print('check it ${detail.value}');
      double entryPercentage = int.parse(
          widget.venuePr.toString() == 'true' ? widget
              .eventData['offeredCommissionPr'].toString() : widget
              .eventData['data']['pomotionData']['offeredCommissionPr']
              .toString()) / 100;
      double tablePercentage = int.parse(
          widget.venuePr.toString() == 'true' ? widget
              .eventData['offeredCommissionTablePr'].toString() : widget
              .eventData['data']['pomotionData']['offeredCommissionTablePr']
              .toString()) / 100;

      double totalAmountTable = 0.0;
      double totalAmountEntry = 0.0;
      double totalFillerEntry = 0.0;
      for (var pr in detail.value) {
        totalReserved += pr['noOfReserved'];


        final docData = pr.data() as Map<String, dynamic>;
        if (docData.containsKey('userList')) {
          totalMale += (pr['userList'] as List).where((element) => element['gender'].toString()=='Male',).toList().length;
          totalFemale += (pr['userList'] as List).where((element) => element['gender'].toString()=='Female',).toList().length;
          totalNoshow += (pr['userList'] as List).where((element) => element['noShow'].toString()=='true',).toList().length;

          for (var data in pr['userList'] as List) {
            double totalAmount = double.parse(data['price'].toString());
            if (data['type'].toString() == 'table') {
              double percentValue = totalAmount * tablePercentage;
              totalAmountTable += percentValue;
            } else {
              if(data['couponDetail']['appliedCoupon'].toString() =='filler') {
                if (checkOutList.isNotEmpty) {
                  for (var checkIn in checkOutList) {
                    if (checkIn['bookingId'].toString() ==
                        data['bookingId'].toString()) {
                      double percentValue = 800;
                      totalFillerEntry += percentValue;
                    }
                  }
                }
              }else{
                double percentValue = totalAmount * entryPercentage;
                totalAmountEntry += percentValue;
              }


            }
          }
        }

        totalEntryCommission = totalAmountEntry;
        totalTableCommissions = totalAmountTable;
        totalFillerAmount = totalFillerEntry;
        totalAmount = totalAmountEntry + totalAmountTable +totalFillerEntry;
      }
      setState(() {});
      print('check promotion detail is $totalAmountEntry');
      print('check promotion detail is $totalAmountTable');
      print('check promotion detail is $detail');
      print('check promotion detail is ${widget.eventId}');
      isLoadingEvent.value = false;
    }catch(e){
      log(e.toString());
    }
  }
  ValueNotifier<bool> isLoadingEvent = ValueNotifier(false);
  ValueNotifier<List> detail = ValueNotifier([]);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchEventDetail();
    fetchPromotionDetails();
  }
  ValueNotifier eventDetail = ValueNotifier(null);
  fetchEventDetail()async{
    var data  = await FirebaseFirestore.instance.collection('Events').doc(widget.eventId).get();
    eventDetail.value = data.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body:ValueListenableBuilder(
          valueListenable: isLoadingEvent,
          builder: (context, bool isLoading, child) {
            if(isLoading){
              return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),);
            }
            return ValueListenableBuilder(
              valueListenable: detail,
              builder: (context, List prDetail, child) {
                if(prDetail.isEmpty){
                  return Center(child: Text('No details are available for this event.',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),);
                }
                final docData = prDetail[0].data() as Map<String, dynamic>;
                return ValueListenableBuilder(
                  valueListenable: eventDetail,
                  builder: (context,event, child) {
                    var eventDetail  = event as Map<String,dynamic>;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child:
                        Column(
                          children: [
                            SizedBox(height: 10,),
                            Text('${widget.venuePr == 'true'?eventDetail['title']:widget.eventData['data']['title']}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize:25),),
                            SizedBox(height: 20,),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Venue:',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 20),),
                                    Text('${widget.venuePr =='true'?eventDetail['venueName']:widget.eventData['data']['venueName']??''}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 16),),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [
                                Text('${DateFormat('dd-MM-yyyy').format((widget.venuePr == 'true'?eventDetail['startTime']:widget.eventData['data']['startTime'] as Timestamp).toDate())} ',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18,),),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('hh : mm a').format(widget.venuePr =='true'?eventDetail['startTime'].toDate():widget.eventData['data']['startTime'].toDate()),
                                      overflow: TextOverflow.visible,
                                      style: GoogleFonts.ubuntu(
                                        color: Colors.grey,
                                        fontSize: 50.sp,
                                      ),
                                    ),
                                    Text(
                                      "- ${DateFormat('hh : mm a').format(widget.venuePr == 'true'?eventDetail['endTime'].toDate():widget.eventData['data']['endTime'].toDate())}",
                                      overflow: TextOverflow.visible,
                                      style: GoogleFonts.ubuntu(
                                        color: Colors.grey,
                                        fontSize: 50.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20,),
                            Divider(color: Colors.grey,),
                            SizedBox(height: 10,),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Lineup",
                                  style: GoogleFonts.adamina(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      decorationColor: Colors.white)),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.black,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                decoration: BoxDecoration(
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     offset: Offset(0, 1.h),
                                  //     spreadRadius: 5.h,
                                  //     blurRadius: 20.h,
                                  //     color: Colors.deepPurple,
                                  //   )
                                  // ],
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.music_note_outlined, color: Colors.white, size: 90.h),
                                        const SizedBox(width: 5),
                                        Text("${widget.venuePr == 'true'?eventDetail['artistName']:widget.eventData['data']['artistName']}", style: GoogleFonts.adamina(fontSize: 15, color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Divider(color: Colors.grey,),

                            SizedBox(height: 20,),
                            if(docData.containsKey('userList'))
                              heading('Gender Ratio'),
                            if(docData.containsKey('userList'))
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width : 200,
                                      height : 200,
                                      child: PieChart(
                                        dataMap: {
                                          "Male" : totalMale,
                                          "Female" : totalFemale,
                                        },
                                        animationDuration: Duration(milliseconds: 800),
                                        chartLegendSpacing: 32,
                                        chartRadius: MediaQuery.of(context).size.width / 3.2,
                                        colorList: [
                                          Colors.blue,
                                          Colors.purple,
                                        ],
                                        initialAngleInDegree: 0,
                                        chartType: ChartType.ring,
                                        ringStrokeWidth: 32,
                                        centerText: "",
                                        legendOptions: const LegendOptions(
                                          showLegendsInRow: false,
                                          legendPosition: LegendPosition.bottom,
                                          showLegends: false,
                                          legendShape: BoxShape.circle,
                                          legendTextStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        chartValuesOptions: ChartValuesOptions(
                                          showChartValueBackground: true,
                                          showChartValues: true,
                                          showChartValuesInPercentage: true,
                                          showChartValuesOutside: true,
                                          decimalPlaces: 1,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: 15,
                                              width: 15,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 5,),
                                            Text('Male',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                                            SizedBox(width: 5,),
                                            Text(totalMale.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              height: 15,
                                              width: 15,
                                              color: Colors.purple,
                                            ),
                                            SizedBox(width: 5,),
                                            Text('Female',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                                            SizedBox(width: 5,),
                                            Text(totalFemale.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            if(docData.containsKey('userList'))
                              SizedBox(height: 40,),
                            if(docData.containsKey('noOfClickList'))
                              heading('Number of Clicks'),
                            if(docData.containsKey('noOfClickList'))
                              SizedBox(height: 10,),
                            if(docData.containsKey('noOfClickList'))
                              SizedBox(
                                  height: Get.height * 0.5,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(31)),
                                      child: TotalNoofclick(data: prDetail[0],))),
                            if(docData.containsKey('noOfClickList'))
                              SizedBox(height: 70,),
                            if(docData.containsKey('userList'))
                              heading('No show / Reserved'),
                            if(docData.containsKey('userList'))
                              SizedBox(height: 20,),
                            if(docData.containsKey('userList'))
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PieChart(
                                      dataMap: {
                                        "Reserved" : totalReserved,
                                        "NoShow" : totalNoshow,
                                      },
                                      animationDuration: Duration(milliseconds: 800),
                                      chartLegendSpacing: 32,

                                      chartRadius: MediaQuery.of(context).size.width / 2.0,
                                      colorList: [
                                        Color(0xff1f51ff),
                                        Color(0xffFF3131),
                                      ],
                                      initialAngleInDegree: 0,
                                      chartType: ChartType.disc,
                                      ringStrokeWidth: 32,
                                      centerText: "",
                                      legendOptions: const LegendOptions(
                                        showLegendsInRow: false,
                                        legendPosition: LegendPosition.bottom,
                                        showLegends: false,
                                        legendShape: BoxShape.circle,
                                        legendTextStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      chartValuesOptions: ChartValuesOptions(
                                        showChartValueBackground: true,
                                        showChartValues: true,
                                        showChartValuesInPercentage: true,
                                        showChartValuesOutside: true,
                                        decimalPlaces: 1,

                                      ),
                                    ),
                                    // SizedBox(
                                    //   width : 200,
                                    //   height : 300,
                                    //   child: ReservedPiaChart(data:  prDetail[0],)
                                    //   // PieChart(
                                    //   //   dataMap: {
                                    //   //     "Reserved" : double.parse(prDetail[0]['noOfReserved'].toString()),
                                    //   //     "NoShow" : (prDetail[0]['userList'] as List).where((e)=>e['noShow'].toString() =='true').length.toDouble(),
                                    //   //   },
                                    //   //   animationDuration: Duration(milliseconds: 800),
                                    //   //   chartLegendSpacing: 32,
                                    //   //   chartRadius: MediaQuery.of(context).size.width / 2.0,
                                    //   //   colorList: [
                                    //   //     Colors.green,
                                    //   //     Colors.blue,
                                    //   //   ],
                                    //   //   initialAngleInDegree: 0,
                                    //   //   chartType: ChartType.disc,
                                    //   //   ringStrokeWidth: 32,
                                    //   //   centerText: "",
                                    //   //   legendOptions: const LegendOptions(
                                    //   //     showLegendsInRow: false,
                                    //   //     legendPosition: LegendPosition.bottom,
                                    //   //     showLegends: false,
                                    //   //     legendShape: BoxShape.circle,
                                    //   //     legendTextStyle: TextStyle(
                                    //   //       fontWeight: FontWeight.bold,
                                    //   //     ),
                                    //   //   ),
                                    //   //   chartValuesOptions: ChartValuesOptions(
                                    //   //     showChartValueBackground: true,
                                    //   //     showChartValues: true,
                                    //   //     showChartValuesInPercentage: true,
                                    //   //     showChartValuesOutside: true,
                                    //   //     decimalPlaces: 1,
                                    //   //   ),
                                    //   // ),
                                    // ),
                                    SizedBox(width: 10,),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 15,
                                                width: 15,
                                                color:Color(0xffFF3131),
                                              ),
                                              SizedBox(width: 5,),
                                              Text('No Show',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                                              SizedBox(width: 5,),
                                              Text(totalNoshow.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                height: 15,
                                                width: 15,
                                                color:  Color(0xff1f51ff),
                                              ),
                                              SizedBox(width: 5,),
                                              Text('Reserved',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                                              SizedBox(width: 5,),
                                              Text(totalReserved.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if(docData.containsKey('userList'))
                              SizedBox(height: 70,),
                            if(docData.containsKey('userList'))
                              SizedBox(height: 10,),
                            if(docData.containsKey('userList'))
                              heading('Age of Reservation Made'),
                            if(docData.containsKey('userList'))
                              SizedBox(height: 20,),
                            if(docData.containsKey('userList'))
                              Container(
                                  height: Get.height * 0.5,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(31)),

                                      child: TotalAgeReservation(data: prDetail,))),
                            // if(docData.containsKey('userList'))
                            //   Text('${(prDetail[0]['userList']as List).length}'),
                            //   SizedBox(
                            //       height: (prDetail[0]['userList']as List).length > 50?Get.height*3:(prDetail[0]['userList']as List).length>100?Get.height*4:(prDetail[0]['userList']as List).length>150?Get.height*5:(prDetail[0]['userList']as List).length>200?Get.height*6:(prDetail[0]['userList']as List).length>=250?Get.height*50:(prDetail[0]['userList']as List).length>300?Get.height*30:Get.height*2,
                            //       child: ReservedPage(data:prDetail[0],)),
                            SizedBox(height: 70,),
                            if(docData.containsKey('userList'))
                              Row(
                                children: [
                                  Text('Summary/Analysis',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 20),),
                                ],
                              ),
                            SizedBox(height: 10,),
                            if(docData.containsKey('userList'))
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: (){
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context, builder: (context) {
                                      return bottomHeading(prDetail,type: 'filler');
                                    },);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Filler Entered',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                                      Text('${(prDetail[0]['userList'] as List).where((element) => element['checkIn'].toString() != '',).where((ele)=>ele['type'].toString()=='entry').where((element) => element['couponDetail']['appliedCoupon'].toString() =='filler',).length}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                                    ],
                                  ),
                                ),
                              )
                            ,
                            if(docData.containsKey('userList'))
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${widget.venuePr =='true'?'Payout Amount':'Amount Generated'}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                                    Text(totalFillerAmount.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                                  ],
                                ),
                              ),
                            SizedBox(height: 10,),
                            if(docData.containsKey('userList'))
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: (){
                                    // Get.to(ReservedPage(data: prDetail[0],type: 'entry',));
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context, builder: (context) {
                                      return bottomHeading(prDetail,type: 'entry');
                                    },);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Paid Entries',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                                      Text('${(prDetail[0]['userList'] as List).where((element) => element['checkIn'].toString() != '',).where((ele)=>ele['type'].toString()=='entry').where((element) => element['couponDetail']['appliedCoupon'].toString() != 'filler',).length}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                                    ],
                                  ),
                                ),
                              ),
                            if(docData.containsKey('userList'))
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${widget.venuePr == 'true'?'Payout Commission':'Commission Generated'}(${widget.venuePr == 'true'?widget.eventData['offeredCommissionPr']:widget.eventData['data']['pomotionData']['offeredCommissionPr'] }%)',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                                    Text('$totalEntryCommission',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                                  ],
                                ),
                              ),
                            SizedBox(height: 10,),
                            if(docData.containsKey('userList'))
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: (){
                                    // Get.to(ReservedPage(data: prDetail[0],type: 'table',));
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context, builder: (context) {
                                      return bottomHeading(prDetail,type: 'table');
                                    },);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Table Entries',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                                      Text('${(prDetail[0]['userList'] as List).where((element) => element['type'].toString() == 'table')
                                          // .where((ele) => ele['duration'].toString() != '',)
                                          .length}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                                    ],
                                  ),
                                ),
                              ),
                            if(docData.containsKey('userList'))
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${widget.venuePr.toString() =='true'?'Payout Commission':'Commission Generated'}(${widget.venuePr == 'true'?widget.eventData['offeredCommissionTablePr']:widget.eventData['data']['pomotionData']['offeredCommissionTablePr'] }%)',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                                    Text('${totalTableCommissions}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 20),),
                                  ],
                                ),
                              ),
                            if(docData.containsKey('userList'))
                              Divider(color: Colors.grey.shade200,),
                            if(docData.containsKey('userList'))
                              SizedBox(height: 10,),
                            // if(docData.containsKey('userList'))
                            //   Padding(
                            //     padding: const EdgeInsets.only(right: 10),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         Text('${widget.venuePr.toString() =='true'?'Pay':'Recievable Amount'}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                            //         Text('${totalAmount}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                            //       ],
                            //     ),
                            //
                            //   ),
                            // SizedBox(height: 10,),
                            // if(docData.containsKey('userList'))
                            //   Divider(color: Colors.grey.shade200,),
                            SizedBox(height: 20,),
                            // if(docData.containsKey('userList'))
                            //   Container(
                            //     margin: EdgeInsets.symmetric(horizontal: 10),
                            //     decoration: BoxDecoration(
                            //         color: Color(0xff1f51ff),
                            //         borderRadius: BorderRadius.all(Radius.circular(11))
                            //     ),
                            //     padding: EdgeInsets.symmetric(vertical: 10),
                            //     child: Center(child: Text('Request Payout',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),),
                            //   ),
                            SizedBox(height: 10,),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },

            );
          },
        )
    );
  }

  Widget bottomHeading(prDetail,{String?type}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Row(
              children: [
                Text('Summary/Analysis',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 20),),
              ],
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: (){
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context, builder: (context) {
                    return bottomHeading(prDetail,type: 'fillars');
                  },);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filler Entered',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                    Text('${(prDetail[0]['userList'] as List).where((element) => element['checkIn'].toString() != '',).where((ele)=>ele['type'].toString()=='entry').where((element) => element['couponDetail']['appliedCoupon'].toString() =='filler',).length}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                  ],
                ),
              ),
            )
            ,
            // if(docData.containsKey('userList'))
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${widget.venuePr =='true'?'Payout Amount':'Amount Generated'}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                    Text(totalFillerAmount.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                  ],
                ),
              ),
            SizedBox(height: 10,),
            // if(docData.containsKey('userList'))
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: (){
                    // Get.to(ReservedPage(data: prDetail[0],type: 'entry',));
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context, builder: (context) {
                      return bottomHeading(prDetail,type: 'entry');
                    },);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Paid Entries',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                      Text('${(prDetail[0]['userList'] as List).where((element) => element['checkIn'].toString() != '',).where((ele)=>ele['type'].toString()=='entry').where((element) => element['couponDetail']['appliedCoupon'].toString() != 'filler',).length}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                    ],
                  ),
                ),
              ),
            // if(docData.containsKey('userList'))
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${widget.venuePr == 'true'?'Payout Commission':'Commission Generated'}(${widget.venuePr == 'true'?widget.eventData['offeredCommissionPr']:widget.eventData['data']['pomotionData']['offeredCommissionPr'] }%)',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                    Text('$totalEntryCommission',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                  ],
                ),
              ),
                SizedBox(height: 10,),
            // if(docData.containsKey('userList'))
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: (){
                    // Get.to(ReservedPage(data: prDetail[0],type: 'table',));
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context, builder: (context) {
                      return bottomHeading(prDetail,type: 'table');
                    },);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Table Entries',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                      Text('${(prDetail[0]['userList'] as List).where((element) => element['type'].toString() == 'table')
                      // .where((ele) => ele['duration'].toString() != '',)
                          .length}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.orangeAccent,fontSize: 18),),
                    ],
                  ),
                ),
              ),
            // if(docData.containsKey('userList'))
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${widget.venuePr.toString() =='true'?'Payout Commission':'Commission Generated'}(${widget.venuePr == 'true'?widget.eventData['offeredCommissionTablePr']:widget.eventData['data']['pomotionData']['offeredCommissionTablePr'] }%)',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
                    Text('${totalTableCommissions}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 20),),
                  ],
                ),
              ),
            Divider(color: Colors.grey.shade200,),
            // SizedBox(height: 10,),
            // Padding(
            //   padding: const EdgeInsets.only(right: 10),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text('Recievable Amount',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
            //       Text('${totalAmount}',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 18),),
            //     ],
            //   ),
            // ),
            // SizedBox(height: 10,),
            // Divider(color: Colors.grey.shade200,),
            SizedBox(height: 20,),

            SizedBox(height: 10,),
            Expanded(child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(41),topRight: Radius.circular(41)),
                child: ReservedPage(data: prDetail[0],type: type!,isVenue: true,)))
          ],
        ),
      ),
    );
  }

  Widget heading(String title){
    return Text(title,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),);
  }
}


