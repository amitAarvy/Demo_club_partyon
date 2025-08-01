import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_const.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/screens/event_management/model/entrance_data_model.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'controller/event_management_controller.dart';
import 'menu_category_fetch.dart';
import 'menu_fetch.dart';

class MenuView extends StatefulWidget {
  final String? eventId;
  final bool isOrganiser;
  final bool isEditEvent;
  final String clubUID;
  final String venueName;

  const MenuView({
    this.eventId = '',
    this.isEditEvent = false,
    this.isOrganiser = false,
    this.clubUID = '',
    this.venueName = '',
    Key? key,
  }) : super(key: key);

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: matte(),
      appBar: appBar(context, title: "View / Edit Menu"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          height: Get.height,
          width: Get.width,
          child:FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('Menucategory')
                .where('status', isEqualTo: 1)
                .where('clubUID', isEqualTo: uid())
            // .where('date', isGreaterThanOrEqualTo: today)
            // .where('city', isEqualTo: homeController.city)
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
                  child: Text("No category found!"),
                );
              }

              if (snapshot.data != null) {
                return Container(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      final productData = snapshot.data!.docs[index];

                      return Wrap(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                                // decoration: BoxDecoration(
                                //   boxShadow: [
                                //     BoxShadow(
                                //       offset: Offset(0, 1.h),
                                //       spreadRadius: 5.h,
                                //       blurRadius: 20.h,
                                //       color: Colors.black,
                                //     )
                                //   ],
                                //   borderRadius: BorderRadius.circular(22),
                                //   color: Color(0x42C3C3C3),
                                // ),
                                width: Get.width,
                                child: Column(children: [

                                  Text(
                                    productData['title'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.white),
                                  ).paddingAll(5.0).marginOnly(left: 10.0,right: 10.0),

                                  MenuFetchView(categoryID: productData['title'],),


                                ])),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }

              return Container();
            },
          ),


        ),
      ),
    );
  }
}
