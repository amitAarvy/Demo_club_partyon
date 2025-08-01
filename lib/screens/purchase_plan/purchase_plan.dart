import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_utils.dart';
import '../payment_gateWay/payment.dart';

class PurchasePlan extends StatefulWidget {
  final String isProfile;
  const PurchasePlan({super.key, required this.isProfile});

  @override
  State<PurchasePlan> createState() => _PurchasePlanState();
}

class _PurchasePlanState extends State<PurchasePlan> {
  ValueNotifier selectPlan= ValueNotifier(null);
  ValueNotifier<bool> loading= ValueNotifier(false);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;




  ValueNotifier<List> planList = ValueNotifier([]);
  ValueNotifier<bool> planBuyCheck = ValueNotifier(false);


  List buyPlanList =[];
  fetchPlan()async{
    loading.value = true;
   await fetchPlanBuy();
  QuerySnapshot querySnapshot = await _firestore
      .collection('plan').get();
  List allPlans= querySnapshot.docs.where((e)=>e['create'].toString() ==widget.isProfile.toString()).toList();

    planList.value  = allPlans.map((plan) {
      Map<String, dynamic> planData = plan.data() as Map<String, dynamic>; // Convert Firestore doc to Map
      print('check id is ${plan.id.toString()}');

      bool isMatched = buyPlanList.any((e) => e['planId'].toString() == plan.id.toString());
      print('check is is match${isMatched}');

      return {
        ...planData,
        "planId":plan.id,
        'orderBuy': isMatched?true:false,
      };
    }).toList();
    planBuyCheck.value =  planList.value[0]['orderBuy'];
    print('plan lsit is ${planList.value}');
    loading.value = false;
}



@override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchPlan();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Plan",showBack:false),
      body: Column(
        children: [
          SizedBox(height: 20,),
          ValueListenableBuilder(
            valueListenable:     loading,
            builder: (context, bool isLoading, child) {
              if(isLoading){
                return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),);
              }
              return ValueListenableBuilder(
                valueListenable: planList,
                builder: (context, List allPlan, child) {
                  if(allPlan.isEmpty){
                    return const Center(child: Text('No plan available',style: TextStyle(color: Colors.white),),);
                  }
                  log('list check is order ${allPlan}');

                  return CarouselSlider.builder(
                    itemCount: allPlan.length,
                    itemBuilder: (context, index, realIndex) {
                      var plan = allPlan[index];
                      return ValueListenableBuilder(
                        valueListenable:selectPlan,
                        builder: (context, selected, child) =>
                                planListView(plan),
                      );
                    },
                    options: CarouselOptions(
                      height: Get.height * 0.62,
                      enlargeCenterPage: true,
                      // enableInfiniteScroll: false,
                      enlargeFactor: kIsWeb ? 0.01 : 0.15,
                      viewportFraction: kIsWeb ? 0.3 : 0.85,
                      autoPlay: false,
                      onPageChanged: (index, reason) {
                        print('current index is ${index}');
                        selectPlan.value= allPlan[index];
                        planBuyCheck.value = allPlan[index]['orderBuy'];
                        print('check it is ${planBuyCheck.value}');
                      },
                    ),
                  );
                },
              );
            },

          ),
          SizedBox(height: 20,),
          // if(planList.value.isNotEmpty)
          ValueListenableBuilder(
            valueListenable: planBuyCheck,
            builder: (context, bool isPlan, child) {
              print('check is ${isPlan}');
              return GestureDetector(
                onTap: ()async{
                  if(isPlan){
                  }else {
                    if (selectPlan.value == null) {
                   await   Get.to(Payments(amount: double.parse(planList.value[0]
                          .data()['price']),
                        userType: widget.isProfile,
                        planDetail: planList.value[0],
                        planId: planList.value[0]['planId'],));
                        print('check select plan is ${selectPlan.value}');
                       fetchPlan();
                    } else {
                    await  Get.to(Payments(amount: double.parse(selectPlan.value['price'].toString()),
                        userType: widget.isProfile,
                        planDetail: selectPlan.value,
                        planId: selectPlan.value['planId'],));
                    fetchPlan();

                    }

                  }
                },
                child: SizedBox(
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                          color: isPlan?Colors.grey:Colors.blue
                      ),
                      child: Center(child: Text(isPlan?'Start Plan':'Buy Plan',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),)),
                    ),
                  ),
                ),
              );
            }


          ),
        ],
      ),
    );
  }
  Widget PlanFeature(String title){
    return Row(
      children: [
        Icon(Icons.check,color: Colors.green,),
        SizedBox(width: 10,),
        Text('$title',style: TextStyle(color: Colors.white),),
      ],
    );
  }

  Widget planListView(plan){
    return  Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        // border: Border.all(color: selected==index?Colors.blue:Colors.transparent),
        boxShadow: const [
          BoxShadow(
              color: Colors.white,
              offset: Offset(1, 1),
              blurRadius: 5
          )
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // alignment: Alignment.bottomCenter,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan['planName'],style: TextStyle(fontWeight: FontWeight.w700,color: Colors.blue,fontSize: 18),),
            SizedBox(height: 20,),

            Row(
              children: [
                Text('₹',style: TextStyle(color: Colors.white,fontSize: 22),),
                Text('${plan['price']}/${plan['duration']}',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white,fontSize: 32,),),
              ],
            ),
            Divider(color: Colors.grey,),
            SizedBox(height: 10,),
            if(plan['videoBanner'] != null)
             PlanFeature('${plan['videoBanner']['noOfVideoBanner'].toString()} Video banner,${plan['videoBanner']['noOfPerDayBanner']} Per banner and \n${plan['videoBanner']['noOfVideoBanner']} Home Page banner'),
            if(plan['videoBanner'] != null)
            SizedBox(height: 10,),
            if(plan['popBanner'] != null)
            PlanFeature('${plan['popBanner']['noOfPopBanner']} Pop banner and \n${plan['popBanner']['noOfDayPerPopBanner']} per pop banner'),
            if(plan['popBanner'] != null)
            SizedBox(height: 10,),
            PlanFeature('No of Entry Management ${plan['entryManagement']['noOfEntry']}\nPercentage of entry ${plan['entryManagement']['percentageOfEntry']}'),
            SizedBox(height: 10,),
            PlanFeature('No of Table Management ${plan['tableManagement']['noOfTable']}\nPercentage of Table ${plan['tableManagement']['percentageOfTable']}'),
            SizedBox(height: 10,),
            PlanFeature('No of event created ${plan['noOfEventCreated']}'),
            SizedBox(height: 10,),
            PlanFeature('No of analytics ${plan['noOfPromotionAnalytics']}'),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
  fetchPlanBuy()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    QuerySnapshot data = await   FirebaseFirestore.instance
        .collection("BookingPlan")
        .where('id',
        isEqualTo: uid()).where('status',isEqualTo: 'S')
        .get();
    buyPlanList = data.docs ?? [];

    if(data.docs.isNotEmpty){
      print('check plan is ${data.docs[0]['planDetail']}');
      Map<String,dynamic> planData = data.docs[0]['planDetail'];
      pref.setString('planData',jsonEncode(planData) );
    }
    setState(() {
    });
  }
}