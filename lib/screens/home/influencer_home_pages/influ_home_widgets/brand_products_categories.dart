import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/brand_products_categories/brand_products_accepted_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/brand_products_categories/brand_products_all_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/brand_products_categories/brand_products_barter_promotion.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/brand_products_categories/brand_products_paid_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/brand_products_categories/brand_products_promotor_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/brand_products_categories/brand_products_venue_promotion.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_accepted_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_all_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_barter_promotion.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_paid_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_promotor_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/grooming_categories/grooming_venue_promotion.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/travel_categories/travel_accepted_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/travel_categories/travel_all_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/travel_categories/travel_barter_promotion.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/travel_categories/travel_paid_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/travel_categories/travel_promotor_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/travel_categories/travel_venue_promotion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandProductsCategories extends StatefulWidget {
  const BrandProductsCategories({super.key});

  @override
  State<BrandProductsCategories> createState() => _BrandProductsCategoriesState();
}

class _BrandProductsCategoriesState extends State<BrandProductsCategories> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.purple, width: 0.5),
            borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Brand & Products Categories", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: [
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
                        Get.to(BrandProductsBarterPromotion());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            border: Border.all(color: Color(0xff00FF00))
                          ),
                          // backgroundImage: NetworkImage("https://thumbs.dreamstime.com/b/bright-holographic-wall-night-club-ready-party-blurred-background-music-promotion-backgroun-323327742.jpg"),
                          child: Center(child: Text("Barter Promotions", style: GoogleFonts.ubuntu(fontSize: 13, color: Colors.white), textAlign: TextAlign.center)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(BrandProductsPaidPromotions());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(color: Color(0xff00FF00))
                          ),
                          // backgroundImage: NetworkImage("https://thumbs.dreamstime.com/b/bright-holographic-wall-night-club-ready-party-blurred-background-music-promotion-backgroun-323327742.jpg"),
                          child: Center(child: Text("Paid Promotions", style: GoogleFonts.ubuntu(fontSize: 13, color: Colors.white), textAlign: TextAlign.center)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(BrandProductsAllPromotions());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(color: Color(0xff00FF00))
                          ),
                          // backgroundImage: NetworkImage("https://thumbs.dreamstime.com/b/bright-holographic-wall-night-club-ready-party-blurred-background-music-promotion-backgroun-323327742.jpg"),
                          child: Center(child: Text("All", style: GoogleFonts.ubuntu(fontSize: 13, color: Colors.white), textAlign: TextAlign.center)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(BrandProductsAcceptedPromotions());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              border: Border.all(color: Color(0xff00FF00))
                          ),
                          // backgroundImage: NetworkImage("https://thumbs.dreamstime.com/b/bright-holographic-wall-night-club-ready-party-blurred-background-music-promotion-backgroun-323327742.jpg"),
                          child: Center(child: Text("Accepted", style: GoogleFonts.ubuntu(fontSize: 13, color: Colors.white), textAlign: TextAlign.center)),
                        ),
                      ),
                    ),
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}
