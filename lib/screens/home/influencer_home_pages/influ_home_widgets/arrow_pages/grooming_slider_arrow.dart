import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_slider_tap.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../grooming_categories/grooming_accepted_promotions.dart';
import '../grooming_categories/grooming_all_promotions.dart';
import '../grooming_categories/grooming_barter_promotion.dart';
import '../grooming_categories/grooming_paid_promotions.dart';

class GroomingSliderArrow extends StatefulWidget {
  const GroomingSliderArrow({super.key});

  @override
  State<GroomingSliderArrow> createState() => _GroomingSliderArrowState();
}

class _GroomingSliderArrowState extends State<GroomingSliderArrow> {
  List<Map<String, dynamic>>? groomingList;

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    fetchGroomingList();
  }

  void fetchGroomingList() async {
    QuerySnapshot clubsData =
        await FirebaseFirestore.instance.collection('Club').get();
    List groomData = clubsData.docs
        .where((element) =>
            (element.data() as Map<String, dynamic>)['businessCategory'] !=
                null &&
            element['businessCategory'] == 3)
        .toList();
    groomingList = [];
    for (var element in groomData) {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection("EventPromotion")
          .where('collabType', isEqualTo: 'influencer')
          .where("clubUID", isEqualTo: element.id)
          .get();
      List saveData = [];
      for (var ele in data.docs) {
        QuerySnapshot reqData = await FirebaseFirestore.instance
            .collection("PromotionRequest")
            .where('eventPromotionId', isEqualTo: ele['id'])
            .where('influencerPromotorId', isEqualTo: uid())
            .get();
        if (reqData.docs.isEmpty ||
            (reqData.docs.isNotEmpty && reqData.docs[0]['status'] != 4)) {
          DateTime startTime = ele['startTime'].toDate();
          if ((startTime.year == DateTime.now().year &&
                  startTime.month == DateTime.now().month &&
                  startTime.day == DateTime.now().day) ||
              startTime.isAfter(DateTime.now())) {
            saveData.add(ele);
          }
        }
      }
      saveData.sort((a, b) => (a['startTime'].toDate() as DateTime)
          .compareTo(b['startTime'].toDate() as DateTime));
      if (saveData.isNotEmpty) {
        groomingList = [
          ...groomingList!,
          {
            ...element.data(),
            ...{"promotionData": saveData[0].data()}
          }
        ];
      }
    }
    setState(() {});
  }

  ValueNotifier<String?> selectedCategory = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Grooming Industry"),
      bottomNavigationBar: Container(
        height: 0.15.sh,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            GestureDetector(
              onTap: () {
                selectedCategory.value = 'acceptPromotions';

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
                      color: Colors.black,
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
            GestureDetector(
              onTap: () {
                selectedCategory.value = 'allPromotion';

                // Get.to(GroomingAllPromotions());
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
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
                selectedCategory.value = 'barter';
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
                      color: Colors.black,
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
                selectedCategory.value = 'paidPromoter';

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
                      color: Colors.black,
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
          ]),
        ),
      ),
      body: groomingList == null
          ? const Center(child: CircularProgressIndicator())
          : groomingList!.isEmpty
              ? const Center(
                  child: Text("No Event available",
                      style: TextStyle(color: Colors.white)))
              : ValueListenableBuilder(
                  valueListenable: selectedCategory,
                  builder: (context, String? selectCategories, child) {
                    if (selectCategories == 'paidPromoter') {
                      return const GroomingPaidPromotions();
                    }
                    if (selectCategories == 'barter') {
                      return const GroomingBarterPromotion();
                    }
                    if (selectCategories == 'allPromotion') {
                      return const GroomingAllPromotions();
                    }
                    if (selectCategories == 'acceptPromotions') {
                      return const GroomingAcceptedPromotions();
                    }
                    return SingleChildScrollView(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                mainAxisExtent: kIsWeb ? 320 : 300),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: groomingList!.length,
                        padding: const EdgeInsets.all(10),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Get.to(GroomingSliderTap(
                                  clubUid: groomingList![index]['clubUID']));
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.white,
                                      offset: Offset(1, 1),
                                      blurRadius: 5)
                                ],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  // alignment: Alignment.bottomCenter,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        groomingList![index]['coverImage'],
                                        fit: BoxFit.fill,
                                        height: 170,
                                        width: double.infinity,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.image_outlined,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '${groomingList![index]['clubName']} ',
                                                    style: GoogleFonts.ubuntu(
                                                        color: Colors.white),
                                                  ),
                                                  // Text(
                                                  //   groomingList![index]['promotionData']['status'] == 2 ? '(In Review)' : '',
                                                  //   style: GoogleFonts.ubuntu(
                                                  //       color: Colors.green),
                                                  // ),
                                                ],
                                              ),
                                              Text(
                                                "${groomingList![index]['promotionData']['acceptedBy']}/${groomingList![index]['promotionData']['noOfBarterCollab']} ${groomingList![index]['promotionData']['acceptedBy'] == groomingList![index]['promotionData']['noOfBarterCollab'] ? "(Slots full)" : ''}",
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                          const Divider(color: Colors.white),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                DateFormat('dd-MM-yy hh:mm a')
                                                    .format(groomingList![index]
                                                                    [
                                                                    'promotionData']
                                                                ['startTime']
                                                            .toDate() ??
                                                        DateTime.now()),
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                groomingList![index][
                                                                'promotionData']
                                                            ['isPaid'] ==
                                                        null
                                                    ? ''
                                                    : groomingList![index][
                                                                'promotionData']
                                                            ['isPaid']
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
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
