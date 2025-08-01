import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/arrow_pages/promotion_by_events_arrow.dart';
import 'package:club/screens/organiser/event_management/promotion_detail.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PromotionByEvents extends StatefulWidget {
  final List pendingRequests;
  final List club;
  const PromotionByEvents({super.key, required this.pendingRequests, required this.club});

  @override
  State<PromotionByEvents> createState() => _PromotionByEventsState();
}

class _PromotionByEventsState extends State<PromotionByEvents> {
  // List? pendingRequests;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('club list is ${widget.club}');
    // fetchPendingRequests();
  }

  // void fetchPendingRequests() async {
  //   QuerySnapshot data = await FirebaseFirestore.instance
  //       .collection("EventPromotion")
  //       .where('collabType', isEqualTo: 'influencer')
  //       .get();
  //   List saveData = [];
  //   for (var element in data.docs) {
  //     DocumentSnapshot club = await FirebaseFirestore.instance
  //         .collection('Club')
  //         .doc(element['clubUID'])
  //         .get();
  //     if (club.data() != null &&
  //         ((club.data() as Map<String, dynamic>)['businessCategory'] == null ||
  //             club['businessCategory'] == 1)) {
  //       DateTime startTime = element['startTime'].toDate();
  //       if ((startTime.year == DateTime.now().year &&
  //               startTime.month == DateTime.now().month &&
  //               startTime.day == DateTime.now().day) ||
  //           startTime.isAfter(DateTime.now())) {
  //         saveData.add(element);
  //       }
  //     }
  //   }
  //   List<Map<dynamic, dynamic>> pendingRequestsList = [];
  //   for (var element in saveData) {
  //     QuerySnapshot reqData = await FirebaseFirestore.instance
  //         .collection("PromotionRequest")
  //         .where('eventPromotionId', isEqualTo: element['id'])
  //         .where('influencerPromotorId', isEqualTo: uid())
  //         // .where('status', isEqualTo: widget.status)
  //         .get();
  //     if (reqData.docs.isEmpty ||
  //         (reqData.docs.isNotEmpty && reqData.docs[0]['status'] != 4)) {
  //       Map ele = {
  //         ...element.data(),
  //         ...{
  //           'promotionId': element.id,
  //           'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status']
  //         }
  //       };
  //       pendingRequestsList.add(ele);
  //     }
  //   }
  //   pendingRequestsList = pendingRequestsList.sublist(
  //       0, pendingRequestsList.length <= 4 ? pendingRequestsList.length : 4);
  //   if (mounted) {
  //     setState(() {
  //       pendingRequests = pendingRequestsList;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return widget.pendingRequests == null
        ? const Center(child: CircularProgressIndicator())
        : widget.pendingRequests!.isEmpty
            ? const Offstage()
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Promotion by events",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        InkWell(
                          onTap: () {
                            Get.to(PromotionByEventsArrow());
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.orange),
                            child: Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 15),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 400,
                      child: widget.pendingRequests == null
                          ? const Center(child: CircularProgressIndicator())
                          : widget.pendingRequests!.isEmpty
                              ? const Center(
                                  child: Text("No data available",
                                      style: TextStyle(color: Colors.white)))
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: widget.pendingRequests.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      List clubSnapshot = widget.club.where((e)=>e.id.toString() == widget.pendingRequests![index]
                                      ['clubUID'].toString()).toList();
                                      print('check club list is ${clubSnapshot}');
                                      return GestureDetector(
                                        onTap: () {
                                          if (widget.pendingRequests[index]['acceptedBy'] != widget.pendingRequests[index]['noOfBarterCollab']) {
                                            Get.to(PromotionDetails(
                                              type: widget.pendingRequests[
                                              index][
                                              'collabType'] ==
                                                  'influencer'
                                                  ? 'venue'
                                                  : 'influencer',
                                              isOrganiser: false,
                                              isPromoter: false,
                                              isEditEvent: true,
                                              isInfluencer: true,
                                              promotionRequestId:
                                              widget.pendingRequests[index]['promotionId'],
                                              collabType:
                                              widget.pendingRequests[index]['collabType'],
                                              isClub: false,
                                              eventPromotionId:
                                              widget.pendingRequests[index]['promotionId'],
                                              clubId:
                                              widget.pendingRequests[index]['clubUID'],
                                            ));
                                          }
                                        },
                                        child: Container(
                                          width: 150,
                                          margin:
                                          const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //       color: Colors.white,
                                            //       offset: Offset(1, 1),
                                            //       blurRadius: 5
                                            //   )
                                            // ],
                                            borderRadius:
                                            BorderRadius.circular(5),
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                // height: 200,
                                                child: AspectRatio(
                                                  aspectRatio: 9 / 16,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                    const BorderRadius.only(
                                                        topRight: Radius
                                                            .circular(
                                                            5),
                                                        topLeft: Radius
                                                            .circular(
                                                            5)),
                                                    child: Image.network(
                                                      clubSnapshot
                                                          [0]
                                                          [
                                                          'coverImage'] !=
                                                              null &&
                                                          clubSnapshot[0]['coverImage']
                                                              .isNotEmpty
                                                          ? clubSnapshot[0]
                                                      [
                                                      'coverImage']
                                                          : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNdi6Gavxh_hhmb3SY4wDfn-mvdtPkvMvKKA&s",
                                                      fit: BoxFit.cover,
                                                      width:
                                                      double.infinity,
                                                      loadingBuilder:
                                                          (context, child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) {
                                                          return child;
                                                        }
                                                        return Center(
                                                          child:
                                                          AspectRatio(
                                                            aspectRatio: 9/16,
                                                            child: Image.asset('assets/loading_shimmer.gif',fit: BoxFit.cover,
                                                              width:
                                                              double.infinity,),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Divider(height: 0),
                                              Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .stretch,
                                                  children: [
                                                    Text(
                                                      DateFormat(
                                                          'dd-MM-yy hh:mm a')
                                                          .format(widget.pendingRequests![index]
                                                      [
                                                      'startTime']
                                                          .toDate() ??
                                                          DateTime
                                                              .now()),
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      style: GoogleFonts
                                                          .ubuntu(
                                                        fontSize: 13.0,
                                                        color:
                                                        Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${clubSnapshot.isEmpty ? '' : clubSnapshot[0]['clubName']} ',
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      style: GoogleFonts
                                                          .ubuntu(
                                                        fontSize: 19.0,
                                                        color:
                                                        Colors.white,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                      ),
                                                    ),
                                                    if (widget.pendingRequests![
                                                    index]
                                                    ['status'] ==
                                                        2)
                                                      Text(
                                                        widget.pendingRequests![
                                                        index]
                                                        [
                                                        'status'] ==
                                                            2
                                                            ? '(In Review)'
                                                            : '',
                                                        style: GoogleFonts
                                                            .ubuntu(
                                                            color: Colors
                                                                .green),
                                                      ),
                                                    Text(
                                                      "${widget.pendingRequests[index]['acceptedBy']}/${widget.pendingRequests![index]['noOfBarterCollab']} ${widget.pendingRequests![index]['acceptedBy'] == widget.pendingRequests![index]['noOfBarterCollab'] ? "(Slots full)" : ''}",
                                                      style: GoogleFonts
                                                          .ubuntu(
                                                          color: Colors
                                                              .white),
                                                    ),
                                                    Text(
                                                      widget.pendingRequests[
                                                      index]
                                                      [
                                                      'isPaid'] ==
                                                          null
                                                          ? ''
                                                          : widget.pendingRequests[
                                                      index]
                                                      [
                                                      'isPaid']
                                                          ? "Paid"
                                                          : "Barter",
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      style: GoogleFonts
                                                          .ubuntu(
                                                        fontSize: 12.0,
                                                        color:
                                                        Colors.white,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ).paddingAll(10.w);

                                      //   FutureBuilder(
                                      //   future: FirebaseFirestore.instance
                                      //       .collection('Club')
                                      //       .where('clubUID',
                                      //           isEqualTo:
                                      //           widget.pendingRequests[index]
                                      //                   ['clubUID'])
                                      //       .get(),
                                      //   builder: (context,
                                      //       AsyncSnapshot<QuerySnapshot>
                                      //           clubSnapshot) {
                                      //     if (clubSnapshot.hasError) {
                                      //       // print("dsfhhdfyhgdf1 ${productData.id}");
                                      //
                                      //       return const Center(
                                      //         child: Text(
                                      //           "Error",
                                      //           style: TextStyle(
                                      //               color: Colors.white),
                                      //         ),
                                      //       );
                                      //     }
                                      //     if (clubSnapshot.connectionState ==
                                      //         ConnectionState.waiting) {
                                      //       // print("dsfhhdfyhgdf2 ${productData.id}");
                                      //
                                      //       return SizedBox(
                                      //         height: Get.height / 5,
                                      //         child: const Center(
                                      //           child:
                                      //               CircularProgressIndicator(),
                                      //         ),
                                      //       );
                                      //     }
                                      //     if (clubSnapshot.hasData) {
                                      //       return GestureDetector(
                                      //         onTap: () {
                                      //           if (widget.pendingRequests[index]['acceptedBy'] != widget.pendingRequests[index]['noOfBarterCollab']) {
                                      //             Get.to(PromotionDetails(
                                      //               type: widget.pendingRequests[
                                      //                               index][
                                      //                           'collabType'] ==
                                      //                       'influencer'
                                      //                   ? 'venue'
                                      //                   : 'influencer',
                                      //               isOrganiser: false,
                                      //               isPromoter: false,
                                      //               isEditEvent: true,
                                      //               isInfluencer: true,
                                      //               promotionRequestId:
                                      //               widget.pendingRequests[index]['promotionId'],
                                      //               collabType:
                                      //               widget.pendingRequests[index]['collabType'],
                                      //               isClub: false,
                                      //               eventPromotionId:
                                      //               widget.pendingRequests[index]['promotionId'],
                                      //               clubId:
                                      //               widget.pendingRequests[index]['clubUID'],
                                      //             ));
                                      //           }
                                      //         },
                                      //         child: Container(
                                      //           width: 150,
                                      //           margin:
                                      //               const EdgeInsets.symmetric(
                                      //                   horizontal: 5),
                                      //           decoration: BoxDecoration(
                                      //             color: Colors.black,
                                      //             // boxShadow: [
                                      //             //   BoxShadow(
                                      //             //       color: Colors.white,
                                      //             //       offset: Offset(1, 1),
                                      //             //       blurRadius: 5
                                      //             //   )
                                      //             // ],
                                      //             borderRadius:
                                      //                 BorderRadius.circular(5),
                                      //           ),
                                      //           child: Column(
                                      //             children: [
                                      //               SizedBox(
                                      //                 // height: 200,
                                      //                 child: AspectRatio(
                                      //                   aspectRatio: 9 / 16,
                                      //                   child: ClipRRect(
                                      //                     borderRadius:
                                      //                         const BorderRadius.only(
                                      //                             topRight: Radius
                                      //                                 .circular(
                                      //                                     5),
                                      //                             topLeft: Radius
                                      //                                 .circular(
                                      //                                     5)),
                                      //                     child: Image.network(
                                      //                       clubSnapshot
                                      //                                   .data!
                                      //                                   .docs
                                      //                                   .isNotEmpty &&
                                      //                               clubSnapshot.data!.docs[0]
                                      //                                       [
                                      //                                       'coverImage'] !=
                                      //                                   null &&
                                      //                               clubSnapshot
                                      //                                   .data!
                                      //                                   .docs[0]
                                      //                                       [
                                      //                                       'coverImage']
                                      //                                   .isNotEmpty
                                      //                           ? clubSnapshot
                                      //                                   .data!
                                      //                                   .docs[0]
                                      //                               [
                                      //                               'coverImage']
                                      //                           : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNdi6Gavxh_hhmb3SY4wDfn-mvdtPkvMvKKA&s",
                                      //                       fit: BoxFit.cover,
                                      //                       width:
                                      //                           double.infinity,
                                      //                       loadingBuilder:
                                      //                           (context, child,
                                      //                               loadingProgress) {
                                      //                         if (loadingProgress ==
                                      //                             null) {
                                      //                           return child;
                                      //                         }
                                      //                         return Center(
                                      //                           child:
                                      //                           SizedBox(
                                      //                             height: 30,
                                      //                             width: 30,
                                      //                             child:Image.asset('assets/loading_shimmer.gif')
                                      //                             // CircularProgressIndicator(
                                      //                             //   strokeWidth:
                                      //                             //       2,
                                      //                             //   value: loadingProgress.expectedTotalBytes ==
                                      //                             //           null
                                      //                             //       ? loadingProgress.cumulativeBytesLoaded /
                                      //                             //           loadingProgress.expectedTotalBytes!
                                      //                             //       : null,
                                      //                             // ),
                                      //                           ),
                                      //                         );
                                      //                       },
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //               // Divider(height: 0),
                                      //               Padding(
                                      //                 padding:
                                      //                     const EdgeInsets.all(
                                      //                         8.0),
                                      //                 child: Column(
                                      //                   crossAxisAlignment:
                                      //                       CrossAxisAlignment
                                      //                           .stretch,
                                      //                   children: [
                                      //                     Text(
                                      //                       DateFormat(
                                      //                               'dd-MM-yy hh:mm a')
                                      //                           .format(widget.pendingRequests![index]
                                      //                                       [
                                      //                                       'startTime']
                                      //                                   .toDate() ??
                                      //                               DateTime
                                      //                                   .now()),
                                      //                       overflow:
                                      //                           TextOverflow
                                      //                               .ellipsis,
                                      //                       style: GoogleFonts
                                      //                           .ubuntu(
                                      //                         fontSize: 13.0,
                                      //                         color:
                                      //                             Colors.white,
                                      //                       ),
                                      //                     ),
                                      //                     Text(
                                      //                       '${clubSnapshot.data!.docs.isEmpty ? '' : clubSnapshot.data!.docs[0]['clubName']} ',
                                      //                       overflow:
                                      //                           TextOverflow
                                      //                               .ellipsis,
                                      //                       style: GoogleFonts
                                      //                           .ubuntu(
                                      //                         fontSize: 19.0,
                                      //                         color:
                                      //                             Colors.white,
                                      //                         fontWeight:
                                      //                             FontWeight
                                      //                                 .w600,
                                      //                       ),
                                      //                     ),
                                      //                     if (widget.pendingRequests![
                                      //                                 index]
                                      //                             ['status'] ==
                                      //                         2)
                                      //                       Text(
                                      //                         widget.pendingRequests![
                                      //                                         index]
                                      //                                     [
                                      //                                     'status'] ==
                                      //                                 2
                                      //                             ? '(In Review)'
                                      //                             : '',
                                      //                         style: GoogleFonts
                                      //                             .ubuntu(
                                      //                                 color: Colors
                                      //                                     .green),
                                      //                       ),
                                      //                     Text(
                                      //                       "${widget.pendingRequests![index]['acceptedBy']}/${widget.pendingRequests![index]['noOfBarterCollab']} ${widget.pendingRequests![index]['acceptedBy'] == widget.pendingRequests![index]['noOfBarterCollab'] ? "(Slots full)" : ''}",
                                      //                       style: GoogleFonts
                                      //                           .ubuntu(
                                      //                               color: Colors
                                      //                                   .white),
                                      //                     ),
                                      //                     Text(
                                      //                       widget.pendingRequests![
                                      //                                       index]
                                      //                                   [
                                      //                                   'isPaid'] ==
                                      //                               null
                                      //                           ? ''
                                      //                           : widget.pendingRequests![
                                      //                                       index]
                                      //                                   [
                                      //                                   'isPaid']
                                      //                               ? "Paid"
                                      //                               : "Barter",
                                      //                       overflow:
                                      //                           TextOverflow
                                      //                               .ellipsis,
                                      //                       style: GoogleFonts
                                      //                           .ubuntu(
                                      //                         fontSize: 12.0,
                                      //                         color:
                                      //                             Colors.white,
                                      //                       ),
                                      //                     )
                                      //                   ],
                                      //                 ),
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       ).paddingAll(10.w);
                                      //     }
                                      //     return const Offstage();
                                      //   },
                                      // );
                                    },
                                  ),
                                ),
                    ),
                  ],
                ),
              );
  }
}
