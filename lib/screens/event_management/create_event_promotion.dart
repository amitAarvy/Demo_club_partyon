import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/coupon_code/view/presentation/widget/shared_coupon_event_list.dart';
import 'package:club/screens/coupon_code/view/presentation/widget/start_end_date.dart';
import 'package:club/screens/event_management/influencer_list.dart';
import 'package:club/screens/event_management/menu_detail.dart';
import 'package:club/utils/app_const.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/screens/event_management/model/entrance_data_model.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/widgets/app_multi_dropdown.dart';
import 'package:club/widgets/dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';
import '../../dynamic_link/dynamic_link.dart';
import '../coupon_code/controller/coupon_code_controller.dart';
import '../coupon_code/model/data/coupon_code_model.dart';
import '../coupon_code/view/presentation/widget/coupon_card.dart';
import 'controller/menu_image_upload.dart';
import 'event_management.dart';
import 'menu_category.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EventPromotionCreate extends StatefulWidget {
  final bool isOrganiser;
  final bool isClub;
  final bool isEditEvent;
  final bool isPromoter;
  final String eventId;
  final String eventPromotionId;
  final Map<String, dynamic> eventData;
  final bool isEdit;
  final String? editPromotionId;

  const EventPromotionCreate(
      {Key? key,
        this.isOrganiser = false,
        this.isPromoter = false,
        this.isEditEvent = false,
        required this.eventId,
        this.eventPromotionId='',
        this.isClub = false,
        required this.eventData,
        this.isEdit = false,
        this.editPromotionId})
      : super(key: key);

  @override
  State<EventPromotionCreate> createState() => _EventPromotionCreateState();
}

class _EventPromotionCreateState extends State<EventPromotionCreate> {
  bool isNineSixteen = false;

  String menuID = const Uuid().v4();
  String invite = "exploreAll";
  List influencerSelected = [];
  TextEditingController noOfBarterCollabController = TextEditingController();
  TextEditingController noOfPromoterCollabController = TextEditingController();
  TextEditingController amountPaidController = TextEditingController();
  List deliverable = [TextEditingController()];
  TextEditingController scriptController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController offeredSalesCommisionController = TextEditingController();
  TextEditingController offeredSalesCommisionTableController = TextEditingController();
  List offerFromMenu = [
    {
      "gender": "",
      "menu": [],
    },
  ];

  final TextEditingController _title = TextEditingController();
  final TextEditingController fillerCouponCode = TextEditingController(text: 'Partyon');
  final TextEditingController noOfEntry = TextEditingController();
  final TextEditingController _briefEvent = TextEditingController();
  final TextEditingController pax = TextEditingController();
  final TextEditingController inta = TextEditingController();
  final TextEditingController  _artistName= TextEditingController();
  late Future<List<CouponModel>> sharedCouponList;


  List? totalMenuData;
  void sharedCoupon() async {
    sharedCouponList = (CouponCodeController.savedCouponCodes());
  }

  final homeController = Get.put(HomeController());
  final MenuEventController menuEventController = Get.put(MenuEventController());
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
  List<File> uploadPosts = [];
  List<File> uploadReels = [];
  var demoImage=[''];
  StreamSubscription? subscription;
  List coverImage = [];
  List offerImage = [];
  List postsImage = [];
  List reelsImage = [];

  List<File> selectedPromotionVideo = [];
  List<File> selectedPostVideo = [];
  List<File> selectedReel = [];
  String dropGenre = "Select Menu Category";
  String eventName = "";
  DateTime startTimeHour= DateTime.now();

  List<String> categoryName = [];

  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);

  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  int durationInHours = 0;

  bool tableShow = false, entranceShow = false, showDate = false;

  bool showPromotionDropdowns = false;
  bool showPromotionalImage = false, showPostsImage = false, showReelImage = false;

  _getFromGallery({bool isOffer = false}) async {
    await cropImageMultiple(!isOffer ? isNineSixteen : false, promotionType: PromotionType.story).then((value) {
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
            selectedPromotionVideo = [];
          });
        }
      }
    });
  }

  _getPostsFromGallery({bool isOffer = false}) async {
    await cropImageMultiple(!isOffer ? isNineSixteen : false, promotionType: PromotionType.post).then((value) {
      if (value.isNotEmpty) {
        // if (isOffer) {
        //   offerImage = [];
        // } else {
          postsImage = [];
        // }
        for (CroppedFile image in value) {
          setState(() {
            // if (isOffer) {
              uploadPosts.add(File((image.path).toString()));
            // } else {
            //   uploadCover.add(File((image.path).toString()));
            // }
              selectedPostVideo = [];
          });
        }
      }
    });
  }

  _getReelsImagesFromGallery({bool isOffer = false}) async {
    await cropImageMultiple(!isOffer ? isNineSixteen : false, promotionType: PromotionType.reel).then((value) {
      if (value.isNotEmpty) {
        // if (isOffer) {
        //   offerImage = [];
        // } else {
        reelsImage = [];
        // }
        for (CroppedFile image in value) {
          setState(() {
            // if (isOffer) {
            uploadReels.add(File((image.path).toString()));
            // } else {
            //   uploadCover.add(File((image.path).toString()));
            // }
            selectedReel = [];
          });
        }
      }
    });
  }

  // _getVideoFromGallery() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
  //   if(result != null){
  //     selectedReel = File(result.files.single.path!);
  //     setState(() {});
  //   }
  //   // selectedReel
  // }

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

  Future<void> PromotionUploadImage(
      List<File> images, List<File> videos, String eventID, HomeController homeController,
      {required List coverImages,
        bool isOffer = false,
        bool isOrganiser = false}) async {
    print("event id is : $eventID");
    // if(videos.isEmpty){
      var imageUrls = await Future.wait(images.map((image) async {
        String url = '';
        if (isOffer) {
          url = 'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
        } else {
          url = 'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
        }
        final Reference ref = FirebaseStorage.instance.ref().child(url);
        String downloadUrl = '';
        final UploadTask uploadTask = ref.putFile(image);
        await uploadTask.then((taskSnapShot) async {
          downloadUrl = await taskSnapShot.ref.getDownloadURL();
        });
        return downloadUrl;
      }));
      if (isOffer) {
        FirebaseAuth.instance.currentUser
            ?.updatePhotoURL(images.isNotEmpty ? imageUrls[0] : coverImages[0])
            .whenComplete(() {
          FirebaseFirestore.instance.collection("EventPromotion").doc(eventID).set(
              {'promotionImages': images.isNotEmpty ? imageUrls : coverImages},
              SetOptions(merge: true));
        });
      }
    // }else{
    //   var videoUrls = await Future.wait(videos.map((video) async {
    //     String url = '';
    //     if (isOffer) {
    //       url = 'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}.mp4';
    //     } else {
    //       url = 'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}.mp4';
    //     }
    //     final Reference ref = FirebaseStorage.instance.ref().child(url);
    //     String downloadUrl = '';
    //     final UploadTask uploadTask = ref.putFile(video);
    //     await uploadTask.then((taskSnapShot) async {
    //       downloadUrl = await taskSnapShot.ref.getDownloadURL();
    //     });
    //     return downloadUrl;
    //   }));
    //   FirebaseFirestore.instance.collection("EventPromotion").doc(eventID).set(
    //       {'promotionImages': videoUrls},
    //       SetOptions(merge: true));
    // }
  }

  Future<void> postsUploadImage(
      List<File> images, List<File> videos, String eventID, HomeController homeController,
      {required List coverImages,
        bool isOffer = false,
        bool isOrganiser = false}) async {
    // if(videos.isEmpty){
      var imageUrls = await Future.wait(images.map((image) async {
        String url = '';
        if (isOffer) {
          url = 'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
        } else {
          url = 'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
        }
        final Reference ref = FirebaseStorage.instance.ref().child(url);
        String downloadUrl = '';
        final UploadTask uploadTask = ref.putFile(image);
        await uploadTask.then((taskSnapShot) async {
          downloadUrl = await taskSnapShot.ref.getDownloadURL();
        });
        return downloadUrl;
      }));
      if (isOffer) {
        FirebaseFirestore.instance.collection("EventPromotion").doc(eventID).set(
            {'postImages': images.isNotEmpty ? imageUrls : coverImages},
            SetOptions(merge: true));
      }
    // }else{
    //   var videoUrls = await Future.wait(videos.map((video) async {
    //     String url = '';
    //     if (isOffer) {
    //       url = 'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}.mp4';
    //     } else {
    //       url = 'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}.mp4';
    //     }
    //     final Reference ref = FirebaseStorage.instance.ref().child(url);
    //     String downloadUrl = '';
    //     final UploadTask uploadTask = ref.putFile(video);
    //     await uploadTask.then((taskSnapShot) async {
    //       downloadUrl = await taskSnapShot.ref.getDownloadURL();
    //     });
    //     return downloadUrl;
    //   }));
    //   FirebaseFirestore.instance.collection("EventPromotion").doc(eventID).set(
    //       {'postImages': videoUrls},
    //       SetOptions(merge: true));
    // }
  }

  Future<void> reelsUploadImage(
      List<File> images, List<File> videos, String eventID, HomeController homeController,
      {required List coverImages,
        bool isOffer = false,
        bool isOrganiser = false}) async {
    // if(videos.isEmpty){
      var imageUrls = await Future.wait(images.map((image) async {
        String url = '';
        if (isOffer) {
          url = 'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
        } else {
          url = 'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
        }
        final Reference ref = FirebaseStorage.instance.ref().child(url);
        String downloadUrl = '';
        final UploadTask uploadTask = ref.putFile(image);
        await uploadTask.then((taskSnapShot) async {
          downloadUrl = await taskSnapShot.ref.getDownloadURL();
        });
        return downloadUrl;
      }));
      if (isOffer) {
        FirebaseFirestore.instance.collection("EventPromotion").doc(eventID).set(
            {'reelsImages': images.isNotEmpty ? imageUrls : coverImages},
            SetOptions(merge: true));
      }
    // }else{
    //   var videoUrls = await Future.wait(videos.map((video) async {
    //     String url = '';
    //     if (isOffer) {
    //       url = 'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}.mp4';
    //     } else {
    //       url = 'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}.mp4';
    //     }
    //     final Reference ref = FirebaseStorage.instance.ref().child(url);
    //     String downloadUrl = '';
    //     final UploadTask uploadTask = ref.putFile(video);
    //     await uploadTask.then((taskSnapShot) async {
    //       downloadUrl = await taskSnapShot.ref.getDownloadURL();
    //     });
    //     return downloadUrl;
    //   }));
    //   FirebaseFirestore.instance.collection("EventPromotion").doc(eventID).set(
    //       {'reelsImages': videoUrls},
    //       SetOptions(merge: true));
    // }
  }


  Future<void> PromotionUploadVideo(
      List<File> images, String eventID, HomeController homeController,
      {required List coverImages,
        bool isOffer = false,
        bool isOrganiser = false})

      async {
    var imageUrls = await Future.wait(images.map((image) async {
      String url = '';
      if (isOffer) {
        url = 'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
      } else {
        url = 'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
      }
      final Reference ref = FirebaseStorage.instance.ref().child(url);
      String downloadUrl = '';
      final UploadTask uploadTask = ref.putFile(image);
      await uploadTask.then((taskSnapShot) async {
        downloadUrl = await taskSnapShot.ref.getDownloadURL();
      });
      return downloadUrl;
    }));
    if (isOffer) {
      FirebaseAuth.instance.currentUser
          ?.updatePhotoURL(images.isNotEmpty ? imageUrls[0] : coverImages[0])
          .whenComplete(() {
        FirebaseFirestore.instance.collection("EventPromotion").doc(eventID).set(
            {'promotionImages': images.isNotEmpty ? imageUrls : coverImages},
            SetOptions(merge: true));
      });
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

  List tableListAll =[];

  void fetchEditTableData() async {
    try {
      await FirebaseFirestore.instance
          .collection("Events")
          .doc(widget.eventId)
          .collection("Tables")
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          tableListAll.add(value);
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
      setState(() { });
      print('check table lsit $tableListAll');
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

  void fetchEditEventsPromotion() async {
    try {

      await FirebaseFirestore.instance
          .collection("EventPromotion")
          .doc(widget.eventPromotionId)
          .get()
          .then((doc) async {
        if (doc.exists) {
          _title.text = getKeyValueFirestore(doc, 'budget') ?? '';
          _briefEvent.text = getKeyValueFirestore(doc, 'detail') ?? '';
          _artistName.text = getKeyValueFirestore(doc, 'menu') ?? '';
          pax.text = getKeyValueFirestore(doc, 'pax') ?? '';
          inta.text = getKeyValueFirestore(doc, 'inta') ?? '';
          offerImage = getKeyValueFirestore(doc, 'promotionImages') ?? [];


          setState(() {});
        }else{
          Fluttertoast.showToast(
              msg: "no data");
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
          .collection("Events")
          .doc(widget.eventId)
          .get()
          .then((doc) async {
        if (doc.exists) {
          eventName = getKeyValueFirestore(doc, 'title') ?? '';
          startTimeHour =
              getKeyValueFirestore(doc, 'startTime').toDate() ??
                  DateTime.now();
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




  List tableList =[];
  List entryList =[];
  @override
  void initState() {
    print('this is page');
    menuCategoryData();
    fetchEditEventsData();
    entryList.addAll({widget.eventData['entryManagementCouponList']??{}});
    tableList.addAll({widget.eventData['tableManagementCouponList']??{}});




    _title.text = '800';
    print('check is event detail is ${widget.eventData}');
    print('check is event detail is ${entryList}');
    print('check is event detail is ${tableList}');
    if (kDebugMode) {
      print(widget.eventId);
    }
    createUrl();
    if (widget.isEditEvent) {
      fetchEditEventsPromotion();
      fetchEditTableData();
    } else {
      getEntranceFieldValues(isDefault: true);
      getDefaultTableData();
      fetchEditTableData();
    }
    super.initState();
    sharedCoupon();
    print('is organiser check ${widget.isOrganiser}');
    fetchMenuList();
    if(widget.isEdit && widget.editPromotionId != null){
      fetchEventPromotion();
    }
    Future.delayed(Duration(seconds: 1),(){
      checkEntryList();
    });
    prefData();
  }


  prefData()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var planData =pref.getString('planData')??'';
    var plans = jsonDecode(planData);
    offeredSalesCommisionTableController.text ='20';
    // plans['tableManagement']==null?'':plans['tableManagement']['percentageOfTable']??'';
    offeredSalesCommisionController.text ="10";
    // plans['entryManagement']==null?'':plans['entryManagement']['percentageOfEntry']??'';
  }

  checkEntryList(){
    if(entryList[0].isEmpty && tableList[0].isEmpty ){
      showModalBottomSheet(
        isDismissible: false,
        context: context, builder: (context) {
        return WillPopScope(
          onWillPop: ()async{
            Get.back();
            Get.back();
            return false;
          },
          child: Container(color: Colors.grey.shade300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Tap to pick coupon code your perfect coupon code and save instantly!',style: TextStyle(fontWeight: FontWeight.w600),),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: (){
                      // Get.to(CouponCodeList());
                      showModalBottomSheet(
                          isDismissible: false,
                          context: context, builder: (context) {
                        return WillPopScope(
                            onWillPop: ()async{
                              Get.back();
                              Get.back();
                              Get.back();
                              Get.back();
                              return false;
                            },
                            child: CouponCodeList(eventId: widget.eventId,));
                      });
                    },
                    child: Container(decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.all(Radius.circular(11))
                    ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: Text('Pick Coupon Code',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
        );
      },);
      return;
    }
  }

  void fetchMenuList() async{
    QuerySnapshot menuData = await FirebaseFirestore.instance
        .collection("Menu").where('clubUID',isEqualTo:widget.isOrganiser ==true?widget.eventData['clubUID']: uid())
        .get();
    totalMenuData = menuData.docs;
    setState(() {});
  }

  void fetchEventPromotion()async{
    DocumentSnapshot promotionData = await FirebaseFirestore.instance
        .collection("EventPromotion")
        .doc(widget.editPromotionId!)
        .get();
    menuID = widget.editPromotionId!;
    _title.text = promotionData['budget'];
    _briefEvent.text = promotionData['detail'];
    invite = promotionData['invite'];
    // eventName.text = promotionData['eventName'];
    noOfEntry.text = promotionData['noOfBarterCollab'].toString();
    amountPaidController.text = promotionData['amountPaid'].toString();
    deliverable = (promotionData['deliverables'] as List).map((e) => TextEditingController(text: e)).toList();
    scriptController.text = promotionData['script'];
    offerFromMenu = promotionData['offerFromMenu'];
    // startSelectedDate = promotionData['startTime'].toDate();
    // startTime = TimeOfDay(hour: (promotionData['startTime'].toDate() as DateTime).hour, minute: (promotionData['startTime'].toDate() as DateTime).minute);
    // endSelectedDate = promotionData['endTime'].toDate();
    setState(() {});
  }

    String url = '';

  bool showUrl = false;
  void createUrl() async {
    url = await FirebaseDynamicLinkEvent.createDynamicLink(
      short: true,
      clubUID: uid().toString() ,
      // clubUID: clu,
      eventID:widget.eventId ,
      organiserID: uid().toString(),
    );

    setState(() {});
  }


  ValueNotifier<String?> selectedEntryCoupon = ValueNotifier(null);
  ValueNotifier<String?> selectedTableCoupon = ValueNotifier(null);

  @override
  void dispose() {
    if (subscription != null) {
      subscription?.cancel();
    }
    super.dispose();
  }

  Widget imageCoverWidget(List coverImages, List uploadImages, List<File> videos,
      {bool isOffer = false, bool isNineSixteenValue = false, required VoidCallback onTap, required String title, required VoidCallback onCancel, required PromotionType promotionType}) {
    double carouselHeight =
    isNineSixteenValue && !isOffer ? (Get.width - 100.w) * 16 / 9 : 600.w;
    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: promotionType == PromotionType.story || promotionType == PromotionType.reel ? 9/16 : 4/5,
              child: Container(
                  // height: carouselHeight,
                  // width: Get.width - 100.w,
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
                  child: coverImages.isNotEmpty && uploadImages.isEmpty
                      ? eventCarousel(coverImages,
                      isEdit: true, aspectRatio: promotionType == PromotionType.story || promotionType == PromotionType.reel ? 9/16 : 4/5)
                      : uploadImages.isNotEmpty
                      ? eventCarousel(uploadImages,
                       aspectRatio: promotionType == PromotionType.story || promotionType == PromotionType.reel ? 9/16 : 4/5)
                      // : videos.isNotEmpty ?
                      // Center(child: Text(videos.map((e) => e.path.split('/').last).toList().join(','), style: TextStyle(color: Colors.white)))
                  : Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 300.h,
                        )))
                  .marginAll(20),
            ),
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
                      onPressed: onCancel,
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
        Text("Aspect Ratio : ${promotionType == PromotionType.story || promotionType == PromotionType.reel ? '9:16' : '4:5'}", style: const TextStyle(color: Colors.white)),
        ElevatedButton(
          onPressed: onTap,
          style: ButtonStyle(
              backgroundColor:
              WidgetStateProperty.resolveWith((states) => Colors.black)),
          child: Text(!isOffer ? "Upload Cover" : title,style: GoogleFonts.ubuntu(
            color: Colors.orange,

          ),),
        ),
      ],
    );
  }
  final CouponCodeController couponCodeController = Get.put(CouponCodeController());

  DateTime startSelectedDate = DateTime.now();
  DateTime startSelectedEntryDate = DateTime.now();
  DateTime startSelectedTableDate = DateTime.now();
  TimeOfDay startTimes = const TimeOfDay(hour: 0, minute: 0);
  DateTime endSelectedDate = DateTime.now();
  DateTime endSelectedEntryDate = DateTime.now();
  DateTime endSelectedTableDate = DateTime.now();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('check build is ');
    return Scaffold(
      backgroundColor: matte(),
      appBar: appBar(context, title: "Create Event Promotion"),
      body: totalMenuData == null
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent,))
          : SingleChildScrollView(
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex = 0;
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: currentIndex == 0 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                            ),
                            child: Text("Barter", style: TextStyle(color: Colors.white),)),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            currentIndex = 1;
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: currentIndex == 1 ? Colors.yellow.withOpacity(0.4) : Colors.transparent,
                            ),
                            child: Text("Paid", style: TextStyle(color: Colors.white),)),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 20.h,
                ),

                Row(
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: invite,
                          groupValue: "inviteOnly",
                          onChanged: (value) {
                            setState(() {
                              invite = "inviteOnly";
                            });
                          },
                        ),
                        const Text("Invite Only", style: TextStyle(color: Colors.white))
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: invite,
                          groupValue: "exploreAll",
                          onChanged: (value) {
                            setState(() {
                              invite = "exploreAll";
                            });
                          },
                        ),
                        const Text("Explore All", style: TextStyle(color: Colors.white))
                      ],
                    )
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () {
                      showUrl = true;
                      print('chec url is ${url}');
                      setState(() {

                      });
                    },
                    child: Container(
                      width: 1.sw,
                        padding: EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius:
                            BorderRadius.circular(10)),
                        child: Center(
                            child: Text(
                                 'Generate URL',
                                style: TextStyle(
                                    color: Colors.white)))),
                  ),
                ),
                if(showUrl)
                  SizedBox(height: 10,),
                if(showUrl)
                Text(url,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showPromotionDropdowns = !showPromotionDropdowns;
                      });
                    },
                    overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(
                        "Upload Promotional Data (If any)",
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
                SizedBox(
                  height: 120.h,
                  width: Get.width - 100.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Start Date: ${DateFormat.yMMMd().format(startSelectedDate)}",
                        style: GoogleFonts.ubuntu(
                            color: Colors.white70, fontSize: 45.sp),
                      ),
                      GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                                initialDate: startSelectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                                context: context);
                            if (picked != null &&
                                picked != startSelectedDate) {
                              setState(() {
                                startSelectedDate = picked;
                                if (endSelectedDate
                                    .isBefore(startSelectedDate)) {
                                  endSelectedDate = picked;
                                }
                              });
                            }
                          },
                          child: Container(
                            height: 100.h,
                            width: 300.w,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white, width: 4.h,
                                ),
                            ),
                            child: Center(
                                child: Text(
                                  "Select Date",
                                  style:
                                  GoogleFonts.ubuntu(color: Colors.white),
                                )),
                          )),
                    ],
                  ),
                ).marginOnly(
                    left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),

                SizedBox(
                  height: 120.h,
                  width: Get.width - 100.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "End Date: ${DateFormat.yMMMd().format(endSelectedDate)}",
                        style: GoogleFonts.ubuntu(
                            color: Colors.white70, fontSize: 45.sp),
                      ),
                      GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                                initialDate: endSelectedDate,
                                firstDate: startSelectedDate,
                                lastDate: DateTime(2101),
                                context: context);
                            if (picked != null &&
                                picked != endSelectedDate) {
                              setState(() {
                                endSelectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            height: 100.h,
                            width: 300.w,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white, width: 4.h)),
                            child: Center(
                                child: Text(
                                  "Select Date",
                                  style:
                                  GoogleFonts.ubuntu(color: Colors.white),
                                )),
                          )),
                    ],
                  ),
                ).marginOnly(
                    left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                if(showPromotionDropdowns)
                  Column(
                    children: [
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
                      if(showPromotionalImage)
                        Column(
                          children: [
                            imageCoverWidget(offerImage, uploadOffer, selectedPromotionVideo, isOffer: true,title: 'Story image', onTap: () async {
                              _getFromGallery(isOffer: true);
                            }, onCancel: () => setState(() {
                              offerImage = [];
                              uploadOffer = [];
                              selectedPromotionVideo = [];
                            }), promotionType: PromotionType.story),
                            ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? picker = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true);
                                  if(picker!= null){
                                    setState(() {
                                      selectedPromotionVideo = picker.paths.map((e) => File(e!)).toList();
                                      // offerImage = [];
                                      uploadOffer = [...uploadOffer, ...selectedPromotionVideo];
                                    });
                                  }
                                },
                                child:
                                const Text("Choose Video File")),
                          ],
                        ),
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
                      if(showPostsImage)
                        Column(
                          children: [
                            imageCoverWidget(postsImage, uploadPosts, selectedPostVideo, isOffer: true,title: 'Post image', onTap: () async {
                              _getPostsFromGallery(isOffer: true);
                            }, onCancel: () => setState(() {
                              postsImage = [];
                              uploadPosts = [];
                              selectedPostVideo = [];
                            }), promotionType: PromotionType.post),
                            ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? picker = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true);
                                  if(picker!= null){
                                    setState(() {
                                      selectedPostVideo = picker.paths.map((e) => File(e!)).toList();
                                      // postsImage = [];
                                      uploadPosts = [...uploadPosts, ...selectedPostVideo];
                                    });
                                  }
                                },
                                child:
                                const Text("Choose Video File")),
                          ],
                        ),
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
                      if(showReelImage)
                        Column(
                          children: [
                            imageCoverWidget(reelsImage, uploadReels, selectedReel, isOffer: true,title: 'Reel', onTap: () async {
                              _getReelsImagesFromGallery(isOffer: true);
                            }, onCancel: () => setState(() {
                              reelsImage = [];
                              uploadReels = [];
                              selectedReel = [];
                            }), promotionType: PromotionType.reel),
                            ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? picker = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true);
                                  if(picker!= null){
                                    setState(() {
                                      selectedReel = picker.paths.map((e) => File(e!)).toList();
                                      // reelsImage = [];
                                      uploadReels = [...uploadReels, ...selectedReel];
                                    });
                                  }
                                },
                                child:
                                const Text("Choose Video File")),
                          ],
                        ),
                    ],
                  ),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                 child: Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(11),
                       border: Border.all(color: Colors.white,width: 1)
                     ),
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Column(
                         children: [
                           textField("Amount per couple ( filler )", _title,isNum: true, isMandatory: true,isReadOnly: true),
                           textField("Filler Coupon Code", fillerCouponCode,isNum: false, isMandatory: true,isReadOnly: true),
                           textField("NO Of Barter", noOfEntry,isNum: true, isMandatory: true),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.stretch,
                               children: [
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     const Row(
                                       children: [
                                         Text("Offer from menu/pax", style: TextStyle(color: Colors.white)),
                                         SizedBox(width: 5),
                                         // Text("*", style: TextStyle(color: Colors.red)),
                                       ],
                                     ),
                                     if(offerFromMenu.length < 4)
                                       GestureDetector(
                                         onTap: () {
                                           setState(() {
                                             offerFromMenu.add({
                                               "gender": "",
                                               "menu": [],
                                             });
                                           });
                                         },
                                         child: Container(
                                           padding: EdgeInsets.all(5),
                                           decoration: BoxDecoration(
                                             borderRadius: BorderRadius.circular(5),
                                             border: Border.all(color: Colors.white, width: 1),
                                           ),
                                           child: Icon(Icons.add, color: Colors.white, size: 16),
                                         ),
                                       ),
                                   ],
                                 ),
                                 const SizedBox(height: 10),
                                 ListView.builder(
                                   shrinkWrap: true,
                                   physics: const NeverScrollableScrollPhysics(),
                                   itemCount: offerFromMenu.length,
                                   itemBuilder: (context, index) {
                                     return Stack(
                                       children: [
                                         Container(
                                           margin: EdgeInsets.symmetric(vertical: 10),
                                           padding: EdgeInsets.all(10),
                                           decoration: BoxDecoration(
                                               border: Border.all(color: Colors.white, width: 0.5),
                                               borderRadius: BorderRadius.circular(10)
                                           ),
                                           child: Column(
                                             children: [
                                               SingleChildScrollView(
                                                 scrollDirection: Axis.horizontal,
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                   children: [
                                                     Row(
                                                       children: [
                                                         Checkbox(
                                                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                           value: offerFromMenu.where((element) => element['gender'] == 'male' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty ? true : offerFromMenu[index]['gender'] == 'male' || offerFromMenu[index]['gender'] == 'both',
                                                           activeColor: offerFromMenu.where((element) => element['gender'] == 'male' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty ? Colors.grey : null,
                                                           onChanged: (value) {
                                                             if(offerFromMenu.where((element) => element['gender'] == 'male' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty) return;
                                                             setState(() {
                                                               offerFromMenu[index]['gender'] = "male";
                                                             });
                                                           },
                                                         ),
                                                         Text("Male", style: TextStyle(color: Colors.white))
                                                       ],
                                                     ),
                                                     Row(
                                                       children: [
                                                         Checkbox(
                                                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                           value: offerFromMenu.where((element) => element['gender'] == 'female' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty ? true : offerFromMenu[index]['gender'] == 'female' || offerFromMenu[index]['gender'] == 'both',
                                                           activeColor: offerFromMenu.where((element) => element['gender'] == 'female' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty ? Colors.grey : null,
                                                           onChanged: (value) {
                                                             if(offerFromMenu.where((element) => element['gender'] == 'female' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty) return;
                                                             setState(() {
                                                               offerFromMenu[index]['gender'] = "female";
                                                             });
                                                           },
                                                         ),
                                                         Text("Female", style: TextStyle(color: Colors.white))
                                                       ],
                                                     ),
                                                     Row(
                                                       children: [
                                                         Checkbox(
                                                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                           value: offerFromMenu.where((element) => element['gender'] == 'both' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty ? true : offerFromMenu[index]['gender'] == 'both',
                                                           activeColor: offerFromMenu.where((element) => element['gender'] == 'both' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty ? Colors.grey : null,
                                                           onChanged: (value) {
                                                             if(offerFromMenu.where((element) => element['gender'] == 'both' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty) return;
                                                             setState(() {
                                                               offerFromMenu[index]['gender'] = "both";
                                                             });
                                                           },
                                                         ),
                                                         Text("Both", style: TextStyle(color: Colors.white))
                                                       ],
                                                     ),
                                                     Row(
                                                       children: [
                                                         Checkbox(
                                                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                           value: offerFromMenu.where((element) => element['gender'] == 'others' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty ? true : offerFromMenu[index]['gender'] == 'others',
                                                           activeColor: offerFromMenu.where((element) => element['gender'] == 'others' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty ? Colors.grey : null,
                                                           onChanged: (value) {
                                                             if(offerFromMenu.where((element) => element['gender'] == 'others' && offerFromMenu[index]['gender'] != element['gender']).toList().isNotEmpty) return;
                                                             setState(() {
                                                               offerFromMenu[index]['gender'] = "others";
                                                             });
                                                           },
                                                         ),
                                                         Text("Others", style: TextStyle(color: Colors.white))
                                                       ],
                                                     ),
                                                   ],
                                                 ),
                                               ),
                                               if(offerFromMenu[index]['gender'].isNotEmpty)
                                                 const SizedBox(height: 10),
                                               if(offerFromMenu[index]['gender'].isNotEmpty)
                                                 Column(
                                                   children: [
                                                     // ListView.builder(
                                                     //   itemCount: totalMenuData?.length ?? 0,
                                                     //   shrinkWrap: true,
                                                     //   itemBuilder: (context, index) {
                                                     //     var item = totalMenuData![index];
                                                     //
                                                     //     offerFromMenu[index]['menu'] ??= [];
                                                     //
                                                     //     List menuList = offerFromMenu[index]['menu'] as List;
                                                     //     print('check list is$offerFromMenu');
                                                     //
                                                     //     bool isSelected = menuList.any((element) => element['id'] == item['id']);
                                                     //
                                                     //     // Get the quantity if selected, otherwise set to 1
                                                     //     int qty = isSelected
                                                     //         ? menuList.firstWhere((element) => element['id'] == item['id'])['qty']
                                                     //         : 1;
                                                     //
                                                     //     return ListTile(
                                                     //       title: Text(
                                                     //         "${item['title']} (₹${item['price']})",
                                                     //         style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                                     //       ),
                                                     //       leading: Checkbox(
                                                     //         value: isSelected,
                                                     //         onChanged: (value) {
                                                     //           setState(() {
                                                     //             if (value == true) {
                                                     //               // Add item to the selected list
                                                     //               menuList.add({
                                                     //                 "id": item['id'],
                                                     //                 "title": item['title'],
                                                     //                 "price": item['price'],
                                                     //                 "qty": 1, // Default quantity
                                                     //               });
                                                     //             } else {
                                                     //               // Remove item from the selected list
                                                     //               menuList.removeWhere((element) => element['id'] == item['id']);
                                                     //             }
                                                     //             offerFromMenu[index]['menu'] = menuList;
                                                     //           });
                                                     //         },
                                                     //       ),
                                                     //       trailing: isSelected
                                                     //           ? Row(
                                                     //         mainAxisSize: MainAxisSize.min,
                                                     //         children: [
                                                     //           IconButton(
                                                     //             icon: Icon(Icons.remove),
                                                     //             onPressed: () {
                                                     //               setState(() {
                                                     //                 int itemIndex = menuList.indexWhere((element) => element['id'] == item['id']);
                                                     //
                                                     //                 if (itemIndex != -1 && menuList[itemIndex]['qty'] > 1) {
                                                     //                   menuList[itemIndex]['qty'] -= 1;
                                                     //                   offerFromMenu[index]['menu'] = menuList;
                                                     //                 }
                                                     //               });
                                                     //             },
                                                     //           ),
                                                     //           Text("$qty"),
                                                     //           IconButton(
                                                     //             icon: Icon(Icons.add),
                                                     //             onPressed: () {
                                                     //               setState(() {
                                                     //                 int itemIndex = menuList.indexWhere((element) => element['id'] == item['id']);
                                                     //
                                                     //                 if (itemIndex != -1) {
                                                     //                   menuList[itemIndex]['qty'] += 1;
                                                     //                   offerFromMenu[index]['menu'] = menuList;
                                                     //                 }
                                                     //               });
                                                     //             },
                                                     //           ),
                                                     //         ],
                                                     //       )
                                                     //           : null,
                                                     //     );
                                                     //   },
                                                     // ),

                                                     AppMultiDropdown(
                                                       items: totalMenuData!.map((e) => DropdownItem(label: "${e['title']} (₹${e['price']})", value: "${e['title']}-${e['price']}", selected: (offerFromMenu[index]['menu'] as List).where((element) => "${element['title']}-${element['price']}" == "${e['title']}-${e['price']}").toList().isNotEmpty)).toList(),
                                                       title: "Select menu item & qty",
                                                       onSelectionChanged: (selectedItems) {
                                                         setState(() {
                                                           offerFromMenu[index]['menu'] = selectedItems.map((e) {
                                                             List currItem = offerFromMenu[index]['menu'].where((element) => element['id'] == e).toList();
                                                             return {
                                                               "id": e,
                                                               "title": e.toString().split('-').first,
                                                               "price": e.toString().split('-').last,
                                                               "qty": currItem.isEmpty ? 1 : currItem.first['qty']
                                                             };
                                                           },).toList();
                                                         });
                                                       },
                                                     ),
                                                     const SizedBox(height: 10),
                                                     ListView.builder(
                                                       shrinkWrap: true,
                                                       physics: const NeverScrollableScrollPhysics(),
                                                       itemCount: offerFromMenu[index]['menu'].length,
                                                       itemBuilder: (context, menuIndex) {
                                                         return Row(
                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                           children: [
                                                             Text(offerFromMenu[index]['menu'][menuIndex]['title'], style: TextStyle(color: Colors.white)),
                                                             Row(
                                                               children: [
                                                                 IconButton(
                                                                   color: Colors.white,
                                                                   onPressed: () {
                                                                     if(offerFromMenu[index]['menu'][menuIndex]['qty'] <= 1){
                                                                       Fluttertoast.showToast(msg: "Quantity should be minimum 1");
                                                                       return;
                                                                     }
                                                                     setState(() {
                                                                       offerFromMenu[index]['menu'] = offerFromMenu[index]['menu'].map((e) => e['id'] == offerFromMenu[index]['menu'][menuIndex]['id'] ? {...e, "qty": e['qty']-1} : e).toList();
                                                                     });
                                                                   },
                                                                   icon: Icon(Icons.remove),
                                                                 ),
                                                                 Container(
                                                                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                                                   decoration: BoxDecoration(
                                                                       border: Border.all(color: Colors.white, width: 0.5),
                                                                       borderRadius: BorderRadius.circular(3)
                                                                   ),
                                                                   child: Text("${offerFromMenu[index]['menu'][menuIndex]['qty']}", style: TextStyle(color: Colors.white)),
                                                                 ),
                                                                 IconButton(
                                                                   color: Colors.white,
                                                                   onPressed: () {
                                                                     setState(() {
                                                                       offerFromMenu[index]['menu'] = offerFromMenu[index]['menu'].map((e) => e['id'] == offerFromMenu[index]['menu'][menuIndex]['id'] ? {...e, "qty": e['qty']+1} : e).toList();
                                                                     });
                                                                   },
                                                                   icon: Icon(Icons.add),
                                                                 ),
                                                               ],
                                                             )
                                                           ],
                                                         );
                                                       },
                                                     ),
                                                     const Divider(),
                                                     const Align(
                                                       alignment: Alignment.centerLeft,
                                                       child: Text("Summary", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                                     ),
                                                     const SizedBox(height: 10),
                                                     ListView.builder(
                                                       shrinkWrap: true,
                                                       physics: const NeverScrollableScrollPhysics(),
                                                       itemCount: offerFromMenu[index]['menu'].length,
                                                       itemBuilder: (context, summaryIndex) {
                                                         return Row(
                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                           children: [
                                                             Text(offerFromMenu[index]['menu'][summaryIndex]['title'], style: TextStyle(color: Colors.white)),
                                                             Text(
                                                               "₹${offerFromMenu[index]['menu'][summaryIndex]['price']} X ${offerFromMenu[index]['menu'][summaryIndex]['qty']} = ₹${int.parse(offerFromMenu[index]['menu'][summaryIndex]['price']) * offerFromMenu[index]['menu'][summaryIndex]['qty']}",
                                                               style: const TextStyle(color: Colors.white),
                                                             ),
                                                           ],
                                                         );
                                                       },
                                                     ),
                                                     if((offerFromMenu[index]['menu'] as List).map((e) => int.parse(e['price'])*e['qty']).toList().isNotEmpty)
                                                       Divider(color: Colors.grey.withOpacity(0.3)),
                                                     if((offerFromMenu[index]['menu'] as List).map((e) => int.parse(e['price'])*e['qty']).toList().isNotEmpty)
                                                       Row(
                                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                         children: [
                                                           const Text("Total", style: TextStyle(color: Colors.white)),
                                                           Text(
                                                             "₹ ${(offerFromMenu[index]['menu'] as List).map((e) => int.parse(e['price'])*e['qty']).toList().reduce((value, element) => value + element)}",
                                                             style: const TextStyle(color: Colors.white),
                                                           ),
                                                         ],
                                                       )
                                                   ],
                                                 ),
                                             ],
                                           ),
                                         ),
                                         if(offerFromMenu.length > 1)
                                           Positioned(
                                             right: 0,
                                             top: 0,
                                             child: GestureDetector(
                                               onTap: () {
                                                 offerFromMenu.removeAt(index);
                                                 setState(() {});
                                               },
                                               child: Container(
                                                 decoration: const BoxDecoration(
                                                   color: Colors.black,
                                                   shape: BoxShape.circle,
                                                 ),
                                                 child: Icon(Icons.remove_circle, size: 26, color: Colors.white,),
                                               ),
                                             ),
                                           )
                                       ],
                                     );
                                   },
                                 ),
                                 if(offerFromMenu.where((element) => element['menu'].isEmpty).toList().isEmpty)
                                   Padding(
                                     padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         const Text("Total Price", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                                         Text(
                                             "₹ ${offerFromMenu.map((e) => (e['menu'] as List).map((ele) => int.parse(ele['price'])*ele['qty']).toList().reduce((value, element) => value+element)).toList().reduce((value, element) => value+element)}",
                                             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)
                                         ),
                                       ],
                                     ),
                                   ),
                               ],
                             ),
                           ),
                         ],
                     ),
                   ),


                 ),
               ),
                // textField("Pax Required", pax,isNum: true, isMandatory: true),
                // textField("Insta Reach Required", inta,isNum: true, isMandatory: true),
                // textField("Offer from Menu", _artistName,isInfo: true, isMandatory: true),
                textField("Specific Requirement", _briefEvent, isInfo: true),
                // textField('No. of barter collab\'s', noOfBarterCollabController, isNum: true, isMandatory: true),
                textField('No. of promoter collab\'s', noOfPromoterCollabController, isNum: true, isMandatory: true),
                // textField('Amount to be paid ${currentIndex==0?'(if any)':''}', amountPaidController, isNum: true,isMandatory: currentIndex ==1?true:false),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Text("Deliverable", style: TextStyle(color: Colors.white)),
                              SizedBox(width: 5),
                              // Text("*", style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          if(deliverable.length < 10)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  deliverable.add(TextEditingController());
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                                child: Icon(Icons.add, color: Colors.white, size: 16),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: deliverable.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: Get.width,
                            // height: 130.h,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(20))),
                            // padding: EdgeInsets.only(left: 20.w, right: 20.w),
                            child: TextFormField(
                                minLines: 2,
                                maxLines: null,
                                controller: deliverable[index],style: GoogleFonts.merriweather(color: Colors.white),
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                    errorStyle: const TextStyle(height: 0),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white70, width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                        const BorderSide(color: Colors.blue, width: 1.0)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                        const BorderSide(color: Colors.red, width: 1.0)),
                                    hintStyle: GoogleFonts.ubuntu(),
                                    label: RichText(
                                      text: TextSpan(text: 'Deliverable ${index+1}', children: [
                                        TextSpan(
                                            text: '',
                                            style: const TextStyle(color: Colors.red))
                                      ]),
                                    ),
                                    suffixIcon: deliverable.length == 1  ? null : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          deliverable.removeAt(index);
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          VerticalDivider(),
                                          Icon(Icons.remove, color: Colors.white, size : 20),
                                        ],
                                      ),
                                    ),
                                    // labelText: label + (isMandatory ? ' *' : ''),
                                    labelStyle:
                                    TextStyle(color: Colors.white70, fontSize: 40.sp))
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                textField('Script', scriptController),
                textField("Url", urlController),

                if(widget.eventData['entryManagementCouponList'] !=null)
                  SizedBox(height: 10,),

                if(widget.eventData['entryManagementCouponList'] !=null)
                  ValueListenableBuilder(
                    valueListenable: selectedEntryCoupon,
                    builder: (context, String? selectValue, child) =>
                      Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AppDropdown(
                        items: entryList
                            .map((e) => DropdownMenuItem(
                          value: e['couponCode'].toString(),
                          child: Text(
                            e['couponCode'].toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedEntryCoupon.value = value;
                          });
                        },
                        value: selectValue ,
                        hintText: 'Select Entry Coupon',
                        showTitle: false,
                        title: 'Entry Coupon',
                      ),
                    ),
                  ),
                if(widget.eventData['entryManagementCouponList'] !=null)
                  SizedBox(
                    height: 120.h,
                    width: Get.width - 100.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Start Date: ${DateFormat.yMMMd().format(startSelectedEntryDate)}",
                          style: GoogleFonts.ubuntu(
                              color: Colors.white70, fontSize: 45.sp),
                        ),
                        GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                  initialDate: startSelectedEntryDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                  context: context);
                              if (picked != null &&
                                  picked != startSelectedEntryDate) {
                                setState(() {
                                  startSelectedEntryDate = picked;
                                  if (endSelectedEntryDate
                                      .isBefore(startSelectedEntryDate)) {
                                    endSelectedEntryDate = picked;
                                  }
                                });
                              }
                            },
                            child: Container(
                              height: 100.h,
                              width: 300.w,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white, width: 4.h)),
                              child: Center(
                                  child: Text(
                                    "Select Date",
                                    style:
                                    GoogleFonts.ubuntu(color: Colors.white),
                                  )),
                            )),
                      ],
                    ),
                  ).marginOnly(
                      left: 30.w, right: 30.w, bottom: 10.h, top: 20.h),
                if(widget.eventData['entryManagementCouponList'] !=null)
                SizedBox(
                  height: 120.h,
                  width: Get.width - 100.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "End Date: ${DateFormat.yMMMd().format(endSelectedEntryDate)}",
                        style: GoogleFonts.ubuntu(
                            color: Colors.white70, fontSize: 45.sp),
                      ),
                      GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                                initialDate: endSelectedEntryDate,
                                firstDate: startSelectedEntryDate,
                                lastDate: DateTime(2101),
                                context: context);
                            if (picked != null &&
                                picked != endSelectedEntryDate) {
                              setState(() {
                                endSelectedEntryDate = picked;
                              });
                            }
                          },
                          child: Container(
                            height: 100.h,
                            width: 300.w,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white, width: 4.h)),
                            child: Center(
                                child: Text(
                                  "Select Date",
                                  style:
                                  GoogleFonts.ubuntu(color: Colors.white),
                                )),
                          )),
                    ],
                  ),
                ).marginOnly(
                    left: 30.w, right: 30.w,  top: 20.h),
                if(widget.eventData['entryManagementCouponList'] !=null)
                  SizedBox(height: 10,),
                if(widget.eventData['entryManagementCouponList'] !=null)
                  textField("Offered Commission Entry ", offeredSalesCommisionController,isNum: true,isReadOnly: true),
                if(widget.eventData['tableManagementCouponList'] !=null)
                  const SizedBox(height: 16),
                if(widget.eventData['tableManagementCouponList'] !=null)
                  ValueListenableBuilder(
                    valueListenable: selectedTableCoupon,
                    builder: (context, String? selectTable, child) =>
                     Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AppDropdown(
                        items: tableList
                            .map((e) => DropdownMenuItem(
                          value: e['couponCode'].toString(),
                          child: Text(
                            e['couponCode'].toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                            selectedTableCoupon.value = value;
                        },
                        value: selectTable ,
                        hintText: 'Select Table Coupon',
                        showTitle: false,
                        title: 'Table Coupon',
                      ),
                    ),
                  ),
                if(widget.eventData['tableManagementCouponList'] !=null)
                  SizedBox(
                    height: 120.h,
                    width: Get.width - 100.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Start Date: ${DateFormat.yMMMd().format(startSelectedTableDate)}",
                          style: GoogleFonts.ubuntu(
                              color: Colors.white70, fontSize: 45.sp),
                        ),
                        GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                  initialDate: startSelectedTableDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                  context: context);
                              if (picked != null &&
                                  picked != startSelectedTableDate) {
                                setState(() {
                                  startSelectedTableDate = picked;
                                  if (endSelectedTableDate
                                      .isBefore(startSelectedTableDate)) {
                                    endSelectedTableDate = picked;
                                  }
                                });
                              }
                            },
                            child: Container(
                              height: 100.h,
                              width: 300.w,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white, width: 4.h)),
                              child: Center(
                                  child: Text(
                                    "Select Date",
                                    style:
                                    GoogleFonts.ubuntu(color: Colors.white),
                                  )),
                            )),
                      ],
                    ),
                  ).marginOnly(
                      left: 30.w, right: 30.w, bottom: 10.h, top: 20.h),
                if(widget.eventData['tableManagementCouponList'] !=null)
                  SizedBox(
                    height: 120.h,
                    width: Get.width - 100.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "End Date: ${DateFormat.yMMMd().format(endSelectedTableDate)}",
                          style: GoogleFonts.ubuntu(
                              color: Colors.white70, fontSize: 45.sp),
                        ),
                        GestureDetector(
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                  initialDate: endSelectedTableDate,
                                  firstDate: startSelectedTableDate,
                                  lastDate: DateTime(2101),
                                  context: context);
                              if (picked != null &&
                                  picked != endSelectedTableDate) {
                                setState(() {
                                  endSelectedTableDate = picked;
                                });
                              }
                            },
                            child: Container(
                              height: 100.h,
                              width: 300.w,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white, width: 4.h)),
                              child: Center(
                                  child: Text(
                                    "Select Date",
                                    style:
                                    GoogleFonts.ubuntu(color: Colors.white),
                                  )),
                            )),
                      ],
                    ),
                  ).marginOnly(
                      left: 30.w, right: 30.w, bottom: 0.h, top: 20.h),
                if(widget.eventData['tableManagementCouponList'] !=null)
                  SizedBox(height: 10,),
                if(widget.eventData['tableManagementCouponList'] !=null)
                  textField("Offered Commission Table Management", offeredSalesCommisionTableController,isNum: true,isReadOnly: true),

                // Obx(
                //       () =>Container(
                //         child: Column(
                //           children:[
                //             Text('Choose start Date',style:TextStyle(fontWeight: FontWeight.w700,color: Colors.white)),
                //           ]
                //         ),
     // )

                      //     CouponCard(
                      // titleText:
                      // 'Choose Start Date & Time: ${couponCodeController.startDate}',
                      // widget: const StartEndDate(isStartDate: true)),
                // ),
                // Obx(
                //       () => CouponCard(
                //       titleText:
                //       'Choose End Date  & Time: ${couponCodeController.endDate}',
                //       widget: const StartEndDate()),
                // ),


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
                      child: Text(widget.isEditEvent
                          ? "Cancel"
                          : "Cancel",
                        style: GoogleFonts.ubuntu(
                          color: Colors.orange,

                        ),),
                    ),
                    SizedBox(
                      width: 50.w,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        print('check ${entryList[0]}');
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        String planData = pref.getString('planData') ?? '{}';
                        Map<String, dynamic> jsonConvert = jsonDecode(planData);
                        if (_formKey.currentState?.validate() == true) {
                          try {
                            // if(deliverable.where((element) => element.text.isEmpty).toList().isNotEmpty){
                            //   Fluttertoast.showToast(msg: "Please fill all deliverables");
                            //   return;
                            // }
                            if(urlController.text.isNotEmpty && !urlController.text.contains('https://') && !urlController.text.contains('http://') && !urlController.text.contains('www')){
                              Fluttertoast.showToast(msg: "Please enter a valid url");
                              return;
                            }
                            if(currentIndex ==1){
                              if(amountPaidController.text.isEmpty){
                                Fluttertoast.showToast(msg: "Please enter a valid amount");
                                return;
                              }
                            }
                            // if(offerFromMenu.isEmpty){
                            //   Fluttertoast.showToast(msg: "Please select offer from menu gender");
                            //   return;
                            // }
                            // if(offerFromMenu.where((element) => element['gender'].isEmpty || element['menu'].isEmpty).toList().isNotEmpty){
                            //   Fluttertoast.showToast(msg: "Please select all menus");
                            //   return;
                            // }
                            if (_title.text.isNotEmpty) {
                              EasyLoading.show();
                              DateTime startTimeApi = DateTime(
                                startSelectedDate.year,
                                startSelectedDate.month,
                                startSelectedDate.day,
                                startTime.hour,
                                startTime.minute,
                              );
                              DateTime endTimeApi = DateTime(
                                endSelectedDate.year,
                                endSelectedDate.month,
                                endSelectedDate.day,
                                startTime.hour,
                                startTime.minute,
                              ); DateTime startTimeApiEntry = DateTime(
                                startSelectedEntryDate.year,
                                startSelectedEntryDate.month,
                                startSelectedEntryDate.day,
                                startTime.hour,
                                startTime.minute,
                              );
                              DateTime endTimeApiEntry = DateTime(
                                endSelectedEntryDate.year,
                                endSelectedEntryDate.month,
                                endSelectedEntryDate.day,
                                startTime.hour,
                                startTime.minute,
                              ); DateTime startTimeApiTable = DateTime(
                                startSelectedTableDate.year,
                                startSelectedTableDate.month,
                                startSelectedTableDate.day,
                                startTime.hour,
                                startTime.minute,
                              );
                              DateTime endTimeApiTable = DateTime(
                                endSelectedTableDate.year,
                                endSelectedTableDate.month,
                                endSelectedTableDate.day,
                                startTime.hour,
                                startTime.minute,
                              );
                              print('test issue tha tis ${startTimeApi}');
                              print('test issue tha tis ${endTimeApi}');
                              Map<String, dynamic> sendData = {
                                'id': menuID,
                                'clubUID': widget.isOrganiser?widget.eventData['clubUID']:uid(),
                                'isOrganiser':widget.isOrganiser?'Organiser':'venue',
                                'organiserId':widget.isOrganiser?uid():'',
                                'eventId': widget.eventId,
                                'fillerCouponCode': fillerCouponCode.text,
                                'noOfEntry': noOfEntry.text,
                                'budget': _title.text,
                                'detail': _briefEvent.text,
                                "eventName": widget.eventData['title'],
                                "startDate": startTimeApi,
                                "endDate": endTimeApi,
                                "startDateEntry": startTimeApiEntry,
                                "endDateEntry": endTimeApiEntry,
                                "startDateTable": startTimeApiTable,
                                "endDateTable": endTimeApiTable,
                                'offeredCommissionPr':offeredSalesCommisionController.text,
                                'offeredCommissionTablePr':offeredSalesCommisionTableController.text,
                                "invite": invite,
                                "urlPromotion":urlController.text,
                                "eventLink":url,
                                'noOfBarterCollab': int.parse(noOfEntry.text),
                                'noOfPromoterCollab': int.parse(noOfPromoterCollabController.text),
                                'amountPaid': amountPaidController.text,
                                'deliverables': deliverable.map((e) => e.text).toList(),
                                'script': scriptController.text,
                                'offerFromMenu': offerFromMenu,
                                'isPaid':currentIndex==1?true:false,
                                'entryCoupon':jsonEncode(entryList[0]),
                                "tableCoupon": jsonEncode(tableList[0]),
                                // 'inta': inta.text,
                                "startTime": widget.eventData['startTime'].toDate(),
                                "endTime": widget.eventData['endTime'].toDate(),
                                "acceptedBy": 0,
                                "type": "event",
                                "collabType": "promotor",
                                'planId':jsonConvert['planId']??'',
                                "dateTime": FieldValue.serverTimestamp(),
                              };
                              print('check menuId is ${menuID} \n ${sendData}');
                              FirebaseFirestore.instance
                                  .collection("EventPromotion")
                                  .doc(widget.isEditEvent ? widget.eventPromotionId : menuID)
                                  .set(sendData, SetOptions(merge: true))
                                  .whenComplete(() async {
                                if (uploadOffer.isNotEmpty || selectedPromotionVideo.isNotEmpty) {
                                  await PromotionUploadImage(
                                      uploadOffer,
                                      selectedPromotionVideo,
                                      widget.isEditEvent
                                          ? widget.eventPromotionId.toString()
                                          : menuID,
                                      homeController,
                                      coverImages: widget.isEditEvent
                                          ? uploadOffer.isEmpty
                                          ? offerImage
                                          : []
                                          : [],
                                      isOrganiser: widget.isOrganiser,
                                      isOffer: true);
                                  }
                                if (uploadPosts.isNotEmpty || selectedPostVideo.isNotEmpty) {
                                  await postsUploadImage(
                                      uploadPosts,
                                      selectedPostVideo,
                                      widget.isEditEvent
                                          ? widget.eventPromotionId.toString()
                                          : menuID,
                                      homeController,
                                      coverImages: widget.isEditEvent
                                          ? uploadOffer.isEmpty
                                          ? offerImage
                                          : []
                                          : [],
                                      isOrganiser: widget.isOrganiser,
                                      isOffer: true);
                                  }
                                if (uploadReels.isNotEmpty || selectedReel.isNotEmpty) {
                                  await reelsUploadImage(
                                      uploadReels,
                                      selectedReel,
                                      widget.isEditEvent
                                          ? widget.eventPromotionId.toString()
                                          : menuID,
                                      homeController,
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
                                if(invite == 'inviteOnly'){
                                  Get.to(InfluencerList(collabId: menuID, isEvent: true));
                                }else{
                                  Get.back();
                                }
                                Fluttertoast.showToast(
                                    msg: widget.isEditEvent
                                        ? 'Event Updated'
                                        : "Event Posted Successfully");
                              });
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Kindly fill all required fields");
                            }
                          } catch (e, s) {
                            print(e);
                            debugPrintStack(stackTrace: s);
                            Fluttertoast.showToast(msg: 'Something Went Wrong');
                          }finally{
                            EasyLoading.dismiss();
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
                        invite == 'inviteOnly' ? "Send Invite" : "Save & Upload",
                        style: GoogleFonts.ubuntu(
                          color: Colors.orange,

                        ),),
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

class CouponCodeList extends StatefulWidget {
  final String eventId;
  const CouponCodeList({super.key, required this.eventId});

  @override
  State<CouponCodeList> createState() => _CouponCodeListState();
}

class _CouponCodeListState extends State<CouponCodeList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SharedCouponEventList(eventId: widget.eventId,),
    );
  }
}


enum PromotionType {story, post, reel}
