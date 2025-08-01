import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/influencer_home_pages/vip_pass.dart';
import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:club/screens/organiser/event_management/promotion_detail.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ElitePassScreen extends StatefulWidget {
  const ElitePassScreen({super.key});

  @override
  State<ElitePassScreen> createState() => _ElitePassScreenState();
}

class _ElitePassScreenState extends State<ElitePassScreen> {
  // final PhylloController phylloController = Get.put(PhylloController());
  // bool isInstagramData = false;
  List? pendingRequests;

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
    // initLoadingData();
  }

  // void initLoadingData() async {
  //   phylloController.isLoading = true;
  //   isInstagramData = true;
  //   try {
  //     await PhylloController.retrieveAllProfileData();
  //     phylloController.profileData =
  //         await PhylloController.retrieveProfileData();
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: 'Error Is This: $e');
  //   } finally {
  //     phylloController.isLoading = false;
  //   }
  // }

  Future<void> fetchPendingRequests() async {
    isLoading.value = true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    pendingRequests = [];

    final firestore = FirebaseFirestore.instance;

    Future<bool> isValidClub(String clubUID) async {
      final doc = await firestore.collection('Club').doc(clubUID).get();
      final data = doc.data();
      return data == null || data['businessCategory'] == null || data['businessCategory'] == 1;
    }

    Future<List<Map<String, dynamic>>> processPromotions({
      required String collabType,
      required String requestCollection,
      required String influencerField,
    }) async {
      final promoSnap = await firestore
          .collection("EventPromotion")
          .where('collabType', isEqualTo: collabType)
          .get();
      print('check pending request is ${pendingRequests}');
      final validPromos = promoSnap.docs.where((doc) {
        final start = doc['startTime'].toDate();
        return start.isAfter(now) ||
            (start.year == today.year && start.month == today.month && start.day == today.day);
      });
      print('check pending request is ${pendingRequests}');
      final List<Future<Map<String, dynamic>?>> futures = validPromos.map((promo) async {
        final clubValid = await isValidClub(promo['clubUID']);
        if (!clubValid) return null;

        final reqSnap = await firestore
            .collection(requestCollection)
            .where('eventPromotionId', isEqualTo: promo['id'])
            .where(influencerField, isEqualTo: uid())
            .get();
        print('check pending request is ${pendingRequests}');

        if (reqSnap.docs.isEmpty || reqSnap.docs[0]['status'] != 4) return null;
        print('check pending request is ${pendingRequests}');

        final reqData = reqSnap.docs[0].data() as Map<String, dynamic>;

        if (requestCollection == "InfluencerPromotionRequest" &&
            reqData.containsKey('isPaid') &&
            reqData['isPaid'] == true) return null;

        return {
          ...promo.data(),
          'promotionId': promo.id,
          'status': reqData['status'],
          'isPaid': reqData['isPaid'] ?? false,
        };
      }).toList();

      final results = await Future.wait(futures);
      return results.whereType<Map<String, dynamic>>().toList();
    }
    print('check pending request is ${pendingRequests}');
    // Fetch both influencer and promotor requests in parallel
    final results = await Future.wait([
      processPromotions(
        collabType: 'influencer',
        requestCollection: 'PromotionRequest',
        influencerField: 'influencerPromotorId',
      ),
      processPromotions(
        collabType: 'promotor',
        requestCollection: 'InfluencerPromotionRequest',
        influencerField: 'InfluencerID',
      ),
    ]);
    print('check pending request is ${pendingRequests}');

    pendingRequests!.addAll(results.expand((e) => e));
    isLoading.value = false;
    print('check pending request is ${pendingRequests}');

    if (!mounted) return;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Elite Pass"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, bool loading, child) {
          if(loading){
            return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,));
          }
          if(pendingRequests!.isEmpty){
            return Center(
                child: Text("No data available",
                    style: TextStyle(color: Colors.white)));
          }
          return  SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                  gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 420,
                      mainAxisExtent: kIsWeb ? 340 : 320),
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
                                  isElitePass: true,
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
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                boxShadow: const [
                                  BoxShadow(
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
                                            clubSnapshot.data!
                                                .docs[0][
                                            'coverImage'] !=
                                                null &&
                                            clubSnapshot
                                                .data!
                                                .docs[0]
                                            ['coverImage']
                                                .isNotEmpty
                                            ? clubSnapshot.data!
                                            .docs[0]['coverImage']
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
                                            // Text(
                                            //   "${pendingRequests![index]['acceptedBy']}/${pendingRequests![index]['noOfBarterCollab']} ${pendingRequests![index]['acceptedBy'] == pendingRequests![index]['noOfBarterCollab'] ? "(Slots full)" : ''}",
                                            //   style: GoogleFonts.ubuntu(
                                            //       color: Colors.white),
                                            // )
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
                                            Expanded(
                                              child: Text(
                                                DateFormat(
                                                    'dd-MM-yy hh:mm a')
                                                    .format(pendingRequests![
                                                index]
                                                [
                                                'startTime']
                                                    .toDate() ??
                                                    DateTime.now()),
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Flexible(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Get.to(VipPass(
                                                      promotionData:
                                                      pendingRequests![
                                                      index]));
                                                },
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors
                                                              .white),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          5)),
                                                  child: Text(
                                                    "Generate",
                                                    style: GoogleFonts
                                                        .ubuntu(
                                                      color:
                                                      Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            // Text(
                                            //   pendingRequests![index]['isPaid'] == null ? '' : pendingRequests![index]['isPaid'] ? "Paid" : "Barter",
                                            //   style: GoogleFonts.ubuntu(
                                            //       color: Colors.white),
                                            // )
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
              ],
            ),
          );

        },

      ),
    );
  }
}
