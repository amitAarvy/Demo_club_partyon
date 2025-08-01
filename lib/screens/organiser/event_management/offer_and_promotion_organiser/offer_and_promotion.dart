import 'package:club/screens/event_management/promotion_offers_home.dart';
import 'package:club/screens/event_management/venue_tabs.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/list_promotor_influencer_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../coupon_code/view/presentation/coupon_code_view.dart';
import 'coupon_code_view_organiser.dart';


class OffersAndPromotionsOrganiser extends StatefulWidget {
  const OffersAndPromotionsOrganiser({super.key});

  @override
  State<OffersAndPromotionsOrganiser> createState() => _OffersAndPromotionsOrganiserState();
}

class _OffersAndPromotionsOrganiserState extends State<OffersAndPromotionsOrganiser>
    with SingleTickerProviderStateMixin {
  final HomeController homeController = Get.put(HomeController());
  late TabController controller;

  String? businessCategory;

  @override
  void initState() {
    super.initState();
    setBusinessCategory();
  }

  setBusinessCategory() async {
    // businessCategory =
    // await const FlutterSecureStorage().read(key: "businessCategory");
    // if(businessCategory == "1"){
    //   controller = TabController(length: 3, vsync: this);
    // }else{
    controller = TabController(length: 3, vsync: this);
    // }
    setState(() {});
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
              // SizedBox(
              //   width: 400.w,
              // ),
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
              // if (businessCategory == "1")
                const Tab(text: "Offers"),
              // if (businessCategory == "1")
                const Tab(text: "Event"),
              // if (businessCategory != "1")
              //   Tab(
              //       text: businessCategory == "1"
              //           ? "Venue"
              //           : "Influencer Collab's"),
              const Tab(text: "List"),
            ],
          ),
          backgroundColor: Colors.black,
          shadowColor: Colors.grey,
        ),
      ),
      body:
      // businessCategory == null
      //     ? Center(child: const CircularProgressIndicator())
      //     :
      DefaultTabController(
        length:  3 ,
        child: TabBarView(
          controller: controller,
          children: [
            // if (businessCategory == "1")
              const CouponCodeViewOrganiser(),
            // if (businessCategory == "1")
              const PromotionOfferHome(isOrganiser: true),
            // if (businessCategory != "1")
            //   VenueTabs(businessCategory: businessCategory!),
            const ListPromoterInfluencerTabs(isOrganiser: 'true',),
          ],
        ),
      ),
    );
  }
}
