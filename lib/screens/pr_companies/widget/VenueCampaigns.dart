import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/home.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../../dynamic_link/dynamic_link.dart';
import '../../../utils/app_utils.dart';
import '../../coupon_code/controller/coupon_code_controller.dart';
import '../../coupon_code/model/data/coupon_code_model.dart';
import 'message_preview.dart';

class VenueCampaigns extends StatefulWidget {
  final data;
  final String eventId;

  const VenueCampaigns({super.key, this.data, required this.eventId,});

  @override
  State<VenueCampaigns> createState() => _VenueCampaignsState();
}

class _VenueCampaignsState extends State<VenueCampaigns> {
  String url ='';
  bool showUrl= false;
  late Future<List<CouponModel>> sharedCouponList;
  MethodChannel channel = const MethodChannel('instagramshare');
  DateTime startSelectedEntryDate = DateTime.now();
  DateTime startSelectedTableDate = DateTime.now();
  TimeOfDay startTimes = const TimeOfDay(hour: 0, minute: 0);
  DateTime endSelectedDate = DateTime.now();
  DateTime endSelectedEntryDate = DateTime.now();
  DateTime endSelectedTableDate = DateTime.now();



  Future<void> shareMultipleToInstagram(List<String> filePaths) async {
    try {
      await channel.invokeMethod('shareMultiple', {'filePaths': filePaths});
    } catch (e) {
      print('Error sharing to Instagram: $e');
    }
  }
  void sharedCoupon() async {
    sharedCouponList = (CouponCodeController.savedCouponCodes(venueId: widget.data['clubUID'].toString()));
  }

  Future<String> downloadFile(String url, String fileName, {String defaultExtension = 'jpg'}) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName.$defaultExtension'; // Add a default extension if missing

      // Force content type detection and append extension dynamically
      final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
      final fileType = response.headers['content-type']?.first ?? 'application/octet-stream';

      String actualExtension;
      if (fileType.startsWith('image')) {
        actualExtension = 'jpg'; // You can refine this further
      } else if (fileType.startsWith('video')) {
        actualExtension = 'mp4'; // Default for videos
      } else {
        actualExtension = defaultExtension; // Fallback
      }

      // Update file path with the detected extension
      final updatedFilePath = '${dir.path}/$fileName.$actualExtension';

      // Write the file
      final file = File(updatedFilePath);
      await file.writeAsBytes(response.data);

      return updatedFilePath;
    } catch (e) {
      print('Error downloading file: $e');
      rethrow;
    }
  }

  List prCouponData = [];
  // fetchPrPromotion()async{
  //   final data;
  //   if(widget.isInf){
  //     data =  await FirebaseFirestore.instance.collection('CouponPR').where('infId',isEqualTo: uid()).where('eventId',isEqualTo: widget.data['allDetail']['pomotionData']['eventId'].toString()).where('isInf',isEqualTo: true).get();
  //   }else{
  //     data =  await FirebaseFirestore.instance.collection('CouponPR').where('prId',isEqualTo: uid()).where('eventId',isEqualTo: widget.data['pomotionData']['eventId'].toString()).where('isInf',isEqualTo: false).get();
  //   }
  //   prCouponData = data.docs;
  //   print('check coupon list is ${prCouponData}');
  //   for(var data in prCouponData){
  //     print(data.id);
  //   }
  //   setState(() {});
  // }

  @override
  void initState() {
    // TODO: implement initState
    log('check is ${widget.data}');
    startSelectedTableDate =widget.data['created_at']==null?DateTime.now(): (widget.data['created_at'] as Timestamp).toDate();
    startSelectedEntryDate = widget.data['created_at']==null?DateTime.now():(widget.data['created_at'] as Timestamp).toDate();
    endSelectedEntryDate = (widget.data['endTime'] as Timestamp).toDate();
    endSelectedTableDate = (widget.data['endTime'] as Timestamp).toDate();
    // createUrl();
    sharedCoupon();
    // updateCouponCodePr();
    // fetchPrPromotion();
    // if(!widget.isInf){
      createUrl();
    // }
    print('check image is ${widget.data}');
  }





  void createUrl() async {
    url = await FirebaseDynamicLinkEvent.createDynamicLink(
      short: true,
      // clubUID: isClub ? uid() : data['clubUID'] ?? '',
      clubUID: widget.data['clubUID'],
      eventID: widget.eventId,
      organiserID: '',
      promoterID: '',
      isVenue:true
    );
    print('check url is ${url}');
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: appBar(context, title: "", ),
        body:Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child:SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Event Details",style: TextStyle(fontWeight: FontWeight.w700,color: Colors.white,fontSize: 16),),
                  SizedBox(height: 10,),
                  Center(
                    child: SizedBox(
                      width:  Get.width / 2.8,
                      child: AspectRatio(
                        aspectRatio: 9/16,
                        child: Container(
                          width: Get.width,
                          // height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:
                            CachedNetworkImage(
                              fit: BoxFit.fill,
                              fadeInDuration: const Duration(milliseconds: 100),
                              fadeOutDuration: const Duration(milliseconds: 100),
                              useOldImageOnUrlChange: true,
                              filterQuality: FilterQuality.low,
                              imageUrl:widget.data['coverImages'][0].toString(), // Use the first image in the list
                              // placeholder: (_, __) => const Center(
                              //   child: CircularProgressIndicator(color: Colors.orange),
                              // ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // AspectRatio(
                  //     aspectRatio: 9/13,
                  //     child: Image.network(widget.data['coverImages'][0].toString(),fit: BoxFit.fill,)),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.data['title'].toString().capitalizeFirstOfEach,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 18),),
                      Text("Date : ${DateFormat('dd/MM/yyyy').format((widget.data['date'] as Timestamp).toDate(),)}",
                        style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            fontSize: 16),
                      ),
                    ],
                  ),

                  Text(widget.data['briefEvent'].toString(),style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white,fontSize: 14),),
                  SizedBox(height: 10,),
                  Text(widget.data['artistName'].toString(),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Expanded(child: Text(url,style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),)),
                      GestureDetector(
                          onTap: (){
                            Clipboard.setData(ClipboardData(text: url));
                            Fluttertoast.showToast(msg: 'Copy Url');
                          },
                          child: Icon(Icons.copy,color: Colors.white,))
                    ],
                  ),
                  SizedBox(height: 20,),
                  if ((widget.data['entryManagementCouponList']) != null)
                    SizedBox(
                      // width: double.infinity,
                      child: Card(
                        color: const Color(0xff451F55),
                        // margin: const EdgeInsets.all(20),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category : ${widget.data['entryManagementCouponList']['couponCategory']??'{}'}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Coupon Code : ${widget.data['entryManagementCouponList']['couponCode']??''}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Discount : ${widget.data['entryManagementCouponList']['discount']??''}%',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  GestureDetector(
                                      onTap: (){
                                        Clipboard.setData(ClipboardData(text: '${widget.data['entryManagementCouponList']['couponCode']??''}'));
                                        Fluttertoast.showToast(msg: 'Copy Url');
                                      },
                                      child: Icon(Icons.copy,color: Colors.white,)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.data['entryManagementCouponList'] != null)
                  SizedBox(height: 20,),
                  if (widget.data['entryManagementCouponList'] != null)
                    StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('VenueAnalysis')
                        .where('eventId', isEqualTo: widget.eventId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return Offstage(); // Hide the UI if venue already analyzed
                      }
                      return Column(
                        children: [
                          SizedBox(
                            height: 120.h,
                            width: Get.width - 100.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Start Date: ${DateFormat.yMMMd().format(startSelectedEntryDate)}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white70, fontSize: 45.sp),
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      DateTime? picked = await showDatePicker(
                                          initialDate: startSelectedEntryDate,
                                          firstDate: DateTime.now(),
                                          lastDate: (widget.data['startTime'] as Timestamp).toDate(),
                                          context: context);
                                      if (picked != null &&
                                          picked != startSelectedEntryDate) {
                                        setState(() {
                                          startSelectedEntryDate = picked;
                                          if (endSelectedEntryDate
                                              .isBefore(startSelectedEntryDate)) {
                                            endSelectedEntryDate = picked;
                                          }
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 100.h,
                                      width: 300.w,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.white, width: 4.h)),
                                      child: Center(
                                          child: Text(
                                            "Select Date",
                                            style:
                                            GoogleFonts.ubuntu(color: Colors.white),
                                          )),
                                    )),
                              ],
                            ),
                          ).marginOnly(
                              left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),

                          SizedBox(
                            height: 120.h,
                            width: Get.width - 100.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "End Date: ${DateFormat.yMMMd().format(endSelectedEntryDate)}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white70, fontSize: 45.sp),
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      DateTime? picked = await showDatePicker(
                                          initialDate: endSelectedEntryDate,
                                          firstDate: startSelectedEntryDate,
                                          lastDate:  (widget.data['startTime'] as Timestamp).toDate(),
                                          context: context);
                                      if (picked != null &&
                                          picked != endSelectedEntryDate) {
                                        setState(() {
                                          endSelectedEntryDate = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 100.h,
                                      width: 300.w,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.white, width: 4.h)),
                                      child: Center(
                                          child: Text(
                                            "Select Date",
                                            style:
                                            GoogleFonts.ubuntu(color: Colors.white),
                                          )),
                                    )),
                              ],
                            ),
                          ).marginOnly(
                              left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                        ],
                      );
                    }
                    ),

                  if (widget.data['tableManagementCouponList'] != null)
                    SizedBox(
                      // width: double.infinity,
                      child: Card(
                        color: const Color(0xff451F55),
                        // margin: const EdgeInsets.all(20),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category : ${widget.data['tableManagementCouponList']['couponCategory']??''}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Coupon Code : ${widget.data['tableManagementCouponList']['couponCode']??''}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                  Text(
                                    'Discount : ${widget.data['tableManagementCouponList']['discount']??''}%',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 40.sp),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                      onTap: (){
                                        Clipboard.setData(ClipboardData(text: '${widget.data['tableManagementCouponList']['couponCode']??''}'));
                                        Fluttertoast.showToast(msg: 'Copy Url');
                                      },
                                      child: Icon(Icons.copy,color: Colors.white,)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.data['tableManagementCouponList'] != null)
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('VenueAnalysis')
                          .where('eventId', isEqualTo: widget.eventId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          return Offstage(); // Hide the UI if venue already analyzed
                        }
                        return Column(
                          children: [
                            SizedBox(
                              height: 120.h,
                              width: Get.width - 100.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Start Date: ${DateFormat.yMMMd().format(startSelectedTableDate)}",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white70, fontSize: 45.sp),
                                  ),
                                  GestureDetector(
                                      onTap: () async {
                                        DateTime? picked = await showDatePicker(
                                            initialDate: startSelectedTableDate,
                                            firstDate: DateTime.now(),
                                            lastDate:  (widget.data['startTime'] as Timestamp).toDate(),
                                            context: context);
                                        if (picked != null &&
                                            picked != startSelectedTableDate) {
                                          setState(() {
                                            startSelectedTableDate = picked;
                                            if (endSelectedTableDate
                                                .isBefore(startSelectedTableDate)) {
                                              endSelectedTableDate = picked;
                                            }
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 100.h,
                                        width: 300.w,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.white, width: 4.h)),
                                        child: Center(
                                            child: Text(
                                              "Select Date",
                                              style:
                                              GoogleFonts.ubuntu(color: Colors.white),
                                            )),
                                      )),
                                ],
                              ),
                            ).marginOnly(
                                left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),

                            SizedBox(
                              height: 120.h,
                              width: Get.width - 100.w,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "End Date: ${DateFormat.yMMMd().format(endSelectedTableDate)}",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white70, fontSize: 45.sp),
                                  ),
                                  GestureDetector(
                                      onTap: () async {
                                        DateTime? picked = await showDatePicker(
                                            initialDate: endSelectedTableDate,
                                            firstDate: startSelectedTableDate,
                                            lastDate:  (widget.data['startTime'] as Timestamp).toDate(),
                                            context: context);
                                        if (picked != null &&
                                            picked != endSelectedTableDate) {
                                          setState(() {
                                            endSelectedTableDate = picked;
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 100.h,
                                        width: 300.w,
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.white, width: 4.h)),
                                        child: Center(
                                            child: Text(
                                              "Select Date",
                                              style:
                                              GoogleFonts.ubuntu(color: Colors.white),
                                            )),
                                      )),
                                ],
                              ),
                            ).marginOnly(
                                left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                          ],
                        );
                      }
                  ),
                  SizedBox(height: 20,),
            StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('VenueAnalysis')
                .where('eventId', isEqualTo: widget.eventId)
                .snapshots(),
            builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
               return Offstage(); // Hide the UI if venue already analyzed
            }

      return InkWell(
      onTap: () async {
     var data =   await FirebaseFirestore.instance.collection('Events').doc(widget.eventId).get();
       var data1 = data.data() as Map<String,dynamic>;
      var entryCouponDetail ={
        "couponCategory":data1['entryManagementCouponList']['couponCategory'],
        "couponCode":data1['entryManagementCouponList']['couponCode'],
        "discount":data1['entryManagementCouponList']['discount'],
        "type":data1['entryManagementCouponList']['type'],
        "uid":data1['entryManagementCouponList']['uid'],
        "validFrom":DateFormat('dd-MM-yyyy hh:mm').format(startSelectedEntryDate),
        "validTill":DateFormat('dd-MM-yyyy hh:mm').format(endSelectedEntryDate)
      };
     var tableCouponDetail ={
       "couponCategory":data1['tableManagementCouponList']['couponCategory'],
       "couponCode":data1['tableManagementCouponList']['couponCode'],
       "discount":data1['tableManagementCouponList']['discount'],
       "type":data1['tableManagementCouponList']['type'],
       "uid":data1['tableManagementCouponList']['uid'],
       "validFrom":DateFormat('dd-MM-yyyy hh:mm').format(startSelectedTableDate),
       "validTill":DateFormat('dd-MM-yyyy hh:mm').format(endSelectedTableDate)
     };
        await FirebaseFirestore.instance.collection('Events').doc(widget.eventId).update({
          "entryManagementCouponList":entryCouponDetail,
          "tableManagementCouponList":tableCouponDetail
        }).whenComplete(()async {
          await FirebaseFirestore.instance.collection('VenueAnalysis').add({
            'eventId': widget.eventId,
            'isVenue': true,
            'venueId': widget.data['clubUID'].toString(),
            'noOfView': 0,
            'noOfReserved': 0,
            'noOfClick': 0,
          });
        },).whenComplete(() {
          Get.back();
          Fluttertoast.showToast(msg: 'success');
        },);



        },
    child: Container(
    width: double.infinity,
    decoration: BoxDecoration(
    color: Colors.green,
    borderRadius: BorderRadius.all(Radius.circular(11)),
    ),
    padding: const EdgeInsets.all(8.0),
    child: Column(
    children: [
    Text(
    'Done',
    style: TextStyle(
    fontWeight: FontWeight.w600,
    color: Colors.white,
    ),
    )
    ],
    ),
    ),
    );
    },
    ),


    SizedBox(height: 20,),
    StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('VenueAnalysis')
        .where('eventId', isEqualTo: widget.eventId)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
        return Offstage(); // Hide the UI if venue already analyzed
      }
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Share Now",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16,color: Colors.white),),
            ],
          ),
          SizedBox(height: 30,),
          Row(
            children: [
              Expanded(
                  child: InkWell(
                    onTap: (){
                      // Share.share("$url");
                      Get.bottomSheet(bottomSheet('whatsaap'));

                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(11))),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(FontAwesomeIcons.whatsapp,color: Colors.green,size: 50,),
                      ),
                    ),
                  )),
              SizedBox(width: 10,),
              Expanded(
                  child: InkWell(
                    onTap: ()async{
                      Get.bottomSheet(bottomSheet('insta'));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(11))),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset('assets/insta_icons.png',height: 50,width: 50,)
                        // Icon(FontAwesomeIcons.instagram,color: Color(0xFFE1306C),size: 50,),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      );
    }
    ),

                  SizedBox(height: 40,),
                  InkWell(
                    onTap: ()async{
                      // if(widget.isInf){
                        Get.offAll(ClubHome());
                      // }else{
                      //   Get.offAll(OrganiserHomeBar());
                      // }
                    },
                    child: Container(
                      width: 1.sw,
                      decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(11))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text('Back to Home',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),)
                          ],),
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
    );
  }




  Widget bottomSheet(String type){
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30,),
            InkWell(
              onTap: () async {
                Get.back();
                if(type != 'insta') {
                  Get.bottomSheet(
                      MessagePreviewBottomSheet(
                        couponCode: widget
                            .data['entryManagementCouponList']['couponCode'] ??
                            '',
                        validFrom: widget
                            .data['entryManagementCouponList']['validFrom'] ??
                            '',
                        validUntil: widget
                            .data['entryManagementCouponList']['validTill'] ??
                            '',
                        couponCategory: widget
                            .data['entryManagementCouponList']['couponCategory'] ??
                            '',
                        eventName: widget.data['title'] ?? '',
                        eventData: DateFormat('dd/MM/yyyy').format(
                          (widget.data['date'] as Timestamp).toDate(),
                        ),
                        imageUrl: widget.data['coverImages'][0].toString(),
                        eventUrl: url,
                        tableCoupon: widget
                            .data['tableManagementCouponList']['couponCode'] ??
                            '',
                        type: 'entry',
                        discountPercentage: widget
                            .data['entryManagementCouponList']['discount'] ??
                            '',
                      )
                  );
                }else{
                  Get.bottomSheet(
                  InstagramShare(
                    couponCode: widget
                        .data['entryManagementCouponList']['couponCode'] ?? '',
                    validFrom: widget
                        .data['entryManagementCouponList']['validFrom'] ??
                        '',
                    validUntil: widget
                        .data['entryManagementCouponList']['validTill'] ??
                        '',
                    couponCategory: widget
                        .data['entryManagementCouponList']['couponCategory'] ??
                        '',
                    eventName: widget.data['title'] ?? '',
                    imageUrl: widget.data['coverImages'][0].toString(),
                    eventUrl: url,
                    type: 'entry',
                    discountPercentage: widget
                        .data['entryManagementCouponList']['discount'] ??
                        '',
                  eventData: DateFormat('dd/MM/yyyy').format((widget.data['date'] as Timestamp).toDate(),


                )
                  ));
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Column(
                  children: [
                    Text(
                      'Entry Management',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            InkWell(
              onTap: () async {
                Get.back();
                Get.bottomSheet(
                  type != 'insta'?
                    MessagePreviewBottomSheet(
                      couponCode: widget.data['entryManagementCouponList']['couponCode']??'',
                      validFrom: widget.data['tableManagementCouponList']['validFrom']??'',
                      validUntil: widget.data['tableManagementCouponList']['validTill']??'',
                      couponCategory:widget.data['tableManagementCouponList']['couponCategory']??'',
                      eventName: widget.data['title']??'',
                      eventData: DateFormat('dd/MM/yyyy').format((widget.data['date'] as Timestamp).toDate(),
                      ),
                      imageUrl: widget.data['coverImages'][0].toString(),
                      eventUrl:url,
                      tableCoupon: widget.data['tableManagementCouponList']['couponCode']??'',
                      type: 'table',
                      discountPercentage: widget.data['tableManagementCouponList']['discount']??'',
                    ):
                InstagramShare(
                couponCode: widget
                    .data['tableManagementCouponList']['couponCode'] ?? '',
                validFrom: widget
                    .data['tableManagementCouponList']['validFrom'] ??
                '',
                validUntil: widget
                    .data['tableManagementCouponList']['validTill'] ??
                '',
                      couponCategory: widget
                    .data['tableManagementCouponList']['couponCategory'] ??
                '',
                eventName: widget.data['title'] ?? '',
                imageUrl: widget.data['coverImages'][0].toString(),
                eventUrl: url,
                type: 'table',
                discountPercentage: widget
                    .data['tableManagementCouponList']['discount'] ??
                '',
                    eventData: DateFormat('dd/MM/yyyy').format((widget.data['date'] as Timestamp).toDate(),
                    ))
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Column(
                  children: [
                    Text(
                      'Table Management',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

}

class InstagramShare extends StatefulWidget {
  final String? couponCode;
  final String validFrom;
  final String validUntil;
  final String couponCategory;
  final String discountPercentage;
  final String eventName;
  final String imageUrl;
  final String eventUrl;
  final String? type;
  final String eventData;


  const InstagramShare({super.key,required this.eventData, this.couponCode, required this.validFrom, required this.validUntil, required this.couponCategory, required this.discountPercentage, required this.eventName, required this.imageUrl, required this.eventUrl, this.type});

  @override
  State<InstagramShare> createState() => _InstagramShareState();
}

class _InstagramShareState extends State<InstagramShare> {
  MethodChannel channel = const MethodChannel('instagramshare');

  Future<void> shareToInstagram(String filePath, String fileType) async {
    try {
      await channel.invokeMethod('share', {'filePath': filePath, 'fileType': fileType});
    } catch (e) {
      print('Error sharing to Instagram: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    var message = '🪩 BIG NIGHT AHEAD!\n'
    '🔥 ${widget.eventName} – ${widget.validFrom} 🔥\n\n'

    '🎟 Use Code: ${widget.couponCode}\n'
   ' 💸 Instant discount on ${widget.type =='table'?'table':'entry'}!\n\n'

    '🕛 Valid: ${widget.validFrom}\n'
    '🚨 Ends: ${widget.validUntil}\n\n'

    '🎧 Don’t just hear about it. Be there.\n'
    '🔗 Tap the link & book now:\n'

    ;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(widget.imageUrl.toString()),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text( message,style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
            ), Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text( 'copy and paste link in instagram story link section',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                  onTap: (){
                    Clipboard.setData(ClipboardData(text: widget.eventUrl));
                    Fluttertoast.showToast(msg: 'Copy ');
                  },
                  child: Text( '  👉 ${widget.eventUrl}\n',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.blue,),)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text( '✨ #PartyOn #WelcomeVibes #LiveTheNight ✨\n\n',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,),),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async{
                    Clipboard.setData(ClipboardData(text: message));
                    Fluttertoast.showToast(msg: 'Copy ');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(11))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                      child:  Text('Copy',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                      // Icon(FontAwesomeIcons.instagram,color: Color(0xFFE1306C),size: 50,),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    int coverImageLength = widget.imageUrl.length ;
                    // if(coverImageLength == 1){
                      final response = await http.get(Uri.parse(widget.imageUrl));
                      final bytes = response.bodyBytes;
                      final tempDir = await getTemporaryDirectory();
                      final file = File(
                          '${tempDir.path}/shared_image.jpg');
                      await file.writeAsBytes(bytes);
                      shareToInstagram(file.path,'image');

                    // }else{
                    //   List<String> localPaths = [];
                    //   int imageLength = widget.data['coverImages'].length;
                    //   for (var i = 0; i < imageLength; i++) {
                    //     final fileName = 'file_$i.${widget.data['coverImages'][i].split('.').last}';
                    //     final localPath = await downloadFile(widget.data['coverImages'][i], fileName);
                    //     localPaths.add(localPath);
                    //     shareMultipleToInstagram(localPaths);
                    //   }
                    // }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(11))),
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child:  Text('Share Instagram',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                      // Icon(FontAwesomeIcons.instagram,color: Color(0xFFE1306C),size: 50,),
                    ),
                  ),
                ),
              ],
            ),
        
        
          ],
        ),
      ),
    );
  }
}
