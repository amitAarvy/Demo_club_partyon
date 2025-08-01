import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/accepted_influencer_list.dart';
import 'package:club/screens/event_management/barter_collab.dart';
import 'package:club/screens/event_management/venue_promotion_create.dart';
import 'package:club/screens/organiser/event_management/promotion_detail.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../promotional_analysis/promotional_analysis_event_list.dart';
import 'accepted_promoter_list.dart';
import 'create_event_promotion.dart';

class PromotionList extends StatelessWidget {
  final String collabType;
  final bool isPromotionalAnalysis;
  final String? isOrganiser;

  const PromotionList({super.key, required this.collabType, this.isPromotionalAnalysis = false,  this.isOrganiser});
  
  Future fetchPromotionRequest(String id) async{
    print('eid is ${id}');
  var data = await FirebaseFirestore.instance.collection('PromotionRequest').where('eventPromotionId',isEqualTo: id).get();
  List  request =data.docs.where((element) => element.data().containsKey('notification') ==true,).where((e)=>e['notification'].toString() =='true').toList();
  int i = request.length;
  print('cehck lenght is ${i}');
   return i;
}

  @override
  Widget build(BuildContext context) {
    DateTime timeNow = DateTime.now();

    DateTime today = DateTime(timeNow.year, timeNow.month, timeNow.day);




    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('EventPromotion')
          .where('collabType', isEqualTo: collabType)
          .where(isOrganiser =='true'?'organiserId':'clubUID', isEqualTo: uid())
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Error"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: Get.height / 5,
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child:
                Text("No List found!", style: TextStyle(color: Colors.white)),
          );
        }

        if (snapshot.data != null) {
          DateTime now = DateTime.now();
          snapshot.data!.docs.sort((a, b) =>
              (a['startTime'].toDate()).compareTo(b['startTime'].toDate()));
          var data = snapshot.data!.docs
              .where((element) => (element['startTime'].toDate() as DateTime)
                  .isAfter(DateTime(now.year, now.month, now.day - 1)))
              .toList();
          if (data.isEmpty) {
            return const Center(
              child: Text("No data available",
                  style: TextStyle(color: Colors.white)),
            );
          }
          return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
                SizedBox(
                  width: Get.width,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                            child: Center(
                                child: Text(
                          "Post Date",
                          style: GoogleFonts.ubuntu(color: Colors.white),
                        ))),
                      ),
                      Expanded(
                        child: SizedBox(
                            child: Center(
                                child: Text(
                          "Event Name",
                          style: GoogleFonts.ubuntu(color: Colors.white),
                        ))),
                      ),
                      Expanded(
                        child: SizedBox(
                            child: Center(
                                child: Text(
                          "Event Date",
                          style: GoogleFonts.ubuntu(color: Colors.white),
                        ))),
                      ),
                      Expanded(
                        child: SizedBox(
                            child: Center(
                                child: Text(
                          "Status",
                          style: GoogleFonts.ubuntu(color: Colors.white),
                        ))),
                      ),
                    ],
                  ).paddingSymmetric(vertical: 60.h),
                ),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    final productData = data[index];
                    ValueNotifier<int> notificationCount =ValueNotifier(0);
                     fetchPromotionRequest(productData.id).then((value) {
                       print('check value is ${value}');
                      notificationCount.value = value;

                    },);
                    print('check notification id ${notificationCount.value}');
                    return ValueListenableBuilder(
                      valueListenable: notificationCount,
                      builder: (context,int notification, child) =>
                       GestureDetector(
                        onTap: () => Get.to(
                          collabType == 'influencer'
                              ? AcceptedInfluencerList(
                                  eventPromotionId: productData.id,
                                )
                              : AcceptedPromoterList(
                                  eventPromotionId: productData.id,
                                ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black),
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
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if(notification != 0)
                                                      Container(
                                                          height:30,width: 30,
                                                          decoration: BoxDecoration(
                                                            color: Colors.green,
                                                            shape: BoxShape.circle
                                                          ),
                                                          child: Center(child: Text(notification.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),))),
                                                      if(notification != 0)
                                                        SizedBox(height: 5,),
                                                      Text(
                                                       DateFormat('dd-MM-yyyy').format(productData['dateTime'].toDate()),
                                                         style: GoogleFonts.ubuntu(
                                                          color: Colors.white),
                                                         ),
                                                    ],
                                                  ))),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                              child: Center(
                                                  child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${productData['eventName'].isNotEmpty ? productData['eventName'].toString().capitalize : collabType == 'influencer' ? 'Influencer Collab' : 'Promotion Collab'}",
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(height: 5),
                                              if (collabType == 'influencer')
                                                Text(
                                                  "(${productData['isPaid'] ? "Paid" : "Barter"})",
                                                  style: GoogleFonts.ubuntu(
                                                      color: productData['isPaid']
                                                          ? Colors.green
                                                          : Colors.white),
                                                ),
                                            ],
                                          ))),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                              child: Center(
                                                  child: Text(
                                            '${DateFormat('dd-MM-yyyy hh:mm a').format(getKeyValueFirestore(productData, 'startTime').toDate() ?? DateTime.now())} onwards',
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.white),
                                          ))),
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                              child: Center(
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PromotionDetails(
                                                                    type: productData['collabType'] == 'influencer' ? 'venue' : 'influencer',
                                                                    isOrganiser: false,
                                                                    isPromoter: false,
                                                                    isEditEvent: true,
                                                                    isInfluencer: true,
                                                                    isElitePass: true,
                                                                    detailShow: true,
                                                                    promotionRequestId:
                                                                        productData
                                                                            .id,
                                                                    collabType:
                                                                        productData[
                                                                            'collabType'],
                                                                    isClub: false,
                                                                    eventPromotionId:
                                                                        productData
                                                                            .id,
                                                                    clubId: productData[
                                                                        'clubUID'],
                                                                  )));
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5),
                                                      decoration: BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: const Text("View",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white)),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  if ((productData.data() as Map<String, dynamic>)['acceptedBy'] == 0)
                                                    GestureDetector(
                                                        onTap: ()async {



                                                          if (productData['collabType'] == 'influencer') {
                                                            Get.to(BarterCollab(isEdit: true,
                                                              eventPromotionalId: productData.id,
                                                              paid: productData['isPaid'],
                                                              type: (productData.data() as Map<String, dynamic>)['type'] ??'venue',
                                                              eventName: (productData.data() as Map<
                                                                              String,
                                                                              dynamic>)[
                                                                          'type'] !=
                                                                      null
                                                                  ? productData[
                                                                              'type'] ==
                                                                          'venue'
                                                                      ? productData[
                                                                          'eventName']
                                                                      : null
                                                                  : null, eventId: productData[
                                                            'evenId'].toString(),
                                                            ));
                                                          } else if (productData['collabType'] == 'promotor') {
                                                            if (productData['type'] == 'event') {
                                                              Get.to(EventPromotionCreate(
                                                                eventId: '', eventData: {
                                                                  "title": productData['eventName'],
                                                                  "startTime": productData['startTime'],
                                                                  "endTime": productData['endTime'],
                                                                },
                                                                isEdit: true,
                                                                editPromotionId:
                                                                    productData
                                                                        .id,
                                                              ));
                                                            } else {
                                                              Get.to(
                                                                  VenuePromotionCreate(
                                                                eventId: '',
                                                                isEdit: true,
                                                                editPromotionId:
                                                                    productData
                                                                        .id,
                                                              ));
                                                            }
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  Colors.yellow,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(8),
                                                          ),
                                                          child: Text(
                                                            'Edit',
                                                            style: GoogleFonts
                                                                .ubuntu(
                                                                    color: Colors
                                                                        .white),
                                                          ).paddingAll(8.0),
                                                        )).marginOnly(bottom: 10),
                                                  Text(
                                                    (productData.data() as Map<
                                                                    String,
                                                                    dynamic>)[
                                                                'acceptedBy'] >=
                                                            (productData.data()
                                                                    as Map<String,
                                                                        dynamic>)[
                                                                'noOfBarterCollab']
                                                        ? 'Accepted'
                                                        : "Pending",
                                                    // promotionDetail.isEmpty
                                                    //     ? 'Pending'
                                                    //     : promotionDetail[0]['status'] == 2
                                                    //     ? 'Pending'
                                                    //     : 'Accepted',
                                                    style: GoogleFonts.ubuntu(
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    "${(productData.data() as Map<String, dynamic>)['acceptedBy']} / ${(productData.data() as Map<String, dynamic>)['noOfBarterCollab']}",
                                                    style: GoogleFonts.ubuntu(
                                                        color: Colors.white),
                                                  )
                                                ]),
                                          )),
                                        ),
                                      ],
                                    ).paddingSymmetric(vertical: 60.h),
                                  ),
                                  if(isPromotionalAnalysis)
                                  TextButton(
                                    style: const ButtonStyle(
                                        backgroundColor:
                                            WidgetStatePropertyAll(Colors.blue)
                                    ),
                                    onPressed: () async {
                                      Get.to(PromotionalAnalysisEventList(eventPromotionId: productData.id));
                                    },
                                    child: Text(
                                      'View Analytics',
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white, fontSize: 40.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).paddingAll(10.w),
                    );
                    // return FutureBuilder(
                    //     future: FirebaseFirestore.instance
                    //         .collection('EventPromotionDetail')
                    //         .where('eventPromotionId', isEqualTo: productData.id)
                    //         .get(),
                    //     builder: (context, AsyncSnapshot<QuerySnapshot> detailSnapshot) {
                    //       if(detailSnapshot.connectionState == ConnectionState.waiting){
                    //         return Offstage();
                    //       }
                    //       if(detailSnapshot.hasData){
                    //         var promotionDetail = detailSnapshot.data!.docs;
                    //         if((productData.data() as Map<String, dynamic>)['eventId'] == null){
                    //           return Offstage();
                    //         }
                    //         return FutureBuilder(
                    //           future: FirebaseFirestore.instance
                    //               .collection('Events')
                    //               .doc(productData['eventId'])
                    //               .get(),
                    //           builder: (context, AsyncSnapshot<DocumentSnapshot> eventSnapshot) {
                    //             if(eventSnapshot.connectionState == ConnectionState.waiting){
                    //               return Offstage();
                    //             }
                    //             if(eventSnapshot.hasData){
                    //               var eventData = eventSnapshot.data;
                    //               if(eventData == null){
                    //                 return Offstage();
                    //               }
                    //               return GestureDetector(
                    //                 onTap: () => Get.to(AcceptedPromoterList(
                    //                   eventPromotionId: productData.id,
                    //                 ),
                    //                 ),
                    //                 child: Column(
                    //                   mainAxisSize: MainAxisSize.min,
                    //                   children: [
                    //                     Container(
                    //                       decoration: BoxDecoration(
                    //                           borderRadius: BorderRadius.circular(20),
                    //                           color: Colors.black),
                    //                       width: Get.width,
                    //                       child: Column(
                    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                         children: [
                    //                           SizedBox(
                    //                             width: Get.width,
                    //                             child: Row(
                    //                               children: [
                    //                                 Expanded(
                    //                                   child: SizedBox(
                    //                                       child: Center(
                    //                                           child: Text(
                    //                                             '${DateFormat('dd-MM-yyyy').format(productData['dateTime'].toDate())}',
                    //                                             style: GoogleFonts.ubuntu(
                    //                                                 color: Colors.white),
                    //                                           ))),
                    //                                 ),
                    //                                 Expanded(
                    //                                   child: SizedBox(
                    //                                       child: Center(
                    //                                           child: Text(
                    //                                             eventData['title'],
                    //                                             style: GoogleFonts.ubuntu(
                    //                                                 color: Colors.white),
                    //                                           ))),
                    //                                 ),
                    //                                 Expanded(
                    //                                   child: SizedBox(
                    //                                       child: Center(
                    //                                           child: Text(
                    //                                             '${DateFormat('dd-MM-yyyy hh:mm a').format(getKeyValueFirestore(productData, 'startTime').toDate() ?? DateTime.now())} onwards',
                    //                                             style: GoogleFonts.ubuntu(
                    //                                                 color: Colors.white),
                    //                                           ))),
                    //                                 ),
                    //                                 Expanded(
                    //                                   child: SizedBox(
                    //                                       child: Center(
                    //                                         child: Column(
                    //                                             mainAxisAlignment:
                    //                                             MainAxisAlignment
                    //                                                 .spaceBetween,
                    //                                             children: [
                    //                                               if(promotionDetail.isEmpty || promotionDetail[0]['status'] == 2)
                    //                                                 GestureDetector(
                    //                                                     onTap: () => Get.to(
                    //                                                       productData['isClub']==false
                    //                                                           ? EventPromotionCreate(
                    //                                                         isOrganiser: false,
                    //                                                         isPromoter: false,
                    //                                                         isEditEvent: true,
                    //                                                         isClub: false,
                    //                                                         eventPromotionId: productData.id,
                    //                                                         eventId: productData['eventId']
                    //                                                             .toString(),
                    //                                                       )
                    //                                                           : VenuePromotionCreate(
                    //                                                         isOrganiser: false,
                    //                                                         isPromoter:false,
                    //                                                         isEditEvent:true,
                    //                                                         isClub:true,
                    //                                                         eventPromotionId:productData.id,
                    //                                                         eventId: ("data.id").toString(),
                    //                                                       ),
                    //
                    //                                                     ),
                    //                                                     child: Container(
                    //                                                       decoration: BoxDecoration(
                    //                                                         border: Border.all(
                    //                                                           color: Colors.yellow,
                    //                                                         ),
                    //                                                         borderRadius: BorderRadius.circular(20),
                    //                                                       ),
                    //                                                       child: Text(
                    //                                                         'Edit',
                    //                                                         style: GoogleFonts.ubuntu(
                    //                                                             color: Colors.white),
                    //                                                       ).paddingAll(10.0),)
                    //                                                 ).marginOnly(bottom: 20),
                    //                                               Text(
                    //                                                 promotionDetail.isEmpty
                    //                                                     ? 'Pending'
                    //                                                     : promotionDetail[0]['status'] == 2
                    //                                                     ? 'Pending'
                    //                                                     : 'Accepted',
                    //                                                 style: GoogleFonts.ubuntu(
                    //                                                     color: Colors.white),
                    //                                               )
                    //                                             ]),
                    //                                       )),
                    //                                 ),
                    //                               ],
                    //                             ).paddingSymmetric(vertical: 60.h),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ).paddingAll(10.w);
                    //             }
                    //             return Offstage();
                    //           },
                    //         );
                    //       }
                    //       return Offstage();
                    //     },
                    // );
                  },
                ),
              ]));
        }
        return Container();
      },
    );
  }
}
