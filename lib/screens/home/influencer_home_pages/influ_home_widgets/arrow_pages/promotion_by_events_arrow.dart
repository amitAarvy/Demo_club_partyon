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

import '../nightlife_categories/accepted_promotions.dart';
import '../nightlife_categories/all_promotions.dart';
import '../nightlife_categories/barter_promotions.dart';
import '../nightlife_categories/paid_promotions.dart';
import '../nightlife_categories/promotor_promotions.dart';
import '../nightlife_categories/venue_promotions.dart';

class PromotionByEventsArrow extends StatefulWidget {
  const PromotionByEventsArrow({super.key});

  @override
  State<PromotionByEventsArrow> createState() => _PromotionByEventsArrowState();
}

class _PromotionByEventsArrowState extends State<PromotionByEventsArrow> {
  List? pendingRequests;

  List tabBar = [{
    "id":"acceptPromoter",
    "name":'Accepted'
  },

    {
      "id":"allPromotion",
      "name":'All'
    },
    {
      "id":"venuePromoter",
      "name":'Venue'
    },
    {
      "id":"promoterPromotion",
      "name":'Promotor'
    },
    {
      "id":"barterPromotion",
      "name":'Barter Promotions'
    },
    {
      "id":"paidPromotion",
      "name":'Paid Promotions'
    },
  ];

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

    // Fetch all EventPromotion documents for 'influencer'
    QuerySnapshot eventPromotionSnapshot = await firestore
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'influencer')
        .get();

    List<QueryDocumentSnapshot> eventDocs = eventPromotionSnapshot.docs;

    // Filter events based on start time before fetching clubs
    List<QueryDocumentSnapshot> validEvents = eventDocs.where((element) {
      DateTime startTime = element['startTime'].toDate();
      return startTime.isAtSameMomentAs(today) || startTime.isAfter(today);
    }).toList();

    // Extract unique Club IDs
    Set<String> clubIds = validEvents.map((e) => e['clubUID'] as String).toSet();
    Map<String, dynamic> clubDataMap = {};

    // Fetch all club data in parallel
    if (clubIds.isNotEmpty) {
      List<DocumentSnapshot> clubDocs = await Future.wait(
          clubIds.map((id) => firestore.collection('Club').doc(id).get())
      );

      for (var doc in clubDocs) {
        if (doc.exists) {
          clubDataMap[doc.id] = doc.data();
        }
      }
    }

    // Process each valid event and attach club data
    List<Map<String, dynamic>> saveData = [];

    for (var event in validEvents) {
      var club = clubDataMap[event['clubUID']];
      if (club == null || (club['businessCategory'] != null && club['businessCategory'] != 1)) {
        continue; // Skip invalid clubs
      }

      saveData.add({
        ...event.data() as Map<String, dynamic>,
        'promotionId': event.id,
        'clubData': club, // Store club data directly
      });
    }

    // Fetch promotion requests in batch
    List<Future<QuerySnapshot>> promotionRequests = saveData.map((element) {
      return firestore.collection("PromotionRequest")
          .where('eventPromotionId', isEqualTo: element['promotionId'])
          .where('influencerPromotorId', isEqualTo: uid())
          .get();
    }).toList();

    List<QuerySnapshot> requestSnapshots = await Future.wait(promotionRequests);

    // Process the requests
    pendingRequests = [];
    for (int i = 0; i < saveData.length; i++) {
      QuerySnapshot reqData = requestSnapshots[i];

      if (reqData.docs.isEmpty || reqData.docs[0]['status'] != 4) {
        pendingRequests!.add({
          ...saveData[i],
          'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status'],
        });
      }
    }

    // Limit pending requests to a maximum of 4
    if (pendingRequests!.length > 4) {
      pendingRequests = pendingRequests!.sublist(0, 4);
    }

    if (!mounted) return;
    setState(() {});
  }


  ValueNotifier<String?> selectedCategory = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(context, title: "Promotion by events"),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValueListenableBuilder(
                valueListenable: selectedCategory,
                builder: (context, String? value, child) =>
              Row(
                  children: tabBar.map((e)=>
                  tabBarWidget(callBack: (){
                    selectedCategory.value = e['id'];
                  },title: e['name'],selectedColor:e['id'].toString() ==value.toString() )
                  ).toList(),
                ),
              ),
            ),

            Expanded(
              child: pendingRequests == null
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : pendingRequests!.isEmpty
                      ? const Center(
                          child: Text("No data found",
                              style: TextStyle(color: Colors.white)))
                      : ValueListenableBuilder(
                          valueListenable: selectedCategory,
                          builder: (context, String? selectCategories, child) {
                            if (selectCategories == 'paidPromotion') {
                              return const PaidPromotions();
                            }
                            if (selectCategories == 'barterPromotion') {
                              return const BarterPromotions();
                            }
                            if (selectCategories == 'promoterPromotion') {
                              return const PromotorPromotions();
                            }
                            if (selectCategories == 'venuePromoter') {
                              return const VenuePromotions();
                            }
                            if (selectCategories == 'allPromotion') {
                              return const AllPromotions();
                            }
                            if (selectCategories == 'acceptPromoter') {
                              return const AcceptedPromotions();
                            }
                            return GridView.builder(
                              gridDelegate: kIsWeb
                                  ? const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200, mainAxisExtent: 450)
                                  : const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, mainAxisExtent: 450.0),
                              itemCount: pendingRequests!.length,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                return FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('Club')
                                      .where('clubUID',
                                          isEqualTo: pendingRequests![index]
                                              ['clubUID'])
                                      .get(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> clubSnapshot) {
                                    if (clubSnapshot.hasError) {
                                      // print("dsfhhdfyhgdf1 ${productData.id}");
              
                                      return const Center(
                                        child: Text(
                                          "Error",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }
                                    if (clubSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // print("dsfhhdfyhgdf2 ${productData.id}");
              
                                      return SizedBox(
                                        height: Get.height / 5,
                                        child: const Center(
                                          child: CupertinoActivityIndicator(),
                                        ),
                                      );
                                    }
                                    if (clubSnapshot.hasData) {
                                      return GestureDetector(
                                        onTap: () {
                                          if (pendingRequests![index]['acceptedBy'] !=
                                              pendingRequests![index]
                                                  ['noOfBarterCollab']) {
                                            Get.to(PromotionDetails(
                                              type: pendingRequests![index]
                                                          ['collabType'] ==
                                                      'influencer'
                                                  ? 'venue'
                                                  : 'influencer',
                                              isOrganiser: false,
                                              isPromoter: false,
                                              isEditEvent: true,
                                              isInfluencer: true,
                                              promotionRequestId:
                                                  pendingRequests![index]
                                                      ['promotionId'],
                                              collabType: pendingRequests![index]
                                                  ['collabType'],
                                              isClub: false,
                                              eventPromotionId:
                                                  pendingRequests![index]
                                                      ['promotionId'],
                                              clubId: pendingRequests![index]
                                                  ['clubUID'],
                                            ));
                                          }
                                        },
                                        child: Container(
                                          // width: 150,
                                          margin: const EdgeInsets.symmetric(
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
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          // Divider(height: 0),
              
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                // height: 200,
                                                child: AspectRatio(
                                                  aspectRatio: 9 / 16,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(5),
                                                            topLeft:
                                                                Radius.circular(5)),
                                                    child: Image.network(
                                                      clubSnapshot.data!.docs
                                                                  .isNotEmpty &&
                                                              clubSnapshot.data!
                                                                          .docs[0][
                                                                      'coverImage'] !=
                                                                  null &&
                                                              clubSnapshot
                                                                  .data!
                                                                  .docs[0]
                                                                      ['coverImage']
                                                                  .isNotEmpty
                                                          ? clubSnapshot.data!.docs[0]
                                                              ['coverImage']
                                                          : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNdi6Gavxh_hhmb3SY4wDfn-mvdtPkvMvKKA&s",
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      loadingBuilder: (context, child,
                                                          loadingProgress) {
                                                        if (loadingProgress == null) {
                                                          return child;
                                                        }
                                                        return Center(
                                                          child: SizedBox(
                                                            height: 30,
                                                            width: 30,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              value: loadingProgress
                                                                          .expectedTotalBytes ==
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : null,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Divider(height: 0),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.stretch,
                                                  children: [
                                                    Text(
                                                      DateFormat('dd-MM-yy hh:mm a')
                                                          .format(pendingRequests![
                                                                          index]
                                                                      ['startTime']
                                                                  .toDate() ??
                                                              DateTime.now()),
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.ubuntu(
                                                        fontSize: 13.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${clubSnapshot.data!.docs.isEmpty ? '' : clubSnapshot.data!.docs[0]['clubName']} ',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.ubuntu(
                                                        fontSize: 19.0,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    if (pendingRequests![index]
                                                            ['status'] ==
                                                        2)
                                                      Text(
                                                        pendingRequests![index]
                                                                    ['status'] ==
                                                                2
                                                            ? '(In Review)'
                                                            : '',
                                                        style: GoogleFonts.ubuntu(
                                                            color: Colors.green),
                                                      ),
                                                    Text(
                                                      "${pendingRequests![index]['acceptedBy']}/${pendingRequests![index]['noOfBarterCollab']} ${pendingRequests![index]['acceptedBy'] == pendingRequests![index]['noOfBarterCollab'] ? "(Slots full)" : ''}",
                                                      style: GoogleFonts.ubuntu(
                                                          color: Colors.white),
                                                    ),
                                                    Text(
                                                      pendingRequests![index]['isPaid'] == null
                                                          ? ''
                                                          : pendingRequests![index]
                                                                  ['isPaid']
                                                              ? "Paid"
                                                              : "Barter",
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.ubuntu(
                                                        fontSize: 12.0,
                                                        color: Colors.white,
                                                      ),
                                                    )
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
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget tabBarWidget({VoidCallback? callBack,String? title,bool selectedColor=false}){
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: callBack,
      child: Container(
        height: 40,
        width: 130,
        decoration: BoxDecoration(
          color: selectedColor?Colors.orangeAccent:Colors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(11)),
          border: Border.all(color: Colors.grey.shade200)

        ),
        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
        child: Center(child: Text(title.toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white,fontSize: 12),)),

      ),
    ),
  );
}
