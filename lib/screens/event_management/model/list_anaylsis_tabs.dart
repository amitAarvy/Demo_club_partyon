import 'package:club/screens/event_management/promotion_list.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../venueAnalysis/venue_analysis.dart';

class ListAnalysisTabs extends StatefulWidget {
  const ListAnalysisTabs({super.key});

  @override
  State<ListAnalysisTabs> createState() => ListAnalysisTabsState();
}

class ListAnalysisTabsState extends State<ListAnalysisTabs>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  final HomeController homeController = Get.put(HomeController());
  late TabController controller;

  String? businessCategory;

  @override
  void initState() {
    super.initState();
    setBusinessCategory();
  }

  setBusinessCategory() async {
    businessCategory =
        await const FlutterSecureStorage().read(key: "businessCategory");
    print(businessCategory);
    controller = TabController(length: 3, vsync: this);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: businessCategory == null
          ? null
          : PreferredSize(
              preferredSize: Size.fromHeight(220.h),
              child: AppBar(
                automaticallyImplyLeading: true,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "PartyOn",
                      style: GoogleFonts.dancingScript(
                        color: Colors.red,
                        fontSize: 70.sp,
                      ),
                    ),
                    SizedBox(
                      width: 300.w,
                      child: Obx(() => Text(
                            homeController.clubName.value.capitalizeFirst
                                .toString(),
                            textAlign: TextAlign.end,
                            style: GoogleFonts.dancingScript(
                                color: Colors.white, fontSize: 70.sp),
                            overflow: TextOverflow.ellipsis,
                          )),
                    )
                  ],
                ),
                bottom: TabBar(
                  controller: controller,
                  indicatorColor: Colors.white,
                  tabs: [
                    if (businessCategory != "1")
                      Tab(
                          text: businessCategory == "1"
                              ? "Venue"
                              : "Influencer Collab's"),
                    const Tab(text: "Promotional Analysis Event List"),
                  ],
                ),
                backgroundColor: Colors.black,
                shadowColor: Colors.grey,
              ),
            ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 0;
                      });
                    },
                    child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: currentIndex == 0
                              ? Colors.yellow.withOpacity(0.4)
                              : Colors.transparent,
                        ),
                        child: const Text(
                          "Promoter Collab's",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 1;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: currentIndex == 1
                              ? Colors.yellow.withOpacity(0.4)
                              : Colors.transparent,
                        ),
                        child: const Text(
                          "Influencer Collab's",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = 2;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: currentIndex == 2
                              ? Colors.yellow.withOpacity(0.4)
                              : Colors.transparent,
                        ),
                        child: const Text(
                          "Past Event",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                ],
              ),
            ),
          ),
          if (currentIndex == 0)
            Expanded(
              key: ValueKey(currentIndex),
              child: const VenueAnalysis(collabType: "promotor"),
            ),
          if (currentIndex == 1)
            Expanded(
              key: ValueKey(currentIndex),
              child: const PromotionList(collabType: "influencer", isPromotionalAnalysis: true,),
            ),
          if (currentIndex == 2)
            Expanded(
              key: ValueKey(currentIndex),
              child: const VenueAnalysis(collabType: "total", isPromotionalAnalysis: true,),
            ),
        ],
      ),
    );
  }
}
