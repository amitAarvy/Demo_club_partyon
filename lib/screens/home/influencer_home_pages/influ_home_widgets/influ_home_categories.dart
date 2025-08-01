import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/nightlife_categories/accepted_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/nightlife_categories/all_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/nightlife_categories/barter_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/nightlife_categories/paid_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/nightlife_categories/promotor_promotions.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home_widgets/nightlife_categories/venue_promotions.dart';
import 'package:club/screens/home/influencer_pages/influencer_requests.dart';
import 'package:club/screens/home/influencer_pages/influencer_tabs.dart';
import 'package:club/screens/home/influencer_pages/pending_request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class InfluHomeCategories extends StatefulWidget {
  const InfluHomeCategories({super.key});

  @override
  State<InfluHomeCategories> createState() => _InfluHomeCategoriesState();
}

class _InfluHomeCategoriesState extends State<InfluHomeCategories> {
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
            const Text("Nightlife Categories", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(VenuePromotions());
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
                        child: Center(child: Text("Venue", style: GoogleFonts.ubuntu(fontSize: 13, color: Colors.white), textAlign: TextAlign.center)),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(PromotorPromotions());
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
                        child: Center(child: Text("Promotor", style: GoogleFonts.ubuntu(fontSize: 13, color: Colors.white), textAlign: TextAlign.center)),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(BarterPromotions());
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
                      Get.to(PaidPromotions());
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
                      Get.to(AllPromotions());
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
                      Get.to(AcceptedPromotions());
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
