// ignore_for_file: file_names, prefer_const_constructors, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../event_management/menu_detail.dart';
import '../../event_management/menu_edit.dart';
import 'promoter_page.dart';

class InfluencerPromotionList extends StatefulWidget {
  final String eventPromotionId;
  final String clubId;
  final List<String> deliverables;
  final String script;
  final List<String> platforms;
  final List promotionalData;
  final String url;
  const InfluencerPromotionList({super.key, required this.eventPromotionId, required this.clubId, required this.deliverables, required this.script, required this.platforms, required this.url, required this.promotionalData});

  @override
  State<InfluencerPromotionList> createState() => _InfluencerPromotionListState();
}

class _InfluencerPromotionListState extends State<InfluencerPromotionList> {

  ValueNotifier<String> selectedBarterType = ValueNotifier('barter');
  List<Map<String, dynamic>>? influencerPromotionRequestData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPromotionRequestData();
  }

  void fetchPromotionRequestData() async{
    QuerySnapshot data =  await FirebaseFirestore.instance
        .collection('InfluencerPromotionRequest')
        .where('eventPromotionId', isEqualTo: widget.eventPromotionId)
        .get();
    influencerPromotionRequestData = data.docs.map((e) => e.data() as Map<String, dynamic>).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('Influencer')
          // .where('status', isEqualTo: 1)
          // .where('clubUID', isEqualTo: uid())
          // .where('categoryID', isEqualTo: categoryID)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: Get.height / 5,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("No Influencer found!"),
          );
        }

        if (snapshot.data != null) {
          return Scaffold(
              backgroundColor: matte(),
              appBar: appBar(
                  context,
                  title: "Influencert List",
                  // title: "Promotion Home",
                  showLogo: true,
              ),
              body: influencerPromotionRequestData == null ?
              Center(child: CircularProgressIndicator())
                  : Container(
                width: Get.width,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: selectedBarterType,
                        builder: (context, String selectedBarter, child) {
                          return Row(
                            children: [
                              Row(
                                children: [
                                  Radio(value: selectedBarter, groupValue: "barter", onChanged: (value) {
                                    selectedBarterType.value = "barter";
                                  },),
                                  Text("Barter", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio(value: selectedBarter, groupValue: "paid", onChanged: (value) {
                                    selectedBarterType.value = "paid";
                                  },),
                                  Text("Paid", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          String imageurl = "";
                          final influencerData = snapshot.data!.docs[index];
                          // if (snapshot.data!.docs[index]['menuImages']
                          //     .toString()
                          //     .isNotEmpty) {
                          //   // final imageMenu = [];
                          //   imageurl = snapshot.data!.docs[index]['menuImages'][0];
                          //   // Fluttertoast.showToast(
                          //   //     msg: imageurl);
                          // }

                          return GestureDetector(
                            onTap: () async {
                              // Get.to(
                              //   MenuEdit(
                              //     snapshot.data!.docs[index].id,
                              //     productData['title'],
                              //     productData['price'],
                              //     productData['detail'],
                              //     imageurl,
                              //   ),
                              // );
                            },
                            child: Padding(
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
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black,
                                      ),
                                      child: FutureBuilder(
                                        future: FirebaseFirestore.instance
                                            .collection('Organiser')
                                            .doc(influencerData.id)
                                            .get(),
                                        builder: (context, AsyncSnapshot<DocumentSnapshot> organSnap) {
                                          if(organSnap.connectionState == ConnectionState.waiting) return const Offstage();
                                          if(organSnap.hasError) return const Offstage();
                                          if(!organSnap.hasData || organSnap.data == null || organSnap.data!.data() == null || (organSnap.data!.data() as Map<String, dynamic>)['profileImages'] == null || (organSnap.data!.data() as Map<String, dynamic>)['profileImages'].isEmpty){
                                            return Center(
                                              child: Text(
                                                "No Image Available",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white),
                                              ).paddingOnly(left: 10),
                                            );
                                          }
                                          return ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              fadeInDuration:
                                              const Duration(milliseconds: 100),
                                              fadeOutDuration:
                                              const Duration(milliseconds: 100),
                                              useOldImageOnUrlChange: true,
                                              filterQuality: FilterQuality.low,
                                              imageUrl: (organSnap.data!.data() as Map<String, dynamic>)['profileImages'][0],
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Container(
                                      // width: Get.width/1.8,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                             '',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white),
                                            ).paddingOnly(left: 10),

                                            Text(
                                              "Followers : ${(influencerData.data() as Map<String, dynamic>)['follower'] ?? 0}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.ubuntu(color: Colors.white),
                                            ).paddingOnly(left: 10),
                                            Text(
                                              "Post Cost : ${(influencerData.data() as Map<String, dynamic>)['postCost'] ?? 0}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.ubuntu(color: Colors.white),
                                            ).paddingOnly(left: 10),
                                            Text(
                                              "Reel Cost : ${(influencerData.data() as Map<String, dynamic>)['reelCost'] ?? 0}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.ubuntu(color: Colors.white),
                                            ).paddingOnly(left: 10),
                                            Text(
                                              "Story Cost : ${(influencerData.data() as Map<String, dynamic>)['storyCost'] ?? 0}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.ubuntu(color: Colors.white),
                                            ).paddingOnly(left: 10),
                                            // Text(
                                            //   "Email / Phone :  ${influencerData['emailPhone']}",
                                            //   maxLines: 2,
                                            //   overflow: TextOverflow.ellipsis,
                                            //   style: GoogleFonts.ubuntu(
                                            //       color: Colors.white),
                                            // ).paddingOnly(left: 10),

                                            // Text(
                                            //   "Coast : Real-100 , Post-${productData['price']} , Story-${productData['price']}",
                                            //   // "Coast : Real-${productData['price']} , Post-${productData['price']} , Story-${productData['price']}",
                                            //   maxLines: 3,
                                            //   overflow: TextOverflow.ellipsis,
                                            //   style: GoogleFonts.ubuntu(
                                            //       color: Colors.white),
                                            // ).paddingOnly(left: 10),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                if(influencerPromotionRequestData!.where((element) => element['InfluencerID'] == (influencerData.data() as Map<String, dynamic>)['InfluencerID']).toList().isEmpty)
                                                  GestureDetector(
                                                      onTap: () {
                                                        String docId = Uuid().v4();
                                                        FirebaseFirestore.instance.collection("InfluencerPromotionRequest").doc(docId).set({
                                                          "id" : docId,
                                                          "eventPromotionId" : widget.eventPromotionId,
                                                          "promotorId": uid(),
                                                          "status": 0,
                                                          "InfluencerID": influencerData['InfluencerID'],
                                                          "newDeliverables": widget.deliverables,
                                                          "newScript": widget.script,
                                                          "platforms": widget.platforms,
                                                          "url": widget.url,
                                                          "isPaid": selectedBarterType.value == 'paid'
                                                        }).whenComplete(() {
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
                                                          'Send Request',
                                                          style: GoogleFonts.ubuntu(
                                                              fontSize: 30.sp,
                                                              color: Colors.white),
                                                        ).paddingAll(5.0),)
                                                  ).marginOnly(left: 5.0)
                                                else
                                                Text(
                                                  'Sent',
                                                  style: GoogleFonts.ubuntu(
                                                      fontSize: 17,
                                                      color: Colors.green,
                                                  ),
                                                ).paddingAll(5.0).marginOnly(left: 5.0),
                                                // GestureDetector(
                                                //     onTap: () {},
                                                //     child: Container(
                                                //       decoration: BoxDecoration(
                                                //         border: Border.all(
                                                //           color: Colors.yellow,
                                                //         ),
                                                //         borderRadius: BorderRadius.circular(20),
                                                //       ),
                                                //       child: Text(
                                                //         'Send Invite',
                                                //         style: GoogleFonts.ubuntu(
                                                //             fontSize: 30.sp,
                                                //             color: Colors.white),
                                                //       ).paddingAll(5.0),)
                                                // ).marginOnly(left: 5.0),
                                              ],
                                            )
                                          ]),
                                    ),
                                  ])),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ));
        }

        return Container();
      },
    );
  }
}
