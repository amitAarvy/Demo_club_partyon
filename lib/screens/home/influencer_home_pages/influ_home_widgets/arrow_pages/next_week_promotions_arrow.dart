import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/organiser/event_management/promotion_detail.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NextWeekPromotionsArrow extends StatefulWidget {
  const NextWeekPromotionsArrow({super.key});

  @override
  State<NextWeekPromotionsArrow> createState() => _NextWeekPromotionsArrowState();
}

class _NextWeekPromotionsArrowState extends State<NextWeekPromotionsArrow> {

  List? pendingRequests;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPendingRequests();
  }

  void fetchPendingRequests() async{
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'influencer')
    // .where('startTime', isLessThan: DateTime.now())
        .get();
    List saveData = [];
    for(var element in data.docs){
      DateTime startTime = element['startTime'].toDate();
      if(startTime.isAfter(DateTime.now().add(Duration(days: 7)))){
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
      if(reqData.docs.isEmpty || (reqData.docs.isNotEmpty && reqData.docs[0]['status'] != 4)) {
        Map ele = {...element.data(), ...{'promotionId': element.id ,'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status']}};
        pendingRequests!.add(ele);
      }
    }
    QuerySnapshot data2 = await FirebaseFirestore.instance
        .collection("EventPromotion")
        .where('collabType', isEqualTo: 'promotor')
    // .where('startTime', isLessThan: DateTime.now())
        .get();
    List saveData2 = [];
    for(var element in data2.docs){
      DateTime startTime = element['startTime'].toDate();
      if(startTime.isAfter(DateTime.now().add(Duration(days: 7)))){
        saveData2.add(element);
      }
    }
    for(var element in saveData2){
      QuerySnapshot reqData = await FirebaseFirestore.instance
          .collection("InfluencerPromotionRequest")
          .where('eventPromotionId', isEqualTo: element['id'])
          .where('InfluencerID', isEqualTo: uid())
      // .where('status', isEqualTo: widget.status)
          .get();
      if(reqData.docs.isEmpty || (reqData.docs.isNotEmpty && reqData.docs[0]['status'] != 4)){
        Map ele = {...element.data(), ...{'promotionId': element.id ,'status': reqData.docs.isEmpty ? 0 : reqData.docs[0]['status'], "isPaid": reqData.docs.isEmpty ? false : (reqData.docs[0].data() as Map<String, dynamic>)['isPaid'] ?? false}};
        pendingRequests!.add(ele);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(context, title: "Next week promotions"),
      body: SafeArea(
        child: pendingRequests == null
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : pendingRequests!.isEmpty
            ? const Center(child: Text("No data found", style: TextStyle(color: Colors.white)))
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 450.0),
          itemCount: pendingRequests!.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Club')
                  .where('clubUID', isEqualTo: pendingRequests![index]['clubUID'])
                  .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> clubSnapshot) {
                if (clubSnapshot.hasError) {
                  // print("dsfhhdfyhgdf1 ${productData.id}");

                  return Center(
                    child: Text("Error", style: TextStyle(color: Colors.white),),
                  );
                }
                if (clubSnapshot.connectionState == ConnectionState.waiting) {
                  // print("dsfhhdfyhgdf2 ${productData.id}");

                  return Container(
                    height: Get.height / 5,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                }
                if(clubSnapshot.hasData){
                  return GestureDetector(
                    onTap: () {
                      if(pendingRequests![index]['acceptedBy'] != pendingRequests![index]['noOfBarterCollab']){
                        Get.to(PromotionDetails(
                          type: pendingRequests![index]['collabType'] == 'influencer' ? 'venue' : 'influencer',
                          isOrganiser: false,
                          isPromoter: false,
                          isEditEvent: true,
                          isInfluencer: true,
                          promotionRequestId: pendingRequests![index]['promotionId'],
                          collabType: pendingRequests![index]['collabType'],
                          isClub: false,
                          eventPromotionId: pendingRequests![index]['promotionId'],
                          clubId: pendingRequests![index]['clubUID'],
                        ));
                      }
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        // boxShadow: [
                        //   BoxShadow(
                        //       color: Colors.white,
                        //       offset: Offset(1, 1),
                        //       blurRadius: 5
                        //   )
                        // ],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            // height: 200,
                            child: AspectRatio(
                              aspectRatio: 9/16,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                                child: Image.network(
                                  clubSnapshot.data!.docs.isNotEmpty && clubSnapshot.data!.docs[0]['coverImage'] != null && clubSnapshot.data!.docs[0]['coverImage'].isNotEmpty ? clubSnapshot.data!.docs[0]['coverImage'] : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNdi6Gavxh_hhmb3SY4wDfn-mvdtPkvMvKKA&s",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if(loadingProgress == null){
                                      return child;
                                    }
                                    return Center(
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value: loadingProgress.expectedTotalBytes == null?
                                          loadingProgress.cumulativeBytesLoaded
                                              /loadingProgress.expectedTotalBytes!
                                              :null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Divider(height: 0),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  DateFormat(
                                      'dd-MM-yy hh:mm a')
                                      .format(
                                      pendingRequests![index]['startTime']
                                          .toDate() ??
                                          DateTime.now()),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 13.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${clubSnapshot.data!.docs.isEmpty ? '' : clubSnapshot.data!.docs[0]['clubName']} ',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 19.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if(pendingRequests![index]['status'] == 2)
                                  Text(
                                    pendingRequests![index]['status'] == 2 ? '(In Review)' : '',
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.green),
                                  ),
                                Text(
                                  "${pendingRequests![index]['acceptedBy']}/${pendingRequests![index]['noOfBarterCollab']} ${pendingRequests![index]['acceptedBy'] == pendingRequests![index]['noOfBarterCollab'] ? "(Slots full)" : ''}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white),
                                ),
                                Text(
                                  pendingRequests![index]['isPaid'] == null ? '' : pendingRequests![index]['isPaid'] ? "Paid" : "Barter",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).paddingAll(10.w);
                }
                return const Offstage();
              },
            );
          },
        ),
      ),
    );
  }
}
