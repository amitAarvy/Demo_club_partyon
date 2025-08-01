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

import 'grooming_accepted_promotions.dart';
import 'grooming_barter_promotion.dart';
import 'grooming_paid_promotions.dart';

class GroomingAllPromotions extends StatefulWidget {
  const GroomingAllPromotions({super.key});

  @override
  State<GroomingAllPromotions> createState() => _GroomingAllPromotionsState();
}

class _GroomingAllPromotionsState extends State<GroomingAllPromotions> {
  List? pendingRequests;

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    fetchPendingRequests();
  }

  int empty = 0;

  void fetchPendingRequests() async {
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'influencer')
// .where('startTime', isLessThan: DateTime.now())
        .get();
    List saveData = [];
    for (var element in data.docs) {
      DocumentSnapshot club = await FirebaseFirestore.instance
          .collection('Club')
          .doc(element['clubUID'])
          .get();
      if (club.data() != null &&
          (club.data() as Map<String, dynamic>)['businessCategory'] != null &&
          club['businessCategory'] == 3) {
        DateTime startTime = element['startTime'].toDate();
        if ((startTime.year == DateTime.now().year &&
                startTime.month == DateTime.now().month &&
                startTime.day == DateTime.now().day) ||
            startTime.isAfter(DateTime.now())) {
          saveData.add(element);
        }
      }
    }
    pendingRequests = [];
    for (var element in saveData) {
      QuerySnapshot reqData = await FirebaseFirestore.instance
          .collection("PromotionRequest")
          .where('eventPromotionId', isEqualTo: element['id'])
          .where('influencerPromotorId', isEqualTo: uid())
// .where('status', isEqualTo: widget.status)
          .get();
      if (reqData.docs.isEmpty ||
          (reqData.docs.isNotEmpty && reqData.docs[0]['status'] != 4)) {
        Map ele = {
          ...element.data(),
          ...{
            'promotionId': element.id,
            'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status']
          }
        };
        pendingRequests!.add(ele);
      }
    }
    QuerySnapshot data2 = await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'promotor')
// .where('startTime', isLessThan: DateTime.now())
        .get();
    List saveData2 = [];
    for (var element in data2.docs) {
      DocumentSnapshot club = await FirebaseFirestore.instance
          .collection('Club')
          .doc(element['clubUID'])
          .get();
      if (club.data() != null &&
          (club.data() as Map<String, dynamic>)['businessCategory'] != null &&
          club['businessCategory'] == 3) {
        DateTime startTime = element['startTime'].toDate();
        if ((startTime.year == DateTime.now().year &&
                startTime.month == DateTime.now().month &&
                startTime.day == DateTime.now().day) ||
            startTime.isAfter(DateTime.now())) {
          saveData2.add(element);
        }
      }
    }
    for (var element in saveData2) {
      QuerySnapshot reqData = await FirebaseFirestore.instance
          .collection("InfluencerPromotionRequest")
          .where('eventPromotionId', isEqualTo: element['id'])
          .where('InfluencerID', isEqualTo: uid())
// .where('status', isEqualTo: widget.status)
          .get();
      if (reqData.docs.isEmpty ||
          (reqData.docs.isNotEmpty && reqData.docs[0]['status'] != 4)) {
        Map ele = {
          ...element.data(),
          ...{
            'promotionId': element.id,
            'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status'],
            "isPaid": reqData.docs.isEmpty
                ? false
                : (reqData.docs[0].data() as Map<String, dynamic>)['isPaid'] ??
                    false
          }
        };
        pendingRequests!.add(ele);
      }
    }
    print(
        "teh request are : ${pendingRequests!.map((e) => e['isPaid']).toList()}");
// pendingRequests = data.docs;
    setState(() {});
  }

  ValueNotifier<String> selectCategory = ValueNotifier('all');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "All Promotions"),
      // appBar: appBar(context, title: "All Promotions"),
      backgroundColor: Colors.black,
      bottomNavigationBar: Container(
        height: 0.3.sh,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ValueListenableBuilder(
            valueListenable: selectCategory,
            builder: (context, selected, child) => Row(children: [
              GestureDetector(
                onTap: () {
                  selectCategory.value = 'all';
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected == 'all'
                            ? const Color(0xff00FF00)
                            : Colors.black,
                        border: Border.all(color: const Color(0xff00FF00))),
                    // backgroundImage: NetworkImage("https://thumbs.dreamstime.com/b/bright-holographic-wall-night-club-ready-party-blurred-background-music-promotion-backgroun-323327742.jpg"),
                    child: Center(
                        child: Text("All",
                            style: GoogleFonts.ubuntu(
                                fontSize: 13, color: Colors.white),
                            textAlign: TextAlign.center)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  selectCategory.value = 'barter';
                  // Get.to(GroomingBarterPromotion());
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected == 'barter'
                            ? const Color(0xff00FF00)
                            : Colors.black,
                        border: Border.all(color: const Color(0xff00FF00))),
                    // backgroundImage: NetworkImage("https://thumbs.dreamstime.com/b/bright-holographic-wall-night-club-ready-party-blurred-background-music-promotion-backgroun-323327742.jpg"),
                    child: Center(
                        child: Text("Barter Promotions",
                            style: GoogleFonts.ubuntu(
                                fontSize: 13, color: Colors.white),
                            textAlign: TextAlign.center)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  selectCategory.value = 'paidPromoter';
                  // Get.to(GroomingPaidPromotions());
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected == 'paidPromoter'
                            ? const Color(0xff00FF00)
                            : Colors.black,
                        border: Border.all(color: const Color(0xff00FF00))),
                    // backgroundImage: NetworkImage("https://thumbs.dreamstime.com/b/bright-holographic-wall-night-club-ready-party-blurred-background-music-promotion-backgroun-323327742.jpg"),
                    child: Center(
                        child: Text("Paid Promotions",
                            style: GoogleFonts.ubuntu(
                                fontSize: 13, color: Colors.white),
                            textAlign: TextAlign.center)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  selectCategory.value = 'acceptPromoter';

                  // Get.to(GroomingAcceptedPromotions());
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected == 'acceptPromoter'
                            ? const Color(0xff00FF00)
                            : Colors.black,
                        border: Border.all(color: const Color(0xff00FF00))),
                    // backgroundImage: NetworkImage("https://thumbs.dreamstime.com/b/bright-holographic-wall-night-club-ready-party-blurred-background-music-promotion-backgroun-323327742.jpg"),
                    child: Center(
                        child: Text("Accepted",
                            style: GoogleFonts.ubuntu(
                                fontSize: 13, color: Colors.white),
                            textAlign: TextAlign.center)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
      body: pendingRequests == null
          ? const Center(child: CircularProgressIndicator())
          : pendingRequests!.isEmpty
              ? const Center(
                  child: Text("No Event available",
                      style: TextStyle(color: Colors.white)))
              : ValueListenableBuilder(
                  valueListenable: selectCategory,
                  builder: (context, selected, child) {
                    if (selected == 'acceptPromoter') {
                      return const GroomingAcceptedPromotions();
                    }
                    if (selected == 'paidPromoter') {
                      return const GroomingPaidPromotions();
                    }
                    if (selected == 'barter') {
                      return const GroomingBarterPromotion();
                    }
                    return SingleChildScrollView(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                mainAxisExtent: kIsWeb ? 320 : 300),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pendingRequests!.length,
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

                                return Container(
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
                                    width: Get.width,
                                    margin: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      boxShadow: [
                                        const BoxShadow(
                                            color: Colors.white,
                                            offset: Offset(1, 1),
                                            blurRadius: 5)
                                      ],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          height: 200,
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
                                                      clubSnapshot.data!.docs[0]
                                                              ['coverImage'] !=
                                                          null &&
                                                      clubSnapshot
                                                          .data!
                                                          .docs[0]['coverImage']
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
                                        const Divider(height: 0),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '${clubSnapshot.data!.docs.isEmpty ? '' : clubSnapshot.data!.docs[0]['clubName']} ',
                                                        style:
                                                            GoogleFonts.ubuntu(
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                      Text(
                                                        pendingRequests![index][
                                                                    'status'] ==
                                                                2
                                                            ? '(In Review)'
                                                            : '',
                                                        style:
                                                            GoogleFonts.ubuntu(
                                                                color: Colors
                                                                    .green),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "${pendingRequests![index]['acceptedBy']}/${pendingRequests![index]['noOfBarterCollab']} ${pendingRequests![index]['acceptedBy'] == pendingRequests![index]['noOfBarterCollab'] ? "(Slots full)" : ''}",
                                                    style: GoogleFonts.ubuntu(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              const Divider(
                                                  color: Colors.white),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                    DateFormat(
                                                            'dd-MM-yy hh:mm a')
                                                        .format(pendingRequests![
                                                                        index][
                                                                    'startTime']
                                                                .toDate() ??
                                                            DateTime.now()),
                                                    style: GoogleFonts.ubuntu(
                                                        color: Colors.white),
                                                  ),
                                                  Text(
                                                    pendingRequests![index]
                                                                ['isPaid'] ==
                                                            null
                                                        ? ''
                                                        : pendingRequests![
                                                                index]['isPaid']
                                                            ? "Paid"
                                                            : "Barter",
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
                    );
                  },
                ),
    );
  }
}
