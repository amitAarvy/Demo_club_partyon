import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudflare/cloudflare.dart';
import 'package:club/screens/home/home.dart';
import 'package:club/screens/home/privacy_policy.dart';
import 'package:club/screens/organiser/home/organiser_home.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/authentication/login_page.dart';
import 'package:club/screens/event_management/event_list.dart';
import 'package:club/screens/event_management/event_management.dart';
import 'package:club/screens/account_details.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/live/live_status.dart';
import 'package:club/screens/organiser/event_management/organiser_event_management.dart';
import 'package:club/screens/profile/edit_profile_view.dart';
import 'package:club/screens/sign_up/upload_docs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:phyllo_connect/phyllo_connect.dart';

import '../../utils/image_uplod.dart';
import '../organiser/home/organiser_profile_edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/deactive_account.dart';


const cloudFlareAccountID = "89174e54fcc5719f4bfecc8c3b8b216f";
const cloudFlareToken = "vb5cg5bPCA_ImMFvDV4SD1f_pHlvBkDdc06ra9SK";
final cloudflare = Cloudflare(
  accountId: cloudFlareAccountID,
  token: cloudFlareToken,
);

Future getCurrentClub() async {
  final homeController = Get.put(HomeController());
  EasyLoading.show();
  try {
    await FirebaseFirestore.instance
        .collection("Club")
        .doc(uid())
        .get()
        .then((value) {
      if (value.exists) {
        homeController.updateClubName((value.data()?["clubName"]).toString());
        homeController.updateProfile((value.data()?["logo"]).toString());
        homeController
            .updateCoveImage((value.data()?["coverImage"]).toString());
        homeController.updateCity((value.data()?["city"]).toString());
        homeController.updateState((value.data()?["state"]).toString());
        homeController.updateClubUid((value.data()?["clubID"]).toString());
        homeController.updateAddress((value.data()?["address"]).toString());
        homeController.updatePinCode((value.data()?["pinCode"]).toString());
        homeController.updateArea((value.data()?["area"]).toString());
        homeController.updateLocality((value.data()?["locality"]).toString());
        homeController.updateLandMark((value.data()?["landmark"]).toString());
        homeController
            .updateDescription((value.data()?["description"]).toString());
        homeController.updateCategory((value.data()?["category"]));
        homeController.updateOpenTime((value.data()?["openTime"]).toString());
        homeController.updateCloseTime((value.data()?["closeTime"]).toString());
        homeController.updateAvgCost((value.data()?["averageCost"]).toString());
        homeController.updateStatus(value.data()?["activeStatus"]);
      } else {
        Fluttertoast.showToast(msg: "This club does not exist");
      }
    }).whenComplete(() => EasyLoading.dismiss());
  } catch (e) {
    EasyLoading.dismiss();
    if (kDebugMode) {
      print(e);
    }
    Fluttertoast.showToast(msg: "Something went wrong");
  }
}

Widget tile(String title, Icon icon,
        {var page,
        bool isLive = false,
       bool notificationIcon = false,
          int eventNotificationCount = 0,
        bool isEVM = false,
        Function()? onTap,
        String? clubUid,
        bool isOrganiser = false}) =>
    GestureDetector(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: 350.h,
              width: 350.h,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(color: Colors.grey, offset: Offset(0, 2.h), blurRadius: 3)
              ], color: Colors.black, borderRadius: BorderRadius.circular(30)),
              margin:
                  const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  SizedBox(
                    height: 50.h,
                  ),
                  Text(
                    title,
                    style: GoogleFonts.ubuntu(color: Colors.white),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            if(notificationIcon)
              Positioned(
                right: 30,
                top: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green
                      ),
                      child: Center(child: Text(eventNotificationCount.toString(),style: TextStyle(color: Colors.white),),),
                    )
                  ],
                ),
              ),

          ],
        ),
        onTap: () async {
          if (onTap != null) {
            onTap();
          } else if (isOrganiser) {
            Get.bottomSheet(Container(
              height: 500.h,
              color: Colors.black,
              child: Column(
                children: [
                  Text(
                    "Choose",
                    style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold),
                  ).paddingAll(40.w),
                  ListTile(
                    onTap: () {
                      Get.back();
                      Get.to(const OrganiserEventManagement());
                    },
                    leading: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Add Event",
                      style: GoogleFonts.ubuntu(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.back();
                      Get.to(EventList(
                        isOrganiser: isOrganiser,
                      ));
                    },
                    leading: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Edit Event",
                      style: GoogleFonts.ubuntu(color: Colors.white),
                    ),
                  )
                ],
              ),
            ));
          } else {


            page != null
                ? Get.to(page)
                : isLive == true
                    ? Get.to(const LiveStatus())
                    : isEVM == true
                        ? Get.bottomSheet(Container(
                            height: 500.h,
                            color: Colors.black,
                            child: Column(
                              children: [
                                Text(
                                  "Choose",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize: 50.sp,
                                      fontWeight: FontWeight.bold),
                                ).paddingAll(40.w),
                                ListTile(
                                  onTap: () async {
                                    const FlutterSecureStorage secureStorage =
                                        FlutterSecureStorage();
                                    String? value = await secureStorage.read(
                                        key: 'clubUids');
                                    print('club id is ${value}');
                                    Get.back();
                                    Get.to(
                                        EventManagement(clubUID: value ?? ''));
                                  },
                                  leading: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    "Add Event",
                                    style:
                                        GoogleFonts.ubuntu(color: Colors.white),
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    Get.back();
                                    Get.to(const EventList());
                                  },
                                  leading: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    "Edit Event",
                                    style:
                                        GoogleFonts.ubuntu(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ))
                        : Fluttertoast.showToast(
                            msg:
                                "This feature will be available at launch of user's app.");
          }
        });



void showDeactivateDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: const DeactivateAccountScreen(),
        ),
      );
    },
  );
}

Widget drawer({bool isOrganiser = false,bool isInf = false,required BuildContext context}) {
  final homeController = Get.put(HomeController());
  return Drawer(
    child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [matte(), Colors.black])),
      child: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 50.h,
          ),
          Obx(
            () => Container(
              height: 300.h,
              width: 300.h,
              decoration: const BoxDecoration(
                  color: Colors.black, shape: BoxShape.circle),
              child: homeController.profileLogo.value != ""
                  ? CircleAvatar(
                      radius: 150.h,
                      backgroundColor: Colors.transparent,
                      backgroundImage: CachedNetworkImageProvider(
                          homeController.profileLogo.value),
                      onBackgroundImageError: (_, __) => [
                        Container(
                          height: 300.h,
                          width: 300.h,
                          color: Colors.white,
                          child: Image.asset(
                            "assets/profile.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    )
                  : CircleAvatar(
                      radius: 150.h,
                      backgroundColor: Colors.white,
                      backgroundImage: const AssetImage("assets/profile.png"),
                      onBackgroundImageError: (_, __) => [
                        Container(
                          height: 300.h,
                          width: 300.h,
                          color: Colors.white,
                          child: Image.asset(
                            "assets/profile.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
            ),
          ).marginAll(20.h),
          Obx(() => Text(
                isOrganiser
                    ? homeController.organiserName.value.capitalizeFirstOfEach
                    : isInf ?homeController.influencerName.value.capitalizeFirstOfEach:homeController.clubName.value.capitalizeFirst.toString(),
                style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20),
              )).marginAll(30.h),
          SizedBox(
            height: 30.h,
          ),
          const Divider(
            color: Colors.white,
            thickness: 1,
            // indent: 50.w,
            // endIndent: 50.w,
          ),
          SizedBox(
            // height: Get.width,
            width: Get.width,
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                        opacity: 0.2,
                        child: SizedBox(
                          height: 600.h,
                          width: 600.h,
                          child: Image.asset("assets/newLogo.png"),
                        ))),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                      title: Text(
                        "Home",
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => Get.back(),
                    ),
                    if (isOrganiser)
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Profile Details",
                          style: GoogleFonts.montserrat(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onTap: () => Get.to( OrganiserProfileEdit(isInf: isInf,)),
                      )
                    else
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Profile Details",
                          style: GoogleFonts.montserrat(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onTap: () => Get.to(EditProfile(
                          isOrganiser: isOrganiser,
                        )),
                      ),
                    if (!isOrganiser)
                      Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.upload_file,
                              color: Colors.white,
                            ),
                            title: Text(
                              "Upload Docs",
                              style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () => Get.to(const UploadDocs(
                              isHome: true,
                            )),
                          ),
                          // ListTile(
                          //   leading: const Icon(
                          //     Icons.account_balance,
                          //     color: Colors.white,
                          //   ),
                          //   title: Text(
                          //     "Account Details",
                          //     style: GoogleFonts.montserrat(
                          //         color: Colors.white,
                          //         fontWeight: FontWeight.bold),
                          //   ),
                          //   onTap: () => Get.to(const AccountDetails()),
                          // ),
                          // ListTile(
                          //   leading: const Icon(
                          //     Icons.help,
                          //     color: Colors.white,
                          //   ),
                          //   title: Text(
                          //     "Help",
                          //     style: GoogleFonts.montserrat(
                          //         color: Colors.white,
                          //         fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                        ],
                      ),

                    // ListTile(
                    //   leading: const Icon(
                    //     FontAwesomeIcons.images,
                    //     color: Colors.white,
                    //   ),
                    //   title: Text(
                    //     "Images Upload",
                    //     style: GoogleFonts.montserrat(
                    //         color: Colors.white, fontWeight: FontWeight.bold),
                    //   ),
                    //   onTap: () => Get.to(const ImageUpload()),
                    // ),

                    // ListTile(
                    //   leading:  const Icon(
                    //     FontAwesomeIcons.share,
                    //     color: Colors.white,
                    //   ),
                    //
                    //   title: Text(
                    //     "Referral",
                    //     style: GoogleFonts.montserrat(
                    //         color: Colors.white, fontWeight: FontWeight.bold),
                    //   ),
                    //   onTap: () {
                    //     // Get.to(const ReferView());
                    //   },
                    // ),

                    ListTile(
                      leading: const Icon(
                        Icons.policy_sharp,
                        color: Colors.white,
                      ),
                      title: Text(
                        "Privacy Policy",
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => Get.to(const PrivacyPolicy()),
                    ),
                    if(Platform.isIOS)
                    ListTile(
                      leading: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      title: Text(
                        "Delete Account",
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onTap: () =>showDeactivateDialog(context),
                    ),
                    ListTile(
                      onTap: () async {
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        pref.clear();
                        await FirebaseAuth.instance.signOut();
                        await const FlutterSecureStorage().deleteAll();
                        await FacebookAuth.instance.logOut();
                        await FirebaseAuth.instance.signOut();
                        await GoogleSignIn().signOut();
                        await Hive.deleteFromDisk();
                        Get.off(const LoginPage());
                      },
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      title: Text(
                        "Log Out",
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
//         title: Text(
//           "Account Details",
//           style: GoogleFonts.montserrat(
//               color: Colors.white,
//               fontWeight: FontWeight.bold),
//         ),
//         onTap: () => Get.to(const AccountDetails()),
//       ),
//       ListTile(
//         leading: const Icon(
//           Icons.help,
//           color: Colors.white,
//         ),
//         title: Text(
//           "Help",
//           style: GoogleFonts.montserrat(
//               color: Colors.white,
//               fontWeight: FontWeight.bold),
//         ),
//       ),
//     ],
//   ),
// ListTile(
//   leading: const Icon(
//     Icons.policy_sharp,
//     color: Colors.white,
//   ),
//   title: Text(
//     "Privacy Policy",
//     style: GoogleFonts.montserrat(
//         color: Colors.white, fontWeight: FontWeight.bold),
//   ),
//   onTap: () => Get.to(const PrivacyPolicy()),
// ),
// ListTile(
//   onTap: () async {
//     await Hive.deleteFromDisk();
//     await FacebookAuth.instance.logOut();
//     FirebaseAuth.instance
//         .signOut()
//         .whenComplete(() => Get.off(const LoginPage()));
//   },
//   leading: const Icon(
//     Icons.logout,
//     color: Colors.white,
//   ),
//   title: Text(
//     "Log Out",
//     style: GoogleFonts.montserrat(
//         color: Colors.white, fontWeight: FontWeight.bold),
//   ),
// ),
            ),
          )
        ]),
      ),
    ),
  );
}
