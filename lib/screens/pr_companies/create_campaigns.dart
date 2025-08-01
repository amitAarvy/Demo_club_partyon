import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../../utils/app_utils.dart';
import '../../widgets/dropdown.dart';
import '../home/home_utils.dart';
import 'create_camigns_second.dart';


class CreateCampaignsPage extends StatefulWidget {

  const CreateCampaignsPage({super.key,});

  @override
  State<CreateCampaignsPage> createState() => _CreateCampaignsPageState();
}

class _CreateCampaignsPageState extends State<CreateCampaignsPage> {
  List pendingRequests = [];
  List eventList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPendingRequests();
  }



  void fetchPendingRequests() async{
    QuerySnapshot data =  await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'promotor')
        .get();

    List saveData = [];
    for(var element in data.docs){
      DateTime startTime = element['startTime'].toDate();
        if(startTime.isAfter(DateTime.now())) {
          saveData.add(element);
        }
    }
    pendingRequests = [];
    for(var element in saveData){
      QuerySnapshot reqData = await FirebaseFirestore.instance
          .collection("PromotionRequest")
          .where('eventPromotionId', isEqualTo: element['id'])
          .where('influencerPromotorId', isEqualTo: uid())
      // .where('status', isEqualTo: widget.status)
          .get();

      if(4 == 4 && reqData.docs.isNotEmpty && reqData.docs[0]['status'] == 4){
        Map ele = {...element.data(), ...{'promotionId': element.id ,'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status']}};
        pendingRequests!.add(ele);
      }
    }
    log('pending request is ${pendingRequests}');
    List<Future<void>> fetchEvents =pendingRequests.map((data) async {
            String? eventId = data['eventId'];
            print('event list is ${eventId}');
            if (eventId != null) {
              DocumentSnapshot eventDoc = await FirebaseFirestore.instance
                  .collection("Events")
                  .doc(eventId)
                  .get();

              var eventData = eventDoc.data() as Map<String, dynamic>?;
              if (eventData != null) {
                eventList.add({
                  ...eventData,
                  'id': eventDoc.id,
                  'pomotionData': data,
                });
              }
            }
          }).toList();
    await Future.wait(fetchEvents);
    setState(() {});
    log('pending request is event list ${eventList}');



  }
  // void fetchPendingRequests() async {
  //   isLoadingEvent.value = true;
  //   pendingRequests = [];
  //   eventList.clear();
  //
  //   try {
  //     QuerySnapshot promoSnap = await FirebaseFirestore.instance
  //         .collection("EventPromotion")
  //         .where('collabType', isEqualTo: 'promotor')
  //         .get();
  //
  //     // Filter by startTime in Dart
  //     List<QueryDocumentSnapshot> upcomingPromos = promoSnap.docs.where((doc) {
  //       DateTime startTime = doc['startTime'].toDate();
  //       return startTime.isAfter(DateTime.now());
  //     }).toList();
  //
  //     // Parallel fetch requests for each promotion
  //     List<Future<void>> fetchRequests = upcomingPromos.map((promo) async {
  //       String promoId = promo.id;
  //
  //       QuerySnapshot reqSnap = await FirebaseFirestore.instance
  //           .collection("PromotionRequest")
  //           .where('eventPromotionId', isEqualTo: promoId)
  //           .where('influencerPromotorId', isEqualTo: uid())
  //           .get();
  //
  //       int status = reqSnap.docs.isNotEmpty ? reqSnap.docs[0]['status'] : 0;
  //
  //       Map<String, dynamic> mergedData = {
  //         ...promo.data() as Map<String, dynamic>,
  //         'promotionId': promoId,
  //         'status': status
  //       };
  //       pendingRequests!.add(mergedData);
  //     }).toList();
  //
  //     await Future.wait(fetchRequests);
  //     List<Future<void>> fetchEvents = pendingRequests!.map((data) async {
  //       String? eventId = data['eventId'];
  //       if (eventId != null) {
  //         DocumentSnapshot eventDoc = await FirebaseFirestore.instance
  //             .collection("Events")
  //             .doc(eventId)
  //             .get();
  //
  //         var eventData = eventDoc.data() as Map<String, dynamic>?;
  //         if (eventData != null) {
  //           eventList.add({
  //             ...eventData,
  //             'id': eventDoc.id,
  //             'pomotionData': data,
  //           });
  //         }
  //       }
  //     }).toList();
  //
  //     await Future.wait(fetchEvents);
  //
  //
  //     log('Final event list: $eventList');
  //     log('uid: ${uid()}');
  //   } catch (e) {
  //     print("Error fetching pending requests: $e");
  //   }
  //   setState(() {});
  //   isLoadingEvent.value = false;
  // }


  ValueNotifier<bool> isLoadingEvent = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: appBar(context, title: "Create Campaigns", ),
        body:ValueListenableBuilder(
          valueListenable: isLoadingEvent,
          builder: (context, bool isLoading, child) {
            if(isLoading){
              return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),);
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: eventList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                          border: Border.all(color: Colors.grey)
                      ),
                      child: ListTile(
                        onTap: (){
                          Get.to(CampaignsTabBar(data: eventList[index], callBack:()=> fetchPendingRequests()));
                        },
                        leading: Text('${index+1}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
                        title: Text(eventList[index]['venueName'].toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                        trailing: Text(
                          DateFormat('dd/MM/yyyy').format(
                            (eventList[index]['date'] as Timestamp).toDate(),
                          ),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                        ), ),
                    ),
                  );
                },),
            );
          },
        )
    );
  }
}
