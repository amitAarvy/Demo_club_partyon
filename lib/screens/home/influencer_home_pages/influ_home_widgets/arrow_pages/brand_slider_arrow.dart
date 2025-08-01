import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_slider_tap.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../brand_products_categories/brand_products_accepted_promotions.dart';
import '../brand_products_categories/brand_products_all_promotions.dart';
import '../brand_products_categories/brand_products_barter_promotion.dart';
import '../brand_products_categories/brand_products_paid_promotions.dart';

class BrandSliderArrow extends StatefulWidget {
  const BrandSliderArrow({super.key});

  @override
  State<BrandSliderArrow> createState() => _BrandSliderArrowState();
}

class _BrandSliderArrowState extends State<BrandSliderArrow> {
  List? groomingList;

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    fetchGroomingList();
  }

  void fetchGroomingList() async {
    QuerySnapshot data =
        await FirebaseFirestore.instance.collection('Club').get();
    List groomData = data.docs
        .where((element) =>
            (element.data() as Map<String, dynamic>)['businessCategory'] !=
                null &&
            element['businessCategory'] == 4)
        .toList();
    groomingList = [];
    for (var element in groomData) {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection("EventPromotion")
          .where('collabType', isEqualTo: 'influencer')
          .where("clubUID", isEqualTo: element.id)
          .get();
      List saveData = [];
      for (var element in data.docs) {
        DateTime startTime = element['startTime'].toDate();
        if ((startTime.year == DateTime.now().year &&
                startTime.month == DateTime.now().month &&
                startTime.day == DateTime.now().day) ||
            startTime.isAfter(DateTime.now())) {
          saveData.add(element);
        }
      }
      saveData.sort((a, b) => (a['startTime'].toDate() as DateTime)
          .compareTo(b['startTime'].toDate() as DateTime));
      if (data.docs.isNotEmpty) {
        groomingList = [
          ...groomingList!,
          {
            ...element.data(),
            ...{"promotionData": data.docs[0].data()}
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
      appBar: appBar(context, title: "Brands and products"),
      bottomNavigationBar: Container(
        height: 0.15.sh,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            // GestureDetector(
            //   onTap: () {
            //     Get.to(BrandProductsVenuePromotion());
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
            //     child: Column(
            //       children: [
            //         const CircleAvatar(
            //           radius: 45,
            //           backgroundImage: AssetImage("assets/venues.jpeg"),
            //         ),
            //         const SizedBox(height: 5),
            //         Text("Venue", style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white), textAlign: TextAlign.center)
            //       ],
            //     ),
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Get.to(BrandProductsPromotorPromotions());
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
            //     child: Column(
            //       children: [
            //         const CircleAvatar(
            //           radius: 45,
            //           backgroundImage: AssetImage("assets/organiser.jpeg"),
            //         ),
            //         const SizedBox(height: 5),
            //         Text("Promotor", style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white), textAlign: TextAlign.center)
            //       ],
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                selectedCategory.value = 'acceptPromotion';
                // Get.to(BrandProductsAcceptedPromotions());
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
                selectedCategory.value = 'allPromotions';
                // Get.to(BrandProductsAllPromotions());
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
                selectedCategory.value = 'barterPromotion';
                // Get.to(BrandProductsBarterPromotion());
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
                selectedCategory.value = 'paidPromotions';
                // Get.to(BrandProductsPaidPromotions());
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
                    if (selectCategories == 'acceptPromotion') {
                      return const BrandProductsAcceptedPromotions();
                    }
                    if (selectCategories == 'allPromotions') {
                      return const BrandProductsAllPromotions();
                    }
                    if (selectCategories == 'barterPromotion') {
                      return const BrandProductsBarterPromotion();
                    }
                    if (selectCategories == 'paidPromotions') {
                      return const BrandProductsPaidPromotions();
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
                                                // Text(
                                                //   groomingList![index]['promotionData']['status'] == 2 ? '(In Review)' : '',
                                                //   style: GoogleFonts.ubuntu(
                                                //       color: Colors.green),
                                                // ),
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
