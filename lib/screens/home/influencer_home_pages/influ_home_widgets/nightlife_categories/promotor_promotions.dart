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

class PromotorPromotions extends StatefulWidget {
  const PromotorPromotions({super.key});

  @override
  State<PromotorPromotions> createState() => _PromotorPromotionsState();
}

class _PromotorPromotionsState extends State<PromotorPromotions> {
  List? pendingRequests;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPendingRequests();
  }

  void fetchPendingRequests() async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<Map<String, dynamic>> pendingRequests = [];

    // Fetch all EventPromotion documents for 'promotor'
    QuerySnapshot eventPromotionSnapshot = await firestore
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'promotor')
        .get();

    List<QueryDocumentSnapshot> eventDocs = eventPromotionSnapshot.docs;

    // Extract unique Club IDs
    Set<String> clubIds = eventDocs.map((e) => e['clubUID'] as String).toSet();
    Map<String, dynamic> clubDataMap = {};

    // Fetch all clubs in parallel
    if (clubIds.isNotEmpty) {
      List<DocumentSnapshot> clubDocs = await Future.wait(
          clubIds.map((id) => firestore.collection('Club').doc(id).get())
      );

      for (var doc in clubDocs) {
        clubDataMap[doc.id] = doc.data();
      }
    }

    // Process each event promotion asynchronously
    List<Future<void>> requestFutures = [];

    for (var event in eventDocs) {
      var club = clubDataMap[event['clubUID']];
      if (club == null || (club['businessCategory'] != null && club['businessCategory'] != 1)) {
        continue; // Skip invalid club data
      }

      DateTime startTime = event['startTime'].toDate();
      if (startTime.isBefore(today)) continue; // Skip past events

      requestFutures.add(_processPromotion(event, pendingRequests));
    }

    await Future.wait(requestFutures);

    print("The request statuses are: ${pendingRequests.map((e) => e['isPaid']).toList()}");

    setState(() {
      this.pendingRequests = pendingRequests;
    });
  }

  Future<void> _processPromotion(QueryDocumentSnapshot event, List<Map<String, dynamic>> pendingRequests) async {
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot reqData = await firestore.collection("InfluencerPromotionRequest")
        .where('eventPromotionId', isEqualTo: event.id)
        .where('InfluencerID', isEqualTo: uid())
        .get();

    bool isPaid = reqData.docs.isNotEmpty && (reqData.docs[0].data() as Map<String, dynamic>)['isPaid'] == true;
    int status = reqData.docs.isEmpty ? 0 : reqData.docs[0]['status'];

    if (reqData.docs.isEmpty || status != 4) {
      Map<String, dynamic> data = {
        ...event.data() as Map<String, dynamic>,
        'promotionId': event.id,
        'status': status,
        'isPaid': isPaid,
      };
      pendingRequests.add(data);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBar(context, title: "Promoter Promotions"),
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

                                    AspectRatio(
                                      aspectRatio: 16/9,
                                      child: Image.asset('assets/loading_shimmer.gif',fit: BoxFit.cover,
                                        width:
                                        double.infinity,),
                                    );

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
