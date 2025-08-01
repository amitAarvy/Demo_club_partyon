import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/event_management/event_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchClubDetails extends StatefulWidget {
  final String? clubUID, title;

  const SearchClubDetails(this.clubUID, this.title, {Key? key})
      : super(key: key);

  @override
  State<SearchClubDetails> createState() => _SearchClubDetailsState();
}

class _SearchClubDetailsState extends State<SearchClubDetails> {
  final List<String> galleryImages = [];
  dynamic location, opening, closing, averageCost;
  bool isLoading = true;

  @override
  void initState() {
    getData();

    super.initState();
  }

  Future<void> getData() async {
    await FirebaseFirestore.instance
        .collection("Club")
        .doc(widget.clubUID)
        .get()
        .then((value) {
      try {
        if (value.exists) {
          List data = [];
          if (value.get("galleryImages").isNotEmpty) {
            data = value.get("galleryImages");
          } else {
            data = [value.get("coverImage")];
          }
          for (var i in data) {
            galleryImages.add(i);
          }
          setState(() {
            location =
                "${value['city'] ?? 'N.A.'}, ${value["state"] ?? 'N.A.'}";
            opening = "${value['openTime'] ?? 'N.A'} A.M.";
            closing = "${value['closeTime'] ?? 'N.A'} P.M";
            averageCost = "${value['averageCost'] ?? 'N.A'} cost for two.";
          });
        }
      } catch (e) {
        setState(() {
          location = "N.A.";
          opening = "N.A.";
          closing = "N.A.";
          averageCost = "N.A.";
        });
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: matte(),
      appBar: appBar(context, title: widget.title.toString()),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: isLoading
            ? SizedBox(
                width: Get.width,
                height: Get.height - 300.h,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                ),
              )
            : Column(
                children: [
                  SizedBox(
                    height: 50.h,
                  ),
                  CarouselSlider(
                      items: galleryImages
                          .map((item) => Container(
                                height: 800.h,
                                width: Get.width,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: item,
                                      placeholder: (_, __) => const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => Center(
                                        child: Container(
                                          height: 800.h,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Text(
                                            galleryImages.isEmpty
                                                ? 'No Images found'
                                                : 'No cover Image Found',
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.white,
                                                fontSize: 60.sp),
                                          ),
                                        ),
                                      ),
                                      fit: BoxFit.fill,
                                    )),
                              ).marginAll(5.w))
                          .toList(),
                      options: CarouselOptions(
                        height: 800.h,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.85,
                        initialPage: 0,
                        reverse: false,
                        autoPlay: false,
                        enableInfiniteScroll: false,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      )).paddingOnly(bottom: 50.h),
                  Column(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          width: Get.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              aboutDetails(
                                  "assets/location.png", "Location", location),
                              aboutDetails(
                                  "assets/open.png", "Opening Timing", opening),
                              aboutDetails("assets/close.png", "Closing Timing",
                                  closing),
                              aboutDetails("assets/cost.png", "Average Cost",
                                  averageCost),
                              aboutDetails("assets/menu.png", "Menu",
                                  "Click here to view"),
                            ],
                          )).marginAll(50.h),
                    ],
                  )
                ],
              ),
      ),
      floatingActionButton: SizedBox(
          width: 350.w,
          child: FloatingActionButton(
            backgroundColor: Colors.orange,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onPressed: () => Get.to(EventManagement(
              isOrganiser: true,
              clubUID: widget.clubUID.toString(),
            )),
            child: Text(
              'Create Event',
              style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold),
            ),
          )),
    );
  }
}

Widget aboutDetails(String assets, String title, String content) => Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 100.h,
          width: 100.h,
          child: Image.asset(
            assets,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(
          width: 50.w,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ).marginAll(10.w),
            Text(
              content,
              style: GoogleFonts.ubuntu(
                color: Colors.white70,
              ),
            ).marginAll(10.w),
          ],
        ),
      ],
    ).marginOnly(bottom: 30.w, top: 30.w, left: 10.w);
