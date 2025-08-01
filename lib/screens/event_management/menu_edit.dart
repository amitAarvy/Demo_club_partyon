import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/menu_detail.dart';
import 'package:club/utils/app_const.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/screens/event_management/model/entrance_data_model.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:firebase_database/firebase_database.dart';
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
import 'controller/menu_image_upload.dart';
import 'event_management.dart';
import 'menu_category.dart';

class MenuEdit extends StatefulWidget {
  final String eventId;
  final String title;
  final String price;
  final String detail;
  final String image;
  final isEditEvent = false;
  final isOrganiser = false;

  const MenuEdit(this.eventId, this.title, this.price, this.detail, this.image,
      {super.key});

  @override
  State<MenuEdit> createState() => _MenuEditState();
}

class _MenuEditState extends State<MenuEdit> {
  bool isNineSixteen = false;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _briefEvent = TextEditingController();
  final TextEditingController _artistName = TextEditingController();
  final homeController = Get.put(HomeController());
  final eventController = Get.put(MenuEventController());
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
  final tableTypesController = Get.put(TableTypesController());
  final entranceTypesController = Get.put(EntranceTypesController());
  final entranceCategoryController = Get.put(EntranceCategoryController());
  final _formKey = GlobalKey<FormState>();
  List entranceList = [];
  List<File> uploadCover = [];
  List<File> uploadOffer = [];
  StreamSubscription? subscription;

  List coverImage = [];
  List offerImage = [];
  String dropGenre = "Select Menu Category";

  List<String> categoryName = [];

  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);

  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  int durationInHours = 0;

  bool tableShow = false, entranceShow = false, showDate = false;

  _getFromGallery({bool isOffer = false}) async {
    await cropImageMultiple(!isOffer ? isNineSixteen : false).then((value) {
      if (value.isNotEmpty) {
        if (isOffer) {
          offerImage = [];
        } else {
          coverImage = [];
        }
        for (CroppedFile image in value) {
          setState(() {
            if (isOffer) {
              uploadOffer.add(File((image.path).toString()));
            } else {
              uploadCover.add(File((image.path).toString()));
            }
          });
        }
      }
    });
  }

  void getDefaultTableData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Club")
          .doc(uid())
          .collection("DefaultTable")
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          tableTypesController.updateTypes(value.docs.length);
          for (int i = 0; i < value.docs.length; i++) {
            tableName[i].text = value.docs[i]["tableName"];
            tableAvailable[i].text = value.docs[i]["tableAvail"];
            tablePrice[i].text = value.docs[i]["tablePrice"];
            seatsAvailable[i].text = value.docs[i]["seatsAvail"];
          }
        }
      });
    } catch (e) {
      tableTypesController.updateTypes(1);
    }
  }

  void menuCategoryData() async {
    categoryName.add("Select Menu Category");
    try {
      await FirebaseFirestore.instance
          .collection("Menucategory")
          .where("clubUID", isEqualTo: uid())
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            categoryName.add(value.docs[i]["title"].toString());
          }
        }
      });
    } catch (e) {
      tableTypesController.updateTypes(1);
    }
  }

  void fetchEditTableData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Events")
          .doc(widget.eventId)
          .collection("Tables")
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          tableTypesController.updateTypes(value.docs.length);
          for (int i = 0; i < value.docs.length; i++) {
            tableTypesController.updateTypes(value.docs.length);
            tableName[i].text = value.docs[i]["tableName"].toString();
            tableAvailable[i].text = value.docs[i]["tableLeft"].toString();
            tablePrice[i].text = value.docs[i]["tablePrice"].toString();
            seatsAvailable[i].text = value.docs[i]["seatsLeft"].toString();
          }
        }
      });
    } catch (e) {
      tableTypesController.updateTypes(1);
    }
  }

//get text field values from server in edit Event
  Future<void> getEntranceFieldValues({
    isDefault = false,
  }) async {
    try {
      if (isDefault) {
        entranceList = await fetchEntranceDataDefault(widget.eventId.toString(),
            isDefault: isDefault);
      } else {
        await FirebaseDatabase.instance
            .ref()
            .child('Events')
            .child(widget.eventId!)
            .child('entranceList')
            .once()
            .then((event) async {
          if (event.snapshot.exists) {
            entranceList = event.snapshot.value as List;
          }
        });
      }
      entranceTypesController.updateTypes(entranceList.length);
      for (int i = 0; i < entranceList.length; i++) {
        final entranceData =
            EntranceDataModel.fromJson(Map.from(entranceList[i]));
        entranceCategoryController.updateTypes(
            i, entranceData.subCategory.length);
        entranceName[i].text = entranceData.categoryName;
        for (int j = 0; j < entranceData.subCategory.length; j++) {
          entryCategoryName[i][j].text =
              entranceData.subCategory[j].entryCategoryName.toString();
          entryCategoryCount[i][j].text =
              entranceData.subCategory[j].entryCategoryCount.toString();
          entryCategoryPrice[i][j].text =
              entranceData.subCategory[j].entryCategoryPrice.toString();
        }
      }
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void fetchEditEventsData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Menu")
          .doc(widget.eventId)
          .get()
          .then((doc) async {
        if (doc.exists) {
          _title.text = getKeyValueFirestore(doc, 'title') ?? '';
          _briefEvent.text = getKeyValueFirestore(doc, 'detail') ?? '';
          _artistName.text = getKeyValueFirestore(doc, 'price') ?? '';
          offerImage = getKeyValueFirestore(doc, 'menuImages') ?? [];

          setState(() {});
        }
      });
      await getEntranceFieldValues();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  bool checkTableNotEmpty(List<TextEditingController> list) {
    bool table = false;
    if (tableTypesController.tableTypes.value > 0) {
      for (int i = 0; i < tableTypesController.tableTypes.value; i++) {
        if (list[i].text.isNotEmpty) {
          table = true;
        } else {
          table = false;
        }
      }
    } else {
      table = true;
    }
    return table;
  }

  bool checkEntranceNotEmpty(List<TextEditingController> categoryList,
      List<List<TextEditingController>> subCategoryList) {
    int count = 0;
    for (int i = 0; i < entranceTypesController.entranceTypes.value; i++) {
      if (categoryList[i].text.isEmpty) {
        count++;
        break;
      }
      for (int j = 0;
          j < entranceCategoryController.entranceCategoryTypes[i].value;
          j++) {
        if (subCategoryList[i][j].text.isEmpty) {
          count++;
          break;
        }
      }
    }
    return count == 0;
  }

  Future<void> saveEntranceListRTDB(
      bool isEditEvent, String eventID, List entranceList) async {
    try {
      final rtdb = FirebaseDatabase.instance.ref();
      final entranceListRef =
          rtdb.child('Events').child(eventID).child('entranceList');
      if (kDebugMode) {
        print(eventID);
      }
      if (isEditEvent) {
        for (int i = 0; i < entranceTypesController.entranceTypes.value; i++) {
          final entranceNameData = entranceName[i].text;
          if (entranceNameData.isNotEmpty) {
            entranceListRef
                .child('$i')
                .update({'categoryName': entranceNameData});
            for (int j = 0;
                j < entranceCategoryController.entranceCategoryTypes[i].value;
                j++) {
              final entryCategoryNameData = (entryCategoryName[i][j].text);
              final entryCategoryCountData = (entryCategoryCount[i][j].text);
              if (kDebugMode) {
                print(entryCategoryNameData);
              }

              final entryCategoryPriceData = (entryCategoryPrice[i][j].text);
              if (entryCategoryNameData.isNotEmpty &&
                  entryCategoryCountData.isNotEmpty &&
                  entryCategoryPriceData.isNotEmpty) {
                int entryCategoryCountLeft = 0;
                await entranceListRef
                    .child('$i/subCategory/$j/entryCategoryCountLeft')
                    .once()
                    .then((event) {
                  if (event.snapshot.exists) {
                    entryCategoryCountLeft = int.parse(
                        (event.snapshot.value ?? entryCategoryCountData)
                            .toString());
                  }
                }).onError((error, stackTrace) {
                  entryCategoryCountLeft =
                      int.parse(entryCategoryCountData.toString());
                });
                entranceListRef.child('$i/subCategory/$j').update({
                  'entryCategoryName': entryCategoryNameData,
                  'entryCategoryCount':
                      int.parse(entryCategoryCountData.toString()),
                  'entryCategoryCountLeft':
                      int.parse(entryCategoryCountLeft.toString()),
                  'entryCategoryPrice':
                      int.parse(entryCategoryPriceData.toString())
                });
              } else {
                entranceListRef.child('$i/subCategory/$j').remove();
              }
            }
          } else {
            entranceListRef.child('$i').remove();
          }
        }
      } else {
        await entranceListRef.set(entranceList);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void onTapSoldOut(int index) {
    Get.defaultDialog(
        title: 'Are you sure?',
        content: Column(
          children: [
            Text(
              'This action cannot be undone.',
              style: GoogleFonts.ubuntu(color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customisedButton('Yes', buttonColor: Colors.green, onTap: () {
                  final ref = FirebaseDatabase.instance.ref(
                      'Events/${widget.eventId}/entranceList/$index/subCategory');
                  ref.once().then((value) {
                    final list = value.snapshot.value as List;
                    for (int i = 0; i < list.length; i++) {
                      ref.child('$i').update({'entryCategoryCountLeft': 0});
                    }
                  }).whenComplete(() {
                    Get.back();
                    getEntranceFieldValues();
                  });
                }).paddingSymmetric(horizontal: 50.w),
                customisedButton('No',
                    onTap: () => Get.back(), buttonColor: Colors.red)
              ],
            )
          ],
        ));
  }

  @override
  void initState() {
    menuCategoryData();
    fetchEditEventsData();
    if (kDebugMode) {
      print(widget.eventId);
    }
    if (widget.isEditEvent) {

      fetchEditTableData();
    } else {
      getEntranceFieldValues(isDefault: true);
      getDefaultTableData();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (subscription != null) {
      subscription?.cancel();
    }
    super.dispose();
  }

  Widget imageCoverWidget(List coverImages, List uploadImages,
      {bool isOffer = false, bool isNineSixteenValue = false}) {
    double carouselHeight =
        isNineSixteenValue && !isOffer ? (Get.width - 100.w) * 16 / 9 : 600.w;
    return Column(
      children: [
        Stack(
          children: [
            Container(
                    height: carouselHeight,
                    width: Get.width - 100.w,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.white)),
                    child: coverImages.isNotEmpty && uploadImages.isEmpty
                        ? eventCarousel(coverImages,
                            isEdit: true, height: carouselHeight)
                        : uploadImages.isEmpty
                            ? Center(
                                child: Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 300.h,
                              ))
                            : eventCarousel(uploadImages,
                                height: carouselHeight))
                .marginAll(20),
            Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 110.h,
                  width: 110.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                  ),
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.orange,
                      ),
                      onPressed: () => setState(() {
                        if (isOffer) {
                          offerImage = [];
                          uploadOffer = [];
                        } else {
                          uploadCover = [];
                          coverImage = [];
                        }
                      }),
                    ),
                  ),
                )).marginOnly(top: 75.h, right: 75.w)
          ],
        ),
        if (!isOffer)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Switch to 9/16',
                style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 50.sp),
              ),
              Switch(
                  activeColor: Colors.orange,
                  value: isNineSixteen,
                  onChanged: (value) {
                    setState(() {
                      isNineSixteen = value;
                    });
                  })
            ],
          ),
        ElevatedButton(
          onPressed: () async {
            _getFromGallery(isOffer: isOffer);
          },
          style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.resolveWith((states) => Colors.black)),
          child: Text(
            !isOffer ? "Upload Cover" : 'Item image',
            style: GoogleFonts.ubuntu(
              color: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: matte(),
      appBar: appBar(context, title: "Menu"),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {

                          try {
                            EasyLoading.show();

                            FirebaseFirestore.instance
                                .collection("Menu")
                                .doc(widget.eventId)
                                .delete()
                                .whenComplete(() {
                              EasyLoading.dismiss();

                              Fluttertoast.showToast(
                                  msg: "Item Delete Successfully");

                              Get.to(const MenuView());

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
                                  side: const BorderSide(color: Colors.white))),
                          backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => Colors.black)),
                      child: Text(
                        widget.isEditEvent ? "Delete Item" : "Delete Item",
                        style: GoogleFonts.ubuntu(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ).marginAll(20.h),

                Text(
                  "Create Menu",
                  style: GoogleFonts.ubuntu(
                      fontSize: 45.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
                Container(
                  height: 130.h,
                  width: Get.width - 100.w,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: DropdownButton(
                      items: categoryName
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          alignment: Alignment.center,
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        setState(() {
                          dropGenre = val!;
                        });
                      },
                      value: dropGenre,
                      style: const TextStyle(color: Colors.white70),
                      dropdownColor: Colors.black,
                    ),
                  ),
                ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                textField("Name", _title, isMandatory: true),
                textField("Price", _artistName, isMandatory: true),
                textField("Details(Optional)", _briefEvent,
                    isInfo: true, isMandatory: true),
                imageCoverWidget(offerImage, uploadOffer, isOffer: true),
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
                              (states) => Colors.black)),
                      child: Text(
                        widget.isEditEvent ? "Cancel" : "Cancel",
                        style: GoogleFonts.ubuntu(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50.w,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() == true) {
                          try {
                            if (_title.text.isNotEmpty &&
                                _artistName.text.isNotEmpty &&
                                dropGenre != "Select Menu Category") {
                              EasyLoading.show();
                              Map<String, dynamic> sendData = {
                                'clubUID': uid(),
                                'title': _title.text,
                                'detail': _briefEvent.text,
                                'price': _artistName.text,
                                'categoryID': dropGenre,
                                'status': 1,
                              };
                              FirebaseFirestore.instance
                                  .collection("Menu")
                                  .doc(widget.eventId)
                                  .set(sendData, SetOptions(merge: true))
                                  .whenComplete(() async {
                                if (uploadOffer.isNotEmpty) {
                                  await MenuUploadImage(uploadOffer,
                                      widget.eventId, homeController,
                                      coverImages: widget.isEditEvent
                                          ? uploadOffer.isEmpty
                                              ? offerImage
                                              : []
                                          : [],
                                      isOrganiser: widget.isOrganiser,
                                      isOffer: true);
                                }
                              }).whenComplete(() {
                                EasyLoading.dismiss();
                                Fluttertoast.showToast(
                                    msg: widget.isEditEvent
                                        ? 'Menu Updated'
                                        : "Menu Updated Successfully");

                                Get.to(const MenuView());


                              });
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Kindly fill all required fields");
                            }
                          } catch (e) {
                            print(e);
                            Fluttertoast.showToast(msg: 'Something Went Wrong');
                          }
                        }
                      },
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: const BorderSide(color: Colors.grey))),
                          backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => Colors.black)),
                      child: Text(
                        widget.isEditEvent ? "Update Menu" : "Save Menu",
                        style: GoogleFonts.ubuntu(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ).marginAll(20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
