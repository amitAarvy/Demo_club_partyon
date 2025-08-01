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

import '../../event_management/menu_detail.dart';
import '../../event_management/menu_edit.dart';
import 'promoter_page.dart';

class AcceptInfluencerPromotionList extends StatelessWidget {
  final String categoryID;
  final String eventPromotionId;
  final String clubId;
  const AcceptInfluencerPromotionList({this.categoryID = '', super.key, required this.eventPromotionId, required this.clubId});

  @override
  Widget build(BuildContext context) {
    DateTime timeNow = DateTime.now();

    DateTime today = DateTime(timeNow.year, timeNow.month, timeNow.day);
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('Menu')
          .where('status', isEqualTo: 1)
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
            child: Text("No menu found!"),
          );
        }

        if (snapshot.data != null) {
          return Scaffold(
              backgroundColor: matte(),
              appBar: appBar(context, title: "Promotion Home", showLogo: true),
              body: Container(
                width: Get.width,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    String imageurl = "";
                    final productData = snapshot.data!.docs[index];
                    if (snapshot.data!.docs[index]['menuImages']
                        .toString()
                        .isNotEmpty) {
                      // final imageMenu = [];
                      imageurl = snapshot.data!.docs[index]['menuImages'][0];
                      // Fluttertoast.showToast(
                      //     msg: imageurl);
                    }

                    return GestureDetector(
                      onTap: () async {
                        Get.to(
                          MenuEdit(
                            snapshot.data!.docs[index].id,
                            productData['title'],
                            productData['price'],
                            productData['detail'],
                            imageurl,
                          ),
                        );
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
                                height: 400.h,
                                width: Get.width/3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black,
                                ),
                                child: imageurl.isNotEmpty
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
                                      imageUrl: imageurl,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                    ))
                                    : Text(
                                  "No Image Available",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black),
                                ).paddingOnly(left: 10),
                              ),
                              Container(
                                width: Get.width/1.8,
                                child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Event :  ${productData['title']}",

                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white),
                                      ).paddingOnly(left: 10),

                                      Text(
                                        "Target Views :  ${productData['price']}",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.white),
                                      ).paddingOnly(left: 10),

                                      Text(
                                        "Current Views :  ${productData['price']}",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.white),
                                      ).paddingOnly(left: 10),


                                      Text(
                                        "Story Views :  ${productData['price']}",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.white),
                                      ).paddingOnly(left: 10),

                                      Text(
                                        "Like : ${productData['price']}",
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.white),
                                      ).paddingOnly(left: 10),

                                      Text(
                                        "Status : Pending Deal",
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.white),
                                      ).paddingOnly(left: 10),

                                      GestureDetector(
                                          onTap: () => Get.to(
                                            PromoterPage(
                                              eventPromotionId: eventPromotionId,
                                              clubId: clubId,
                                            ),

                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.yellow,
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'PAY NOW',
                                              style: GoogleFonts.ubuntu(
                                                  fontSize: 30.sp,
                                                  color: Colors.white),
                                            ).paddingAll(5.0),)
                                      ).marginOnly(left: 5.0),
                                    ]),
                              ),
                            ])),
                      ),
                    );
                  },
                ),
              ));
        }

        return Container();
      },
    );
  }
}
