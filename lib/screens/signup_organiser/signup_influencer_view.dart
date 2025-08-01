import 'dart:io';
import 'dart:typed_data';
import 'package:club/local_db/hive_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/organiser/home/profile_image_upload.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/utils/provider_utils.dart';
import 'package:club/authentication/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:random_string/random_string.dart';
import 'package:club/screens/refer/presentation/controller/refer_controller.dart';

import '../home/InfluencerHome.dart';

class SingUpInfluencer extends StatefulWidget {
  final String email, phone;
  final bool isPhone;

  const SingUpInfluencer(
      {this.phone = "", this.isPhone = false, required this.email, Key? key})
      : super(key: key);

  @override
  State<SingUpInfluencer> createState() => _SingUpInfluencerState();
}

class _SingUpInfluencerState extends State<SingUpInfluencer> {
  final HomeController homeController = Get.put(HomeController());
  final TextEditingController companyName = TextEditingController();
  final TextEditingController emailPhone = TextEditingController();
  final TextEditingController whatsappNumber = TextEditingController();
  String gender = '';
  final TextEditingController reelCost = TextEditingController();
  final TextEditingController storyCost = TextEditingController();
  final TextEditingController postCost = TextEditingController();
  final TextEditingController gstNumber = TextEditingController();
  final loginProvider = Get.put(LoginProvider());

  List<File> uploadCover = [];
  List<File> uploadOffer = [];
  List<Uint8List> webImages = [];

  List coverImage = [];
  List offerImage = [];

  @override
  void initState() {
    emailPhone.text = widget.isPhone == true ? widget.phone : widget.email;
    super.initState();
  }

  _getFromGallery({bool isOffer = false}) async {
    await cropImageMultiple(false, context: context).then((value) async {
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

  Widget imageCoverWidget(List coverImages, List uploadImages,
      {bool isOffer = false, bool isNineSixteenValue = false}) {
    double carouselHeight = 300.w;
    return Column(
      children: [
        Stack(
          children: [
            Container(
                    height: 200,
                    width: 200,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.white)),
                    child: coverImages.isNotEmpty && uploadImages.isEmpty
                        ? eventCarousel(coverImages,
                            isEdit: true, height: carouselHeight)
                        : uploadImages.isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.white,
                                  size: 100,
                                ),
                              )
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
    return Scaffold(
        appBar: appBar(context, title: " Influencer Profile"),
        backgroundColor: matte(),
        body: SingleChildScrollView(
          child: Column(children: [
            // SizedBox(
            //   height: 250.h,
            // ),
            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: Text(
            //     "Influencer Details",
            //     style: GoogleFonts.ubuntu(
            //         color: Colors.orange,
            //         fontSize: 24,
            //         fontWeight: FontWeight.bold),
            //   ).marginSymmetric(horizontal: 20, vertical: 8),
            // ),
            GestureDetector(
              onTap: () => _getFromGallery(isOffer: true),
              child: imageCoverWidget(offerImage, uploadOffer, isOffer: true),
            ),
            textField("Name", companyName, isMandatory: true),
            textField("Email / Phone", emailPhone,
                isMandatory: true, isEmail: true, isPhone: widget.isPhone),
            textField("Whatsapp Number", whatsappNumber, isNum: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Row(
                    children: [
                      Radio(
                        value: gender,
                        groupValue: 'male',
                        onChanged: (value) {
                          gender = 'male';
                          setState(() {});
                        },
                      ),
                      const Text("Male", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: gender,
                        groupValue: 'female',
                        onChanged: (value) {
                          gender = 'female';
                          setState(() {});
                        },
                      ),
                      const Text("Female",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: gender,
                        groupValue: 'others',
                        onChanged: (value) {
                          gender = 'others';
                          setState(() {});
                        },
                      ),
                      const Text("Others",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text("Input Your Cost for Promotional Data",
                          style: TextStyle(color: Colors.white)),
                      SizedBox(width: 5),
                      Text("*", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 0.5)),
                  child: Column(
                    children: [
                      textField("Reel Cost", reelCost,
                          isMandatory: true, isNum: true),
                      textField("Story Cost", storyCost,
                          isMandatory: true, isNum: true),
                      textField("Post Cost", postCost,
                          isMandatory: true, isNum: true),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                if (emailPhone.text.isNotEmpty &&
                    companyName.text.isNotEmpty &&
                    reelCost.text.isNotEmpty &&
                    storyCost.text.isNotEmpty &&
                    postCost.text.isNotEmpty &&
                    gender.isNotEmpty &&
                    uploadOffer.isNotEmpty) {
                  String promoterID = randomAlphaNumeric(8);
                  try {
                    EasyLoading.show();
                    await FirebaseFirestore.instance
                        .collection('Influencer')
                        .doc(uid())
                        .set({
                      'companyMame': companyName.text,
                      'emailPhone': emailPhone.text,
                      'gender': gender,
                      'gstNumber': gstNumber.text,
                      'InfluencerID': uid(),
                      'promoterID': promoterID,
                      'isInfluencer': true,
                      "follower": 0,
                      "reel": 0,
                      "reelCost": reelCost.text,
                      "story": 0,
                      "storyCost": storyCost.text,
                      "post": 0,
                      "postCost": postCost.text,
                    }).onError((error, stackTrace) {
                      Fluttertoast.showToast(msg: 'Something went wrong');
                      Get.offAll(const LoginPage());
                    }).whenComplete(() async {
                      String menuID = randomAlphaNumeric(10);
                      await FirebaseFirestore.instance
                          .collection("Organiser")
                          .doc(uid())
                          .set({
                        'promoterName': companyName.text,
                        'whatsappNumber': whatsappNumber.text,
                      }, SetOptions(merge: true));
                      await ProfileUploadImage(uploadOffer, menuID, homeController,webImages: webImages,
                          coverImages: uploadOffer,
                          isOrganiser: false, isOffer: true);
                      Fluttertoast.showToast(
                          msg: 'Influencer registered successfully');
                      Box box = await HiveDB.openBox();
                      HiveDB.putKey(box, 'isInfluencer', true);
                      Get.off(const InfluencerHome());
                    });
                  } catch (e, s) {
                    debugPrint("object : $e");
                    debugPrintStack(stackTrace: s);
                    Fluttertoast.showToast(msg: "something went wrong");
                  } finally {
                    EasyLoading.dismiss();
                  }
                  // String referredById = await ReferController.getReferredById();
                  await FirebaseFirestore.instance
                      .collection('Influencer')
                      .doc(uid())
                      .set({
                    'companyMame': companyName.text,
                    'emailPhone': emailPhone.text,
                    'gstNumber': gstNumber.text,
                    'influencerID': uid(),
                    'uid': uid(),
                    'promoterID': promoterID,
                    'isInfluencer': true,
                    "businessType": "influencer",
                    "referralId": randomAlphaNumeric(8),
                    // "referredBy": referredById
                  }).onError((error, stackTrace) {
                    Fluttertoast.showToast(msg: 'Something went wrong');
                    Get.offAll(const LoginPage());
                  }).whenComplete(() async {
                    await ReferController.updateReferral(
                        "influencer", companyName.text);
                    // await ReferController.updateReferral(
                    //     "influencer", companyName.text);
                    saveBusinessType("influencer");
                    Fluttertoast.showToast(
                        msg: 'Influencer registered successfully');
                    Get.off(const InfluencerHome());
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: "Kindly fill all required fields");
                }
              },
              child: Container(
                // height: 100.h,
                width: 200,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.orange,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: Text(
                    "Save Details",
                    style:
                        GoogleFonts.ubuntu(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ).marginAll(20.h),
            ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Get.off(const LoginPage());
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.black)),
                child: const Text("Back to Login"))
          ]),
        ));
  }
}
