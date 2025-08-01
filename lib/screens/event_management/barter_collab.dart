import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/controller/menu_image_upload.dart';
import 'package:club/screens/event_management/create_event_promotion.dart';
import 'package:club/screens/event_management/influencer_list.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/widgets/app_multi_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:random_string/random_string.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BarterCollab extends StatefulWidget {
  final bool paid;
  final bool isEdit;
  final String? eventPromotionalId;
  final String? eventName;
  final String type;
  final bool? isOrganiser;
  final String eventId;

  const BarterCollab(
      {super.key,
      this.paid = false,
      this.isEdit = false,
      this.eventPromotionalId,
      this.eventName, required this.eventId,
      required this.type, this.isOrganiser});

  @override
  State<BarterCollab> createState() => _BarterCollabState();
}

class _BarterCollabState extends State<BarterCollab> {
  String? businessCategory;

  setBusinessCategory() async {
    businessCategory =
        await const FlutterSecureStorage().read(key: "businessCategory");
    setState(() {});
  }

  String menuId = const Uuid().v4();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final homeController = Get.put(HomeController());

  String invite = "exploreAll";
  List influencerSelected = [];
  TextEditingController eventNameController = TextEditingController();
  TextEditingController noOfBarterCollabController = TextEditingController();
  TextEditingController amountPaidController = TextEditingController();
  List deliverable = [TextEditingController()];
  TextEditingController scriptController = TextEditingController();
  List<String> platformForPosting = [];
  TextEditingController urlController = TextEditingController();
  TextEditingController offeredBarterItemController = TextEditingController();
  List offerFromMenu = [
    {
      "gender": "",
      "menu": [],
    },
  ];
  DateTime startSelectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  DateTime endSelectedDate = DateTime.now();
  int durationInHours = 0;

  List? totalMenuData;

  bool showPromotionDropdowns = false;
  bool showPromotionalImage = false,
      showPostsImage = false,
      showReelImage = false;

  List<File> uploadCover = [];
  List<File> uploadOffer = [];
  List<File> uploadPosts = [];
  List<File> uploadReels = [];

  List coverImage = [];
  List offerImage = [];
  List postsImage = [];
  List reelsImage = [];

  List<File> selectedPromotionVideo = [];
  List<File> selectedPostVideo = [];
  List<File> selectedReel = [];

  Future<void> PromotionUploadImage(List<File> images, List<File> videos,
      String eventID, HomeController homeController,
      {required List coverImages,
      bool isOffer = false,
      bool isOrganiser = false}) async {
    print("event id is : $eventID");
    // if(videos.isEmpty){
    var imageUrls = await Future.wait(images.map((image) async {
      String url = '';
      if (isOffer) {
        url =
            'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
      } else {
        url =
            'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
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
          {'promotionImages': images.isNotEmpty ? imageUrls : coverImages},
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
    //       {'promotionImages': videoUrls},
    //       SetOptions(merge: true));
    // }
  }

  Future<void> postsUploadImage(List<File> images, List<File> videos,
      String eventID, HomeController homeController,
      {required List coverImages,
      bool isOffer = false,
      bool isOrganiser = false}) async {
    // if(videos.isEmpty){
    var imageUrls = await Future.wait(images.map((image) async {
      String url = '';
      if (isOffer) {
        url =
            'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
      } else {
        url =
            'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
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

  Future<void> reelsUploadImage(List<File> images, List<File> videos,
      String eventID, HomeController homeController,
      {required List coverImages,
      bool isOffer = false,
      bool isOrganiser = false}) async {
    // if(videos.isEmpty){
    var imageUrls = await Future.wait(images.map((image) async {
      String url = '';
      if (isOffer) {
        url =
            'Promotion/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
      } else {
        url =
            'Promotion/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}${image.path.split('/').last}';
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

  _getFromGallery({bool isOffer = false}) async {
    await cropImageMultiple(false, promotionType: PromotionType.story)
        .then((value) {
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
    await cropImageMultiple(false, promotionType: PromotionType.post)
        .then((value) {
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
    await cropImageMultiple(false, promotionType: PromotionType.reel)
        .then((value) {
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

  Widget imageCoverWidget(
      List coverImages, List uploadImages, List<File> videos,
      {bool isOffer = false,
      bool isNineSixteenValue = false,
      required VoidCallback onTap,
      required String title,
      required VoidCallback onCancel,
      required PromotionType promotionType}) {
    double carouselHeight =
        isNineSixteenValue && !isOffer ? (Get.width - 100.w) * 16 / 9 : 600.w;
    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: promotionType == PromotionType.story ||
                      promotionType == PromotionType.reel
                  ? 9 / 16
                  : 4 / 5,
              child: Container(
                      // height: carouselHeight,
                      // width: Get.width - 100.w,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white)),
                      child: coverImages.isNotEmpty && uploadImages.isEmpty
                          ? eventCarousel(coverImages,
                              aspectRatio:
                                  promotionType == PromotionType.story ||
                                          promotionType == PromotionType.reel
                                      ? 9 / 16
                                      : 4 / 5)
                          : uploadImages.isNotEmpty
                              ? eventCarousel(uploadImages,
                                  aspectRatio: promotionType ==
                                              PromotionType.story ||
                                          promotionType == PromotionType.reel
                                      ? 9 / 16
                                      : 4 / 5)
                              //     : videos.isNotEmpty ?
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
        Text(
            "Aspect Ratio : ${promotionType == PromotionType.story || promotionType == PromotionType.reel ? '9:16' : '4:5'}",
            style: const TextStyle(color: Colors.white)),
        ElevatedButton(
          onPressed: onTap,
          style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.resolveWith((states) => Colors.black)),
          child: Text(
            !isOffer ? "Upload Cover" : title,
            style: GoogleFonts.ubuntu(
              color: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setBusinessCategory();
    fetchMenuList();
    if (widget.isEdit && widget.eventPromotionalId != null) {
      fetchEventPromotion();
    }
  }

  void fetchMenuList() async {
    QuerySnapshot menuData =
        await FirebaseFirestore.instance.collection("Menu").get();
    totalMenuData = menuData.docs;
    setState(() {});
  }

  void fetchEventPromotion() async {
    DocumentSnapshot promotionData = await FirebaseFirestore.instance
        .collection("EventPromotion")
        .doc(widget.eventPromotionalId!)
        .get();
    menuId = widget.eventPromotionalId!;
    invite = promotionData['invite'];
    eventNameController.text = promotionData['eventName'];
    noOfBarterCollabController.text =
        promotionData['noOfBarterCollab'].toString();
    amountPaidController.text = promotionData['amountPaid'].toString();
    deliverable = (promotionData['deliverables'] as List)
        .map((e) => TextEditingController(text: e))
        .toList();
    scriptController.text = promotionData['script'];
    offerFromMenu = promotionData['offerFromMenu'];
    startSelectedDate = promotionData['startTime'].toDate();
    startTime = TimeOfDay(
        hour: (promotionData['startTime'].toDate() as DateTime).hour,
        minute: (promotionData['startTime'].toDate() as DateTime).minute);
    endSelectedDate = promotionData['endTime'].toDate();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:widget.isOrganiser ==true?SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isEdit)
                  Center(
                      child: Text("Update",
                          style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600)))
                      .paddingOnly(top: 10),
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
                // if(!widget.paid)
                // SizedBox(
                //   height: 120.h,
                //   width: Get.width - 100.w,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Start Time: ${DateFormat('hh : mm a').format(DateTime(startSelectedDate.year, startSelectedDate.month, startSelectedDate.day, startTime.hour, startTime.minute))}",
                //         style: GoogleFonts.ubuntu(
                //             color: Colors.white70, fontSize: 45.sp),
                //       ),
                //       GestureDetector(
                //           onTap: () async {
                //             final TimeOfDay? pickedStartTime =
                //             await showTimePicker(
                //                 context: context, initialTime: startTime);
                //             if (pickedStartTime != null &&
                //                 pickedStartTime != startTime) {
                //               setState(() {
                //                 startTime = pickedStartTime;
                //               });
                //             }
                //           },
                //           child: Container(
                //             height: 100.h,
                //             width: 300.w,
                //             decoration: BoxDecoration(
                //                 color: Colors.black,
                //                 borderRadius: BorderRadius.circular(20),
                //                 border: Border.all(
                //                     color: Colors.white, width: 4.h)),
                //             child: Center(
                //                 child: Text(
                //                   "Select Time",
                //                   style: GoogleFonts.ubuntu(color: Colors.white),
                //                 )),
                //           )),
                //     ],
                //   ),
                // ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                // if(!widget.paid)
                //   SizedBox(
                //   height: 120.h,
                //   width: Get.width - 100.w,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Duration: $durationInHours hours",
                //         style: GoogleFonts.ubuntu(
                //             color: Colors.white70, fontSize: 45.sp),
                //       ),
                //       GestureDetector(
                //           onTap: () async {
                //             Get.defaultDialog(
                //                 title: 'Choose duration in Hours',
                //                 content: Builder(builder: (context) {
                //                   TextEditingController durationController =
                //                   TextEditingController(
                //                       text: '$durationInHours');
                //                   return Column(
                //                     children: [
                //                       SizedBox(
                //                         width: 300.w,
                //                         child: TextFormField(
                //                           style: TextStyle(fontSize: 50.sp),
                //                           textAlign: TextAlign.center,
                //                           decoration: const InputDecoration(
                //                               border: OutlineInputBorder(
                //                                   borderSide: BorderSide(
                //                                       color: Colors.blue))),
                //                           controller: durationController,
                //                           keyboardType: TextInputType.number,
                //                           inputFormatters: [
                //                             FilteringTextInputFormatter
                //                                 .digitsOnly
                //                           ],
                //                           validator: (validate) {
                //                             if (durationController
                //                                 .text.isNotEmpty) {
                //                               return null;
                //                             } else {
                //                               return 'Enter a valid value';
                //                             }
                //                           },
                //                         ),
                //                       ).paddingSymmetric(vertical: 20.h),
                //                       ElevatedButton(
                //                           style: ButtonStyle(
                //                               backgroundColor:
                //                               WidgetStateProperty
                //                                   .resolveWith((states) =>
                //                               Colors.black)),
                //                           onPressed: () {
                //                             setState(() {
                //                               durationInHours = int.parse(
                //                                   durationController.text);
                //                             });
                //                             Get.back();
                //                           },
                //                           child: const Text('Ok'))
                //                     ],
                //                   );
                //                 }));
                //           },
                //           child: Container(
                //             height: 100.h,
                //             width: 300.w,
                //             decoration: BoxDecoration(
                //                 color: Colors.black,
                //                 borderRadius: BorderRadius.circular(20),
                //                 border: Border.all(
                //                     color: Colors.white, width: 4.h)),
                //             child: Center(
                //                 child: Text(
                //                   "Select",
                //                   style: GoogleFonts.ubuntu(color: Colors.white),
                //                 )),
                //           )),
                //     ],
                //   ),
                // ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h)
                // else
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
                if (!widget.isEdit)
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
                          const Text("Invite Only",
                              style: TextStyle(color: Colors.white))
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
                          const Text("Explore All",
                              style: TextStyle(color: Colors.white))
                        ],
                      )
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    overlayColor: WidgetStateProperty.resolveWith(
                            (states) => Colors.transparent),
                    onTap: () {
                      setState(() {
                        showPromotionDropdowns = !showPromotionDropdowns;
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Upload Promotional Data ${widget.paid ? '' : '(If any)'}",
                            style: GoogleFonts.ubuntu(
                                fontSize: 45.sp,
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                      if (showPromotionalImage)
                        Column(
                          children: [
                            imageCoverWidget(offerImage, uploadOffer,
                                selectedPromotionVideo,
                                isOffer: true,
                                title: 'Story image',
                                onTap: () async {
                                  _getFromGallery(isOffer: true);
                                },
                                onCancel: () => setState(() {
                                  offerImage = [];
                                  uploadOffer = [];
                                  selectedPromotionVideo = [];
                                }),
                                promotionType: PromotionType.story),
                            ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? picker =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.video,
                                      allowMultiple: true);
                                  if (picker != null) {
                                    setState(() {
                                      selectedPromotionVideo = picker
                                          .paths
                                          .map((e) => File(e!))
                                          .toList();
                                      // offerImage = [];
                                      uploadOffer = [
                                        ...uploadOffer,
                                        ...selectedPromotionVideo
                                      ];
                                    });
                                  }
                                },
                                child: const Text("Choose Video File")),
                          ],
                        ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                      if (showPostsImage)
                        Column(
                          children: [
                            imageCoverWidget(postsImage, uploadPosts,
                                selectedPostVideo,
                                isOffer: true,
                                title: 'Post image',
                                onTap: () async {
                                  _getPostsFromGallery(isOffer: true);
                                },
                                onCancel: () => setState(() {
                                  postsImage = [];
                                  uploadPosts = [];
                                  selectedPostVideo = [];
                                }),
                                promotionType: PromotionType.post),
                            ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? picker =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.video,
                                      allowMultiple: true);
                                  if (picker != null) {
                                    setState(() {
                                      selectedPostVideo = picker.paths
                                          .map((e) => File(e!))
                                          .toList();
                                      // postsImage = [];
                                      uploadPosts = [
                                        ...uploadPosts,
                                        ...selectedPostVideo
                                      ];
                                    });
                                  }
                                },
                                child: const Text("Choose Video File")),
                          ],
                        ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                      if (showReelImage)
                        Column(
                          children: [
                            imageCoverWidget(
                                reelsImage, uploadReels, selectedReel,
                                isOffer: true,
                                title: 'Reel',
                                onTap: () async {
                                  _getReelsImagesFromGallery(
                                      isOffer: true);
                                },
                                onCancel: () => setState(() {
                                  reelsImage = [];
                                  uploadReels = [];
                                  selectedReel = [];
                                }),
                                promotionType: PromotionType.reel),
                            ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? picker =
                                  await FilePicker.platform.pickFiles(
                                      type: FileType.video,
                                      allowMultiple: true);
                                  if (picker != null) {
                                    setState(() {
                                      selectedReel = picker.paths
                                          .map((e) => File(e!))
                                          .toList();
                                      // reelsImage = [];
                                      uploadReels = [
                                        ...uploadReels,
                                        ...selectedReel
                                      ];
                                    });
                                  }
                                },
                                child: const Text("Choose Video File")),
                          ],
                        ),
                    ],
                  ),
                const SizedBox(height: 10),
                if (widget.eventName == null)
               textField(
                      '${widget.paid ? 'Promotional' : 'Event'} Name',
                      eventNameController),
                textField(
                    'No. of ${widget.paid ? 'influencer' : 'barter'} collab\'s',
                    noOfBarterCollabController,
                    isNum: true,
                    isMandatory: true),
                textField(
                    'Amount to be paid ${'1000/Influencer'}',
                    amountPaidController,
                    isNum: true,
                    isReadOnly: true,
                    isMandatory: widget.paid),
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
                              Text("Deliverable",
                                  style: TextStyle(color: Colors.white)),
                              SizedBox(width: 5),
                              Text("*",
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          if (deliverable.length < 10)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  deliverable
                                      .add(TextEditingController());
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.white, width: 1),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 16),
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
                            margin:
                            const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20))),
                            // padding: EdgeInsets.only(left: 20.w, right: 20.w),
                            child: TextFormField(
                                minLines: 2,
                                maxLines: null,
                                controller: deliverable[index],
                                style: GoogleFonts.merriweather(
                                    color: Colors.white),
                                decoration: InputDecoration(
                                    alignLabelWithHint: true,
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    errorStyle:
                                    const TextStyle(height: 0),
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white70,
                                          width: 1.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.blue,
                                            width: 1.0)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 1.0)),
                                    hintStyle: GoogleFonts.ubuntu(),
                                    label: RichText(
                                      text: TextSpan(
                                          text:
                                          'Deliverable ${index + 1}',
                                          children: const [
                                            TextSpan(
                                                text: '',
                                                style: TextStyle(
                                                    color: Colors.red))
                                          ]),
                                    ),
                                    suffixIcon: deliverable.length == 1
                                        ? null
                                        : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          deliverable
                                              .removeAt(index);
                                        });
                                      },
                                      child: const Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          VerticalDivider(),
                                          Icon(Icons.remove,
                                              color: Colors.white,
                                              size: 20),
                                        ],
                                      ),
                                    ),
                                    // labelText: label + (isMandatory ? ' *' : ''),
                                    labelStyle: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 40.sp))),
                          );
                        },
                      )
                    ],
                  ),
                ),
                textField('Script', scriptController),
                if (businessCategory != "1")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text("Platform to be used",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17)),
                            Wrap(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: platformForPosting
                                          .contains("Instagram"),
                                      onChanged: (value) {
                                        if (platformForPosting
                                            .contains("Instagram")) {
                                          platformForPosting
                                              .remove("Instagram");
                                        } else {
                                          platformForPosting
                                              .add("Instagram");
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    const Text("Instagram",
                                        style: TextStyle(
                                            color: Colors.white))
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: platformForPosting
                                          .contains("Facebook"),
                                      onChanged: (value) {
                                        if (platformForPosting
                                            .contains("Facebook")) {
                                          platformForPosting
                                              .remove("Facebook");
                                        } else {
                                          platformForPosting
                                              .add("Facebook");
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    const Text("Facebook",
                                        style: TextStyle(
                                            color: Colors.white))
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: platformForPosting
                                          .contains("Youtube"),
                                      onChanged: (value) {
                                        if (platformForPosting
                                            .contains("Youtube")) {
                                          platformForPosting
                                              .remove("Youtube");
                                        } else {
                                          platformForPosting
                                              .add("Youtube");
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    const Text("Youtube",
                                        style: TextStyle(
                                            color: Colors.white))
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: platformForPosting
                                          .contains("Linkedin"),
                                      onChanged: (value) {
                                        if (platformForPosting
                                            .contains("Linkedin")) {
                                          platformForPosting
                                              .remove("Linkedin");
                                        } else {
                                          platformForPosting
                                              .add("Linkedin");
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    const Text("Linkedin",
                                        style: TextStyle(
                                            color: Colors.white))
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: platformForPosting
                                          .contains("Twitter"),
                                      onChanged: (value) {
                                        if (platformForPosting
                                            .contains("Twitter")) {
                                          platformForPosting
                                              .remove("Twitter");
                                        } else {
                                          platformForPosting
                                              .add("Twitter");
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    const Text("Twitter",
                                        style: TextStyle(
                                            color: Colors.white))
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                // if(businessCategory != "1")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    textField("Url", urlController),
                  ],
                ),
                if (!widget.paid && businessCategory != "1")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      textField("Offered barter item",
                          offeredBarterItemController),
                    ],
                  ),
                if (businessCategory == "1")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text("Offer from menu/pax",
                                    style:
                                    TextStyle(color: Colors.white)),
                                SizedBox(width: 5),
                                // Text("*",
                                //     style: TextStyle(color: Colors.red)),
                              ],
                            ),
                            if (offerFromMenu.length < 4)
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
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 16),
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
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white,
                                          width: 0.5),
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Checkbox(
                                                materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                                value: offerFromMenu
                                                    .where((element) =>
                                                (element['gender'] ==
                                                    'male' ||
                                                    element['gender'] ==
                                                        'both') &&
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] !=
                                                        element[
                                                        'gender'])
                                                    .toList()
                                                    .isNotEmpty
                                                    ? true
                                                    : offerFromMenu[index]
                                                [
                                                'gender'] ==
                                                    'male' ||
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] ==
                                                        'both',
                                                activeColor: offerFromMenu
                                                    .where((element) =>
                                                (element['gender'] ==
                                                    'male' ||
                                                    element['gender'] ==
                                                        'both') &&
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] !=
                                                        element[
                                                        'gender'])
                                                    .toList()
                                                    .isNotEmpty
                                                    ? Colors.white
                                                    : null,
                                                onChanged: (value) {
                                                  if (offerFromMenu
                                                      .where((element) =>
                                                  (element['gender'] ==
                                                      'male' ||
                                                      element['gender'] ==
                                                          'both') &&
                                                      offerFromMenu[
                                                      index]
                                                      [
                                                      'gender'] !=
                                                          element[
                                                          'gender'])
                                                      .toList()
                                                      .isNotEmpty) return;
                                                  setState(() {
                                                    offerFromMenu[index]
                                                    ['gender'] =
                                                    "male";
                                                  });
                                                },
                                              ),
                                              const Text("Male",
                                                  style: TextStyle(
                                                      color:
                                                      Colors.white))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Checkbox(
                                                materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                                value: offerFromMenu
                                                    .where((element) =>
                                                (element['gender'] ==
                                                    'female' ||
                                                    element['gender'] ==
                                                        'both') &&
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] !=
                                                        element[
                                                        'gender'])
                                                    .toList()
                                                    .isNotEmpty
                                                    ? true
                                                    : offerFromMenu[index]
                                                [
                                                'gender'] ==
                                                    'female' ||
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] ==
                                                        'both',
                                                activeColor: offerFromMenu
                                                    .where((element) =>
                                                (element['gender'] ==
                                                    'female' ||
                                                    element['gender'] ==
                                                        'both') &&
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] !=
                                                        element[
                                                        'gender'])
                                                    .toList()
                                                    .isNotEmpty
                                                    ? Colors.white
                                                    : null,
                                                onChanged: (value) {
                                                  if (offerFromMenu
                                                      .where((element) =>
                                                  (element['gender'] ==
                                                      'female' ||
                                                      element['gender'] ==
                                                          'both') &&
                                                      offerFromMenu[
                                                      index]
                                                      [
                                                      'gender'] !=
                                                          element[
                                                          'gender'])
                                                      .toList()
                                                      .isNotEmpty) return;
                                                  setState(() {
                                                    offerFromMenu[index]
                                                    ['gender'] =
                                                    "female";
                                                  });
                                                },
                                              ),
                                              const Text("Female",
                                                  style: TextStyle(
                                                      color:
                                                      Colors.white))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Checkbox(
                                                materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                                value: offerFromMenu
                                                    .where((element) =>
                                                (element[
                                                'gender'] ==
                                                    'both' ||
                                                    element['gender'] ==
                                                        'male' ||
                                                    element['gender'] ==
                                                        'female') &&
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] !=
                                                        element[
                                                        'gender'])
                                                    .toList()
                                                    .isNotEmpty
                                                    ? true
                                                    : offerFromMenu[index]
                                                ['gender'] ==
                                                    'both',
                                                activeColor: offerFromMenu
                                                    .where((element) =>
                                                (element[
                                                'gender'] ==
                                                    'both' ||
                                                    element['gender'] ==
                                                        'male' ||
                                                    element['gender'] ==
                                                        'female') &&
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] !=
                                                        element[
                                                        'gender'])
                                                    .toList()
                                                    .isNotEmpty
                                                    ? Colors.white
                                                    : null,
                                                onChanged: (value) {
                                                  if (offerFromMenu
                                                      .where((element) =>
                                                  (element[
                                                  'gender'] ==
                                                      'both' ||
                                                      element['gender'] ==
                                                          'male' ||
                                                      element['gender'] ==
                                                          'female') &&
                                                      offerFromMenu[
                                                      index]
                                                      [
                                                      'gender'] !=
                                                          element[
                                                          'gender'])
                                                      .toList()
                                                      .isNotEmpty) return;
                                                  setState(() {
                                                    offerFromMenu[index]
                                                    ['gender'] =
                                                    "both";
                                                  });
                                                },
                                              ),
                                              const Text("Both",
                                                  style: TextStyle(
                                                      color:
                                                      Colors.white))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Checkbox(
                                                materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                                value: offerFromMenu
                                                    .where((element) =>
                                                element['gender'] ==
                                                    'others' &&
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] !=
                                                        element[
                                                        'gender'])
                                                    .toList()
                                                    .isNotEmpty
                                                    ? true
                                                    : offerFromMenu[index]
                                                ['gender'] ==
                                                    'others',
                                                activeColor: offerFromMenu
                                                    .where((element) =>
                                                element['gender'] ==
                                                    'others' &&
                                                    offerFromMenu[
                                                    index]
                                                    [
                                                    'gender'] !=
                                                        element[
                                                        'gender'])
                                                    .toList()
                                                    .isNotEmpty
                                                    ? Colors.white
                                                    : null,
                                                onChanged: (value) {
                                                  if (offerFromMenu
                                                      .where((element) =>
                                                  element['gender'] ==
                                                      'others' &&
                                                      offerFromMenu[
                                                      index]
                                                      [
                                                      'gender'] !=
                                                          element[
                                                          'gender'])
                                                      .toList()
                                                      .isNotEmpty) return;
                                                  setState(() {
                                                    offerFromMenu[index]
                                                    ['gender'] =
                                                    "others";
                                                  });
                                                },
                                              ),
                                              const Text("Others",
                                                  style: TextStyle(
                                                      color:
                                                      Colors.white))
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (offerFromMenu[index]['gender']
                                          .isNotEmpty)
                                        const SizedBox(height: 10),
                                      if (offerFromMenu[index]['gender']
                                          .isNotEmpty)
                                        Column(
                                          children: [
                                            AppMultiDropdown(
                                              items: totalMenuData!
                                                  .map((e) => DropdownItem(
                                                  label:
                                                  "${e['title']} (₹${e['price']})",
                                                  value:
                                                  "${e['title']}-${e['price']}",
                                                  selected: (offerFromMenu[
                                                  index]
                                                  ['menu']
                                                  as List)
                                                      .where((element) =>
                                                  "${element['title']}-${element['price']}" ==
                                                      "${e['title']}-${e['price']}")
                                                      .toList()
                                                      .isNotEmpty))
                                                  .toList(),
                                              title:
                                              "Select menu item & qty",
                                              onSelectionChanged:
                                                  (selectedItems) {
                                                setState(() {
                                                  offerFromMenu[index]
                                                  ['menu'] =
                                                      selectedItems.map(
                                                            (e) {
                                                          List currItem = offerFromMenu[
                                                          index]
                                                          ['menu']
                                                              .where((element) =>
                                                          element[
                                                          'id'] ==
                                                              e)
                                                              .toList();
                                                          return {
                                                            "id": e,
                                                            "title": e
                                                                .toString()
                                                                .split('-')
                                                                .first,
                                                            "price": e
                                                                .toString()
                                                                .split('-')
                                                                .last,
                                                            "qty": currItem
                                                                .isEmpty
                                                                ? 1
                                                                : currItem
                                                                .first[
                                                            'qty']
                                                          };
                                                        },
                                                      ).toList();
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                              const NeverScrollableScrollPhysics(),
                                              itemCount:
                                              offerFromMenu[index]
                                              ['menu']
                                                  .length,
                                              itemBuilder:
                                                  (context, menuIndex) {
                                                return Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                        offerFromMenu[index]
                                                        [
                                                        'menu']
                                                        [
                                                        menuIndex]
                                                        ['title'],
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white)),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          color: Colors
                                                              .white,
                                                          onPressed: () {
                                                            if (offerFromMenu[index]['menu']
                                                            [
                                                            menuIndex]
                                                            [
                                                            'qty'] <=
                                                                1) {
                                                              Fluttertoast
                                                                  .showToast(
                                                                  msg:
                                                                  "Quantity should be minimum 1");
                                                              return;
                                                            }
                                                            setState(() {
                                                              offerFromMenu[
                                                              index]
                                                              [
                                                              'menu'] = offerFromMenu[index]
                                                              [
                                                              'menu']
                                                                  .map((e) => e['id'] == offerFromMenu[index]['menu'][menuIndex]['id']
                                                                  ? {
                                                                ...e,
                                                                "qty": e['qty'] - 1
                                                              }
                                                                  : e)
                                                                  .toList();
                                                            });
                                                          },
                                                          icon: const Icon(
                                                              Icons
                                                                  .remove),
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              10,
                                                              vertical:
                                                              3),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width:
                                                                  0.5),
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  3)),
                                                          child: Text(
                                                              "${offerFromMenu[index]['menu'][menuIndex]['qty']}",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                        IconButton(
                                                          color: Colors
                                                              .white,
                                                          onPressed: () {
                                                            setState(() {
                                                              offerFromMenu[
                                                              index]
                                                              [
                                                              'menu'] = offerFromMenu[index]
                                                              [
                                                              'menu']
                                                                  .map((e) => e['id'] == offerFromMenu[index]['menu'][menuIndex]['id']
                                                                  ? {
                                                                ...e,
                                                                "qty": e['qty'] + 1
                                                              }
                                                                  : e)
                                                                  .toList();
                                                            });
                                                          },
                                                          icon: const Icon(
                                                              Icons.add),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                );
                                              },
                                            ),
                                            const Divider(),
                                            const Align(
                                              alignment:
                                              Alignment.centerLeft,
                                              child: Text("Summary",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                      FontWeight
                                                          .w600)),
                                            ),
                                            const SizedBox(height: 10),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                              const NeverScrollableScrollPhysics(),
                                              itemCount:
                                              offerFromMenu[index]
                                              ['menu']
                                                  .length,
                                              itemBuilder: (context,
                                                  summaryIndex) {
                                                return Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                        offerFromMenu[index]
                                                        [
                                                        'menu']
                                                        [
                                                        summaryIndex]
                                                        ['title'],
                                                        style: const TextStyle(
                                                            color: Colors
                                                                .white)),
                                                    Text(
                                                      "₹${offerFromMenu[index]['menu'][summaryIndex]['price']} X ${offerFromMenu[index]['menu'][summaryIndex]['qty']} = ₹${int.parse(offerFromMenu[index]['menu'][summaryIndex]['price']) * offerFromMenu[index]['menu'][summaryIndex]['qty']}",
                                                      style:
                                                      const TextStyle(
                                                          color: Colors
                                                              .white),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            if ((offerFromMenu[index]
                                            ['menu'] as List)
                                                .map((e) =>
                                            int.parse(
                                                e['price']) *
                                                e['qty'])
                                                .toList()
                                                .isNotEmpty)
                                              const Divider(
                                                  color: Colors.grey),
                                            if ((offerFromMenu[index]
                                            ['menu'] as List)
                                                .map((e) =>
                                            int.parse(
                                                e['price']) *
                                                e['qty'])
                                                .toList()
                                                .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  const Text("Total",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .white)),
                                                  Text(
                                                    "₹ ${(offerFromMenu[index]['menu'] as List).map((e) => int.parse(e['price']) * e['qty']).toList().reduce((value, element) => value + element)}",
                                                    style:
                                                    const TextStyle(
                                                        color: Colors
                                                            .white),
                                                  ),
                                                ],
                                              )
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                if (offerFromMenu.length > 1)
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
                                        child: const Icon(
                                          Icons.remove_circle,
                                          size: 26,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            );
                          },
                        ),
                        if (offerFromMenu.where((element) => element['menu'].isEmpty).toList().isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 10),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Price",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                Text(
                                    "₹ ${offerFromMenu.map((e) => (e['menu'] as List).map((ele) => int.parse(ele['price']) * ele['qty']).toList().reduce((value, element) => value + element)).toList().reduce((value, element) => value + element)}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
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
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  side: const BorderSide(
                                      color: Colors.grey))),
                          backgroundColor:
                          WidgetStateProperty.all(Colors.black)),
                      child: Text(
                        "Cancel",
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
                            if (deliverable
                                .where((element) => element.text.isEmpty)
                                .toList()
                                .isNotEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please fill all deliverables");
                              return;
                            }
                            if (urlController.text.isNotEmpty &&
                                !urlController.text
                                    .contains('https://') &&
                                !urlController.text.contains('http://')) {
                              Fluttertoast.showToast(
                                  msg: "Please enter a valid url");
                              return;
                            }
                            if (businessCategory != "1") {
                              if (platformForPosting.isEmpty) {
                                Fluttertoast.showToast(
                                    msg: "Select at least one platform");
                                return;
                              }
                              if (!widget.paid &&
                                  offeredBarterItemController
                                      .text.isEmpty) {
                                Fluttertoast.showToast(
                                    msg:
                                    "Please fill offered barter item");
                                return;
                              }
                            }
                            if (businessCategory == "1") {
                              // if (offerFromMenu.isEmpty) {
                              //   Fluttertoast.showToast(
                              //       msg:
                              //       "Please select offer from menu gender");
                              //   return;
                              // }
                              // if (offerFromMenu
                              //     .where((element) =>
                              // element['gender'].isEmpty ||
                              //     element['menu'].isEmpty)
                              //     .toList()
                              //     .isNotEmpty) {
                              //   Fluttertoast.showToast(
                              //       msg: "Please select all menus");
                              //   return;
                              // }
                            }
                            if (!widget.isEdit &&
                                widget.paid &&
                                ((uploadOffer.isEmpty &&
                                    selectedPromotionVideo.isEmpty) &&
                                    (uploadPosts.isEmpty &&
                                        selectedPostVideo.isEmpty) &&
                                    (uploadReels.isEmpty &&
                                        selectedReel.isEmpty))) {
                              Fluttertoast.showToast(
                                  msg:
                                  "Please upload the promotion data");
                              return;
                            }
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
                            );
                            // widget.paid ?
                            // DateTime(
                            //     endSelectedDate.year,
                            //     endSelectedDate.month,
                            //     endSelectedDate.day,
                            //   );
                            // : DateTime(
                            //   startSelectedDate.year,
                            //   startSelectedDate.month,
                            //   startSelectedDate.day,
                            //   startTime.hour + durationInHours,
                            //   startTime.minute,
                            // );
                            Map<String, dynamic> sendData = {
                              'id': menuId,
                              'clubUID': uid(),
                              // 'eventId': widget.eventId,
                              "invite": invite,
                              "eventName": widget.eventName ??
                                  eventNameController.text,
                              "noOfBarterCollab": int.parse(
                                  noOfBarterCollabController.text),
                              'amountPaid': amountPaidController.text.isEmpty?1000:amountPaidController.text,
                              'deliverables':
                              deliverable.map((e) => e.text).toList(),
                              'script': scriptController.text,
                              'offerFromMenu': offerFromMenu,
                              "offeredBarterItem":
                              offeredBarterItemController.text,
                              "startTime": startTimeApi,
                              "endTime": endTimeApi,
                              "isPaid": widget.paid,
                              "acceptedBy": 0,
                              "platforms": platformForPosting,
                              "url": urlController.text,
                              "type": widget.type,
                              "collabType": "influencer",
                              // 'status': 'pending',
                              "dateTime": FieldValue.serverTimestamp(),
                            };
                            FirebaseFirestore.instance
                                .collection("EventPromotion")
                                .doc(menuId)
                                .set(sendData, SetOptions(merge: true))
                                .whenComplete(() async {
                              if (uploadOffer.isNotEmpty ||
                                  selectedPromotionVideo.isNotEmpty) {
                                await PromotionUploadImage(
                                    uploadOffer,
                                    selectedPromotionVideo,
                                    menuId,
                                    homeController,
                                    coverImages: offerImage,
                                    // isOrganiser: widget.isOrganiser,
                                    isOffer: true);
                              }
                              if (uploadPosts.isNotEmpty ||
                                  selectedPostVideo.isNotEmpty) {
                                await postsUploadImage(
                                    uploadPosts,
                                    selectedPostVideo,
                                    menuId,
                                    homeController,
                                    coverImages: offerImage,
                                    // isOrganiser: widget.isOrganiser,
                                    isOffer: true);
                              }
                              if (uploadReels.isNotEmpty ||
                                  selectedReel.isNotEmpty) {
                                await reelsUploadImage(uploadReels,
                                    selectedReel, menuId, homeController,
                                    coverImages: offerImage,
                                    // isOrganiser: widget.isOrganiser,
                                    isOffer: true);
                              }
                            }).whenComplete(() {
                              EasyLoading.dismiss();
                              if (invite == 'inviteOnly') {
                                Get.to(InfluencerList(collabId: menuId));
                              } else {
                                Get.back();
                              }
                              Fluttertoast.showToast(
                                  msg: "Upload Successfully");
                            });
                          } catch (e) {
                            print(e);
                            Fluttertoast.showToast(
                                msg: 'Something Went Wrong');
                          }
                        }
                      },
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all<
                              RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  side: const BorderSide(
                                      color: Colors.grey))),
                          backgroundColor:
                          WidgetStateProperty.all(Colors.black)),
                      child: Text(
                        invite == 'inviteOnly'
                            ? "Send Invite"
                            : "Save & Upload",
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
        ) : totalMenuData == null || businessCategory == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.isEdit)
                        Center(
                                child: Text("Update",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)))
                            .paddingOnly(top: 10),
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
                      // if(!widget.paid)
                      // SizedBox(
                      //   height: 120.h,
                      //   width: Get.width - 100.w,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         "Start Time: ${DateFormat('hh : mm a').format(DateTime(startSelectedDate.year, startSelectedDate.month, startSelectedDate.day, startTime.hour, startTime.minute))}",
                      //         style: GoogleFonts.ubuntu(
                      //             color: Colors.white70, fontSize: 45.sp),
                      //       ),
                      //       GestureDetector(
                      //           onTap: () async {
                      //             final TimeOfDay? pickedStartTime =
                      //             await showTimePicker(
                      //                 context: context, initialTime: startTime);
                      //             if (pickedStartTime != null &&
                      //                 pickedStartTime != startTime) {
                      //               setState(() {
                      //                 startTime = pickedStartTime;
                      //               });
                      //             }
                      //           },
                      //           child: Container(
                      //             height: 100.h,
                      //             width: 300.w,
                      //             decoration: BoxDecoration(
                      //                 color: Colors.black,
                      //                 borderRadius: BorderRadius.circular(20),
                      //                 border: Border.all(
                      //                     color: Colors.white, width: 4.h)),
                      //             child: Center(
                      //                 child: Text(
                      //                   "Select Time",
                      //                   style: GoogleFonts.ubuntu(color: Colors.white),
                      //                 )),
                      //           )),
                      //     ],
                      //   ),
                      // ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                      // if(!widget.paid)
                      //   SizedBox(
                      //   height: 120.h,
                      //   width: Get.width - 100.w,
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         "Duration: $durationInHours hours",
                      //         style: GoogleFonts.ubuntu(
                      //             color: Colors.white70, fontSize: 45.sp),
                      //       ),
                      //       GestureDetector(
                      //           onTap: () async {
                      //             Get.defaultDialog(
                      //                 title: 'Choose duration in Hours',
                      //                 content: Builder(builder: (context) {
                      //                   TextEditingController durationController =
                      //                   TextEditingController(
                      //                       text: '$durationInHours');
                      //                   return Column(
                      //                     children: [
                      //                       SizedBox(
                      //                         width: 300.w,
                      //                         child: TextFormField(
                      //                           style: TextStyle(fontSize: 50.sp),
                      //                           textAlign: TextAlign.center,
                      //                           decoration: const InputDecoration(
                      //                               border: OutlineInputBorder(
                      //                                   borderSide: BorderSide(
                      //                                       color: Colors.blue))),
                      //                           controller: durationController,
                      //                           keyboardType: TextInputType.number,
                      //                           inputFormatters: [
                      //                             FilteringTextInputFormatter
                      //                                 .digitsOnly
                      //                           ],
                      //                           validator: (validate) {
                      //                             if (durationController
                      //                                 .text.isNotEmpty) {
                      //                               return null;
                      //                             } else {
                      //                               return 'Enter a valid value';
                      //                             }
                      //                           },
                      //                         ),
                      //                       ).paddingSymmetric(vertical: 20.h),
                      //                       ElevatedButton(
                      //                           style: ButtonStyle(
                      //                               backgroundColor:
                      //                               WidgetStateProperty
                      //                                   .resolveWith((states) =>
                      //                               Colors.black)),
                      //                           onPressed: () {
                      //                             setState(() {
                      //                               durationInHours = int.parse(
                      //                                   durationController.text);
                      //                             });
                      //                             Get.back();
                      //                           },
                      //                           child: const Text('Ok'))
                      //                     ],
                      //                   );
                      //                 }));
                      //           },
                      //           child: Container(
                      //             height: 100.h,
                      //             width: 300.w,
                      //             decoration: BoxDecoration(
                      //                 color: Colors.black,
                      //                 borderRadius: BorderRadius.circular(20),
                      //                 border: Border.all(
                      //                     color: Colors.white, width: 4.h)),
                      //             child: Center(
                      //                 child: Text(
                      //                   "Select",
                      //                   style: GoogleFonts.ubuntu(color: Colors.white),
                      //                 )),
                      //           )),
                      //     ],
                      //   ),
                      // ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h)
                      // else
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
                      if (!widget.isEdit)
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
                                const Text("Invite Only",
                                    style: TextStyle(color: Colors.white))
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
                                const Text("Explore All",
                                    style: TextStyle(color: Colors.white))
                              ],
                            )
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          overlayColor: WidgetStateProperty.resolveWith(
                              (states) => Colors.transparent),
                          onTap: () {
                            setState(() {
                              showPromotionDropdowns = !showPromotionDropdowns;
                            });
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Upload Promotional Data ${widget.paid ? '' : '(If any)'}",
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 45.sp,
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
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                            if (showPromotionalImage)
                              Column(
                                children: [
                                  imageCoverWidget(offerImage, uploadOffer,
                                      selectedPromotionVideo,
                                      isOffer: true,
                                      title: 'Story image',
                                      onTap: () async {
                                        _getFromGallery(isOffer: true);
                                      },
                                      onCancel: () => setState(() {
                                            offerImage = [];
                                            uploadOffer = [];
                                            selectedPromotionVideo = [];
                                          }),
                                      promotionType: PromotionType.story),
                                  ElevatedButton(
                                      onPressed: () async {
                                        FilePickerResult? picker =
                                            await FilePicker.platform.pickFiles(
                                                type: FileType.video,
                                                allowMultiple: true);
                                        if (picker != null) {
                                          setState(() {
                                            selectedPromotionVideo = picker
                                                .paths
                                                .map((e) => File(e!))
                                                .toList();
                                            // offerImage = [];
                                            uploadOffer = [
                                              ...uploadOffer,
                                              ...selectedPromotionVideo
                                            ];
                                          });
                                        }
                                      },
                                      child: const Text("Choose Video File")),
                                ],
                              ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                            if (showPostsImage)
                              Column(
                                children: [
                                  imageCoverWidget(postsImage, uploadPosts,
                                      selectedPostVideo,
                                      isOffer: true,
                                      title: 'Post image',
                                      onTap: () async {
                                        _getPostsFromGallery(isOffer: true);
                                      },
                                      onCancel: () => setState(() {
                                            postsImage = [];
                                            uploadPosts = [];
                                            selectedPostVideo = [];
                                          }),
                                      promotionType: PromotionType.post),
                                  ElevatedButton(
                                      onPressed: () async {
                                        FilePickerResult? picker =
                                            await FilePicker.platform.pickFiles(
                                                type: FileType.video,
                                                allowMultiple: true);
                                        if (picker != null) {
                                          setState(() {
                                            selectedPostVideo = picker.paths
                                                .map((e) => File(e!))
                                                .toList();
                                            // postsImage = [];
                                            uploadPosts = [
                                              ...uploadPosts,
                                              ...selectedPostVideo
                                            ];
                                          });
                                        }
                                      },
                                      child: const Text("Choose Video File")),
                                ],
                              ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                            if (showReelImage)
                              Column(
                                children: [
                                  imageCoverWidget(
                                      reelsImage, uploadReels, selectedReel,
                                      isOffer: true,
                                      title: 'Reel',
                                      onTap: () async {
                                        _getReelsImagesFromGallery(
                                            isOffer: true);
                                      },
                                      onCancel: () => setState(() {
                                            reelsImage = [];
                                            uploadReels = [];
                                            selectedReel = [];
                                          }),
                                      promotionType: PromotionType.reel),
                                  ElevatedButton(
                                      onPressed: () async {
                                        FilePickerResult? picker =
                                            await FilePicker.platform.pickFiles(
                                                type: FileType.video,
                                                allowMultiple: true);
                                        if (picker != null) {
                                          setState(() {
                                            selectedReel = picker.paths
                                                .map((e) => File(e!))
                                                .toList();
                                            // reelsImage = [];
                                            uploadReels = [
                                              ...uploadReels,
                                              ...selectedReel
                                            ];
                                          });
                                        }
                                      },
                                      child: const Text("Choose Video File")),
                                ],
                              ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      if (widget.eventName == null)
                        textField(
                            '${widget.paid ? 'Promotional' : 'Event'} Name',
                            eventNameController),
                      textField(
                          'No. of ${widget.paid ? 'influencer' : 'barter'} collab\'s',
                          noOfBarterCollabController,
                          isNum: true,
                          isMandatory: true),
                      textField(
                          'Amount to be paid ${'1000/Influencer'}',
                          amountPaidController,
                          isNum: true,
                          isMandatory: widget.paid),
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
                                    Text("Deliverable",
                                        style: TextStyle(color: Colors.white)),
                                    SizedBox(width: 5),
                                    Text("*",
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                                if (deliverable.length < 10)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        deliverable
                                            .add(TextEditingController());
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.white, width: 1),
                                      ),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 16),
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
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  // padding: EdgeInsets.only(left: 20.w, right: 20.w),
                                  child: TextFormField(
                                      minLines: 2,
                                      maxLines: null,
                                      controller: deliverable[index],
                                      style: GoogleFonts.merriweather(
                                          color: Colors.white),
                                      decoration: InputDecoration(
                                          alignLabelWithHint: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 15),
                                          errorStyle:
                                              const TextStyle(height: 0),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white70,
                                                width: 1.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.blue,
                                                  width: 1.0)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 1.0)),
                                          hintStyle: GoogleFonts.ubuntu(),
                                          label: RichText(
                                            text: TextSpan(
                                                text:
                                                    'Deliverable ${index + 1}',
                                                children: const [
                                                  TextSpan(
                                                      text: '',
                                                      style: TextStyle(
                                                          color: Colors.red))
                                                ]),
                                          ),
                                          suffixIcon: deliverable.length == 1
                                              ? null
                                              : GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      deliverable
                                                          .removeAt(index);
                                                    });
                                                  },
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      VerticalDivider(),
                                                      Icon(Icons.remove,
                                                          color: Colors.white,
                                                          size: 20),
                                                    ],
                                                  ),
                                                ),
                                          // labelText: label + (isMandatory ? ' *' : ''),
                                          labelStyle: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 40.sp))),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      textField('Script', scriptController),
                      if (businessCategory != "1")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text("Platform to be used",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17)),
                                  Wrap(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: platformForPosting
                                                .contains("Instagram"),
                                            onChanged: (value) {
                                              if (platformForPosting
                                                  .contains("Instagram")) {
                                                platformForPosting
                                                    .remove("Instagram");
                                              } else {
                                                platformForPosting
                                                    .add("Instagram");
                                              }
                                              setState(() {});
                                            },
                                          ),
                                          const Text("Instagram",
                                              style: TextStyle(
                                                  color: Colors.white))
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: platformForPosting
                                                .contains("Facebook"),
                                            onChanged: (value) {
                                              if (platformForPosting
                                                  .contains("Facebook")) {
                                                platformForPosting
                                                    .remove("Facebook");
                                              } else {
                                                platformForPosting
                                                    .add("Facebook");
                                              }
                                              setState(() {});
                                            },
                                          ),
                                          const Text("Facebook",
                                              style: TextStyle(
                                                  color: Colors.white))
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: platformForPosting
                                                .contains("Youtube"),
                                            onChanged: (value) {
                                              if (platformForPosting
                                                  .contains("Youtube")) {
                                                platformForPosting
                                                    .remove("Youtube");
                                              } else {
                                                platformForPosting
                                                    .add("Youtube");
                                              }
                                              setState(() {});
                                            },
                                          ),
                                          const Text("Youtube",
                                              style: TextStyle(
                                                  color: Colors.white))
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: platformForPosting
                                                .contains("Linkedin"),
                                            onChanged: (value) {
                                              if (platformForPosting
                                                  .contains("Linkedin")) {
                                                platformForPosting
                                                    .remove("Linkedin");
                                              } else {
                                                platformForPosting
                                                    .add("Linkedin");
                                              }
                                              setState(() {});
                                            },
                                          ),
                                          const Text("Linkedin",
                                              style: TextStyle(
                                                  color: Colors.white))
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: platformForPosting
                                                .contains("Twitter"),
                                            onChanged: (value) {
                                              if (platformForPosting
                                                  .contains("Twitter")) {
                                                platformForPosting
                                                    .remove("Twitter");
                                              } else {
                                                platformForPosting
                                                    .add("Twitter");
                                              }
                                              setState(() {});
                                            },
                                          ),
                                          const Text("Twitter",
                                              style: TextStyle(
                                                  color: Colors.white))
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      // if(businessCategory != "1")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          textField("Url", urlController),
                        ],
                      ),
                      if (!widget.paid && businessCategory != "1")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            textField("Offered barter item",
                                offeredBarterItemController),
                          ],
                        ),
                      if (businessCategory == "1")
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Text("Offer from menu/pax",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      SizedBox(width: 5),
                                      Text("*",
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                  if (offerFromMenu.length < 4)
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
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.white, width: 1),
                                        ),
                                        child: const Icon(Icons.add,
                                            color: Colors.white, size: 16),
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
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 0.5),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      value: offerFromMenu
                                                              .where((element) =>
                                                                  (element['gender'] ==
                                                                          'male' ||
                                                                      element['gender'] ==
                                                                          'both') &&
                                                                  offerFromMenu[
                                                                              index]
                                                                          [
                                                                          'gender'] !=
                                                                      element[
                                                                          'gender'])
                                                              .toList()
                                                              .isNotEmpty
                                                          ? true
                                                          : offerFromMenu[index]
                                                                      [
                                                                      'gender'] ==
                                                                  'male' ||
                                                              offerFromMenu[
                                                                          index]
                                                                      [
                                                                      'gender'] ==
                                                                  'both',
                                                      activeColor: offerFromMenu
                                                              .where((element) =>
                                                                  (element['gender'] ==
                                                                          'male' ||
                                                                      element['gender'] ==
                                                                          'both') &&
                                                                  offerFromMenu[
                                                                              index]
                                                                          [
                                                                          'gender'] !=
                                                                      element[
                                                                          'gender'])
                                                              .toList()
                                                              .isNotEmpty
                                                          ? Colors.white
                                                          : null,
                                                      onChanged: (value) {
                                                        if (offerFromMenu
                                                            .where((element) =>
                                                                (element['gender'] ==
                                                                        'male' ||
                                                                    element['gender'] ==
                                                                        'both') &&
                                                                offerFromMenu[
                                                                            index]
                                                                        [
                                                                        'gender'] !=
                                                                    element[
                                                                        'gender'])
                                                            .toList()
                                                            .isNotEmpty) return;
                                                        setState(() {
                                                          offerFromMenu[index]
                                                                  ['gender'] =
                                                              "male";
                                                        });
                                                      },
                                                    ),
                                                    const Text("Male",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      value: offerFromMenu
                                                              .where((element) =>
                                                                  (element['gender'] ==
                                                                          'female' ||
                                                                      element['gender'] ==
                                                                          'both') &&
                                                                  offerFromMenu[
                                                                              index]
                                                                          [
                                                                          'gender'] !=
                                                                      element[
                                                                          'gender'])
                                                              .toList()
                                                              .isNotEmpty
                                                          ? true
                                                          : offerFromMenu[index]
                                                                      [
                                                                      'gender'] ==
                                                                  'female' ||
                                                              offerFromMenu[
                                                                          index]
                                                                      [
                                                                      'gender'] ==
                                                                  'both',
                                                      activeColor: offerFromMenu
                                                              .where((element) =>
                                                                  (element['gender'] ==
                                                                          'female' ||
                                                                      element['gender'] ==
                                                                          'both') &&
                                                                  offerFromMenu[
                                                                              index]
                                                                          [
                                                                          'gender'] !=
                                                                      element[
                                                                          'gender'])
                                                              .toList()
                                                              .isNotEmpty
                                                          ? Colors.white
                                                          : null,
                                                      onChanged: (value) {
                                                        if (offerFromMenu
                                                            .where((element) =>
                                                                (element['gender'] ==
                                                                        'female' ||
                                                                    element['gender'] ==
                                                                        'both') &&
                                                                offerFromMenu[
                                                                            index]
                                                                        [
                                                                        'gender'] !=
                                                                    element[
                                                                        'gender'])
                                                            .toList()
                                                            .isNotEmpty) return;
                                                        setState(() {
                                                          offerFromMenu[index]
                                                                  ['gender'] =
                                                              "female";
                                                        });
                                                      },
                                                    ),
                                                    const Text("Female",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      value: offerFromMenu
                                                              .where((element) =>
                                                                  (element[
                                                                              'gender'] ==
                                                                          'both' ||
                                                                      element['gender'] ==
                                                                          'male' ||
                                                                      element['gender'] ==
                                                                          'female') &&
                                                                  offerFromMenu[
                                                                              index]
                                                                          [
                                                                          'gender'] !=
                                                                      element[
                                                                          'gender'])
                                                              .toList()
                                                              .isNotEmpty
                                                          ? true
                                                          : offerFromMenu[index]
                                                                  ['gender'] ==
                                                              'both',
                                                      activeColor: offerFromMenu
                                                              .where((element) =>
                                                                  (element[
                                                                              'gender'] ==
                                                                          'both' ||
                                                                      element['gender'] ==
                                                                          'male' ||
                                                                      element['gender'] ==
                                                                          'female') &&
                                                                  offerFromMenu[
                                                                              index]
                                                                          [
                                                                          'gender'] !=
                                                                      element[
                                                                          'gender'])
                                                              .toList()
                                                              .isNotEmpty
                                                          ? Colors.white
                                                          : null,
                                                      onChanged: (value) {
                                                        if (offerFromMenu
                                                            .where((element) =>
                                                                (element[
                                                                            'gender'] ==
                                                                        'both' ||
                                                                    element['gender'] ==
                                                                        'male' ||
                                                                    element['gender'] ==
                                                                        'female') &&
                                                                offerFromMenu[
                                                                            index]
                                                                        [
                                                                        'gender'] !=
                                                                    element[
                                                                        'gender'])
                                                            .toList()
                                                            .isNotEmpty) return;
                                                        setState(() {
                                                          offerFromMenu[index]
                                                                  ['gender'] =
                                                              "both";
                                                        });
                                                      },
                                                    ),
                                                    const Text("Both",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      value: offerFromMenu
                                                              .where((element) =>
                                                                  element['gender'] ==
                                                                      'others' &&
                                                                  offerFromMenu[
                                                                              index]
                                                                          [
                                                                          'gender'] !=
                                                                      element[
                                                                          'gender'])
                                                              .toList()
                                                              .isNotEmpty
                                                          ? true
                                                          : offerFromMenu[index]
                                                                  ['gender'] ==
                                                              'others',
                                                      activeColor: offerFromMenu
                                                              .where((element) =>
                                                                  element['gender'] ==
                                                                      'others' &&
                                                                  offerFromMenu[
                                                                              index]
                                                                          [
                                                                          'gender'] !=
                                                                      element[
                                                                          'gender'])
                                                              .toList()
                                                              .isNotEmpty
                                                          ? Colors.white
                                                          : null,
                                                      onChanged: (value) {
                                                        if (offerFromMenu
                                                            .where((element) =>
                                                                element['gender'] ==
                                                                    'others' &&
                                                                offerFromMenu[
                                                                            index]
                                                                        [
                                                                        'gender'] !=
                                                                    element[
                                                                        'gender'])
                                                            .toList()
                                                            .isNotEmpty) return;
                                                        setState(() {
                                                          offerFromMenu[index]
                                                                  ['gender'] =
                                                              "others";
                                                        });
                                                      },
                                                    ),
                                                    const Text("Others",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (offerFromMenu[index]['gender']
                                                .isNotEmpty)
                                              const SizedBox(height: 10),
                                            if (offerFromMenu[index]['gender']
                                                .isNotEmpty)
                                              Column(
                                                children: [
                                                  AppMultiDropdown(
                                                    items: totalMenuData!
                                                        .map((e) => DropdownItem(
                                                            label:
                                                                "${e['title']} (₹${e['price']})",
                                                            value:
                                                                "${e['title']}-${e['price']}",
                                                            selected: (offerFromMenu[
                                                                            index]
                                                                        ['menu']
                                                                    as List)
                                                                .where((element) =>
                                                                    "${element['title']}-${element['price']}" ==
                                                                    "${e['title']}-${e['price']}")
                                                                .toList()
                                                                .isNotEmpty))
                                                        .toList(),
                                                    title:
                                                        "Select menu item & qty",
                                                    onSelectionChanged:
                                                        (selectedItems) {
                                                      setState(() {
                                                        offerFromMenu[index]
                                                                ['menu'] =
                                                            selectedItems.map(
                                                          (e) {
                                                            List currItem = offerFromMenu[
                                                                        index]
                                                                    ['menu']
                                                                .where((element) =>
                                                                    element[
                                                                        'id'] ==
                                                                    e)
                                                                .toList();
                                                            return {
                                                              "id": e,
                                                              "title": e
                                                                  .toString()
                                                                  .split('-')
                                                                  .first,
                                                              "price": e
                                                                  .toString()
                                                                  .split('-')
                                                                  .last,
                                                              "qty": currItem
                                                                      .isEmpty
                                                                  ? 1
                                                                  : currItem
                                                                          .first[
                                                                      'qty']
                                                            };
                                                          },
                                                        ).toList();
                                                      });
                                                    },
                                                  ),
                                                  const SizedBox(height: 10),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        offerFromMenu[index]
                                                                ['menu']
                                                            .length,
                                                    itemBuilder:
                                                        (context, menuIndex) {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              offerFromMenu[index]
                                                                          [
                                                                          'menu']
                                                                      [
                                                                      menuIndex]
                                                                  ['title'],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                          Row(
                                                            children: [
                                                              IconButton(
                                                                color: Colors
                                                                    .white,
                                                                onPressed: () {
                                                                  if (offerFromMenu[index]['menu']
                                                                              [
                                                                              menuIndex]
                                                                          [
                                                                          'qty'] <=
                                                                      1) {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                "Quantity should be minimum 1");
                                                                    return;
                                                                  }
                                                                  setState(() {
                                                                    offerFromMenu[
                                                                            index]
                                                                        [
                                                                        'menu'] = offerFromMenu[index]
                                                                            [
                                                                            'menu']
                                                                        .map((e) => e['id'] == offerFromMenu[index]['menu'][menuIndex]['id']
                                                                            ? {
                                                                                ...e,
                                                                                "qty": e['qty'] - 1
                                                                              }
                                                                            : e)
                                                                        .toList();
                                                                  });
                                                                },
                                                                icon: const Icon(
                                                                    Icons
                                                                        .remove),
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        3),
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .white,
                                                                        width:
                                                                            0.5),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            3)),
                                                                child: Text(
                                                                    "${offerFromMenu[index]['menu'][menuIndex]['qty']}",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white)),
                                                              ),
                                                              IconButton(
                                                                color: Colors
                                                                    .white,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    offerFromMenu[
                                                                            index]
                                                                        [
                                                                        'menu'] = offerFromMenu[index]
                                                                            [
                                                                            'menu']
                                                                        .map((e) => e['id'] == offerFromMenu[index]['menu'][menuIndex]['id']
                                                                            ? {
                                                                                ...e,
                                                                                "qty": e['qty'] + 1
                                                                              }
                                                                            : e)
                                                                        .toList();
                                                                  });
                                                                },
                                                                icon: const Icon(
                                                                    Icons.add),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  const Divider(),
                                                  const Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text("Summary",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        offerFromMenu[index]
                                                                ['menu']
                                                            .length,
                                                    itemBuilder: (context,
                                                        summaryIndex) {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              offerFromMenu[index]
                                                                          [
                                                                          'menu']
                                                                      [
                                                                      summaryIndex]
                                                                  ['title'],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                          Text(
                                                            "₹${offerFromMenu[index]['menu'][summaryIndex]['price']} X ${offerFromMenu[index]['menu'][summaryIndex]['qty']} = ₹${int.parse(offerFromMenu[index]['menu'][summaryIndex]['price']) * offerFromMenu[index]['menu'][summaryIndex]['qty']}",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                  if ((offerFromMenu[index]
                                                          ['menu'] as List)
                                                      .map((e) =>
                                                          int.parse(
                                                              e['price']) *
                                                          e['qty'])
                                                      .toList()
                                                      .isNotEmpty)
                                                    const Divider(
                                                        color: Colors.grey),
                                                  if ((offerFromMenu[index]
                                                          ['menu'] as List)
                                                      .map((e) =>
                                                          int.parse(
                                                              e['price']) *
                                                          e['qty'])
                                                      .toList()
                                                      .isNotEmpty)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Text("Total",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                        Text(
                                                          "₹ ${(offerFromMenu[index]['menu'] as List).map((e) => int.parse(e['price']) * e['qty']).toList().reduce((value, element) => value + element)}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ],
                                                    )
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (offerFromMenu.length > 1)
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
                                              child: const Icon(
                                                Icons.remove_circle,
                                                size: 26,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  );
                                },
                              ),
                              if (offerFromMenu
                                  .where((element) => element['menu'].isEmpty)
                                  .toList()
                                  .isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Total Price",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                      Text(
                                          "₹ ${offerFromMenu.map((e) => (e['menu'] as List).map((ele) => int.parse(ele['price']) * ele['qty']).toList().reduce((value, element) => value + element)).toList().reduce((value, element) => value + element)}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
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
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                            color: Colors.grey))),
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.black)),
                            child: Text(
                              "Cancel",
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
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              String planData = pref.getString('planData') ?? '{}';
                              Map<String, dynamic> jsonConvert = jsonDecode(planData);
                              if (_formKey.currentState?.validate() == true) {
                                try {
                                  if (deliverable
                                      .where((element) => element.text.isEmpty)
                                      .toList()
                                      .isNotEmpty) {
                                    Fluttertoast.showToast(
                                        msg: "Please fill all deliverables");
                                    return;
                                  }
                                  if (urlController.text.isNotEmpty &&
                                      !urlController.text
                                          .contains('https://') &&
                                      !urlController.text.contains('http://')) {
                                    Fluttertoast.showToast(
                                        msg: "Please enter a valid url");
                                    return;
                                  }
                                  if (businessCategory != "1") {
                                    if (platformForPosting.isEmpty) {
                                      Fluttertoast.showToast(
                                          msg: "Select at least one platform");
                                      return;
                                    }
                                    if (!widget.paid &&
                                        offeredBarterItemController
                                            .text.isEmpty) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Please fill offered barter item");
                                      return;
                                    }
                                  }
                                  if (businessCategory == "1") {
                                    if (offerFromMenu.isEmpty) {
                                      Fluttertoast.showToast(msg: "Please select offer from menu gender");
                                      return;
                                    }
                                    if (offerFromMenu.where((element) =>
                                    element['gender'].isEmpty || element['menu'].isEmpty).toList()
                                        .isNotEmpty) {
                                      Fluttertoast.showToast(
                                          msg: "Please select all menus");
                                      return;
                                    }
                                  }
                                  if (!widget.isEdit &&
                                      widget.paid &&
                                      ((uploadOffer.isEmpty &&
                                              selectedPromotionVideo.isEmpty) &&
                                          (uploadPosts.isEmpty &&
                                              selectedPostVideo.isEmpty) &&
                                          (uploadReels.isEmpty &&
                                              selectedReel.isEmpty))) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Please upload the promotion data");
                                    return;
                                  }
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
                                  );
                                  // widget.paid ?
                                  // DateTime(
                                  //     endSelectedDate.year,
                                  //     endSelectedDate.month,
                                  //     endSelectedDate.day,
                                  //   );
                                  // : DateTime(
                                  //   startSelectedDate.year,
                                  //   startSelectedDate.month,
                                  //   startSelectedDate.day,
                                  //   startTime.hour + durationInHours,
                                  //   startTime.minute,
                                  // );
                                  Map<String, dynamic> sendData = {
                                    'id': menuId,
                                    'clubUID': uid(),
                                    'eventId': widget.eventId,
                                    "invite": invite,
                                    "eventName": widget.eventName ??
                                        eventNameController.text,
                                    "noOfBarterCollab": int.parse(
                                        noOfBarterCollabController.text),
                                    'amountPaid': amountPaidController.text.isEmpty?1000:amountPaidController.text,
                                    'deliverables':
                                        deliverable.map((e) => e.text).toList(),
                                    'script': scriptController.text,
                                    'offerFromMenu': offerFromMenu,
                                    "offeredBarterItem":
                                        offeredBarterItemController.text,
                                    "startTime": startTimeApi,
                                    "endTime": endTimeApi,
                                    "isPaid": widget.paid,
                                    "acceptedBy": 0,
                                    "platforms": platformForPosting,
                                    "url": urlController.text,
                                    "type": widget.type,
                                    "collabType": "influencer",
                                    'planId':jsonConvert['planId']??'',
                                    // 'status': 'pending',
                                    "dateTime": FieldValue.serverTimestamp(),
                                  };
                                  FirebaseFirestore.instance
                                      .collection("EventPromotion")
                                      .doc(menuId)
                                      .set(sendData, SetOptions(merge: true))
                                      .whenComplete(() async {
                                    if (uploadOffer.isNotEmpty ||
                                        selectedPromotionVideo.isNotEmpty) {
                                      await PromotionUploadImage(
                                          uploadOffer,
                                          selectedPromotionVideo,
                                          menuId,
                                          homeController,
                                          coverImages: offerImage,
                                          // isOrganiser: widget.isOrganiser,
                                          isOffer: true);
                                    }
                                    if (uploadPosts.isNotEmpty ||
                                        selectedPostVideo.isNotEmpty) {
                                      await postsUploadImage(
                                          uploadPosts,
                                          selectedPostVideo,
                                          menuId,
                                          homeController,
                                          coverImages: offerImage,
                                          // isOrganiser: widget.isOrganiser,
                                          isOffer: true);
                                    }
                                    if (uploadReels.isNotEmpty ||
                                        selectedReel.isNotEmpty) {
                                      await reelsUploadImage(uploadReels,
                                          selectedReel, menuId, homeController,
                                          coverImages: offerImage,
                                          // isOrganiser: widget.isOrganiser,
                                          isOffer: true);
                                    }
                                  }).whenComplete(() {
                                    EasyLoading.dismiss();
                                    if (invite == 'inviteOnly') {
                                      Get.to(InfluencerList(collabId: menuId));
                                    } else {
                                      Get.back();
                                    }
                                    Fluttertoast.showToast(
                                        msg: "Upload Successfully");
                                  });
                                } catch (e) {
                                  print(e);
                                  Fluttertoast.showToast(
                                      msg: 'Something Went Wrong');
                                }
                              }
                            },
                            style: ButtonStyle(
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                            color: Colors.grey))),
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.black)),
                            child: Text(
                              invite == 'inviteOnly'
                                  ? "Send Invite"
                                  : "Save & Upload",
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
