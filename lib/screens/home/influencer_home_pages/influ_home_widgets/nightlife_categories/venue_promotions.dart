import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/organiser/event_management/promotion_detail.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class VenuePromotions extends StatefulWidget {
  const VenuePromotions({super.key});

  @override
  State<VenuePromotions> createState() => _VenuePromotionsState();
}

class _VenuePromotionsState extends State<VenuePromotions> {
  List? pendingRequests;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPendingRequests();
  }
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void fetchPendingRequests() async {
    final now = DateTime.now();

    QuerySnapshot<Map<String, dynamic>> eventData = await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'influencer')
        .get();

    List<Map<String, dynamic>> tempList = [];

    List<Future<void>> futures = [];

    for (var event in eventData.docs) {
      futures.add(FirebaseFirestore.instance
          .collection('Club')
          .doc(event['clubUID'])
          .get()
          .then((clubSnapshot) async {
        if (clubSnapshot.exists) {
          var clubData = clubSnapshot.data();
          if (clubData == null || clubData['businessCategory'] == null || clubData['businessCategory'] == 1) {
            DateTime startTime = event['startTime'].toDate();
            if (isSameDay(startTime, now) || startTime.isAfter(now)) {
              QuerySnapshot reqData = await FirebaseFirestore.instance
                  .collection("PromotionRequest")
                  .where('eventPromotionId', isEqualTo: event.id)
                  .where('influencerPromotorId', isEqualTo: uid())
                  .get();

              if (reqData.docs.isEmpty || reqData.docs.first['status'] != 4) {
                tempList.add({
                  ...event.data(),
                  'promotionId': event.id,
                  'status': reqData.docs.isEmpty ? 0 : reqData.docs.first['status']
                });
              }
            }
          }
        }
      }));
    }

    await Future.wait(futures);

    setState(() {
      pendingRequests = tempList;
    });

    print("Pending requests: ${pendingRequests!.map((e) => e['isPaid']).toList()}");
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBar(context, title: "Venue Promotions"),
      backgroundColor: Colors.black,
      body: pendingRequests == null
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent,))
          : pendingRequests!.isEmpty
          ? const Center(child: Text("No Event available", style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 400, mainAxisExtent: kIsWeb ? 320 : 300),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingRequests!.length,
          itemBuilder: (context, index) {
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Club')
                  .where('clubUID', isEqualTo: pendingRequests![index]['clubUID'])
                  .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> clubSnapshot) {
                if (clubSnapshot.hasError) {
                  // print("dsfhhdfyhgdf1 ${productData.id}");

                  return Center(
                    child: Text("Error", style: TextStyle(color: Colors.white),),
                  );
                }
                if (clubSnapshot.connectionState == ConnectionState.waiting) {
                  // print("dsfhhdfyhgdf2 ${productData.id}");

                  return Container(
                    height: Get.height / 5,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                }
                if(clubSnapshot.hasData){
                  return GestureDetector(
                    onTap: () {
                      if(pendingRequests![index]['acceptedBy'] != pendingRequests![index]['noOfBarterCollab']){
                        Get.to(PromotionDetails(
                          type: pendingRequests![index]['collabType'] == 'influencer' ? 'venue' : 'influencer',
                          isOrganiser: false,
                          isPromoter: false,
                          isEditEvent: true,
                          isInfluencer: true,
                          promotionRequestId: pendingRequests![index]['promotionId'],
                          collabType: pendingRequests![index]['collabType'],
                          isClub: false,
                          eventPromotionId: pendingRequests![index]['promotionId'],
                          clubId: pendingRequests![index]['clubUID'],
                        ));
                      }
                    },
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
                                  return
                                    Center(
                                      child: AspectRatio(
                                        aspectRatio: 16/9,
                                        child: Image.asset('assets/loading_shimmer.gif',fit: BoxFit.cover,
                                          width:
                                          double.infinity,),
                                      ),

                                    );
                                  //   Center(
                                  //   child: SizedBox(
                                  //     height: 30,
                                  //     width: 30,
                                  //     child: CircularProgressIndicator(
                                  //       strokeWidth: 2,
                                  //       value: loadingProgress.expectedTotalBytes == null?
                                  //       loadingProgress.cumulativeBytesLoaded
                                  //           /loadingProgress.expectedTotalBytes!
                                  //           :null,
                                  //     ),
                                  //   ),
                                  // );
                                },
                              ),
                            ),
                          ),
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
                                          '${clubSnapshot.data!.docs.isEmpty ? '' : clubSnapshot.data!.docs[0]['clubName']} ',
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
                                      "${pendingRequests![index]['acceptedBy']}/${pendingRequests![index]['noOfBarterCollab']} ${pendingRequests![index]['acceptedBy'] == pendingRequests![index]['noOfBarterCollab'] ? "(Slots full)" : ''}",
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
                                      pendingRequests![index]['isPaid'] == null ? '' : pendingRequests![index]['isPaid'] ? "Paid" : "Barter",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
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
      ),
    );
  }
}
