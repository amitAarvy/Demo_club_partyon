import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class InfluencerList extends StatefulWidget {
  final String collabId;
  final bool isEvent;
  const InfluencerList({super.key, required this.collabId, this.isEvent = false});

  @override
  State<InfluencerList> createState() => _InfluencerListState();
}

class _InfluencerListState extends State<InfluencerList> {
  final c = Get.put(HomeController());
  List? promotionRequestData;
  List? totalInfluencerData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPromotionRequestData();
    fetchInfluencerList();
  }

  void fetchPromotionRequestData() async{
    QuerySnapshot data;
    if(widget.isEvent){
      data =  await FirebaseFirestore.instance
          .collection('PromotionRequest')
          .where('eventPromotionId', isEqualTo: widget.collabId)
          .get();
    }else{
      data =  await FirebaseFirestore.instance
          .collection('PromotionRequest')
          .where('barterCollabId', isEqualTo: widget.collabId)
          .get();
    }
    promotionRequestData = data.docs;
    setState(() {});
  }

  void fetchInfluencerList() async{
    QuerySnapshot menuData = await FirebaseFirestore.instance
        .collection("Influencer")
        .get();
    totalInfluencerData = menuData.docs;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160.h),
        child: AppBar(
          automaticallyImplyLeading: false,
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
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.back();
                },
                  child: Icon(Icons.check, color: Colors.green),
              )
              // SizedBox(
              //   width: 300.w,
              //   child: Obx(() => Text(
              //     c.clubName.value.capitalizeFirst.toString(),
              //     textAlign: TextAlign.end,
              //     style: GoogleFonts.dancingScript(
              //         color: Colors.white, fontSize: 70.sp),
              //     overflow: TextOverflow.ellipsis,
              //   )),
              // )
            ],
          ),
          backgroundColor: Colors.black,
          shadowColor: Colors.grey,
        ),
      ),
      body: totalInfluencerData == null
      ? const CircularProgressIndicator()
      : ListView.builder(
        itemCount: totalInfluencerData!.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                width: Get.width,
                child: Row(children: [
                  Container(
                    height: 400.h,
                    width: Get.width/3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    child: totalInfluencerData![index].data()['image'] != null
                        ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          fadeInDuration:
                          const Duration(milliseconds: 100),
                          fadeOutDuration:
                          const Duration(milliseconds: 100),
                          useOldImageOnUrlChange: true,
                          filterQuality: FilterQuality.low,
                          imageUrl: totalInfluencerData![index]['image'],
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                        ))
                        : Center(
                      child: Icon(Icons.image_outlined, color: Colors.white),
                    ),
                  ),
                  Container(
                    width: Get.width/1.8,
                    child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            totalInfluencerData![index]['companyMame'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ).paddingOnly(left: 10),

                          Text(
                            "Followers :  ${totalInfluencerData![index].data()['follower'] ?? 0}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(
                                color: Colors.white),
                          ).paddingOnly(left: 10),

                          Text(
                            "Reels :  ${totalInfluencerData![index].data()['reel'] ?? 0}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(
                                color: Colors.white),
                          ).paddingOnly(left: 10),

                          Text(
                            "Posts :  ${totalInfluencerData![index].data()['post'] ?? 0}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(
                                color: Colors.white),
                          ).paddingOnly(left: 10),

                          Text(
                            "Cost : Reel- ${totalInfluencerData![index].data()['reelCost'] ?? 0}/- , Post- ${totalInfluencerData![index].data()['postCost'] ?? 0}/- , Story- ${totalInfluencerData![index].data()['storyCost'] ?? 0}/-",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ubuntu(
                                color: Colors.white),
                          ).paddingOnly(left: 10),
                          const SizedBox(height: 10),
                          if(promotionRequestData != null)
                          if(promotionRequestData!.where((element) => element.data()['InfluencerID'] == totalInfluencerData![index].data()['InfluencerID']).toList().isEmpty)
                            GestureDetector(
                                onTap: () {
                                  String docId = Uuid().v4();
                                  Map<String, dynamic> sendData = {
                                    "id" : docId,
                                    // "clubId" : clubId,
                                    "status": 2,
                                    "InfluencerID": totalInfluencerData![index].data()['InfluencerID'],
                                  };
                                  if(widget.isEvent){
                                    sendData.addAll({
                                      "eventPromotionId" : widget.collabId,
                                    });
                                  }else{
                                    sendData.addAll({
                                      "barterCollabId" : widget.collabId,
                                    });
                                  }
                                  FirebaseFirestore.instance.collection("PromotionRequest")
                                      .doc(docId)
                                      .set(sendData)
                                      .whenComplete(() {
                                    fetchPromotionRequestData();
                                    Fluttertoast.showToast(msg: "Request Sent");
                                  },).onError((error, stackTrace) {
                                    Fluttertoast.showToast(msg: "some error occurred");
                                  },);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.yellow,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Send Invite',
                                    style: GoogleFonts.ubuntu(
                                        fontSize: 30.sp,
                                        color: Colors.white),
                                  ).paddingAll(5.0),)
                            ).marginOnly(left: 5.0)
                          else
                            const Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text("Invited", style: TextStyle(color: Colors.green)),
                            )
                        ]),
                  ),
                ])),
          );
        },
      ),
    );
  }
}
