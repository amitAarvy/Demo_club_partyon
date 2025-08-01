import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_utils.dart';
import 'Analytics_tabBar.dart';


class PromotionEvent extends StatefulWidget {

  const PromotionEvent({super.key,});

  @override
  State<PromotionEvent> createState() => _PromotionEventState();
}

class _PromotionEventState extends State<PromotionEvent> {
 

  @override
  void initState() {
    super.initState();
    fetchPromotionList();
  }


  List eventList=[];
  fetchPromotionList()async{
    isLoadingEvent.value = true;
     var data =await FirebaseFirestore.instance.collection('CouponPR').where('isInf',isEqualTo:false).where('prId',isEqualTo: uid()).get();
     eventList = data.docs;
     setState(() {});
    isLoadingEvent.value = false;
  }

  ValueNotifier<bool> isLoadingEvent = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: appBar(context, title: "Event Analytics", ),
        body:ValueListenableBuilder(
          valueListenable: isLoadingEvent,
          builder: (context, bool isLoading, child) {
            if(isLoading){

              return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,),);
            }
            // data1.sort((a, b) =>
            //     b['date'].toDate().compareTo(a['date'].toDate()));
            eventList.sort((a,b)=>b['data']['date'].toDate().compareTo(a['data']['date'].toDate()));
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
                          Get.to(AnalyticsTabBar(eventId: eventList[index]['eventId'].toString(),data: eventList[index]));
                        },
                        leading: Text('${index+1}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
                        title: Text(eventList[index]['data']['venueName'].toString(),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                        trailing: Text(
                          DateFormat('dd/MM/yyyy').format(
                            (eventList[index]['data']['date'] as Timestamp).toDate(),
                          ),style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                        ), ),
                    ),
                  );
                },
              ),
            );
          },
        )
    );
  }
}
