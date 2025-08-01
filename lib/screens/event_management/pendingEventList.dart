import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/event_and_promotor_detail.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/event_management/event_management.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingEventList extends StatefulWidget {
  final bool isOrganiser;
  final bool isPendingRequest;

  const PendingEventList(
      {Key? key, this.isOrganiser = false, this.isPendingRequest = false})
      : super(key: key);

  @override
  State<PendingEventList> createState() => _PendingEventListState();
}

class _PendingEventListState extends State<PendingEventList> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final homeController = Get.put(HomeController());

  Widget eventCard(
      {required int index,
        required DocumentSnapshot data,
        required DateTime date,
        DocumentSnapshot? organiserDetail}){
    print('organiser id is${data['organiserID']}');
    // if(widget.isOrganiser){
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Organiser')
          .doc(data['organiserID'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error loading data", style: GoogleFonts.ubuntu(color: Colors.white)));
        }

        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
          return Center(child: Text("No data available", style: GoogleFonts.ubuntu(color: Colors.white)));
        }

        // Extracting data safely
        var dataOrganiser = snapshot.data!.data() as Map<String, dynamic>;

        return GestureDetector(
          onTap:(){
            Navigator.push(context, MaterialPageRoute(builder: (context) => EventAndPromotorDetail(data: data.data() as Map<String, dynamic>, dataId: data.id)));
          },
          child: SizedBox(
            width: Get.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 0.3.sw,
                  height: 0.2.sh,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: dataOrganiser['profile_image'] ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
                SizedBox(width: 10,),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (dataOrganiser["companyMame"] ?? "Unknown").toString().capitalizeFirstOfEach,
                        style: GoogleFonts.ubuntu(
                          color: Colors.white, fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (dataOrganiser["address"] ?? "").toString().capitalizeFirstOfEach,
                        style: GoogleFonts.ubuntu(
                          color: Colors.white, fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${ (dataOrganiser["city"] ?? "").toString().capitalizeFirstOfEach},',
                            style: GoogleFonts.ubuntu(
                              color: Colors.white, fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (dataOrganiser["state"] ?? "").toString().capitalizeFirstOfEach,
                            style: GoogleFonts.ubuntu(
                              color: Colors.white, fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: 20, vertical: 2)),
                                  backgroundColor:
                                  WidgetStateProperty
                                      .resolveWith(
                                          (states) =>
                                      Colors
                                          .green)),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('Events')
                                    .doc(data.id)
                                    .set(
                                    {
                                      'isActive':
                                      true,
                                      'status': 'A',
                                    },
                                    SetOptions(
                                        merge: true))
                                    .whenComplete(() =>
                                    FirebaseFirestore
                                        .instance
                                        .collection(
                                        "Club")
                                        .doc(uid())
                                        .set(
                                        {
                                          "eventCover": data['cover']
                                              .isNotEmpty
                                              ? (data['cover']
                                          [0])
                                              : "",
                                          'eventStartTime':
                                          data[
                                          'startTime'],
                                          'eventEndTime':
                                          data[
                                          'endTime'],
                                        },
                                        SetOptions(
                                            merge:
                                            true)))
                                    .whenComplete(() {
                                  setState(() {});
                                });
                              },
                              child:
                              const Text('Accept')),
                          ElevatedButton(
                              style: ButtonStyle(
                                  padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: 20, vertical: 2)),
                                  backgroundColor:
                                  WidgetStateProperty
                                      .resolveWith(
                                          (states) =>
                                      Colors
                                          .red)),
                              onPressed: () {
                                FirebaseFirestore
                                    .instance
                                    .collection(
                                    'Events')
                                    .doc(data.id)
                                    .set(
                                  {
                                    'isActive': false,
                                    'status': 'D',
                                  },
                                  SetOptions(
                                      merge: true),
                                ).whenComplete(() {
                                  setState(() {});
                                });
                              },
                              child: const Text(
                                  'Reject'))
                              .paddingSymmetric(
                              horizontal: 50.w),
                        ],
                      )

                    ],
                  ),
                ),
                // Expanded(
                //   child: SizedBox(
                //     child: Center(
                //       child: Text(
                //         "${date.day}-${date.month}-${date.year}",
                //         style: GoogleFonts.ubuntu(color: Colors.white),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ).paddingSymmetric(vertical: 60.h),
          ),
        );
      },
    );



    // DocumentSnapshot promotor = await FirebaseFirestore.instance
    //     .collection('Organiser')
    //     .doc(widget.data['organiserID'])
    //     .get();

    //   SizedBox(
    //   width: Get.width,
    //   child: Row(
    //     // children: [
    //     //   Expanded(
    //     //     child: SizedBox(
    //     //         child: Center(
    //     //             child: CachedNetworkImage(
    //     //               imageUrl: data[''],
    //     //               fit: BoxFit.fill,
    //     //             ))),
    //     //   ),
    //       Expanded(
    //         child: SizedBox(
    //             child: Center(
    //                 child: Text(
    //                   "${data["title"]}".toString().capitalizeFirstOfEach,
    //                   style: GoogleFonts.ubuntu(
    //                       color: Colors.white, fontWeight: FontWeight.bold),
    //                 ))),
    //       ),
    //       Expanded(
    //         child: SizedBox(
    //             child: Center(
    //                 child: Text(
    //                   "${date.day}-${date.month}-${date.year}",
    //                   style: GoogleFonts.ubuntu(color: Colors.white),
    //                 ))),
    //       ),
    //     ],
    //   ).paddingSymmetric(vertical: 60.h),
    // );
    // }
    // return SizedBox(
    //   width: Get.width,
    //   child: Row(
    //     children: [
    //       // Expanded(
    //       //   child: SizedBox(
    //       //       child: Center(
    //       //           child: CachedNetworkImage(
    //       //             imageUrl: data[''],
    //       //             fit: BoxFit.fill,
    //       //           ))),
    //       // ),
    //       Expanded(
    //         child: SizedBox(
    //             child: Center(
    //                 child: Text(
    //                   "${data["title"]}".toString().capitalizeFirstOfEach,
    //                   style: GoogleFonts.ubuntu(
    //                       color: Colors.white, fontWeight: FontWeight.bold),
    //                 ))),
    //       ),
    //       Expanded(
    //         child: SizedBox(
    //             child: Center(
    //                 child: Text(
    //                   "${date.day}-${date.month}-${date.year}",
    //                   style: GoogleFonts.ubuntu(color: Colors.white),
    //                 ))),
    //       ),
    //     ],
    //   ).paddingSymmetric(vertical: 60.h),
    // );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: appBar(context, title: "Organiser Event", key: _key),
      drawer: drawer(isOrganiser: widget.isOrganiser,context: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SizedBox(
            //   height: 50.h,
            // ),
            FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("Events")
                    .where(widget.isOrganiser ? 'organiserID' : 'clubUID',
                    isEqualTo: uid())
                    .orderBy('date', descending: true)
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (kDebugMode) {
                    print(uid());
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
                            "No events found",
                            style:
                            TextStyle(color: Colors.white, fontSize: 70.sp),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          try {
                            DocumentSnapshot data = (snapshot.data?.docs[index])
                            as DocumentSnapshot;
                            // print(data);
                            DateTime date =
                            getKeyValueFirestore(data, 'date').toDate();
                            bool isPending =
                                getKeyValueFirestore(data, 'status') == 'P';
                            bool isDeclined =
                                getKeyValueFirestore(data, 'status') == 'D';
                            String clubUID =
                                getKeyValueFirestore(data, 'clubUID') ?? '';
                            return GestureDetector(
                              onTap: () {
                                // if (widget.isOrganiser
                                //     ? (!isPending && !isDfeclined && isActive)
                                //     : true) {
                                if (!widget.isPendingRequest) {
                                  Get.to(EventManagement(
                                    isEditEvent: true,
                                    eventId: data.id,
                                    isOrganiser: widget.isOrganiser,
                                    clubUID: clubUID,
                                  ));
                                }
                                //  }
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black),
                                    width: Get.width,
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (!widget.isPendingRequest &&
                                            !widget.isOrganiser &&
                                            !isPending)
                                          eventCard(
                                              index: index,
                                              data: data,
                                              date: date),
                                        if (widget.isPendingRequest &&
                                            isPending)
                                          eventCard(
                                              index: index,
                                              data: data,
                                              date: date),
                                        if (widget.isOrganiser)
                                          eventCard(
                                              index: index,
                                              data: data,
                                              date: date),
                                        Column(children: [
                                          // if (isPending &&
                                          //     !widget.isOrganiser &&
                                          //     widget.isPendingRequest)
                                          //   Row(
                                          //     mainAxisAlignment:
                                          //         MainAxisAlignment.end,
                                          //     children: [
                                          //       TextButton(
                                          //         onPressed: () {
                                          //           Navigator.push(context, MaterialPageRoute(builder: (context) => EventAndPromotorDetail(data: data.data() as Map<String, dynamic>, dataId: data.id)));
                                          //         },
                                          //         child: Text(
                                          //           'Click for details',
                                          //           style: TextStyle(
                                          //               decoration:
                                          //                   TextDecoration
                                          //                       .underline,
                                          //               decorationColor:
                                          //                   Colors.orange,
                                          //               fontSize: 40.sp,
                                          //               color: Colors.white),
                                          //         ),
                                          //       ).paddingSymmetric(
                                          //           horizontal: 30.w),
                                          //       ElevatedButton(
                                          //           style: ButtonStyle(
                                          //             padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: 20, vertical: 2)),
                                          //               backgroundColor:
                                          //                   WidgetStateProperty
                                          //                       .resolveWith(
                                          //                           (states) =>
                                          //                               Colors
                                          //                                   .green)),
                                          //           onPressed: () {
                                          //             FirebaseFirestore.instance
                                          //                 .collection('Events')
                                          //                 .doc(data.id)
                                          //                 .set(
                                          //                     {
                                          //                       'isActive':
                                          //                           true,
                                          //                       'status': 'A',
                                          //                     },
                                          //                     SetOptions(
                                          //                         merge: true))
                                          //                 .whenComplete(() =>
                                          //                     FirebaseFirestore
                                          //                         .instance
                                          //                         .collection(
                                          //                             "Club")
                                          //                         .doc(uid())
                                          //                         .set(
                                          //                             {
                                          //                           "eventCover": data['cover']
                                          //                                   .isNotEmpty
                                          //                               ? (data['cover']
                                          //                                   [0])
                                          //                               : "",
                                          //                           'eventStartTime':
                                          //                               data[
                                          //                                   'startTime'],
                                          //                           'eventEndTime':
                                          //                               data[
                                          //                                   'endTime'],
                                          //                         },
                                          //                             SetOptions(
                                          //                                 merge:
                                          //                                     true)))
                                          //                 .whenComplete(() {
                                          //                   setState(() {});
                                          //                 });
                                          //           },
                                          //           child:
                                          //               const Text('Accept')),
                                          //       ElevatedButton(
                                          //               style: ButtonStyle(
                                          //                   padding: WidgetStateProperty.resolveWith((states) => EdgeInsets.symmetric(horizontal: 20, vertical: 2)),
                                          //                   backgroundColor:
                                          //                       WidgetStateProperty
                                          //                           .resolveWith(
                                          //                               (states) =>
                                          //                                   Colors
                                          //                                       .red)),
                                          //               onPressed: () {
                                          //                 FirebaseFirestore
                                          //                     .instance
                                          //                     .collection(
                                          //                         'Events')
                                          //                     .doc(data.id)
                                          //                     .set(
                                          //                   {
                                          //                     'isActive': false,
                                          //                     'status': 'D',
                                          //                   },
                                          //                   SetOptions(
                                          //                       merge: true),
                                          //                 ).whenComplete(() {
                                          //                   setState(() {});
                                          //                 });
                                          //               },
                                          //               child: const Text(
                                          //                   'Reject'))
                                          //           .paddingSymmetric(
                                          //               horizontal: 50.w),
                                          //     ],
                                          //   )
                                          // else
                                          if (isDeclined)
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              children: [
                                                const Text('Declined')
                                                    .paddingSymmetric(
                                                    vertical: 30.h,
                                                    horizontal: 30.w)
                                              ],
                                            ),
                                          if (widget.isOrganiser)
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              children: [
                                                if (isPending)
                                                  Text(
                                                    'Waiting for Approval',
                                                    style: GoogleFonts.ubuntu(
                                                      color: Colors.amber,
                                                    ),
                                                  ).paddingSymmetric(
                                                      vertical: 30.h,
                                                      horizontal: 30.w)
                                                else if (isDeclined)
                                                  Text(
                                                    'Declined by club',
                                                    style: GoogleFonts.ubuntu(
                                                        color: Colors.red),
                                                  ).paddingSymmetric(
                                                      vertical: 30.h,
                                                      horizontal: 30.w)
                                              ],
                                            ),
                                        ])
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ).paddingSymmetric(horizontal: 30.w, vertical: 5);
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
