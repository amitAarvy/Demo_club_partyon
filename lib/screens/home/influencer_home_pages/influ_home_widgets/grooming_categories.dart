import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_accepted_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_all_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_barter_promotion.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_paid_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_promotor_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_venue_promotion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class GroomingCategories extends StatefulWidget {
  const GroomingCategories({super.key});

  @override
  State<GroomingCategories> createState() => _GroomingCategoriesState();
}

class _GroomingCategoriesState extends State<GroomingCategories> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.purple, width: 0.5),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                    ""
                    "Grooming Categories",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                    onTap: () {
                      Get.to(const GroomingAllPromotions());
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.red,
                    ))
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                // GestureDetector(
                //   onTap: () {
                //     Get.to(GroomingVenuePromotion());
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
                //     Get.to(GroomingPromotorPromotions());
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
                    Get.to(const GroomingBarterPromotion());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
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
                    Get.to(const GroomingPaidPromotions());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
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
                GestureDetector(
                  onTap: () {
                    Get.to(const GroomingAllPromotions());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
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
                    Get.to(const GroomingAcceptedPromotions());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
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
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
