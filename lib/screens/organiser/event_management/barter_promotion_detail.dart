import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/menu_detail.dart';
import 'package:club/utils/app_const.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/screens/event_management/model/entrance_data_model.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:mime/mime.dart';
// import 'package:pod_player/pod_player.dart';
import 'package:random_string/random_string.dart';

import '../../event_management/controller/event_management_controller.dart';

class BarterPromotionDetails extends StatefulWidget {
  final bool isOrganiser;
  final bool isClub;
  final bool isEditEvent;
  final bool isPromoter;
  final String clubId;
  final String barterCollabId;
  final bool isInfluencer;
  final String? promotionRequestId;

  const BarterPromotionDetails(
      {Key? key,
      this.isOrganiser = false,
      this.isPromoter = false,
      this.isEditEvent = false,
      this.barterCollabId = '',
      required this.clubId,
      this.isClub = false,
      this.isInfluencer = false,
      this.promotionRequestId})
      : super(key: key);

  @override
  State<BarterPromotionDetails> createState() => _BarterPromotionDetailsState();
}

class _BarterPromotionDetailsState extends State<BarterPromotionDetails> {
  bool isNineSixteen = false;

  final homeController = Get.put(HomeController());
  final eventController = Get.put(EventController());
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

  dynamic mainData = "";

  List<String> categoryName = [];

  DateTime selectedDate = DateTime.now();
  DateTime dateTime = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);

  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  int durationInHours = 0;

  bool tableShow = false, entranceShow = false, showDate = false;


  bool showPromotionDropdowns = false;
  bool showPromotionalImage = false, showPostsImage = false, showReelImage = false;

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
          .collection("BarterCollab")
          .doc(widget.barterCollabId)
          .get()
          .then((doc) async {
        if (doc.exists) {
          mainData = doc.data() as Map<String, dynamic>;
          await FirebaseFirestore.instance
              .collection("PromotionRequest")
              .where("barterCollabId", isEqualTo: widget.barterCollabId)
              .where("InfluencerID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .get().then((request) async{
                if(request.docs.isNotEmpty){
                  mainData['status'] = request.docs[0]['status'];
                }
              },);
          setState(() {});
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

    if (widget.isEditEvent) {
      fetchEditEventsData();
      fetchEditClubsData();
      // fetchEditTableData();
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
        appBar: appBar(
          context,
          title: "Promotion Details",
        ),
        body: mainData == ""
            ? const Center(child: CircularProgressIndicator())
      : Container(
          width: Get.width,
          height: Get.height,
          color: Colors.black,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 120.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${clubName}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white70, fontSize: 45.sp),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 120.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if(mainData['amountPaid'] != null)
                                Text(
                                  "Amount Paid: ${mainData['amountPaid']}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white70, fontSize: 45.sp),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    if(!((mainData['promotionImages'] == null || mainData['promotionImages'].isEmpty) && (mainData['postImages'] == null || mainData['postImages'].isEmpty) && (mainData['reelsImages'] == null || mainData['reelsImages'].isEmpty)))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                        onTap: () {
                          setState(() {
                            showPromotionDropdowns = !showPromotionDropdowns;
                          });
                        },
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(
                            "Upload Promotional Data",
                            style: GoogleFonts.ubuntu(
                                fontSize: 45.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  showPromotionDropdowns = !showPromotionDropdowns;
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
                    if(showPromotionDropdowns)
                      Column(
                        children: [
                          if(mainData['promotionImages'] != null && mainData['promotionImages'].isNotEmpty)
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              "Story",
                              style: GoogleFonts.ubuntu(
                                  fontSize: 45.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPromotionalImage = !showPromotionalImage;
                                  });
                                },
                                icon: Icon(
                                  showPromotionalImage == false
                                      ? Icons.arrow_drop_down
                                      : Icons.arrow_drop_up,
                                  color: Colors.white,
                                ))
                          ]),
                          if(showPromotionalImage && mainData['promotionImages'] != null && mainData['promotionImages'].isNotEmpty)
                            AspectRatio(
                              aspectRatio: 9/16,
                              child: PageView.builder(
                                reverse: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: mainData['promotionImages'].length,
                                itemBuilder: (context, index) {
                                  Uri url = Uri.parse(mainData['promotionImages'][index]);
                                  if(lookupMimeType(url.path) == "application/image"){
                                    return Image.network(mainData['promotionImages'][index], errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Text("some error occurred", style: TextStyle(color: Colors.white)));
                                    },);
                                  }else if(lookupMimeType(url.path) == "application/video"){
                                    return CustomVideoPlayer(link: mainData['promotionImages'][index]);
                                  }else{
                                    return Image.network(mainData['promotionImages'][index], errorBuilder: (context, error, stackTrace) {
                                      return CustomVideoPlayer(link: mainData['promotionImages'][index]);
                                    },);
                                  }
                                },
                              ),
                            ),
                          if(mainData['postImages'] != null && mainData['postImages'].isNotEmpty)
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              "Posts",
                              style: GoogleFonts.ubuntu(
                                  fontSize: 45.sp,
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
                          if(showPostsImage && mainData['postImages'] != null && mainData['postImages'].isNotEmpty)
                            AspectRatio(
                              aspectRatio: 4/5,
                              child: PageView.builder(
                                reverse: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: mainData['postImages'].length,
                                itemBuilder: (context, index) {
                                  Uri url = Uri.parse(mainData['postImages'][index]);
                                  if(lookupMimeType(url.path) == "application/image"){
                                    return Image.network(mainData['postImages'][index], errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Text("some error occurred", style: TextStyle(color: Colors.white)));
                                    },);
                                  }else if(lookupMimeType(url.path) == "application/video"){
                                    return CustomVideoPlayer(link: mainData['postImages'][index]);
                                  }else{
                                    return Image.network(mainData['postImages'][index], errorBuilder: (context, error, stackTrace) {
                                      return CustomVideoPlayer(link: mainData['postImages'][index]);
                                    },);
                                  }
                                },
                              ),
                            ),
                          if(mainData['reelsImages'] != null && mainData['reelsImages'].isNotEmpty)
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              "Reels",
                              style: GoogleFonts.ubuntu(
                                  fontSize: 45.sp,
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
                          if(showReelImage && mainData['reelsImages'] != null && mainData['reelsImages'].isNotEmpty)
                            AspectRatio(
                              aspectRatio: 9/16,
                              child: PageView.builder(
                                reverse: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: mainData['reelsImages'].length,
                                itemBuilder: (context, index) {
                                  Uri url = Uri.parse(mainData['reelsImages'][index]);
                                  print("the reels right path is : ${url.path}");
                                  if(lookupMimeType(url.path) == "application/image"){
                                    return Image.network(mainData['reelsImages'][index], errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Text("some error occurred", style: TextStyle(color: Colors.white)));
                                    },);
                                  }else if(lookupMimeType(url.path) == "application/video"){
                                    return CustomVideoPlayer(link: mainData['reelsImages'][index]);
                                  }else{
                                    return Image.network(mainData['reelsImages'][index], errorBuilder: (context, error, stackTrace) {
                                      return CustomVideoPlayer(link: mainData['reelsImages'][index]);
                                    },);
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    if (widget.isClub == false)
                      SizedBox(
                        height: 120.h,
                        width: Get.width - 100.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Event Name : ${eventName}",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white70, fontSize: 45.sp),
                            ),
                          ],
                        ),
                      ).marginOnly(
                          left: 30.w, right: 30.w, bottom: 0.h, top: 20.h),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 120.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Amount Paid : ${mainData['amountPaid']}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white70, fontSize: 45.sp),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 120.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "pax : ${mainData['noOfBarterCollab'] ?? 0}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white70, fontSize: 45.sp),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 120.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Date : ${selectedDate.day} July ${selectedDate.year}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white70, fontSize: 45.sp),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 120.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Time : ${DateFormat('hh : mm a').format(DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute))}",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white70, fontSize: 45.sp),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: 120.h,
                    //   width: Get.width - 100.w,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         "Duration : $durationInHours hours",
                    //         style: GoogleFonts.ubuntu(
                    //             color: Colors.white70, fontSize: 45.sp),
                    //       ),
                    //     ],
                    //   ),
                    // ).marginOnly(
                    //     left: 30.w, right: 30.w, bottom: 00.h, top: 00.h),
                    SizedBox(
                      // height: 120.h,
                      width: Get.width - 100.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text("Deliverables : ", style: GoogleFonts.ubuntu(
                              color: Colors.white70, fontSize: 45.sp)),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: mainData['deliverables'].length,
                            itemBuilder: (context, index) {
                              return Text("    ${index+1}. ${mainData['deliverables'][index]}", style: GoogleFonts.ubuntu(color: Colors.white70));
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      // height: 120.h,
                      width: Get.width - 100.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Menu : ",
                            style: GoogleFonts.ubuntu(
                                color: Colors.white70, fontSize: 45.sp),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: mainData['offerFromMenu'].length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white, width: 0.5)
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text("Gender: ${mainData['offerFromMenu'][index]['gender'][0].toString().toUpperCase()}${mainData['offerFromMenu'][index]['gender'].toString().substring(1).toLowerCase()}", style: GoogleFonts.ubuntu(color: Colors.white70)),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: mainData['offerFromMenu'][index]['menu'].length,
                                      itemBuilder: (context, menuIndex) {
                                        var menu = mainData['offerFromMenu'][index]['menu'][menuIndex];
                                        return Text("      ${menuIndex+1}. ${menu['title']} - Price: ₹${menu['price']} - Qty: ${menu['qty']}", style: GoogleFonts.ubuntu(color: Colors.white70));
                                      },
                                    )
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ).marginOnly(
                        left: 30.w, right: 30.w, bottom: 00.h, top: 00.h),
                    // SizedBox(
                    //   height: 120.h,
                    //   width: Get.width - 100.w,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         "Venue Address : ${clubAddress}",
                    //         style: GoogleFonts.ubuntu(
                    //             color: Colors.white70, fontSize: 45.sp),
                    //       ),
                    //     ],
                    //   ),
                    // ).marginOnly(
                    //     left: 30.w, right: 30.w, bottom: 00.h, top: 00.h),
                    const SizedBox(height: 10),
                    // SizedBox(
                    //   height: 120.h,
                    //   width: Get.width - 100.w,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Expanded(
                    //         child: Text(
                    //           "detail : ${_briefEvent}",
                    //           style: GoogleFonts.ubuntu(
                    //               color: Colors.white70, fontSize: 45.sp),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ).marginOnly(
                    //     left: 30.w, right: 30.w, bottom: 00.h, top: 00.h),
                      if(mainData['status'] == 1)
                        Text("Declined", style: GoogleFonts.ubuntu(color: Colors.red, fontSize: 17))
                      // else if(!widget.isInfluencer && mainData['status'] == 2)
                      //   Text("Pending", style: GoogleFonts.ubuntu(color: Colors.yellow, fontSize: 17))
                      else if(mainData['status'] == 4)
                        Text("Accepted", style: GoogleFonts.ubuntu(color: Colors.green, fontSize: 17))
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  EasyLoading.show();
                                  await FirebaseFirestore.instance
                                      .collection("PromotionRequest")
                                      .doc(widget.promotionRequestId)
                                      .set(
                                      {'status' : 1},
                                      SetOptions(merge: true),
                                  ).then((value) {
                                    fetchEditEventsData();
                                    Fluttertoast.showToast(
                                        msg: "Declined Successfully");
                                  },);
                                } catch (e) {
                                  print(e);
                                  Fluttertoast.showToast(
                                      msg: 'Something Went Wrong');
                                }finally{
                                  EasyLoading.dismiss();
                                }
                              },
                              style: ButtonStyle(
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          side: const BorderSide(
                                              color: Colors.grey))),
                                  backgroundColor:
                                  WidgetStateProperty.resolveWith(
                                          (states) => Colors.black)),
                              child: Text(
                                widget.isEditEvent ? "Decline" : "Declined",
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
                                try {
                                  EasyLoading.show();
                                  await FirebaseFirestore.instance
                                      .collection("PromotionRequest")
                                      .doc(widget.promotionRequestId)
                                      .set(
                                    {'status' : 4},
                                    SetOptions(merge: true),
                                  ).then((value) {
                                    fetchEditEventsData();
                                    Fluttertoast.showToast(
                                        msg: "Accept Successfully");
                                  },);
                                } catch (e) {
                                  print(e);
                                  Fluttertoast.showToast(
                                      msg: 'Something Went Wrong');
                                }finally{
                                  EasyLoading.dismiss();
                                }
                              },
                              style: ButtonStyle(
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          side: const BorderSide(
                                              color: Colors.grey))),
                                  backgroundColor:
                                  WidgetStateProperty.resolveWith(
                                          (states) => Colors.black)),
                              child: Text(
                                widget.isEditEvent ? "Accept" : "Accept",
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
    if(widget.link is File){
      // controller = PodPlayerController(
      //     playVideoFrom: kIsWeb ? PlayVideoFrom.network(widget.link.path) : PlayVideoFrom.file(widget.link),
      //     podPlayerConfig: const PodPlayerConfig(
      //         autoPlay: false
      //     )
      // )..initialise().then((value) => setState(() {}));
    }else{
      // controller = PodPlayerController(
      //     playVideoFrom: PlayVideoFrom.network(widget.link),
      //   podPlayerConfig: const PodPlayerConfig(
      //     autoPlay: false
      //   )
      // )..initialise().then((value) => setState(() {}));
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
    //   controller.videoPlayerValue == null
    //     ?
    // const Center(child: CircularProgressIndicator())
    //   :
      Container();
    // PodVideoPlayer(controller: controller, videoAspectRatio: controller.videoPlayerValue!.aspectRatio, frameAspectRatio: controller.videoPlayerValue!.aspectRatio);
  }
}
