import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/authentication/phyllo_integration/pyllo_init.dart';
import 'package:club/screens/event_management/controller/menu_image_upload.dart';
import 'package:club/screens/event_management/menu_detail.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:club/screens/home/influencer_home_pages/influ_start_promotion.dart';
import 'package:club/screens/insta-analytics/view_file/phyllo_view.dart';
import 'package:club/screens/organiser/event_management/promoter_page.dart';
import 'package:club/utils/app_const.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/screens/event_management/model/entrance_data_model.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/widgets/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
// import 'package:pod_player/pod_player.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';

import '../../pr_companies/create_camigns_second.dart';

class PromotionDetails extends StatefulWidget {
  final bool isOrganiser;
  final bool isClub;
  final bool isEditEvent;
  final bool isPromoter;
  final String clubId;
  final String eventPromotionId;
  final String collabType;
  final bool isInfluencer;
  final String? promotionRequestId;
  final String? type;
  final bool isElitePass;
  final bool isInstaLogin;
  final bool detailShow;

  const PromotionDetails(
      {Key? key,
      this.isOrganiser = false,
      this.isPromoter = false,
      this.isEditEvent = false,
        this.detailShow = false,
      this.eventPromotionId = '',
      required this.collabType,
      required this.clubId,
      this.isClub = false,
      this.isInfluencer = false,
      this.promotionRequestId,
      this.type,
      this.isElitePass = false,
      this.isInstaLogin = false})
      : super(key: key);

  @override
  State<PromotionDetails> createState() => _PromotionDetailsState();
}

class _PromotionDetailsState extends State<PromotionDetails> {
  bool isNineSixteen = false;

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
  var demoImage = [''];
  StreamSubscription? subscription;

  List coverImage = [];
  List offerImage = [];
  String dropGenre = "Select Menu Category";
  String _title = "";
  String _briefEvent = "";
  String pax = "";
  String inta = "";
  String _artistName = "";
  String eventName = "";
  String clubName = "";
  String clubAddress = "";

  String? promotionRequestId;
  dynamic mainData = "";
  dynamic currentUserData = "";

  List<String> categoryName = [];

  DateTime selectedDate = DateTime.now();
  DateTime dateTime = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);

  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  int durationInHours = 0;

  bool tableShow = false, entranceShow = false, showDate = false;

  bool showPromotionDropdowns = false;
  bool showPromotionalImage = false,
      showPostsImage = false,
      showReelImage = false;

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
          .doc(widget.clubId)
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
        entranceList = await fetchEntranceDataDefault(widget.clubId.toString(),
            isDefault: isDefault);
      } else {
        await FirebaseDatabase.instance
            .ref()
            .child('Events')
            .child(widget.clubId!)
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

  void fetchEditClubsData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Club")
          .doc(widget.clubId)
          .get()
          .then((doc) async {
        if (doc.exists) {
          clubName = getKeyValueFirestore(doc, 'clubName') ?? '';
          clubAddress = getKeyValueFirestore(doc, 'address') ?? '';
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

  void fetchEditEventsData() async {
    try {
      await FirebaseFirestore.instance
          .collection("EventPromotion")
          .doc(widget.eventPromotionId)
          .get()
          .then((doc) async {
        if (doc.exists) {
          QuerySnapshot<Map<String, dynamic>> promotionalDetail = widget.type !=
                      null &&
                  widget.type == 'influencer'
              ? await FirebaseFirestore.instance
                  .collection("InfluencerPromotionRequest")
                  .where('eventPromotionId', isEqualTo: widget.eventPromotionId)
                  .where('InfluencerID', isEqualTo: uid())
                  .get()
              : await FirebaseFirestore.instance
                  .collection("PromotionRequest")
                  .where('eventPromotionId', isEqualTo: widget.eventPromotionId)
                  .where('influencerPromotorId', isEqualTo: uid())
                  .get();
          mainData = doc.data() as Map<String, dynamic>;
          if (promotionalDetail.docs.isNotEmpty) {
            promotionRequestId = promotionalDetail.docs[0].id;
            mainData['status'] = (promotionalDetail.docs[0].data())['status'];
            mainData['promotionalData'] = promotionalDetail.docs[0].data();
          } else {
            mainData['status'] = 0;
          }
          _title = getKeyValueFirestore(doc, 'budget') ?? '';
          _briefEvent = getKeyValueFirestore(doc, 'detail') ?? '';
          pax = getKeyValueFirestore(doc, 'pax') ?? '';
          inta = getKeyValueFirestore(doc, 'inta') ?? '';
          _artistName = getKeyValueFirestore(doc, 'menu') ?? '';
          eventName = getKeyValueFirestore(doc, 'name') ?? '';
          durationInHours = getKeyValueFirestore(doc, 'duration') ?? 0;
          DateTime startTimeHour =
              getKeyValueFirestore(doc, 'startTime').toDate() ?? DateTime.now();
          DateTime startTimeHourgdgg =
              getKeyValueFirestore(doc, 'dateTime').toDate() ?? DateTime.now();

          startTime =
              TimeOfDay(hour: startTimeHour.hour, minute: startTimeHour.minute);
          durationInHours = getKeyValueFirestore(doc, 'duration') ?? 0;
          endTime = TimeOfDay(
              hour: startTimeHour.hour + durationInHours,
              minute: startTimeHour.minute);

          selectedDate = startTimeHour;
          dateTime = startTimeHourgdgg;

          setState(() {});
          fetchPendingRequests();
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
                      'Events/${widget.clubId}/entranceList/$index/subCategory');
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
    // menuCategoryData();
    print('check promotional event id ${widget.eventPromotionId}');
    fetchCurrentInfluencerData();
    if (widget.isEditEvent) {
      fetchEditEventsData();
      fetchEditClubsData();

      // fetchEditTableData();
    }
    super.initState();
  }

  // List eventList = [];

  // List<Map<String, dynamic>> eventList = [];

  // Define this at the top of your state class
  List<Map<String, dynamic>> eventList = [];

  Future<void> fetchPendingRequests() async {
    try {
      final eventId = mainData['eventId'];
      if (eventId == null) {
        print("Error: eventId is null in mainData");
        return;
      }

      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection("Events")
          .doc(eventId)
          .get();

      final data = eventDoc.data();
      if (data != null && data is Map<String, dynamic>) {
        setState(() {
          eventList.add({
            ...data,
            'id': eventDoc.id,
            'pomotionData': mainData,
          });
        });
      } else {
        print("Event data not found or invalid for eventId: $eventId");
      }

      log('Final event list: $eventList');
    } catch (e, stack) {
      print("Error fetching pending requests: $e");
      print("Stack Trace:\n$stack");
    }
  }





  void fetchCurrentInfluencerData() async {
    DocumentSnapshot userData = await FirebaseFirestore.instance
        .collection(
            widget.collabType == 'influencer' ? 'Influencer' : 'Organiser')
        .doc(uid())
        .get();
    currentUserData = userData;
    setState(() {});
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
    print('check it main  data ${mainData}');
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
  Widget rowDataWidget(String title,String subtitle){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title",
            style: GoogleFonts.ubuntu(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          SizedBox(height: 5,),
          Container(
            // height: 50,
            width: 1.sw,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(11)),
                border: Border.all(color:Colors.white)
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: Row(
                children: [
                  Center(
                    child: SizedBox(
                      width:0.7.sw,
                      child: Text(
                        "$subtitle",
                        style: GoogleFonts.ubuntu(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log('check main data is 1${mainData}');
    return Scaffold(
      appBar: appBar(
        context,
        title: mainData != "" ? mainData['eventName'] ?? "" : "",
      ),
      drawer: drawer(context: context),
      body: mainData == ""
          ? const Center(child: CircularProgressIndicator())
          // : widget.isElitePass
          //   ? Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 20),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.stretch,
          //       children: [
          //         const SizedBox(height: 15),
          //         Text("Offered Menu Items", style: GoogleFonts.ubuntu(
          //             color: Colors.white, fontSize: 45.sp, fontWe ight: FontWeight.bold)),
          //         const SizedBox(height: 10),
          //         Container(
          //           padding: EdgeInsets.all(15),
          //           width: Get.width - 100.w,
          //           // height: 100,
          //           decoration: BoxDecoration(
          //               color: Colors.grey.shade900,
          //               borderRadius: BorderRadius.circular(20)
          //           ),
          //           child: ListView.builder(
          //             shrinkWrap: true,
          //             physics: const NeverScrollableScrollPhysics(),
          //             itemCount: (mainData['offerFromMenu'] as List).where((element) => element['gender'] == (currentUserData.data()['gender'] ?? 'male') || (element['gender'] == "both" && (currentUserData.data()['gender'] ?? 'male') != 'others')).toList().first['menu'].length,
          //             itemBuilder: (context, index) {
          //               var data = (mainData['offerFromMenu'] as List).where((element) => element['gender'] == (currentUserData.data()['gender'] ?? 'male') || (element['gender'] == "both" && (currentUserData.data()['gender'] ?? 'male') != 'others')).toList().first['menu'];
          //               return Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   Text("${data[index]['title'].toString().capitalize}", style: GoogleFonts.ubuntu(color: Colors.white70)),
          //                   const SizedBox(height: 25),
          //                   Text("${data[index]['qty']}", style: GoogleFonts.ubuntu(color: Colors.white70)),
          //                 ],
          //               );
          //               // return MenuComponent(data: mainData['offerFromMenu'][index], index: index);
          //             },
          //           ),
          //         ),
          //       ],
          //     ),
          //   )
          : Container(
              width: Get.width,
              height: Get.height,
              color: Colors.black,
              child: SingleChildScrollView(
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
                          height: 50.h,
                        ),
                        if(widget.detailShow == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            height: 120.h,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Promotion Detail",
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if(widget.detailShow == true)
                        SizedBox(height: 10,),
                        if(widget.detailShow == true)
                        Padding(padding:const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                            Text('Deliverables:',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                            SizedBox(height: 5,),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:(mainData['deliverables']as List).map((e) =>  Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(11)),
                                      border: Border.all(color:Colors.white)
                                    ),

                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                      child: Text('$e',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),),
                                    )),
                                ),).toList()
                            ),
                              rowDataWidget('No Of Barter Collab: ',mainData['noOfBarterCollab'].toString()??''),
                              SizedBox(height: 5,),
                              rowDataWidget('No Of Promotion Collab: ',mainData['noOfPromoterCollab'].toString()??''),
                              SizedBox(height: 5,),
                              rowDataWidget('Offer commission Pr Entry: ',mainData['offeredCommissionPr']??''),
                              SizedBox(height: 5,),
                              rowDataWidget('Offer commission Pr Table: ',mainData['offeredCommissionTablePr']??''),
                              SizedBox(height: 5,),
                              rowDataWidget('Budget: ',mainData['budget']??''),
                              SizedBox(height: 5,),
                              rowDataWidget('Script: ',mainData['script']??''),
                              SizedBox(height: 5,),
                              rowDataWidget('Detail: ',mainData['detail']??''),
                              SizedBox(height: 5,),
                              rowDataWidget('Url: ',mainData['urlPromotion']??''),
                              SizedBox(height: 5,),
                              rowDataWidget('Coupon Code Entry : ',mainData['entryCoupon']==null?'':jsonDecode(mainData['entryCoupon'])['couponCode'].toString()??''),
                              SizedBox(height: 5,),
                              rowDataWidget('Coupon Code Table : ',mainData['tableCoupon'] ==null?'':jsonDecode(mainData['tableCoupon'])['couponCode'].toString()??''),
                              SizedBox(height: 10,),
                              Text('Offer From Menu :',style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),),
                              SizedBox(height: 5,),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:(mainData['offerFromMenu']as List).map((e) =>  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      width: 1.sw,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(11)),
                                            border: Border.all(color:Colors.white)
                                        ),

                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Gender :${e['gender']=='both'?'Male, Female':e['gender']??''}',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),),
                                             Padding(
                                               padding: const EdgeInsets.symmetric(horizontal: 10),
                                               child: Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: (e['menu'] as List).map((f) => Column(
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                     children: [
                                                     Text('Title :${f['title']??''}',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),),
                                                     Text('Price :${f['price']??''}',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),),
                                                     Text('QTY :${f['qty']??''}',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),),
                                                   ],),).toList(),
                                               ),
                                             )
                                            ],
                                          ),
                                        )),
                                  ),).toList()
                              ),



                          ]
                      ),
                     ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [


                              SizedBox(
                                height: 120.h,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${clubName.capitalize}",
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 120.h,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (mainData['amountPaid'].isNotEmpty)
                                      Text(
                                        "Amount Paid: ${mainData['amountPaid']}",
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.white70,
                                            fontSize: 18),
                                      ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(15),
                                width: Get.width - 100.w,
                                // height: 100,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Date : ${DateFormat.yMMMd().format(mainData['startTime'].toDate())}",
                                          style: GoogleFonts.ubuntu(
                                              color: Colors.white70,
                                              fontSize: 16),
                                        ),
                                        Text(
                                          "Time : ${DateFormat('hh : mm a').format(mainData['startTime'].toDate())}",
                                          style: GoogleFonts.ubuntu(
                                              color: Colors.white70,
                                              fontSize: 16),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      "Duration : ${DateTime.parse(mainData['endTime'].toDate().toString()).difference(DateTime.parse(mainData['startTime'].toDate().toString())).inHours.abs()} hours",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white70, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        if(mainData['influencerCommissionPercentage'] !=null)
                          SizedBox(height: 10,),
                        if(mainData['influencerCommissionPercentage'] !=null || mainData['influencerCommissionTablePercentage'] !=null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Text(
                                  "Offered Commission",
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        if(mainData['influencerCommissionPercentage'] !=null || mainData['influencerCommissionTablePercentage'] !=null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              width: 1.sw,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                children: [
                                  Text("ENTRY : ${mainData['influencerCommissionPercentage']??''}%",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
                                 if(mainData['influencerCommissionTablePercentage'] !=null)
                                  Text("TABLE : ${mainData['influencerCommissionTablePercentage']??''}%",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                          ),

                        if (!((mainData['promotionImages'] == null ||
                                mainData['promotionImages'].isEmpty) &&
                            (mainData['postImages'] == null ||
                                mainData['postImages'].isEmpty) &&
                            (mainData['reelsImages'] == null ||
                                mainData['reelsImages'].isEmpty)))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: InkWell(
                              overlayColor: WidgetStateProperty.resolveWith(
                                  (states) => Colors.transparent),
                              onTap: () {
                                setState(() {
                                  showPromotionDropdowns =
                                      !showPromotionDropdowns;
                                });
                              },
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Promotional Data (to be used)",
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showPromotionDropdowns =
                                                !showPromotionDropdowns;
                                          });
                                        },
                                        icon: Icon(
                                          showPromotionDropdowns == false
                                              ? Icons.arrow_drop_down
                                              : Icons.arrow_drop_up,
                                          color: Colors.white,
                                        ))
                                  ]),
                            ),
                          ),



                        if (showPromotionDropdowns)
                          Column(
                            children: [
                              if (mainData['promotionImages'] != null &&
                                  mainData['promotionImages'].isNotEmpty)
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Story",
                                        style: GoogleFonts.ubuntu(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              showPromotionalImage =
                                                  !showPromotionalImage;
                                            });
                                          },
                                          icon: Icon(
                                            showPromotionalImage == false
                                                ? Icons.arrow_drop_down
                                                : Icons.arrow_drop_up,
                                            color: Colors.white,
                                          ))
                                    ]),
                              if (showPromotionalImage &&
                                  mainData['promotionImages'] != null &&
                                  mainData['promotionImages'].isNotEmpty)
                                SizedBox(
                                  width: kIsWeb ? 300 : null,
                                  child: AspectRatio(
                                    aspectRatio: 9 / 16,
                                    child: PageView.builder(
                                      reverse: false,
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          mainData['promotionImages'].length,
                                      itemBuilder: (context, index) {
                                        Uri url = Uri.parse(
                                            mainData['promotionImages'][index]);
                                        if (lookupMimeType(url.path)!
                                            .contains("image/")) {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Center(
                                                child: Image.network(
                                                  mainData['promotionImages']
                                                      [index],
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                        child: Text(
                                                            "some error occurred",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)));
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (kIsWeb) {
                                                    Utils.downloadForWeb(mainData[
                                                            'promotionImages']
                                                        [index]);
                                                  } else {
                                                    FileDownloader.downloadFile(
                                                        url: mainData[
                                                                'promotionImages']
                                                            [index],
                                                        onDownloadCompleted:
                                                            (path) {
                                                          debugPrint(
                                                              "download complete hua: ${path}");
                                                        },
                                                        onDownloadError:
                                                            (errorMessage) {
                                                          debugPrint(
                                                              "download complete nhi hua error: ${errorMessage}");
                                                        },
                                                        onProgress: (fileName,
                                                            progress) {
                                                          debugPrint(
                                                              "download complete in progress");
                                                        },
                                                        notificationType:
                                                            NotificationType
                                                                .all);
                                                  }
                                                },
                                                child: Container(
                                                  // margin: EdgeInsets.only(right: 20),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              )
                                            ],
                                          );
                                        } else if (lookupMimeType(url.path)!
                                            .contains("video/")) {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Center(
                                                  child: CustomVideoPlayer(
                                                      link: mainData[
                                                              'promotionImages']
                                                          [index])),
                                              InkWell(
                                                onTap: () {
                                                  FileDownloader.downloadFile(
                                                      url: mainData[
                                                              'promotionImages']
                                                          [index],
                                                      onDownloadCompleted:
                                                          (path) {
                                                        debugPrint(
                                                            "download complete hua: ${path}");
                                                      },
                                                      onDownloadError:
                                                          (errorMessage) {
                                                        debugPrint(
                                                            "download complete nhi hua error: ${errorMessage}");
                                                      },
                                                      onProgress:
                                                          (fileName, progress) {
                                                        debugPrint(
                                                            "download complete in progress");
                                                      },
                                                      notificationType:
                                                          NotificationType.all);
                                                },
                                                child: Container(
                                                  // margin: EdgeInsets.only(right: 20),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              )
                                            ],
                                          );
                                        } else {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Center(
                                                child: Image.network(
                                                  mainData['promotionImages']
                                                      [index],
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return CustomVideoPlayer(
                                                        link: mainData[
                                                                'promotionImages']
                                                            [index]);
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  FileDownloader.downloadFile(
                                                      url: mainData[
                                                              'promotionImages']
                                                          [index],
                                                      onDownloadCompleted:
                                                          (path) {
                                                        debugPrint(
                                                            "download complete hua: ${path}");
                                                      },
                                                      onDownloadError:
                                                          (errorMessage) {
                                                        debugPrint(
                                                            "download complete nhi hua error: ${errorMessage}");
                                                      },
                                                      onProgress:
                                                          (fileName, progress) {
                                                        debugPrint(
                                                            "download complete in progress");
                                                      },
                                                      notificationType:
                                                          NotificationType.all);
                                                },
                                                child: Container(
                                                  // margin: EdgeInsets.only(right: 20),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              if (mainData['postImages'] != null &&
                                  mainData['postImages'].isNotEmpty)
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Posts",
                                        style: GoogleFonts.ubuntu(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              showPostsImage = !showPostsImage;
                                            });
                                          },
                                          icon: Icon(
                                            showPostsImage == false
                                                ? Icons.arrow_drop_down
                                                : Icons.arrow_drop_up,
                                            color: Colors.white,
                                          ))
                                    ]),
                              if (showPostsImage &&
                                  mainData['postImages'] != null &&
                                  mainData['postImages'].isNotEmpty)
                                SizedBox(
                                  width: kIsWeb ? 300 : null,
                                  child: AspectRatio(
                                    aspectRatio: 4 / 5,
                                    child: PageView.builder(
                                      reverse: false,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: mainData['postImages'].length,
                                      itemBuilder: (context, index) {
                                        Uri url = Uri.parse(
                                            mainData['postImages'][index]);
                                        if (lookupMimeType(url.path)!
                                            .contains("image/")) {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Center(
                                                child: Image.network(
                                                  mainData['postImages'][index],
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                        child: Text(
                                                            "some error occurred",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)));
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  FileDownloader.downloadFile(
                                                      url:
                                                          mainData['postImages']
                                                              [index],
                                                      onDownloadCompleted:
                                                          (path) {
                                                        debugPrint(
                                                            "download complete hua: ${path}");
                                                      },
                                                      onDownloadError:
                                                          (errorMessage) {
                                                        debugPrint(
                                                            "download complete nhi hua error: ${errorMessage}");
                                                      },
                                                      onProgress:
                                                          (fileName, progress) {
                                                        debugPrint(
                                                            "download complete in progress");
                                                      },
                                                      notificationType:
                                                          NotificationType.all);
                                                },
                                                child: Container(
                                                  // margin: EdgeInsets.only(right: 20),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else if (lookupMimeType(url.path)!
                                            .contains("video/")) {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Center(
                                                  child: CustomVideoPlayer(
                                                      link:
                                                          mainData['postImages']
                                                              [index])),
                                              InkWell(
                                                onTap: () {
                                                  FileDownloader.downloadFile(
                                                      url:
                                                          mainData['postImages']
                                                              [index],
                                                      onDownloadCompleted:
                                                          (path) {
                                                        debugPrint(
                                                            "download complete hua: ${path}");
                                                      },
                                                      onDownloadError:
                                                          (errorMessage) {
                                                        debugPrint(
                                                            "download complete nhi hua error: ${errorMessage}");
                                                      },
                                                      onProgress:
                                                          (fileName, progress) {
                                                        debugPrint(
                                                            "download complete in progress");
                                                      },
                                                      notificationType:
                                                          NotificationType.all);
                                                },
                                                child: Container(
                                                  // margin: EdgeInsets.only(right: 20),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Center(
                                                child: Image.network(
                                                  mainData['postImages'][index],
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return CustomVideoPlayer(
                                                        link: mainData[
                                                                'postImages']
                                                            [index]);
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  FileDownloader.downloadFile(
                                                      url:
                                                          mainData['postImages']
                                                              [index],
                                                      onDownloadCompleted:
                                                          (path) {
                                                        debugPrint(
                                                            "download complete hua: ${path}");
                                                      },
                                                      onDownloadError:
                                                          (errorMessage) {
                                                        debugPrint(
                                                            "download complete nhi hua error: ${errorMessage}");
                                                      },
                                                      onProgress:
                                                          (fileName, progress) {
                                                        debugPrint(
                                                            "download complete in progress");
                                                      },
                                                      notificationType:
                                                          NotificationType.all);
                                                },
                                                child: Container(
                                                  // margin: EdgeInsets.only(right: 20),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              if (mainData['reelsImages'] != null &&
                                  mainData['reelsImages'].isNotEmpty)
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Reels",
                                        style: GoogleFonts.ubuntu(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              showReelImage = !showReelImage;
                                            });
                                          },
                                          icon: Icon(
                                            showReelImage == false
                                                ? Icons.arrow_drop_down
                                                : Icons.arrow_drop_up,
                                            color: Colors.white,
                                          ))
                                    ]),
                              if (showReelImage &&
                                  mainData['reelsImages'] != null &&
                                  mainData['reelsImages'].isNotEmpty)
                                SizedBox(
                                  width: kIsWeb ? 300 : null,
                                  child: AspectRatio(
                                    aspectRatio: 9 / 16,
                                    child: PageView.builder(
                                      reverse: false,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: mainData['reelsImages'].length,
                                      itemBuilder: (context, index) {
                                        Uri url = Uri.parse(
                                            mainData['reelsImages'][index]);
                                        if (lookupMimeType(url.path)!
                                            .contains("image/")) {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Center(
                                                child: Image.network(
                                                  mainData['reelsImages']
                                                      [index],
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                        child: Text(
                                                            "some error occurred",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)));
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  FileDownloader.downloadFile(
                                                      url: mainData[
                                                          'reelsImages'][index],
                                                      onDownloadCompleted:
                                                          (path) {
                                                        debugPrint(
                                                            "download complete hua: ${path}");
                                                      },
                                                      onDownloadError:
                                                          (errorMessage) {
                                                        debugPrint(
                                                            "download complete nhi hua error: ${errorMessage}");
                                                      },
                                                      onProgress:
                                                          (fileName, progress) {
                                                        debugPrint(
                                                            "download complete in progress");
                                                      },
                                                      notificationType:
                                                          NotificationType.all);
                                                },
                                                child: Container(
                                                  // margin: EdgeInsets.only(right: 20),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              )
                                            ],
                                          );
                                        } else if (lookupMimeType(url.path)!
                                            .contains("video/")) {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Center(
                                                  child: CustomVideoPlayer(
                                                      link: mainData[
                                                              'reelsImages']
                                                          [index])),
                                              InkWell(
                                                onTap: () {
                                                  FileDownloader.downloadFile(
                                                      url: mainData[
                                                          'reelsImages'][index],
                                                      onDownloadCompleted:
                                                          (path) {
                                                        debugPrint(
                                                            "download complete hua: ${path}");
                                                      },
                                                      onDownloadError:
                                                          (errorMessage) {
                                                        debugPrint(
                                                            "download complete nhi hua error: ${errorMessage}");
                                                      },
                                                      onProgress:
                                                          (fileName, progress) {
                                                        debugPrint(
                                                            "download complete in progress");
                                                      },
                                                      notificationType:
                                                          NotificationType.all);
                                                },
                                                child: Container(
                                                  // margin: EdgeInsets.only(right: 20),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              )
                                            ],
                                          );
                                        } else {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Center(
                                                child: Image.network(
                                                  mainData['reelsImages']
                                                      [index],
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return CustomVideoPlayer(
                                                        link: mainData[
                                                                'reelsImages']
                                                            [index]);
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  FileDownloader.downloadFile(
                                                      url: mainData[
                                                          'reelsImages'][index],
                                                      onDownloadCompleted:
                                                          (path) {
                                                        debugPrint(
                                                            "download complete hua: ${path}");
                                                      },
                                                      onDownloadError:
                                                          (errorMessage) {
                                                        debugPrint(
                                                            "download complete nhi hua error: ${errorMessage}");
                                                      },
                                                      onProgress:
                                                          (fileName, progress) {
                                                        debugPrint(
                                                            "download complete in progress");
                                                      },
                                                      notificationType:
                                                          NotificationType.all);
                                                },
                                                child: Container(
                                                  // margin: EdgeInsets.only(right: 20),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: const Text("Download",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),


                        if ((widget.type != null && widget.type == "influencer" && mainData['promotionalData'] != null && mainData['promotionalData']['platforms'] != null &&
                                mainData['promotionalData']['platforms'].isNotEmpty) || (widget.type != null && widget.type == "venue" &&
                                mainData['platforms'] != null &&
                                mainData['platforms'].isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 10),
                                Text("Platform to be used",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  width: Get.width - 100.w,
                                  // height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: ((widget.type == "influencer"
                                            ? mainData['promotionalData']
                                                ['platforms']
                                            : mainData['platforms']) as List)
                                        .map(
                                      (e) {
                                        if (e == "Youtube") {
                                          return const Icon(
                                              PhosphorIcons.youtube_logo,
                                              color: Color(0xffFF0000),
                                              size: 30);
                                        }
                                        if (e == "Instagram") {
                                          return const Icon(
                                              PhosphorIcons.instagram_logo,
                                              color: Color(0xffFCAF45),
                                              size: 30);
                                        }
                                        if (e == "Facebook") {
                                          return const Icon(
                                              PhosphorIcons.facebook_logo,
                                              color: Color(0xff1877F2),
                                              size: 30);
                                        }
                                        if (e == "Linkedin") {
                                          return const Icon(
                                              PhosphorIcons.linkedin_logo,
                                              color: Color(0xff0077B5),
                                              size: 30);
                                        }
                                        if (e == "Twitter") {
                                          return const Icon(
                                              PhosphorIcons.twitter_logo,
                                              color: Color(0xff1DA1F2),
                                              size: 30);
                                        }
                                        return const Offstage();
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),


                        if (widget.type == null ||
                            (widget.type != null && widget.type == "venue") ||
                            (widget.type != null &&
                                widget.type == "influencer" &&
                                mainData['promotionalData'] != null &&
                                mainData['promotionalData']
                                        ['newDeliverables'] !=
                                    null &&
                                mainData['promotionalData']['newDeliverables']
                                        .length !=
                                    1 &&
                                mainData['promotionalData']['newDeliverables']
                                        [0]
                                    .isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 10),
                                Text("Deliverables",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  width: Get.width - 100.w,
                                  // height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: widget.type != null &&
                                            widget.type == "influencer"
                                        ? mainData['promotionalData']
                                                ['newDeliverables']
                                            .length
                                        : mainData['deliverables'].length,
                                    itemBuilder: (context, index) {
                                      String item = widget.type != null &&
                                              widget.type == "influencer"
                                          ? mainData['promotionalData']
                                              ['newDeliverables'][index]
                                          : mainData['deliverables'][index];
                                      if (item.isEmpty) return const Offstage();
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        margin: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 0.5),
                                            borderRadius:
                                                BorderRadius.circular(60)),
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                  color: Colors.primaries[
                                                          index %
                                                                  Colors
                                                                      .primaries
                                                                      .length +
                                                              10]
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1000)),
                                              child: Center(
                                                  child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                    color: Colors.primaries[
                                                        index %
                                                                Colors.primaries
                                                                    .length +
                                                            10]),
                                              )),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                                child: Text(item,
                                                    style: GoogleFonts.ubuntu(
                                                        color: Colors.white70,
                                                        fontWeight:
                                                            FontWeight.w600))),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.type == null ||
                            (widget.type != null &&
                                widget.type == "influencer" &&
                                mainData['promotionalData'] != null &&
                                mainData['promotionalData']['newScript'] !=
                                    null &&
                                mainData['promotionalData']['newScript']
                                    .isNotEmpty) ||
                            (widget.type != null &&
                                widget.type == "venue" &&
                                mainData['script'] != null &&
                                mainData['script'].isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 15),
                                Text("Scripts",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  width: Get.width - 100.w,
                                  // height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                    "${widget.type != null && widget.type == "influencer" ? mainData['promotionalData']['newScript'] : mainData['script']}",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white70, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.type == null ||
                            (widget.type != null &&
                                mainData['offeredBarterItem'] != null &&
                                mainData['offeredBarterItem'].isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 15),
                                Text("Offered barter item",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  width: Get.width - 100.w,
                                  // height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                    "${mainData['offeredBarterItem']}",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white70, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.type == null ||
                            (widget.type != null &&
                                widget.type == "influencer" &&
                                mainData['promotionalData'] != null &&
                                mainData['promotionalData']['url'] != null &&
                                mainData['promotionalData']['url']
                                    .isNotEmpty) ||
                            (widget.type != null &&
                                widget.type == "venue" &&
                                mainData['url'] != null &&
                                mainData['url'].isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 15),
                                Text("URL",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  width: Get.width - 100.w,
                                  // height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${widget.type == "influencer" ? mainData['promotionalData']['urlPromotion'] : mainData['urlPromotion']}",
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white70,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(ClipboardData(
                                                      text:
                                                          "${widget.type == "influencer" ? mainData['promotionalData']['url'] : mainData['url']}"));
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Copied to Clipboard');
                                                },
                                                child: const Icon(
                                                  Icons.copy,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        ),
                                      ),
                                      // GestureDetector(
                                      //     onTap: () {
                                      //       Clipboard.setData(ClipboardData(
                                      //           text:
                                      //               "${widget.type == "influencer" ? mainData['promotionalData']['url'] : mainData['url']}"));
                                      //       Fluttertoast.showToast(
                                      //           msg: 'Copied to Clipboard');
                                      //     },
                                      //     child: const Icon(
                                      //       Icons.copy,
                                      //       color: Colors.white,
                                      //     ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.type == null ||
                            (widget.type != null &&
                                widget.type == "influencer" &&
                                mainData['promotionalData'] != null &&
                                mainData['promotionalData']['url'] != null &&
                                mainData['promotionalData']['url']
                                    .isNotEmpty) ||
                            (widget.type != null &&
                                widget.type == "venue" &&
                                mainData['url'] != null &&
                                mainData['url'].isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 15),
                                Text("Amount per couple",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  width: Get.width - 100.w,
                                  // height: 100,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${widget.type == "influencer" ? mainData['promotionalData']['budget'] :
                                                '600'// mainData['budget']
                                                }",
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white70,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(ClipboardData(
                                                      text:
                                                          "${widget.type == "influencer" ? mainData['promotionalData']['url'] : mainData['url']}"));
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Copied to Clipboard');
                                                },
                                                child: const Icon(
                                                  Icons.copy,
                                                  color: Colors.white,
                                                ))
                                          ],
                                        ),
                                      ),
                                      // GestureDetector(
                                      //     onTap: () {
                                      //       Clipboard.setData(ClipboardData(
                                      //           text:
                                      //               "${widget.type == "influencer" ? mainData['promotionalData']['url'] : mainData['url']}"));
                                      //       Fluttertoast.showToast(
                                      //           msg: 'Copied to Clipboard');
                                      //     },
                                      //     child: const Icon(
                                      //       Icons.copy,
                                      //       color: Colors.white,
                                      //     ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        if (widget.type == null ||
                            (widget.type != null &&
                                widget.type == "influencer" &&
                                mainData['promotionalData'] != null &&
                                mainData['promotionalData']['isPaid'] != null &&
                                mainData['promotionalData']['isPaid'] ==
                                    false) ||
                            (widget.type != null &&
                                widget.type == "venue" &&
                                mainData['isPaid'] != null &&
                                mainData['isPaid'] == false))
                          if (currentUserData.data() != null &&
                              (mainData['offerFromMenu'] as List)
                                  .where((element) =>
                                      element['gender'] ==
                                          (currentUserData.data()['gender'] ??
                                              'male') ||
                                      (element['gender'] == "both" &&
                                          (currentUserData.data()['gender'] ??
                                                  'male') !=
                                              'others'))
                                  .toList()
                                  .isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 15),
                                  Text("Offered Menu Items",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    width: Get.width - 100.w,
                                    // height: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade900,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: (mainData['offerFromMenu']
                                              as List)
                                          .where((element) =>
                                              element['gender'] ==
                                                  (currentUserData
                                                          .data()['gender'] ??
                                                      'male') ||
                                              (element['gender'] == "both" &&
                                                  (currentUserData.data()[
                                                              'gender'] ??
                                                          'male') !=
                                                      'others'))
                                          .toList()
                                          .first['menu']
                                          .length,
                                      itemBuilder: (context, index) {
                                        var data = (mainData['offerFromMenu']
                                                as List)
                                            .where((element) =>
                                                element['gender'] ==
                                                    (currentUserData
                                                            .data()['gender'] ??
                                                        'male') ||
                                                (element['gender'] == "both" &&
                                                    (currentUserData.data()[
                                                                'gender'] ??
                                                            'male') !=
                                                        'others'))
                                            .toList()
                                            .first['menu'];
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                "${data[index]['title'].toString().capitalize}",
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white70)),
                                            const SizedBox(height: 25),
                                            Text("${data[index]['qty']}",
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.white70)),
                                          ],
                                        );
                                        // return MenuComponent(data: mainData['offerFromMenu'][index], index: index);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        if (!widget.isElitePass)
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              if (mainData['status'] == 1)
                                Text("Declined",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.red, fontSize: 17))
                              else if (mainData['status'] == 2)
                                Text("Pending",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.yellow, fontSize: 17))
                              else if (mainData['status'] == 4)
                                if (widget.isPromoter)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Accepted",
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.green,
                                                fontSize: 17)),
                                        GestureDetector(
                                          onTap: () async {
                                           await fetchPendingRequests();
                                            setState(() {
                                              widget.isInstaLogin == true;
                                            });
                                            // Get.to(const PhylloView());

                                            print('event list is ${eventList[0]}');
                                            Get.to(
                                                CampaignsTabBar(callBack: () {  },data: eventList[0] ,id: widget.eventPromotionId,)
                                            //     PromoterPage(
                                            //   eventPromotionId:
                                            //       widget.eventPromotionId,
                                            //   clubId: mainData['clubUID'],
                                            // )
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: const Text("Start Promotion",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                else if (widget.isInfluencer)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Accepted",
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.green,
                                                fontSize: 17)),
                                        GestureDetector(
                                          onTap: () {

                                            Get.to(CheckUniqueId(data: mainData,));
                                            // Get.to(InfluStartPromotion(
                                            //     data: mainData));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: const Text("Start Promotion",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                else
                                  Text("Accepted",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.green, fontSize: 17))
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          EasyLoading.show();
                                          // if(widget.isInfluencer && widget.promotionRequestId != null){
                                          // await FirebaseFirestore.instance
                                          //     .collection("PromotionRequest")
                                          //     .doc(widget.promotionRequestId)
                                          //     .set(
                                          //     {'status' : 1},
                                          //     SetOptions(merge: true),
                                          // ).then((value) {
                                          //   fetchEditEventsData();
                                          //   Fluttertoast.showToast(
                                          //       msg: "Declined Successfully");
                                          // },);
                                          // }else{
                                          //   Map<String, dynamic> sendData = {
                                          //     'promoterId': uid(),
                                          //     'eventPromotionId': widget.eventPromotionId,
                                          //     'clubId': widget.clubId,
                                          //     'status': 1,
                                          //     'isClub': widget.isClub,
                                          //     'dateTime':dateTime,
                                          //     'name': eventName,
                                          //     'startTime': selectedDate,
                                          //   };

                                          Map<String, dynamic> sendData = {
                                            "influencerPromotorId": uid(),
                                            'eventPromotionId':
                                                widget.eventPromotionId,
                                            'status': 1,
                                          };

                                          String menuID = promotionRequestId ??
                                              const Uuid().v4();

                                          FirebaseFirestore.instance
                                              .collection("PromotionRequest")
                                              .doc(menuID)
                                              .set(sendData,
                                                  SetOptions(merge: true))
                                              .then(
                                            (value) {
                                              EasyLoading.dismiss();
                                              fetchEditEventsData();
                                              Fluttertoast.showToast(
                                                  msg: widget.isEditEvent
                                                      ? 'Declined Successfully'
                                                      : "Declined Successfully");
                                            },
                                          );

                                          // FirebaseFirestore.instance
                                          //     .collection("EventPromotionDetail")
                                          //     .where('eventPromotionId',
                                          //     isEqualTo: widget.eventPromotionId)
                                          //     .where('promoterId', isEqualTo: uid())
                                          //     .get()
                                          //     .then((doc) async {
                                          //   if (doc.docs.isNotEmpty) {
                                          //     // categoryName.add(doc.docs[i]["title"].toString());
                                          //     FirebaseFirestore.instance
                                          //         .collection("EventPromotionDetail")
                                          //         .doc(doc.docs.first.id)
                                          //         .set(sendData, SetOptions(merge: true))
                                          //         .whenComplete(() {
                                          //       EasyLoading.dismiss();
                                          //       Fluttertoast.showToast(
                                          //           msg: widget.isEditEvent
                                          //               ? 'Declined Successfully'
                                          //               : "Declined Successfully");
                                          //     });
                                          //   } else {
                                          //     FirebaseFirestore.instance
                                          //         .collection("EventPromotionDetail")
                                          //         .doc(menuID)
                                          //         .set(sendData, SetOptions(merge: true))
                                          //         .whenComplete(() {
                                          //       EasyLoading.dismiss();
                                          //       Fluttertoast.showToast(
                                          //           msg: widget.isEditEvent
                                          //               ? 'Declined Successfully'
                                          //               : "Declined Successfully");
                                          //     });
                                          //   }
                                          //   fetchEditEventsData();
                                          // });
                                          // }
                                        } catch (e) {
                                          print(e);
                                          Fluttertoast.showToast(
                                              msg: 'Something Went Wrong');
                                        } finally {
                                          EasyLoading.dismiss();
                                        }
                                      },
                                      style: ButtonStyle(
                                          shape: WidgetStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  side: const BorderSide(
                                                      color: Colors.grey))),
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith(
                                                  (states) => Colors.black)),
                                      child: Text(
                                        widget.isEditEvent
                                            ? "Decline"
                                            : "Declined",
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
                                        print('check event promotion id ${widget.eventPromotionId}');
                                        try {
                                          EasyLoading.show();
                                          Map<String, dynamic> sendData = {
                                            "influencerPromotorId": uid(),
                                            'eventPromotionId': widget.eventPromotionId,
                                            'status': 4,
                                            // 'status': 2,
                                            "notification":true,
                                            "venueId":widget.clubId,
                                            "collabType":widget.collabType,
                                          };

                                          String menuID = promotionRequestId ??
                                              const Uuid().v4();
                                          if (widget.type != null &&
                                              widget.type == 'influencer') {
                                            FirebaseFirestore.instance
                                                .collection(
                                                    "InfluencerPromotionRequest")
                                                .doc(menuID)
                                                .set({
                                              // "status": 2
                                              "status": 4
                                            }, SetOptions(merge: true)).then(
                                              (value) {
                                                EasyLoading.dismiss();
                                                fetchEditEventsData();
                                                Fluttertoast.showToast(
                                                    msg: widget.isEditEvent
                                                        ? 'Accept Successfully'
                                                        : "Accept Successfully");
                                              },
                                            );
                                          } else {
                                            print('check list is ${menuID}');
                                            FirebaseFirestore.instance
                                                .collection("PromotionRequest")
                                                .doc(menuID)
                                                .set(sendData,
                                                    SetOptions(merge: true))
                                                .then(
                                              (value) {
                                                EasyLoading.dismiss();
                                                fetchEditEventsData();
                                                Fluttertoast.showToast(
                                                    msg: widget.isEditEvent
                                                        ? 'Accept Successfully'
                                                        : "Accept Successfully");
                                              },
                                            );
                                          }
                                          // if(widget.isInfluencer && widget.promotionRequestId != null){
                                          //   await FirebaseFirestore.instance
                                          //       .collection("PromotionRequest")
                                          //       .doc(widget.promotionRequestId)
                                          //       .set(
                                          //     {'status' : 4},
                                          //     SetOptions(merge: true),
                                          //   ).then((value) {
                                          //     fetchEditEventsData();
                                          //     Fluttertoast.showToast(
                                          //         msg: "Accept Successfully");
                                          //   },);
                                          // }else{
                                          //   Map<String, dynamic> sendData = {
                                          //     'promoterId': uid(),
                                          //     'eventPromotionId': widget.eventPromotionId,
                                          //     'clubId': widget.clubId,
                                          //     'status': 2,
                                          //     'isClub': widget.isClub,
                                          //     'dateTime':dateTime,
                                          //     'name': eventName,
                                          //     'startTime': selectedDate,
                                          //   };
                                          //
                                          //   String menuID = randomAlphaNumeric(10);
                                          //
                                          //   FirebaseFirestore.instance
                                          //       .collection("EventPromotionDetail")
                                          //       .where('eventPromotionId',
                                          //       isEqualTo: widget.eventPromotionId)
                                          //       .where('promoterId', isEqualTo: uid())
                                          //       .get()
                                          //       .then((doc) async {
                                          //     if (doc.docs.isNotEmpty) {
                                          //       // categoryName.add(doc.docs[i]["title"].toString());
                                          //       FirebaseFirestore.instance
                                          //           .collection("EventPromotionDetail")
                                          //           .doc(doc.docs.first.id)
                                          //           .set(sendData, SetOptions(merge: true))
                                          //           .whenComplete(() {
                                          //         EasyLoading.dismiss();
                                          //         Fluttertoast.showToast(
                                          //             msg: widget.isEditEvent
                                          //                 ? 'Accept Successfully'
                                          //                 : "Accept Successfully");
                                          //       });
                                          //     } else {
                                          //       FirebaseFirestore.instance
                                          //           .collection("EventPromotionDetail")
                                          //           .doc(menuID)
                                          //           .set(sendData, SetOptions(merge: true))
                                          //           .whenComplete(() {
                                          //         EasyLoading.dismiss();
                                          //         Fluttertoast.showToast(
                                          //             msg: widget.isEditEvent
                                          //                 ? 'Accept Successfully'
                                          //                 : "Accept Successfully");
                                          //       });
                                          //     }
                                          //     fetchEditEventsData();
                                          //   });
                                          // }
                                        } catch (e) {
                                          print(e);
                                          Fluttertoast.showToast(msg: 'Something Went Wrong');
                                        } finally {
                                          EasyLoading.dismiss();
                                        }
                                      },
                                      style: ButtonStyle(
                                          shape: WidgetStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  side: const BorderSide(
                                                      color: Colors.grey))),
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith(
                                                  (states) => Colors.black)),
                                      child: Text(
                                        widget.isEditEvent
                                            ? "Accept"
                                            : "Accept",
                                        style: GoogleFonts.ubuntu(
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ).marginAll(20.h),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}


class CheckUniqueId extends StatefulWidget {
  final data;
  const CheckUniqueId({super.key, this.data});

  @override
  State<CheckUniqueId> createState() => _CheckUniqueIdState();
}

class _CheckUniqueIdState extends State<CheckUniqueId> {
  List allUniqueId = [];
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  TextEditingController uniqueName = TextEditingController();


  uniqueIdGenerate()async{
    print('check call this function');
    isLoading.value =true;
    var data =  await FirebaseFirestore.instance.collection('UniqueInfluencerId').get();
    allUniqueId = data.docs;
    List uniqueId = data.docs.where((e)=>getKeyValueFirestore(e, 'infId') ==uid()).toList();
    print('check this is ${uniqueId}');
    if(uniqueId.isEmpty){
      modalBottomSheet(context);
    }else{
      couponCodeNew.value =uniqueId[0]['couponId'].toString();
      Get.off(CreateCamignsSecond(callBack: () {  },data: widget.data,isInf: true,couponId: uniqueId[0]['couponId'].toString(),));
    }
    setState(() {});
    isLoading.value =false;
  }

  ValueNotifier<String?> couponCodeNew = ValueNotifier(null);

  void modalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Get.back();
            Get.back();
            return false;
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),            child: Material(
            color: Colors.black54,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Please provide a unique name for the coupon code.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  textField('Enter your unique name', uniqueName, isMandatory: true,isWithOutSpace: true,isUpperCase: true),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if(uniqueName.text.isEmpty){
                            Fluttertoast.showToast(msg: 'Please enter unique id');
                            return ;
                          }
                          List match = allUniqueId.where((e)=>getKeyValueFirestore(e, 'couponId') == uniqueName.text.toString()).toList();
                          if(match.isNotEmpty){
                            Fluttertoast.showToast(msg: 'The name already exists.');
                            return ;
                          }
                          FirebaseFirestore.instance.collection('UniqueInfluencerId').doc().set({
                            "infId":uid(),
                            "couponId":uniqueName.text
                          }).whenComplete(() {
                            Get.back();
                            Get.back();
                            Fluttertoast.showToast(msg: 'Update successful');
                          },);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: const Center(
                            child: Text(
                              'Update',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uniqueIdGenerate();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, value, child) {
          return Center(child: CircularProgressIndicator(color: Colors.orangeAccent,));
        },
      ),
    );
  }
}


class CustomVideoPlayer extends StatefulWidget {
  final dynamic link;

  const CustomVideoPlayer({super.key, required this.link});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  // late PodPlayerController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.link is File) {
      // controller = PodPlayerController(
        //   playVideoFrom: PlayVideoFrom.file(widget.link),
        //   podPlayerConfig: const PodPlayerConfig(autoPlay: false))
        // ..initialise().then((value) => setState(() {}));
    } else {
      // controller = PodPlayerController(
      //     playVideoFrom: PlayVideoFrom.network(widget.link),
      //     podPlayerConfig: const PodPlayerConfig(autoPlay: false))
      //   ..initialise().then((value) => setState(() {}));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      // controller.videoPlayerValue == null
      //   ? const Center(child: CircularProgressIndicator())
      //   :
      Container();
    // PodVideoPlayer(
    //         controller: controller,
    //         videoAspectRatio: controller.videoPlayerValue!.aspectRatio,
    //         frameAspectRatio: controller.videoPlayerValue!.aspectRatio);
  }
}

class MenuComponent extends StatefulWidget {
  final dynamic data;
  final int index;

  const MenuComponent({super.key, required this.data, required this.index});

  @override
  State<MenuComponent> createState() => _MenuComponentState();
}

class _MenuComponentState extends State<MenuComponent> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // GestureDetector(
        //   onTap: () {
        //     expanded = !expanded;
        //     setState(() {});
        //   },
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        //     margin: const EdgeInsets.all(5),
        //     decoration: BoxDecoration(
        //         border: Border.all(color: Colors.white, width: 0.5),
        //         borderRadius: BorderRadius.circular(1000)
        //     ),
        //     child: Row(
        //       children: [
        //         Container(
        //           height: 40,
        //           width: 40,
        //           decoration: BoxDecoration(
        //               color: Colors.primaries[widget.index % Colors.primaries.length+10].withOpacity(0.3),
        //               borderRadius: BorderRadius.circular(1000)
        //           ),
        //           child: Center(child: Icon(Icons.food_bank_outlined, color: Colors.primaries[widget.index % Colors.primaries.length+10])),
        //         ),
        //         const SizedBox(width: 10),
        //         Text("${widget.data['gender'].toString().capitalize}", style: GoogleFonts.ubuntu(color: Colors.white70)),
        //         const Spacer(),
        //         Icon(expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.white)
        //       ],
        //     ),
        //   ),
        // ),
        // if(expanded)
        ListView.builder(
          padding: const EdgeInsets.all(5),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.data['menu'].length,
          itemBuilder: (context, menuIndex) {
            var menu = widget.data['menu'][menuIndex];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: const BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text("Dish", style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w800)),
                  //     Text(, style: GoogleFonts.ubuntu(color: Colors.white70)),
                  //   ],
                  // ),
                  // const SizedBox(height: 10),
                  // Row(
                  //   children: [
                  //     Text("Price : ", style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w800)),
                  //     Text("${menu['price']}", style: GoogleFonts.ubuntu(color: Colors.white70)),
                  //   ],
                  // ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${menu['title']}",
                          style: GoogleFonts.ubuntu(
                              color: Colors.white70,
                              fontWeight: FontWeight.w800)),
                      Text("${menu['qty']}",
                          style: GoogleFonts.ubuntu(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
