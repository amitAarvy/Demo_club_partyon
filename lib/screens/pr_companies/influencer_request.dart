import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../utils/app_utils.dart';
import '../../widgets/dropdown.dart';
import '../event_management/accepted_influencer_list.dart';
import '../home/home_utils.dart';
import 'create_camigns_second.dart';


class AllInfluencerRequest extends StatefulWidget {

  const AllInfluencerRequest({super.key,});

  @override
  State<AllInfluencerRequest> createState() => AllInfluencerRequestState();
}

class AllInfluencerRequestState extends State<AllInfluencerRequest> {
  List pendingRequests = [];
  List eventList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPendingRequests();
  }

  void fetchPendingRequests() async {
    isLoadingEvent.value = true;
    pendingRequests = [];
    eventList.clear();

    try {
      print('check pr id ${uid()}');
      QuerySnapshot promoSnap = await FirebaseFirestore.instance
          .collection("EventPromotion").where('prId',isEqualTo: uid()).where('collabType',isEqualTo: 'influencer')
          .get();

      pendingRequests =   promoSnap.docs.where((element) => (element['startTime'].toDate() as DateTime)
          .isAfter(DateTime.now())).toList().reversed.toList();
      setState(() {});
      print('check influenecer request ${pendingRequests}');
    } catch (e) {
      print("Error fetching pending requests: $e");
    }
    setState(() {});
    isLoadingEvent.value = false;
  }


  ValueNotifier<bool> isLoadingEvent = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body:ListView.builder(
            shrinkWrap: true,
            itemCount: pendingRequests.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              var data = pendingRequests[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: (){
                    print('check promotion id ${data.id}');
                    Get.to(AcceptedInfluencerList(eventPromotionId: data.id,));
                  },
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(11)),
                      border: Border.all(color: Colors.grey.shade200,width: 1)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('dd-MM-yyyy').format(
                                  (getKeyValueFirestore(data, 'dateTime') as Timestamp).toDate()
                              ),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(child: Text(getKeyValueFirestore(data, 'eventName'),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),)),
                          Expanded(child: Text(DateFormat('dd-MM-yyyy').format((getKeyValueFirestore(data, 'startTime') as Timestamp).toDate()),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),)),
                          Text('${getKeyValueFirestore(data, 'acceptedBy') }/ ${getKeyValueFirestore(data, 'noOfBarterCollab')}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),

                        ],
                      ),
                    ),
                  ),
                ),
              );
            },)
    );
  }
}
