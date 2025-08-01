
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/accepted_influencer_list.dart';
import 'package:club/screens/event_management/barter_collab.dart';
import 'package:club/screens/event_management/venue_promotion_create.dart';
import 'package:club/screens/organiser/event_management/promotion_detail.dart';
import 'package:club/screens/venueAnalysis/venueTotal.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../event_management/accepted_promoter_list.dart';
import '../event_management/create_event_promotion.dart';
import '../pr_companies/Analystics/myPromotionDetail.dart';
import '../promotional_analysis/promotional_analysis_event_list.dart';
import 'my_promotion.dart';


class PromoterList extends StatefulWidget  {
  final String eventPromotionId;
  final String eventId;
  final data;


  const PromoterList({super.key, required this.eventPromotionId, required this.eventId, this.data, });

  @override
  State<PromoterList> createState() => _PromoterListState();
}

class _PromoterListState extends State<PromoterList> with SingleTickerProviderStateMixin{
  late TabController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchInfluencerData();
    print('check event promotion detail ${widget.data}');
  }
  List promoterList = [];
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  void fetchInfluencerData()async{
    isLoading.value = true;
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('PromotionRequest')
        .where('eventPromotionId', isEqualTo: widget.eventPromotionId)
        .where(Filter.or(Filter('status', isEqualTo: 2), Filter('status', isEqualTo: 4)))
        .get();
    promoterList = [];
    for(var element in data.docs){
      DocumentSnapshot promotorData = await FirebaseFirestore.instance
          .collection('Organiser')
          .doc(element['influencerPromotorId'])
          .get();
      DocumentSnapshot promotionData = await FirebaseFirestore.instance
          .collection('EventPromotion')
          .doc(element['eventPromotionId'])
          .get();
      // DocumentSnapshot organiserDetail = await FirebaseFirestore.instance
      //     .collection('EventPromotion')
      //     .doc(element['eventPromotionId'])
      //     .get();
      if(promotorData.data() != null){
        Map<String, dynamic> ele = element.data() as Map<String, dynamic>;
        print('check id Is ${promotorData.data()}');
        ele['id'] = element.id;
        ele['userData'] = promotorData.data();
        ele['promotionData'] = promotionData.data();
        promoterList.add(ele);
      }
    }
    setState(() {});
    log('check promotional data ${promoterList}');
    controller = TabController(length: promoterList.length+2, vsync: this);
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, bool loading, child) {
        if(loading){
          return Container(
              height: 1.sh,
              width: 1.sw,
              color: Colors.black,
              child: Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),));
        }
        return  Scaffold(
            backgroundColor: matte(),
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
                  ],
                ),
                bottom: TabBar(
                    controller: controller,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'Total',),
                      Tab(text: 'My Promotion',),
                      ...promoterList.map((e) => Tab(text: e['userData']['name'],),).toList()
                    ]
                ),
                backgroundColor: Colors.black,
                shadowColor: Colors.grey,
              ),
            ),
            body: DefaultTabController(
              length: promoterList.length +2,
              child: TabBarView(
                  controller: controller,
                  children: [
                    VenueTotal(eventId: widget.eventId, eventData: widget.data, venuePr: 'true',),
                    MyPromotion(eventId: widget.eventId, eventData: widget.data, venuePr: 'true',),
                    ...promoterList.map((e) => MyPromotionDetail(eventId: widget.eventId, eventData: widget.data, venuePr: 'true',prId: e['userData']['uid'],),).toList()
                  ]
              ),
            )
        );
      },
    );
  }
}
