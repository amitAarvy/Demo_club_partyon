import 'dart:io';
import 'package:club/screens/refer/presentation/controller/refer_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/organiser/home/profile_image_upload.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/utils/provider_utils.dart';
import 'package:club/authentication/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:random_string/random_string.dart';

import '../signup_organiser/organiser_image_upload.dart';
import 'influencer_addImage.dart';

class SignUpInfluencer extends StatefulWidget {
  final String email, phone;
  final bool isPhone;

  const SignUpInfluencer(
      {this.phone = "", this.isPhone = false, required this.email, Key? key})
      : super(key: key);

  @override
  State<SignUpInfluencer> createState() => _SignUpInfluencerState();
}

class _SignUpInfluencerState extends State<SignUpInfluencer> {
  final homeController = Get.put(HomeController());
  final TextEditingController companyName = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController whatsaapNo = TextEditingController();
  final TextEditingController emailPhone = TextEditingController();
  final TextEditingController gstNumber = TextEditingController();
  final TextEditingController whatsappNumber = TextEditingController();
  String gender = '';
  final loginProvider = Get.put(LoginProvider());

  List<File> uploadCover = [];
  List<File> uploadOffer = [];

  List coverImage = [];
  List offerImage = [];

  @override
  void initState() {
    emailPhone.text = widget.isPhone == true ? widget.phone : widget.email;
    super.initState();
    fetchPrList();

  }

  List prUserList = [];

  void fetchPrList() async {


    try {
      QuerySnapshot prList = await FirebaseFirestore.instance
          .collection("Organiser")
          .where('businessCategory', isEqualTo: '2')
          .get();
      prUserList = prList.docs;
    } catch (e) {
      print("Error fetching pending requests: $e");
    }
    setState(() {});
  }


  _getFromGallery({bool isOffer = false}) async {
    await cropImageMultiple(false).then((value) {
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

  ValueNotifier<String?> selectBusinessCategory = ValueNotifier('1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Club Details"),
      backgroundColor: matte(),
      body: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            height: 250.h,
          ),
          ValueListenableBuilder(
            valueListenable: selectBusinessCategory,
            builder: (context, selectedCategory, child) =>
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Influencer Details",
                      style: GoogleFonts.ubuntu(
                          color: Colors.orange,
                          fontSize: 60.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ).marginOnly(left: 40.w, bottom: 40.w),
          ),


          ValueListenableBuilder(
              valueListenable: selectBusinessCategory,
              builder: (context, selectedCategory, child) =>
                  textField("${'Influencer'} Name", companyName, isMandatory: true)),
          textField("Name", name, isMandatory: true),
          textField("Whatsapp number", whatsaapNo, isMandatory: true,isNum: true),
          textField("Email / Phone", emailPhone,
              isMandatory: true, isEmail: true, isPhone: widget.isPhone),
          textField("GST No.", gstNumber),
          SizedBox(
            height: 40.h,
          ),
          SizedBox(height: 30.h),
          GestureDetector(
            onTap: () async {
              String? userId = await uid();
              print(companyName.text.toString());
              List promotionExist = prUserList
                  .where((e) => e['companyMame'].toString().capitalizeFirstOfEach.trim() == companyName.text.toString().capitalizeFirstOfEach.trim()).toList();
              print('check it is ${promotionExist}');

              if (emailPhone.text.isNotEmpty && name.text.isNotEmpty ) {
                  print('yes check it s');
                  if(promotionExist.isNotEmpty){
                    Fluttertoast.showToast(msg: "This user already exists.");
                    return;
                  }
                String promoterID = randomAlphaNumeric(8);
                Map<String, dynamic> data ={
                  'isNew':true,
                  "whatsaapNo":whatsaapNo.text,
                  'name':name.text,
                  'companyMame': companyName.text,
                  'emailPhone': emailPhone.text,
                  'gstNumber': gstNumber.text,
                  'influencer': uid(),
                  'uid': uid(),
                  'promoterID': promoterID,
                  'isOrganiser': true,
                  "businessType": "organiser",
                  "referralId": randomAlphaNumeric(8),
                  // "referredBy": referredById
                };
                Get.to(AddInfluencerImage(id:userId.toString(), data: data,));
                // String referredById = await ReferController.getReferredById();
                // await FirebaseFirestore.instance
                //     .collection('Organiser')
                //     .doc(uid())
                //     .set({
                //   'isNew':true,
                //   'companyMame': companyName.text,
                //   'emailPhone': emailPhone.text,
                //   'gstNumber': gstNumber.text,
                //   'organiserID': uid(),
                //   'uid': uid(),
                //   'promoterID': promoterID,
                //   'isOrganiser': true,
                //   "businessType": "organiser",
                //   "referralId": randomAlphaNumeric(8),
                //   // "referredBy": referredById
                // }).onError((error, stackTrace) {
                //   Fluttertoast.showToast(msg: 'Something went wrong');
                //   Get.offAll(const LoginPage());
                // }).whenComplete(() async {
                //   // await ReferController.updateReferral(
                //   //     "organiser", companyName.text);
                //   // saveBusinessType("organiser");
                //   // Fluttertoast.showToast(
                //   //     msg: 'Organiser registered successfully');
                //   Get.to(AddOrganiserImage(id:userId.toString()));
                //   // Get.off(const OrganiserHome());
                // });
              } else {
                Fluttertoast.showToast(msg: "Kindly fill all required fields");
              }
            },
            child: Container(
              height: 100.h,
              width: 300.w,
              decoration: BoxDecoration(
                  color: Colors.orange,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Text(
                  "Continue",
                  style:
                  GoogleFonts.ubuntu(color: Colors.white, fontSize: 35.sp),
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
      ),
    );
  }
}
