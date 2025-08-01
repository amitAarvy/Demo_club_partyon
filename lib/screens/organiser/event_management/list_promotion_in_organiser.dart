// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/venue_promotion_create.dart';
import 'package:club/screens/organiser/event_management/promoter_page.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'promotion_detail.dart';

class PromotionListOrganiser extends StatefulWidget {
  final int status;
  final String? type;

  const PromotionListOrganiser({
    Key? key,
    required this.status, this.type,
  }) : super(key: key);

  @override
  State<PromotionListOrganiser> createState() => _PromotionListOrganiserState();
}

class _PromotionListOrganiserState extends State<PromotionListOrganiser> {
  List? pendingRequests;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPendingRequests();
  }

  void fetchPendingRequests() async{
    QuerySnapshot data = widget.status != 1
        ? await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'promotor')
        // .where('startTime', isGreaterThan: DateTime.now())
        .get()
        : await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'promotor')
        // .where('startTime', isLessThan: DateTime.now())
        .get();
    List saveData = [];
    DateTime now = DateTime.now();
    for(var element in data.docs){
      DateTime startTime = element['startTime'].toDate();
      if(widget.status != 1){
        if(widget.type.toString() == 'past'){
          if(startTime.isBefore(DateTime.now())){
            saveData.add(element);
          }
        }else
        if(startTime.isAfter(DateTime(now.year, now.month, now.day ))){
          saveData.add(element);
        }
      }else{
        if(startTime.isBefore(DateTime.now())){
          saveData.add(element);
        }
      }
    }
    pendingRequests = [];
    for(var element in saveData){
      QuerySnapshot reqData = await FirebaseFirestore.instance
          .collection("PromotionRequest")
          .where('eventPromotionId', isEqualTo: element['id'])
          .where('influencerPromotorId', isEqualTo: uid())
      // .where('status', isEqualTo: widget.status)
          .get();
      if(widget.status == 0 || widget.status == 1){
        if(reqData.docs.isEmpty || (reqData.docs.isNotEmpty && reqData.docs[0]['status'] != 4)){
          Map ele = {...element.data(), ...{'promotionId': element.id ,'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status']}};
          pendingRequests!.add(ele);
        }
      }
      if(widget.status == 4 && reqData.docs.isNotEmpty && reqData.docs[0]['status'] == 4){
        Map ele = {...element.data(), ...{'promotionId': element.id ,'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status']}};
        pendingRequests!.add(ele);
      }
    }
    log('pending request is ${pendingRequests!}');
    // pendingRequests = data.docs;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // DateTime timeNow = DateTime.now();
    // DateTime today = DateTime(timeNow.year, timeNow.month, timeNow.day);
    // DateTime tomorrow = today.add(const Duration(days: 1));
    // DateTime week = today.add(const Duration(days: 10));
    // DateTime month = today.add(const Duration(days: 30));
    // pendingRequests![index]['startTime']
    pendingRequests==null?[]:pendingRequests!.sort((a, b) => b['startTime'].toDate().compareTo(a['startTime'].toDate()));

    return pendingRequests == null
          ? const Center(child: CircularProgressIndicator())
          : pendingRequests!.isEmpty
          ? const Center(child: Text("No Event available", style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
            child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingRequests!.length,
                    itemBuilder: (context, index) {
                return FutureBuilder(
                  future:
                  FirebaseFirestore.instance
                      .collection('Club')
                      .where('clubUID', isEqualTo: pendingRequests![index]['clubUID'])
                      .get(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> clubSnapshot) {
                    if (clubSnapshot.hasError) {
                      return Center(
                        child: Text("Error", style: TextStyle(color: Colors.white),),
                      );
                    }
                    if (clubSnapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: Get.height / 5,
                        child: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    }
                    if(clubSnapshot.hasData){
                      return GestureDetector(
                        onTap: () =>
                            Get.to(PromotionDetails(
                              isOrganiser: false,
                              isPromoter: true,
                              isEditEvent: true,
                              isInfluencer: true,
                              promotionRequestId: pendingRequests![index]['promotionId'],
                              collabType: pendingRequests![index]['collabType'],
                              isClub: false,
                              eventPromotionId: pendingRequests![index]['promotionId'],
                              clubId: pendingRequests![index]['clubUID'],
                            )
                            ),
                        child: Container(
                          width: Get.width,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(1, 1),
                                  blurRadius: 5
                              )
                            ],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween,
                            children: [
                              SizedBox(
                                height: 200,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                                  child: Image.network(
                                    clubSnapshot.data!.docs.isNotEmpty && clubSnapshot.data!.docs[0]['coverImage'] != null && clubSnapshot.data!.docs[0]['coverImage'].isNotEmpty ? clubSnapshot.data!.docs[0]['coverImage'] : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNdi6Gavxh_hhmb3SY4wDfn-mvdtPkvMvKKA&s",
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if(loadingProgress == null){
                                        return child;
                                      }
                                      return Center(
                                        child: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value: loadingProgress.expectedTotalBytes == null?
                                            loadingProgress.cumulativeBytesLoaded
                                                /loadingProgress.expectedTotalBytes!
                                                :null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //     child: Center(
                              //         child: Text(
                              //           pendingRequests![index]['eventName'].isNotEmpty ?
                              //           pendingRequests![index]['eventName']
                              //           : pendingRequests![index]['collabType'] == 'influencer'
                              //           ? "Influencer Collab"
                              //               : 'Promotor Collab',
                              //           style: GoogleFonts.ubuntu(
                              //               color: Colors.white),
                              //         ))),
                              // const SizedBox(height: 10),
                              // SizedBox(
                              //     child: Center(
                              //         child: Text(
                              //           "Headline",
                              //           style: GoogleFonts.ubuntu(
                              //               color: Colors.white),
                              //         ))),
                              // const SizedBox(height: 10),
                              Divider(height: 0),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${clubSnapshot.data!.docs[0]['clubName']} ',
                                              style: GoogleFonts.ubuntu(
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              pendingRequests![index]['status'] == 2 ? '(In Review)' : '',
                                              style: GoogleFonts.ubuntu(
                                                  color: Colors.green),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${pendingRequests![index]['acceptedBy']}/${pendingRequests![index]['noOfBarterCollab']}",
                                          style: GoogleFonts.ubuntu(
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                    Divider(color: Colors.white),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Text(
                                        //   '${DateFormat('dd-MM-yy')
                                        //       .format(
                                        //       pendingRequests![index]['dateTime']
                                        //           .toDate())}',
                                        //   style: GoogleFonts.ubuntu(
                                        //       color: Colors.white),
                                        // ),
                                        Text(
                                          '${DateFormat(
                                              'dd-MM-yy hh:mm a')
                                              .format(
                                              pendingRequests![index]['startTime']
                                                  .toDate() ??
                                                  DateTime.now())}',
                                          style: GoogleFonts.ubuntu(
                                              color: Colors.white),
                                        ),
                                        Text(
                                          pendingRequests![index]['isOrganiser'] ??'',
                                          style: GoogleFonts.ubuntu(
                                              color: Colors.white),
                                        ),
                                        Text(
                                          pendingRequests![index]['isPaid'] == null ? '' : pendingRequests![index]['isPaid'] ? "Paid" : "Barter",
                                          style: GoogleFonts.ubuntu(
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //   width: Get.width,
                              //   child: Column(
                              //     children: [
                              //       Row(
                              //         children: [
                              //           Expanded(
                              //             child: SizedBox(
                              //                 child: Center(
                              //                     child: Text(
                              //                       '${DateFormat('dd-MM-yyyy')
                              //                           .format(
                              //                           productData['dateTime']
                              //                               .toDate())}',
                              //                       style: GoogleFonts.ubuntu(
                              //                           color: Colors.white),
                              //                     ))),
                              //           ),
                              //           Expanded(
                              //             child: SizedBox(
                              //                 child: Center(
                              //                     child: Text(
                              //                       getKeyValueFirestore(
                              //                           productData, 'name') ??
                              //                           'Loading',
                              //                       style: GoogleFonts.ubuntu(
                              //                           color: Colors.white),
                              //                     ))),
                              //           ),
                              //           Expanded(
                              //             child: SizedBox(
                              //                 child: Center(
                              //                     child: Text(
                              //                       '${DateFormat(
                              //                           'dd-MM-yyyy hh:mm a')
                              //                           .format(
                              //                           getKeyValueFirestore(
                              //                               productData,
                              //                               'startTime')
                              //                               .toDate() ??
                              //                               DateTime.now())}',
                              //                       style: GoogleFonts.ubuntu(
                              //                           color: Colors.white),
                              //                     ))),
                              //           ),
                              //           Expanded(
                              //             child: SizedBox(
                              //                 child: Center(
                              //                   child: Column(
                              //                       mainAxisAlignment:
                              //                       MainAxisAlignment
                              //                           .spaceBetween,
                              //                       children: [
                              //                         ElevatedButton(
                              //                           onPressed: () async {
                              //                             try {
                              //                               FirebaseFirestore.instance
                              //                                   .collection("EventPromotionDetail")
                              //                                   .where('eventPromotionId', isEqualTo: productData.id)
                              //                                   .where('promoterId', isEqualTo: uid())
                              //                                   .get()
                              //                                   .then((
                              //                                   doc) async {
                              //                                 if (doc
                              //                                     .docs
                              //                                     .isNotEmpty) {
                              //                                   Get
                              //                                       .defaultDialog(
                              //                                       title: "Status",
                              //                                       content: Column(
                              //                                         mainAxisAlignment:
                              //                                         MainAxisAlignment
                              //                                             .center,
                              //                                         children: [
                              //                                           Column(
                              //                                             children: [
                              //                                               Text(
                              //                                                   "Pending"),
                              //                                             ],
                              //                                           ),
                              //                                         ],
                              //                                       ));
                              //                                   print(
                              //                                       'uydsfgyudfhgyudgfdh ${getKeyValueFirestore(
                              //                                           doc.docs
                              //                                               .first,
                              //                                           'status') ??
                              //                                           ''}');
                              //                                 } else {
                              //                                   Get
                              //                                       .defaultDialog(
                              //                                       title: "Status",
                              //                                       content: Column(
                              //                                         mainAxisAlignment:
                              //                                         MainAxisAlignment
                              //                                             .center,
                              //                                         children: [
                              //                                           Column(
                              //                                             children: [
                              //                                               GestureDetector(
                              //                                                 onTap: () =>
                              //                                                     Get
                              //                                                         .to(
                              //                                                         PromotionDetails(
                              //                                                           isOrganiser:
                              //                                                           false,
                              //                                                           isPromoter:
                              //                                                           false,
                              //                                                           isEditEvent:
                              //                                                           true,
                              //                                                           isClub:
                              //                                                           productData["isClub"],
                              //                                                           eventPromotionId:
                              //                                                           productData
                              //                                                               .id,
                              //                                                           clubId:
                              //                                                           productData["clubUID"],
                              //                                                         )),
                              //                                                 child: Text(
                              //                                                     "Apply Now"),
                              //                                               )
                              //                                             ],
                              //                                           ),
                              //                                         ],
                              //                                       ));
                              //                                   print(
                              //                                       'uydsfgyudfhgyudgfdh noooooooo');
                              //                                 }
                              //                               });
                              //                             } catch (e) {
                              //                               print(e);
                              //                               Fluttertoast
                              //                                   .showToast(
                              //                                   msg:
                              //                                   'Something Went Wrong');
                              //                             }
                              //                           },
                              //                           style: ButtonStyle(
                              //                               shape: WidgetStateProperty
                              //                                   .all<
                              //                                   RoundedRectangleBorder>(
                              //                                   RoundedRectangleBorder(
                              //                                       borderRadius:
                              //                                       BorderRadius
                              //                                           .circular(
                              //                                           10.0),
                              //                                       side: const BorderSide(
                              //                                           color: Colors
                              //                                               .grey))),
                              //                               backgroundColor:
                              //                               WidgetStateProperty
                              //                                   .resolveWith(
                              //                                       (states) =>
                              //                                   Colors.black)),
                              //                           child: Text(
                              //                             "View",
                              //                             style: GoogleFonts
                              //                                 .ubuntu(
                              //                               color: Colors
                              //                                   .orange,
                              //                             ),
                              //                           ),
                              //                         ),
                              //                       ]),
                              //                 )),
                              //           ),
                              //         ],
                              //       ).paddingSymmetric(vertical: 60.h),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ).paddingAll(10.w);
                    }
                    return const Offstage();
                  },
                );
                     },
                  ),
          );;
  }
}
