import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:random_string/random_string.dart';

import 'menu_category_fetch.dart';

class MenuCategory extends StatefulWidget {
  final VoidCallback? onTap;
  final String? eventId;
  final bool isOrganiser;
  final bool isEditEvent;
  final String clubUID;
  final String venueName;

  const MenuCategory({
    this.eventId = '',
    this.isEditEvent = false,
    this.isOrganiser = false,
    this.clubUID = '',
    this.venueName = '',
    Key? key,this.onTap,
  }) : super(key: key);

  @override
  State<MenuCategory> createState() => _MenuCategoryState();
}

class _MenuCategoryState extends State<MenuCategory> {
  bool isNineSixteen = false;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _briefEvent = TextEditingController();
  final TextEditingController _artistName = TextEditingController();

  List<TextEditingController> tableName =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> seatsAvailable =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> tableAvailable =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> tablePrice =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> tableInclusion =
      List.generate(30, (i) => TextEditingController(text: ""));

  //Entrance
  List<TextEditingController> entranceName =
      List.generate(30, (i) => TextEditingController());
  List<TextEditingController> totalEntry =
      List.generate(30, (i) => TextEditingController());

  List<List<TextEditingController>> entryCategoryName = List.generate(
      30, (i) => List.generate(5, (index) => TextEditingController()));
  List<List<TextEditingController>> entryCategoryCount = List.generate(
      30, (i) => List.generate(5, (index) => TextEditingController()));
  List<List<TextEditingController>> entryCategoryPrice = List.generate(
      30, (i) => List.generate(5, (index) => TextEditingController()));

  List<TextEditingController> entryNotesList =
      List.generate(30, (i) => TextEditingController(text: ""));

  final _formKey = GlobalKey<FormState>();
  List entranceList = [];
  List<File> uploadCover = [];
  List<File> uploadOffer = [];
  StreamSubscription? subscription;

  List coverImage = [];
  List offerImage = [];
  String dropGenre = "Select Genre";
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);

  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  int durationInHours = 0;

  bool tableShow = false, entranceShow = false, showDate = false;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (subscription != null) {
      subscription?.cancel();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: matte(),
      appBar: appBar(context, title: "Create Category"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: Get.width,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // imageCoverWidget(coverImage, uploadCover,
                //     isNineSixteenValue: isNineSixteen),
                // imageCoverWidget(offerImage, uploadOffer, isOffer: true),
                SizedBox(
                  height: 20.h,
                ),

                textField("Category Name ", _title, isMandatory: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(color: Colors.grey))),
                          backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => Colors.red)),
                      child: Text(widget.isEditEvent ? "Cancel" : "Cancel"),
                    ),
                    SizedBox(
                      width: 50.w,
                    ),
                    ElevatedButton(
                      onPressed: () async {

                          try {
                            String categoryID = randomAlphaNumeric(10);
                            Map<String, dynamic> sendData = {
                              'clubUID':
                                  widget.isOrganiser ? widget.clubUID : uid(),
                              'title': _title.text,
                              'status': 1
                            };

                            FirebaseFirestore.instance
                                .collection("Menucategory")
                                .doc(categoryID)
                                .set(sendData, SetOptions(merge: true))
                                .whenComplete(() {
                              Fluttertoast.showToast(msg: 'Category Created');
                            });
                            _title.clear();
                            widget.onTap!();
                            setState(() {
                            });
                          } catch (e) {

                            print(e);
                            Fluttertoast.showToast(msg: 'Something Went Wrong');
                          }

                      },
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(color: Colors.grey))),
                          backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => Colors.green)),
                      child: Text(widget.isEditEvent ? "Update" : "Save"),
                    ),
                  ],
                ).marginAll(20.h),
                MenuCategoryView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
