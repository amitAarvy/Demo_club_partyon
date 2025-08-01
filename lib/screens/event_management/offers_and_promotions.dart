import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/promotion_offers_home.dart';
import 'package:club/screens/event_management/venue_tabs.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/list_promotor_influencer_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_utils.dart';
import '../coupon_code/view/presentation/coupon_code_view.dart';

class OffersAndPromotions extends StatefulWidget {
  const OffersAndPromotions({super.key});

  @override
  State<OffersAndPromotions> createState() => _OffersAndPromotionsState();
}

class _OffersAndPromotionsState extends State<OffersAndPromotions>
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
    businessCategory =
        await const FlutterSecureStorage().read(key: "businessCategory");
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
      appBar: businessCategory == null
          ? null
          : PreferredSize(
              preferredSize: Size.fromHeight(220.h),
              child:StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('PromotionRequest').where('venueId',isEqualTo: uid()).snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    int notificationCount = 0;
    if (snapshot.hasError) {
    notificationCount = 0;
    // return Center(child: Text('Error: ${snapshot.error}'));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
        notificationCount = 0;
    // return Center(child: CircularProgressIndicator());
    }
        notificationCount = snapshot.data == null
        ? 0
        : snapshot.data!.docs
          .where((doc) {
            var data1 = doc.data() as Map<String, dynamic>;
            return data1.containsKey('venueId') &&
            data1.containsKey('notification') &&
            doc['notification'].toString() == 'true';
            })
                .toList()
                .length;
            return     AppBar(
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
            if (businessCategory == "1") const Tab(text: "Offers"),
            if (businessCategory == "1") const Tab(text: "Event"),
            if (businessCategory != "1")
              Tab(
              text: businessCategory == "1"
              ? "Venue"
                  : "Influencer Collab's"),
     Tab(
         child: Row(
           children: [
             Text('List',style: TextStyle(color: Colors.white),),
             if(notificationCount!=0)
               SizedBox(width: 5,),
             if(notificationCount!=0)
             Container(
               height: 20,
               width: 20,
               decoration:BoxDecoration(
                 shape: BoxShape.circle,
                 color: Colors.green
               ),
               child: Center(child: Text(notificationCount.toString(),style: TextStyle(color: Colors.white),),),
             )
           ],
         ),
     )
         // text: "List ${notificationCount==0?'':notificationCount.toString()}"),
    ],
    ),
    backgroundColor: Colors.black,
    shadowColor: Colors.grey,
    );
    }),),
      body: businessCategory == null
          ? Center(child: const CircularProgressIndicator())
          : DefaultTabController(
              length: businessCategory == "1" ? 3 : 2,
              child: TabBarView(
                controller: controller,
                children: [
                  if (businessCategory == "1") const CouponCodeView(),
                  if (businessCategory == "1")
                    const PromotionOfferHome(isClub: true),
                  if (businessCategory != "1")
                    VenueTabs(businessCategory: businessCategory!),
                  const ListPromoterInfluencerTabs(isOrganiser: 'false',),
                ],
              ),
            ),
    );
  }
}
