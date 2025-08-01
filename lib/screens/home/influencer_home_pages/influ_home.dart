import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'influ_home_widgets/brand_products_carousel.dart';
import 'influ_home_widgets/grooming_carousel.dart';
import 'influ_home_widgets/promotion_by_events.dart';
import 'influ_home_widgets/travel_carousel.dart';


class InfluHome extends StatefulWidget {
  const InfluHome({super.key});

  @override
  State<InfluHome> createState() => _InfluHomeState();
}

class _InfluHomeState extends State<InfluHome> {
  List pendingRequests = [];
  List<Map<String, dynamic>> groomingList = [];
  List travelCategoryList = [];
  List brandProductList = [];
  ValueNotifier<bool> isLoading = ValueNotifier(false);


  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value= true;
    await Future.wait([
      fetchPendingRequests(),
      fetchCategoryList(3, (data) => groomingList = data),
      fetchCategoryList(2, (data) => travelCategoryList = data),
      fetchCategoryList(4, (data) => brandProductList = data),
    ]);
    if (!mounted) return;
    setState(() {});
    isLoading.value= false;
  }
  List clubList = [];
  Future<void> fetchPendingRequests() async {
    clubList = (await FirebaseFirestore.instance
        .collection('Club')
        .get()).docs;
    var querySnapshot = await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'influencer')
        .get();

    List<Map<String, dynamic>> tempList = [];

    await Future.wait(querySnapshot.docs.map((event) async {
      var clubSnapshot = await FirebaseFirestore.instance
          .collection('Club')
          .doc(event['clubUID'])
          .get();

      if (clubSnapshot.exists &&
          (clubSnapshot.data()?['businessCategory'] == null ||
              clubSnapshot.data()?['businessCategory'] == 1)) {
        DateTime startTime = event['startTime'].toDate();
        if (startTime.isAfter(DateTime.now()) || isSameDay(startTime, DateTime.now())) {
          var reqData = await FirebaseFirestore.instance
              .collection("PromotionRequest")
              .where('eventPromotionId', isEqualTo: event.id)
              .where('influencerPromotorId', isEqualTo: uid())
              .get();

          if (reqData.docs.isEmpty || reqData.docs.first['status'] != 4) {
            tempList.add({
              ...event.data(),
              'promotionId': event.id,
              'status': reqData.docs.isEmpty ? 0 : reqData.docs.first['status'],
            });
          }
        }
      }
    }).toList());

    pendingRequests = tempList.take(4).toList(); // Max 4 requests
  }

  Future<void> fetchCategoryList(int category, Function(List<Map<String, dynamic>>) setData) async {
    // var clubSnapshot = await FirebaseFirestore.instance
    //     .collection('Club')
    //     .where('businessCategory', isEqualTo: category)
    //     .get();

    List<Map<String, dynamic>> categoryList = [];

    await Future.wait(clubList.map((club) async {
      var eventSnapshot = await FirebaseFirestore.instance
          .collection("EventPromotion")
          .where('collabType', isEqualTo: 'influencer')
          .where("clubUID", isEqualTo: club.id)
          .get();

      List<Map<String, dynamic>> validPromotions = [];

      for (var event in eventSnapshot.docs) {
        var reqData = await FirebaseFirestore.instance
            .collection("PromotionRequest")
            .where('eventPromotionId', isEqualTo: event.id)
            .where('influencerPromotorId', isEqualTo: uid())
            .get();

        if (reqData.docs.isEmpty || reqData.docs.first['status'] != 4) {
          DateTime startTime = event['startTime'].toDate();
          if (startTime.isAfter(DateTime.now()) || isSameDay(startTime, DateTime.now())) {
            validPromotions.add(event.data()!);
          }
        }
      }

      if (validPromotions.isNotEmpty) {
        validPromotions.sort((a, b) => a['startTime'].toDate().compareTo(b['startTime'].toDate()));
        categoryList.add({
          ...club.data()!,
          "promotionData": validPromotions.first,
        });
      }
    }).toList());

    setData(categoryList);
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String uid() {
    return "user_id_placeholder";
  }

  @override
  Widget build(BuildContext context) {
    print('club data is ${clubList}');
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder:(context, bool isLoading, child) {
          if(isLoading){
            return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),);
          }
          return  SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                  child: Text("Night Life & Events",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                ),
                if (pendingRequests.isNotEmpty)  PromotionByEvents(pendingRequests: pendingRequests, club: clubList,),
                if (groomingList.isNotEmpty)  GroomingCarousel(groomingList: groomingList,),
                if (travelCategoryList.isNotEmpty)  TravelCarousel(groomingList: travelCategoryList,),
                if (brandProductList.isNotEmpty)  BrandProductsCarousel(groomingList: brandProductList,),
              ],
            ),
          );
        },

      ),
    );
  }
}
