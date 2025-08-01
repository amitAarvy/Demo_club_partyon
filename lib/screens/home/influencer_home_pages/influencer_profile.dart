import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/event_management/controller/menu_image_upload.dart';
import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:club/screens/sign_up/influencer_profile_text_widget.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/cities.dart';
import '../../home/home_utils.dart';
import '../../insta-analytics/presentation/views/instagram_data_screen_one/widgets/loader/phyllo_loader.dart';
import '../../profile/profile_utils.dart';
import '../../sign_up/influencer_profile_mobile_ui.dart';
import '../InfluencerHome.dart';
import 'influ_home_widgets/influencer_disqualification.dart';

class InfluencerProfile extends StatefulWidget {
  final bool isOrganiser;
  final bool isClub;
  final bool isEditEvent;
  final bool isPromoter;
  final String eventId;
  final String eventPromotionId;
  final bool isFromHome;
  final bool isLoading;
  final bool isWeb;

  const InfluencerProfile({
    Key? key,
    this.isOrganiser = false,
    this.isPromoter = false,
    this.isEditEvent = false,
    this.eventId = '',
    this.eventPromotionId = '',
    this.isClub = false,
    this.isFromHome = false,
    this.isLoading = false,
    required this.isWeb,
  }) : super(key: key);

  @override
  State<InfluencerProfile> createState() => _InfluencerProfileState();
}

class _InfluencerProfileState extends State<InfluencerProfile> {
  late Future<Map<String, dynamic>>? phylloData;
  final PhylloController phylloController = Get.put(PhylloController());
  bool isNineSixteen = false;
  final TextEditingController promoterName = TextEditingController();
  final TextEditingController agencyName = TextEditingController();
  final TextEditingController whatsappNumber = TextEditingController();
  final TextEditingController emailName = TextEditingController();

  @override
  void initState() {
    print("the uid is xx: ${uid()}");
    super.initState();
    if (!widget.isLoading) {
      phylloData = initLoadingData();
    }
  }

  Future<Map<String, dynamic>> initLoadingData() async {
    phylloController.isLoading = true;
    try {
      await PhylloController.retrieveAllProfileData();
      phylloController.profileData =
          await PhylloController.retrieveProfileData();
      if (widget.isFromHome) await loadFirebaseDetails();
      return {
        'profileData': phylloController.profileData,
        'contentData': phylloController.contentData,
      };
    } catch (e, stack) {
      Fluttertoast.showToast(msg: 'Error Is This: $e');
      print('Error=> $e | Stack => $stack');
    } finally {
      phylloController.isLoading = false;
    }
    return {};
  }

  Future<void> loadFirebaseDetails() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Influencer")
        .doc(uid())
        .get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    promoterName.text = data['promoterName'] ?? '';
    agencyName.text = data['companyMame'] ?? '';
    whatsappNumber.text = data['whatsappNumber'] ?? '';
    dropdownState = data['state'] ?? '';
    dropdownCity = data['city'] ?? '';
    emailName.text = data['emailPhone'] ?? '';
    phylloController.isReadOnly = true;
    if (!context.mounted) return;
    setState(() {});
  }

  int engagementRate() {
    final int followers = 200;
    final engagementRate = 30;
//  final likes = phylloController.profileData?.reputation?.likeCount;
//  final comments = phylloController.profileData.profileData.comments;
//  final shares = phylloController.profileData?.reputation?.shareCount;
//  final saves = phylloController.profileData?.reputation?.saveCount;
// final totalEngagement = likes! + comments! + shares! + saves!;
//  final followers = phylloController.profileData?.reputation?.followerCount;
//  final engagementRate = (totalEngagement! / followers!) * 100;
//  print("the engagement rate is : $engagementRate");
    return engagementRate;
  }

  String dropdownState = 'Andhra Pradesh',
      dropdownCity = 'Select City',
      dropdownCategory = '';

  final homeController = Get.put(HomeController());
  final eventController = Get.put(MenuEventController());

  final _formKey = GlobalKey<FormState>();
  bool dialogOther = false;
  final TextEditingController _otherCity = TextEditingController();

  void updateDialogState(String city) {
    if (city == "Other") {
      dialogOther = true;
    } else {
      _otherCity.text = "";
      dialogOther = false;
    }
    setState(() {}); // Trigger rebuild only once after all updates.
  }

  @override
  Widget build(BuildContext context) {
    // if (dropdownCity == "Other") {
    //   setState(() {
    //     dialogOther = true;
    //   });
    // } else {
    //   setState(() {
    //     _otherCity.text = "";
    //     dialogOther = false;
    //   });
    // }
    // if (widget.isLoading) {
    //   return SizedBox(
    //     height: Get.height / 1.7,
    //     child: const Center(
    //       child: CircularProgressIndicator(),
    //     ),
    //   );
    // }
    List stateCity = getStateCity(dropdownState);

    List<String> itemsCity = [
      "Select City",
      ...stateCity,
      stateCity.contains(dropdownCity) == true || dropdownCity == "Select City"
          ? ""
          : dropdownCity
    ];
    if (!widget.isWeb) {
      return Scaffold(
        backgroundColor: matte(),
        appBar: appBar(context, title: 'Profile Details', showBack: true, isHome: true),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: Get.width,
            child: Form(
              key: _formKey,
              child: Obx(() {
                if (phylloController.isLoading) {
                  return SizedBox(
                    height: Get.height / 1.7,
                    child: const Center(
                      child: PhylloLoader(),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      InfluencerProfileMobileUi(
                        phylloData: phylloController.profileData ?? null,
                        userName:
                            phylloController.profileData?.platformUsername ??
                                null,
                        imageURL:
                            phylloController.profileData?.imageUrl ?? null,
                        followerCount: phylloController
                                .profileData?.reputation?.followerCount ??
                            0,
                        followingCount: phylloController
                                .profileData?.reputation?.followingCount ??
                            0,
                        reels: 0,
                        post: 0,
                        story: 0,
                      ),
                      InfluencerProfileTextWidget(
                          text: 'Instagram User Name',
                          value: phylloController.profileData?.username),
                      InfluencerProfileTextWidget(
                          text: 'Full Name',
                          value: phylloController.profileData?.fullName),
                      textField("Promoter Name", promoterName,
                          isReadOnly: phylloController.isReadOnly),
                      textField("Promoter Agency / Company", agencyName,
                          isReadOnly: phylloController.isReadOnly),
                      textField("Whatsapp Number", whatsappNumber,
                          isNum: true, isReadOnly: phylloController.isReadOnly),
                      textField("Email Address", emailName,
                          isReadOnly: phylloController.isReadOnly),
                      Container(
                        height: 130.h,
                        width: 800.w,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: Center(
                          child: DropdownButton<String>(
                            alignment: Alignment.center,
                            items: states
                                .map<DropdownMenuItem<String>>((String value) {
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
                              Fluttertoast.showToast(
                                  msg: "Select city to continue");
                            },
                            value: dropdownState,
                            style: const TextStyle(color: Colors.white70),
                            dropdownColor: Colors.black,
                          ),
                        ),
                      ).marginOnly(
                          left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
                      SizedBox(
                        height: 50.h,
                      ),
                      Container(
                        height: 130.h,
                        width: 800.w,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
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
                              updateDialogState(val!); // CHANGE: Call updateDialogState here
    if (dropdownCity != "Other" && dropdownCity != "Select City") {
      // dropdownCity != "Other" &&
      // dropdownCity != "Select City"
      // ?
      Get.defaultDialog(
          title: "Change City",
          content: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  IconButton(
                      onPressed: () {
                        if (dropdownCity !=
                            "Select City" ||
                            dropdownCity !=
                                "Other") {
                          FirebaseFirestore.instance
                              .collection("Club")
                              .doc(uid())
                              .set(
                              {
                                "state":
                                dropdownState,
                                "city": dropdownCity
                              },
                              SetOptions(
                                  merge:
                                  true)).whenComplete(
                                  () {
                                getCurrentClub();
                                Get.back();
                                setState(() {});
                              });
                        } else {
                          Get.back();
                          Fluttertoast.showToast(
                              msg:
                              "Enter a valid city");
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
          ));
    }
                                  // : Container();
                            },
                            value: dropdownCity,
                            style: const TextStyle(color: Colors.white70),
                            dropdownColor: Colors.black,
                          ),
                        ),
                      ).marginOnly(
                          left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
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
                                    WidgetStateProperty.resolveWith(
                                        (states) => Colors.black)),
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
                                if (engagementRate() <= 20) {
                                  print('engagementRate ${engagementRate()}');
                                  InfluencerDisqualification.showAlertDialog(
                                      context);
                                } else {
                                  try {
                                    EasyLoading.show();
                                    Map<String, dynamic> sendData = {
                                      'emailPhone': emailName.text,
                                      // 'userId' : ,
                                      // 'accountId' : '',
                                      // 'profileId' : '',
                                      'imageURL': phylloController.profileData?.imageUrl,
                                      'instaUserName': phylloController
                                          .profileData?.username,
                                      'followerCount': phylloController
                                          .profileData
                                          ?.reputation
                                          ?.followerCount,
                                      'followingCount': phylloController
                                          .profileData
                                          ?.reputation
                                          ?.followingCount,
                                      'fullName': phylloController
                                          .profileData?.fullName,
                                      'promoterName': promoterName.text,
                                      'companyName': agencyName.text,
                                      'whatsappNumber': whatsappNumber.text,
                                      'state': dropdownState,
                                      'city': dropdownCity,
                                    };
                                    await FirebaseFirestore.instance
                                        .collection("Influencer")
                                        .doc(uid())
                                        .set(sendData, SetOptions(merge: true));
                                    phylloController.isReadOnly = true;
                                    Get.to(const InfluencerHome());
                                  } catch (e) {
                                    print(e);
                                    // Fluttertoast.showToast(
                                    //     msg: 'Something Went Wrong');
                                  }
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
                                    WidgetStateProperty.resolveWith(
                                        (states) => Colors.black)),
                            child: Text(
                              phylloController.isReadOnly ? "Edit" : "Save",
                              style: GoogleFonts.ubuntu(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ).marginAll(20.h),
                    ],
                  );
                }
              }),
            ),
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: Get.width,
          child: Form(
            key: _formKey,
            child: Obx(() {
              if (phylloController.isLoading) {
                return SizedBox(
                  height: Get.height / 1.7,
                  child: const Center(
                    child: PhylloLoader(),
                  ),
                );
              } else {
                return Column(
                  children: [
                    InfluencerProfileMobileUi(
                      phylloData: phylloController.profileData ?? null,
                      userName:
                          phylloController.profileData?.platformUsername ??
                              null,
                      imageURL: phylloController.profileData?.imageUrl ?? null,
                      followerCount: phylloController
                              .profileData?.reputation?.followerCount ??
                          0,
                      followingCount: phylloController
                              .profileData?.reputation?.followingCount ??
                          0,
                      reels: 0,
                      post: 0,
                      story: 0,
                    ),
                    InfluencerProfileTextWidget(
                        text: 'Instagram User Name',
                        value: phylloController.profileData?.username),
                    InfluencerProfileTextWidget(
                        text: 'Full Name',
                        value: phylloController.profileData?.fullName),
                    textField("Promoter Name", promoterName,
                        isReadOnly: phylloController.isReadOnly),
                    textField("Promoter Agency / Company", agencyName,
                        isReadOnly: phylloController.isReadOnly),
                    textField("Whatsapp Number", whatsappNumber,
                        isNum: true, isReadOnly: phylloController.isReadOnly),
                    textField("Email Address", emailName,
                        isReadOnly: phylloController.isReadOnly),
                    Container(
                      height: 130.h,
                      width: 800.w,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Center(
                        child: DropdownButton<String>(
                          alignment: Alignment.center,
                          items: states
                              .map<DropdownMenuItem<String>>((String value) {
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
                            Fluttertoast.showToast(
                                msg: "Select city to continue");
                          },
                          value: dropdownState,
                          style: const TextStyle(color: Colors.white70),
                          dropdownColor: Colors.black,
                        ),
                      ),
                    ).marginOnly(
                        left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
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
    updateDialogState(val!); // CHANGE: Call updateDialogState here
    if (dropdownCity != "Other" && dropdownCity != "Select City") {
      // dropdownCity != "Other" &&
      //         dropdownCity != "Select City"
      //     ?
      Get.defaultDialog(
          title: "Change City",
          content: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
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
                                "state":
                                dropdownState,
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
                              msg:
                              "Enter a valid city");
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
          ));
    }
                                // : Container();
                          },
                          value: dropdownCity,
                          style: const TextStyle(color: Colors.white70),
                          dropdownColor: Colors.black,
                        ),
                      ),
                    ).marginOnly(
                        left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
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
                                      side: const BorderSide(
                                          color: Colors.grey))),
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) => Colors.black)),
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
                            if (phylloController.isReadOnly &&
                                widget.isFromHome) {
                              phylloController.isReadOnly = false;
                            } else {
                              if (_formKey.currentState?.validate() == true) {
                                if (engagementRate() <= 20) {
                                  print('engagementRate ${engagementRate()}');
                                  InfluencerDisqualification.showAlertDialog(
                                      context);
                                } else {
                                  try {
                                    EasyLoading.show();
                                    Map<String, dynamic> sendData = {
                                      'instaUserName': phylloController
                                          .profileData?.username,
                                      'fullName': phylloController
                                          .profileData?.fullName,
                                      'followerCount': phylloController
                                          .profileData
                                          ?.reputation
                                          ?.followerCount,
                                      'followingCount': phylloController
                                          .profileData
                                          ?.reputation
                                          ?.followingCount,
                                      'emailPhone': emailName.text,
                                      'promoterName': promoterName.text,
                                      'companyMame': agencyName.text,
                                      'whatsappNumber': whatsappNumber.text,
                                      'state': dropdownState,
                                      'city': dropdownCity,
                                    };
                                    await FirebaseFirestore.instance
                                        .collection("Influencer")
                                        .doc(uid())
                                        .set(sendData, SetOptions(merge: true));
                                    phylloController.isReadOnly = true;
                                    if (!widget.isFromHome) {
                                      Get.to(const InfluencerHome());
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Updated Successfully");
                                    }
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg: 'Something Went Wrong');
                                  }
                                  EasyLoading.dismiss();
                                }
                              }
                            }
                          },
                          style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: const BorderSide(
                                          color: Colors.grey))),
                              backgroundColor: WidgetStateProperty.resolveWith(
                                  (states) => Colors.black)),
                          child: Text(
                            phylloController.isReadOnly ? "Edit" : "Save",
                            style: GoogleFonts.ubuntu(
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ).marginAll(20.h),
                  ],
                );
              }
            }),
          ),
        ),
      );
    }
  }
}
