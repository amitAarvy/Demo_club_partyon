import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/influencer_pages/influencer_tabs.dart';
import 'package:club/screens/home/influencer_pages/pending_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class InfluencerRequest extends StatefulWidget {
  const InfluencerRequest({super.key});

  @override
  State<InfluencerRequest> createState() => _InfluencerRequestState();
}

class _InfluencerRequestState extends State<InfluencerRequest> with SingleTickerProviderStateMixin {

  final c = Get.put(HomeController());

  late TabController tabController;

  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(220.h),
        child: AppBar(
          automaticallyImplyLeading: true,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          backgroundColor: Colors.black,
          shadowColor: Colors.grey,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "PartyOn",
                    style: GoogleFonts.dancingScript(
                      color: Colors.red,
                      fontSize: 70.sp,
                    ),
                  ),
                ],
              ),
              // SizedBox(
              //   width: 400.w,
              // ),
              SizedBox(
                width: 300.w,
                child: Obx(() => Text(
                  c.clubName.value.capitalizeFirst.toString(),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.dancingScript(
                      color: Colors.white, fontSize: 70.sp),
                  overflow: TextOverflow.ellipsis,
                )),
              )
            ],
          ),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: "List"),
              Tab(text: "Accepted"),
              Tab(text: "Past"),
            ],
          ),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        // initialIndex: currentIndex,
        child: TabBarView(
          controller: tabController,
          children: const [
            InfluencerTabs(key: ValueKey("Pending"), status: 0),
            InfluencerTabs(key: ValueKey("Accepted"), status: 4),
            InfluencerTabs(key: ValueKey("Declined"), status: 1),
          ],
        )
      ),
    );
  }
}

