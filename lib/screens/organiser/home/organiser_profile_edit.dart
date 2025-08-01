import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/controller/menu_image_upload.dart';
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

import '../../../utils/cities.dart';
import '../../home/home_utils.dart';
import '../../profile/profile_utils.dart';


class OrganiserProfileEdit extends StatefulWidget {
  final bool isOrganiser;
  final bool isClub;
  final bool isEditEvent;
  final bool isInf;
  final bool isPromoter;
  final String eventId;
  final String eventPromotionId;

  const OrganiserProfileEdit(
      {Key? key,
      this.isOrganiser = false,
        this.isInf = false,
      this.isPromoter = false,
      this.isEditEvent = false,
      this.eventId = '',
      this.eventPromotionId = '',
      this.isClub = false})
      : super(key: key);

  @override
  State<OrganiserProfileEdit> createState() => _OrganiserProfileEditState();
}

class _OrganiserProfileEditState extends State<OrganiserProfileEdit> {
  bool isNineSixteen = false;
  final TextEditingController instaUserName = TextEditingController();
  final TextEditingController promoterName = TextEditingController();
  final TextEditingController agencyName = TextEditingController();
  final TextEditingController whatsappNumber = TextEditingController();
  final TextEditingController emailName = TextEditingController();
  final TextEditingController accountNo = TextEditingController();
  final TextEditingController reEnterAccountNo = TextEditingController();
  final TextEditingController ifscCode = TextEditingController();
  final TextEditingController holderName = TextEditingController();
  final TextEditingController bankName = TextEditingController();
  final TextEditingController upi = TextEditingController();

  String dropdownState = 'Andhra Pradesh',
      dropdownCity = 'Select City',
      dropdownCategory = '';

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
  List<Uint8List> webImages = [];
  var demoImage = [''];
  StreamSubscription? subscription;
  List coverImage = [];
  List offerImage = [];
  String dropGenre = "Select Menu Category";
  String eventName = "";
  DateTime startTimeHour = DateTime.now();
  bool dialogOther = false;
  final TextEditingController _otherCity = TextEditingController();
  List<String> categoryName = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  int durationInHours = 0;
  bool tableShow = false, entranceShow = false, showDate = false;

  _getFromGallery({bool isOffer = false}) async {
    await cropImageMultiple(!isOffer ? isNineSixteen : false, context: context).then((value) async{
      if (value.isNotEmpty) {
        if (isOffer) {
          offerImage = [];
        } else {
          coverImage = [];
        }
        for (CroppedFile image in value) {
          webImages.add(await image.readAsBytes());
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

  String category = '';

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

  void fetchEditEventsInf() async {
    try {
      await FirebaseFirestore.instance
          .collection("Influencer")
          .doc(uid())
          .get()
          .then((doc) async {
        if (doc.exists) {
          category = getKeyValueFirestore(doc, 'businessCategory') ?? '';
          instaUserName.text = getKeyValueFirestore(doc, 'instaUserName') ?? '';
          promoterName.text = getKeyValueFirestore(doc, 'username') ?? '';
          agencyName.text = getKeyValueFirestore(doc, 'companyMame') ?? '';
          whatsappNumber.text = getKeyValueFirestore(doc, 'whatsaapNo') ?? '';
          emailName.text = getKeyValueFirestore(doc, 'emailPhone') ?? '';
          dropdownCity = getKeyValueFirestore(doc, 'city') ?? 'Select City';
          dropdownState = getKeyValueFirestore(doc, 'state') ?? 'Andhra Pradesh';
          // offerImage = getKeyValueFirestore(doc, 'profile_image') ?? [];
          if (getKeyValueFirestore(doc, 'profile_image') != null) {
            offerImage.add(getKeyValueFirestore(doc, 'profile_image') ?? []);
          }
          setState(() {});
          print('check image url is ${offerImage}');
        } else {
          Fluttertoast.showToast(msg: "no data");
        }
      });
      await getEntranceFieldValues();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void fetchEditEventsPromotion() async {
    try {
      await FirebaseFirestore.instance
          .collection("Organiser")
          .doc(uid())
          .get()
          .then((doc) async {
        if (doc.exists) {
          category = getKeyValueFirestore(doc, 'businessCategory') ?? '';
          instaUserName.text = getKeyValueFirestore(doc, 'instaUserName') ?? '';
          promoterName.text = getKeyValueFirestore(doc, 'name') ?? '';
          agencyName.text = getKeyValueFirestore(doc, 'companyMame') ?? '';
          whatsappNumber.text = getKeyValueFirestore(doc, 'whatsaapNo') ?? '';
          emailName.text = getKeyValueFirestore(doc, 'emailPhone') ?? '';
          accountNo.text = getKeyValueFirestore(doc, 'accountNo') ?? '';
          reEnterAccountNo.text = getKeyValueFirestore(doc, 'accountNo') ?? '';
          ifscCode.text = getKeyValueFirestore(doc, 'ifsc') ?? '';
          holderName.text = getKeyValueFirestore(doc, 'holderName') ?? '';
          bankName.text = getKeyValueFirestore(doc, 'bankName') ?? '';
          upi.text = getKeyValueFirestore(doc, 'upi') ?? '';
          dropdownCity = getKeyValueFirestore(doc, 'city') ?? 'Select City';
          dropdownState = getKeyValueFirestore(doc, 'state') ?? 'Andhra Pradesh';
          // offerImage = getKeyValueFirestore(doc, 'profile_image') ?? [];
          offerImage.add(getKeyValueFirestore(doc, 'profile_image'));
          setState(() {});
          print('check image url is ${offerImage}');
        } else {
          Fluttertoast.showToast(msg: "no data");
        }
      });
      await getEntranceFieldValues();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
  void fetchEditEventsData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Organiser")
          .doc(uid())
          .get()
          .then((doc) async {
        if (doc.exists) {
          eventName = getKeyValueFirestore(doc, 'title') ?? '';
          // eventName = getKeyValueFirestore(doc, 'title') ?? '';
          // eventName = getKeyValueFirestore(doc, 'title') ?? '';
          // eventName = getKeyValueFirestore(doc, 'title') ?? '';
          // eventName = getKeyValueFirestore(doc, 'title') ?? '';
          // _briefEvent.text = getKeyValueFirestore(doc, 'briefEvent') ?? '';
          // _artistName.text = getKeyValueFirestore(doc, 'artistName') ?? '';
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
    super.initState();
    print("the uid is : ${uid()}");
    menuCategoryData();
    if(widget.isInf ==true){
      fetchEditEventsInf();
    }else{
    fetchEditEventsPromotion();
    }
    if (kDebugMode) {
      print(widget.eventId);
    }
    if (widget.isEditEvent) {

      fetchEditTableData();
    } else {
      getEntranceFieldValues(isDefault: true);
      getDefaultTableData();
    }
    // dropdownState = homeController.state.value;
    // dropdownCity = homeController.city.value;


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
    double carouselHeight = 300.w;
    return
        Column(
      children: [
        Stack(
          children: [
            Container(
                    height: carouselHeight,
                    width: Get.width - 400.w,
                    decoration:BoxDecoration(border: Border.all(color: Colors.white)),
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
          ],
        ),

        // ElevatedButton(
        //   onPressed: () async {
        //     _getFromGallery(isOffer: isOffer);
        //   },
        //   style: ButtonStyle(
        //       backgroundColor:
        //           WidgetStateProperty.resolveWith((states) => Colors.black)),
        //   child: Text(
        //     !isOffer ? "Upload Cover" : 'Promotional image',
        //     style: GoogleFonts.ubuntu(
        //       color: Colors.orange,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (dropdownCity == "Other") {
      setState(() {
        dialogOther = true;
      });
    } else {
      setState(() {
        _otherCity.text = "";
        dialogOther = false;
      });
    }
    List stateCity = getStateCity(dropdownState);

    List<String> itemsCity = [
      "Select City",
      ...stateCity,
      stateCity.contains(dropdownCity) == true || dropdownCity == "Select City"
          ? ""
          : dropdownCity
    ];
    return Scaffold(
      backgroundColor: matte(),
      appBar: appBar(context, title: "${widget.isInf?'Influencer':category=='2'?'PR':'Organiser'} Details"),
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
                    if(!widget.isInf)
                    Container(
                        // width: 400.w,
                        // height: 500.w,
                      // decoration: BoxDecoration(
                      //   shape: BoxShape.circle
                      // ),
                        child: GestureDetector(
                          onTap: () => Get.to(_getFromGallery(isOffer: true)),
                          child: Center(
                            child: imageCoverWidget(offerImage, uploadOffer,
                                isOffer: true),
                          ),
                        )),
                    // Container(
                    //     width: Get.width - 400.w,
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: [
                    //         Row(
                    //             mainAxisAlignment:
                    //                 MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Text(
                    //                 "Followers : 5000",
                    //                 style: GoogleFonts.ubuntu(
                    //                     fontSize: 40.sp,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.orange),
                    //               ),
                    //             ]).marginOnly(bottom: 20),
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             Column(
                    //               children: [
                    //                 Text(
                    //                   "195",
                    //                   style: GoogleFonts.ubuntu(
                    //                       fontSize: 40.sp,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.orange),
                    //                 ),
                    //                 Text(
                    //                   "Reels",
                    //                   style: GoogleFonts.ubuntu(
                    //                       fontSize: 40.sp,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.orange),
                    //                 ),
                    //               ],
                    //             ),
                    //             Column(
                    //               children: [
                    //                 Text(
                    //                   "3000",
                    //                   style: GoogleFonts.ubuntu(
                    //                       fontSize: 40.sp,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.orange),
                    //                 ),
                    //                 Text(
                    //                   "Story",
                    //                   style: GoogleFonts.ubuntu(
                    //                       fontSize: 40.sp,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.orange),
                    //                 ),
                    //               ],
                    //             ),
                    //             Column(
                    //               children: [
                    //                 Text(
                    //                   "125",
                    //                   style: GoogleFonts.ubuntu(
                    //                       fontSize: 40.sp,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.orange),
                    //                 ),
                    //                 Text(
                    //                   "Post",
                    //                   style: GoogleFonts.ubuntu(
                    //                       fontSize: 40.sp,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.orange),
                    //                 ),
                    //               ],
                    //             )
                    //           ],
                    //         ).marginOnly(bottom: 0,right: 20),
                    //       ],
                    //     )),
                  ],
                ).paddingZero.marginZero,
                if(widget.isInf)
                  Container(
                    width: 150,
                    height: 150,
                    // decoration: BoxDecoration(
                    //   shape: BoxShape.circle
                    // ),
                      child: GestureDetector(
                        onTap: () => Get.to(_getFromGallery(isOffer: true)),
                        child: Center(
                          child: imageCoverWidget(offerImage, uploadOffer,
                              isOffer: true),
                        ),
                      )),

                // textField("Instagram User Name", instaUserName),
                textField(widget.isInf?'Name':"Promoter Name", promoterName),
                textField(widget.isInf?'Company':"Promoter Agency / Company", agencyName),
                textField("Whatsapp Number", whatsappNumber, isNum: true ),
                textField("Email Address", emailName),
                Container(
                  height: 130.h,
                  width: 800.w,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: DropdownButton<String>(
                      alignment: Alignment.center,
                      items:
                          states.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          alignment: Alignment.center,
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        setState(() {
                          dropdownState = val!;
                          dropdownCity = "Select City";
                        });
                        Fluttertoast.showToast(msg: "Select city to continue");
                      },
                      value: dropdownState,
                      style: const TextStyle(color: Colors.white70),
                      dropdownColor: Colors.black,
                    ),
                  ),
                ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                SizedBox(
                  height: 50.h,
                ),
                Container(
                  height: 130.h,
                  width: 800.w,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Center(
                    child: DropdownButton<String>(
                      alignment: Alignment.center,
                      items: (itemsCity)
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          alignment: Alignment.center,
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        setState(() {
                          dropdownCity = val!;
                        });
                        dropdownCity != "Other" && dropdownCity != "Select City"
                            ? Get.defaultDialog(
                                title: "Change City",
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              if (dropdownCity !=
                                                      "Select City" ||
                                                  dropdownCity != "Other") {
                                                FirebaseFirestore.instance
                                                    .collection("Club")
                                                    .doc(uid())
                                                    .set(
                                                        {
                                                      "state": dropdownState,
                                                      "city": dropdownCity
                                                    },
                                                        SetOptions(
                                                            merge:
                                                                true)).whenComplete(
                                                        () {
                                                  getCurrentClub();
                                                  Get.back();
                                                  Fluttertoast.showToast(
                                                          msg:
                                                              "Updated Successfully")
                                                      .whenComplete(() =>
                                                          setState(() {}));
                                                });
                                              } else {
                                                Get.back();
                                                Fluttertoast.showToast(
                                                    msg: "Enter a valid city");
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )),
                                        const Text("Yes"),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            )),
                                        const Text("No"),
                                      ],
                                    )
                                  ],
                                ))
                            : Container();
                      },
                      value: dropdownCity,
                      style: const TextStyle(color: Colors.white70),
                      dropdownColor: Colors.black,
                    ),
                  ),
                ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('Account Detail',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                    ],
                  ),
                ),
                textField("Account Number", accountNo,isNum: true),
                textField("Re-enter Account Number", reEnterAccountNo,isNum: true),
                textField("IFSC", ifscCode),
                textField("Account Holder Name", holderName),
                textField("Bank Name", bankName),
                Text('OR',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                textField("UPI", upi),
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
                        if(widget.isInf){
                          profileUpdateInf();

                        }else{
                          if (_formKey.currentState?.validate() == true) {
                            try {

                              if(accountNo.text.isNotEmpty){
                                if(accountNo.text.toString() != reEnterAccountNo.text.toString()){
                                 Fluttertoast.showToast(msg: 'Account number does not match the re-entered account number');
                                  return;
                                }
                              }
                              EasyLoading.show();
                              Map<String, dynamic> sendData = {
                                'emailPhone': emailName.text,
                                'instaUserName': instaUserName.text,
                                'name': promoterName.text,
                                'companyMame': agencyName.text,
                                'whatsaapNo': whatsappNumber.text,
                                'state': dropdownState,
                                'city': dropdownCity,
                                'accountNo':accountNo.text,
                                'ifsc':ifscCode.text,
                                'holderName':holderName.text,
                                'bankName':bankName.text,
                                'upi':upi.text
                              };
                              String menuID = randomAlphaNumeric(10);
                              FirebaseFirestore.instance
                                  .collection("Organiser")
                                  .doc(uid())
                                  .set(sendData, SetOptions(merge: true))
                                  .whenComplete(() async {
                                if (uploadOffer.isNotEmpty) {
                                  await ProfileUploadImage(
                                      uploadOffer,
                                      menuID,
                                      homeController,
                                      webImages: webImages,
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
                                        ? 'Profile Updated'
                                        : "Profile Updated Successfully");
                              });

                            } catch (e) {
                              print(e);
                              Fluttertoast.showToast(msg: 'Something Went Wrong');
                            }
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
                        widget.isEditEvent ? "Update" : "Save",
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

  profileUpdateInf()async{
    if (_formKey.currentState?.validate() == true) {
      try {
        EasyLoading.show();
        Map<String, dynamic> sendData = {
          'emailPhone': emailName.text,
          'instaUserName': instaUserName.text,
          'username': promoterName.text,
          'companyMame': agencyName.text,
          'whatsaapNo': whatsappNumber.text,
          'state': dropdownState,
          'city': dropdownCity,
        };
        String menuID = randomAlphaNumeric(10);
        FirebaseFirestore.instance
            .collection("Influencer")
            .doc(uid())
            .set(sendData, SetOptions(merge: true))
            .whenComplete(() async {
          if (uploadOffer.isNotEmpty) {
            // await ProfileUploadImage(
            //     uploadOffer,
            //     menuID,
            //     homeController,
            //     webImages: webImages,
            //     coverImages: widget.isEditEvent
            //         ? uploadOffer.isEmpty
            //         ? offerImage
            //         : []
            //         : [],
            //     isOrganiser: widget.isOrganiser,
            //     isOffer: true);
          }
        }).whenComplete(() {
          EasyLoading.dismiss();
          Fluttertoast.showToast(
              msg: widget.isEditEvent
                  ? 'Profile Updated'
                  : "Profile Updated Successfully");
        });

      } catch (e) {
        print(e);
        Fluttertoast.showToast(msg: 'Something Went Wrong');
      }
    }
  }
}
