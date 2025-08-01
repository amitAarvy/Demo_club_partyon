import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart' as otpController;
import 'package:club/screens/refer/presentation/controller/refer_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/organiser/home/profile_image_upload.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/utils/provider_utils.dart';
import 'package:club/authentication/login_page.dart';
import 'package:club/local_db/hive_db.dart';
import 'package:club/screens/organiser/home/organiser_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:msg91/msg91.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:random_string/random_string.dart';
import 'organiser_image_upload.dart';
import 'package:http/http.dart' as http;


class SignUpOrganiser extends StatefulWidget {
  final String email, phone;
  final bool isPhone;

  const SignUpOrganiser(
      {this.phone = "", this.isPhone = false, required this.email, Key? key})
      : super(key: key);

  @override
  State<SignUpOrganiser> createState() => _SignUpOrganiserState();
}

class _SignUpOrganiserState extends State<SignUpOrganiser> {

  //msg 91

  late Msg91 msg91;
  late dynamic msgOtp;
  // final OtpController otpController = Get.put(OtpController());

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
    msg91 = Msg91().initialize(authKey: "456047A13TTYLdn684c3039P1");
    msgOtp = msg91.getOtp();
    fetchPrList();

  }

  String generateOtp() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // Ensures 4-digit OTP
  }

  // Future<void> startTimer() async {
  //   otpController.updateCount();
  //   Timer.periodic(const Duration(seconds: 1), (Timer timer) {
  //     if (otpController.count > 0) {
  //       otpController.decCount();
  //     } else {
  //       timer.cancel();
  //     }
  //   });
  // }
  String? generatedOtp;
  bool sendOtp = false;
  List prUserList = [];
  final templateId = "685cec7ad6fc05713b4079e2";



  Future<void> _phoneSignIn(var phone,String userId) async {
    TextEditingController otpTextController = TextEditingController();

    try {
      EasyLoading.dismiss();
      await EasyLoading.show();

      // Error handling.
      try {
        generatedOtp = generateOtp();
        Map<String, String> variables = {"OTP": generatedOtp!};
        final response = await msg91.getSMS().send(flowId: templateId, recipient: SmsRecipient(mobile: "+91$phone", key: variables));

        final message = response["message"];
        if (message != null && message.toString().trim().isNotEmpty) {
          print('OTP sent successfully!');
          await EasyLoading.dismiss();
          // startTimer();

          await Get.defaultDialog(
            title: 'Enter OTP',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PinCodeTextField(
                  length: 4,
                  appContext: context,
                  autoFocus: true,
                  controller: otpTextController,
                  onChanged: (String val) {},
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> states) => Colors.black,
                  ),
                ),
                child: const Text('Confirm'),
                onPressed: () async {
                  final String code = otpTextController.text.trim();
                  try {
                    print(generatedOtp);
                    print(code);
                    if (generatedOtp == code) {
                      if(selectBusinessCategory.value.toString() == '2'){
                        print('yes check it s');
                        List promotionExist = prUserList
                            .where((e) => e['companyMame'].toString().capitalizeFirstOfEach.trim() == companyName.text.toString().capitalizeFirstOfEach.trim()).toList();
                        print('check it is ${promotionExist}');

                        if(promotionExist.isNotEmpty){
                          Fluttertoast.showToast(msg: "This user already exists.");
                          return;
                        }
                      }

                      String promoterID = randomAlphaNumeric(8);
                      Map<String, dynamic> data ={
                        'businessCategory':selectBusinessCategory.value,
                        'isNew':true,
                        "whatsaapNo":whatsaapNo.text,
                        'name':name.text,
                        'companyMame': companyName.text,
                        'emailPhone': emailPhone.text,
                        'gstNumber': gstNumber.text,
                        'organiserID': uid(),
                        'uid': uid(),
                        'promoterID': promoterID,
                        'isOrganiser': true,
                        "businessType": "organiser",
                        "referralId": randomAlphaNumeric(8),
                        // "referredBy": referredById
                      };
                      Get.to(AddOrganiserImage(id:userId.toString(), data: data,));

                    } else {
                      print('OTP verification failed: $response');
                      await Fluttertoast.showToast(msg: 'OTP verification failed');
                    }
                  } catch (e) {
                    print('check error is ${e.toString()}');
                    otpTextController.clear();
                    await Fluttertoast.showToast(msg: e.toString());
                  }
                },
              ),
              // ElevatedButton(
              //   onPressed: () async {
              //     if (otpController.count.value != 0) {
              //       await Fluttertoast.showToast(msg: 'Please wait for few seconds before resending.');
              //     } else {
              //       try {
              //         startTimer();
              //         generatedOtp = generateOtp();
              //         print("reseent otp");
              //         print(generatedOtp);
              //         Map<String, String> variables = {"OTP": generatedOtp!};
              //         final response = await msg91.getSMS().send(flowId: templateId, recipient: SmsRecipient(mobile: "+91$phone", key: variables));
              //
              //         final message = response["message"];
              //         if (message != null && message.toString().trim().isNotEmpty) {
              //           await Fluttertoast.showToast(msg: 'OTP resent successfully');
              //         } else {
              //           await Fluttertoast.showToast(msg: 'Failed to resend OTP');
              //         }
              //       } catch (e) {
              //         await Fluttertoast.showToast(msg: e.toString());
              //       }
              //     }
              //   },
              //   style: ButtonStyle(
              //     backgroundColor: MaterialStateProperty.resolveWith(
              //           (Set<MaterialState> states) => Colors.green,
              //     ),
              //   ),
              //   child: Obx(
              //         () => Text(
              //       otpController.count.value == 0 ? 'Resend' : 'Resend in ${otpController.count.value}',
              //       style: GoogleFonts.ubuntu(color: Colors.white),
              //     ),
              //   ),
              // )
            ],
          );
        } else {
          print('Failed to send OTP: $response');
        }
      } on TimeoutException {
        // Style guide.
        Fluttertoast.showToast(msg: 'Otp verification timeout. Please try again.');

        // Dismiss the loading indicator.
        await EasyLoading.dismiss();

        // Report failure.
        return;
      } catch (e) {
        // Style guide.
        print('Error while waiting for otp verification: $e');
        Fluttertoast.showToast(msg: 'Something went wrong. Please try again.');

        // Dismiss the loading indicator.
        await EasyLoading.dismiss();

        // Report failure.
        return;
      }
    } catch (e) {
      EasyLoading.dismiss();
      await Fluttertoast.showToast(msg: 'Something went wrong');
    }
  }

  void fetchPrList() async {
    try {
      QuerySnapshot prList = await FirebaseFirestore.instance
          .collection("Organiser")
          .where('businessCategory', isEqualTo: '2')
          .get();
      prUserList = prList.docs;
      setState(() {

      });

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

  ValueNotifier<String?> selectBusinessCategory = ValueNotifier('2');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Promoter Details"),
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
                  "${selectedCategory=='1'?'Organiser':'PR'} Details",
                  style: GoogleFonts.ubuntu(
                      color: Colors.orange,
                      fontSize: 60.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ).marginOnly(left: 40.w, bottom: 40.w),
          ),
          ValueListenableBuilder(
            valueListenable:selectBusinessCategory ,
            builder:  (context,String? selectedCategory, child) =>
             Row(
              children: [
                // Radio<String>(
                //   fillColor: WidgetStateProperty.resolveWith(
                //           (states) => Colors.grey),
                //     value: selectedCategory.toString(),
                //   groupValue: '1',
                //   onChanged: (value) {
                //        selectBusinessCategory.value ='1';
                //     },
                // ) ,
                // Text('Organiser',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,color: Colors.white),),
                Radio<String>(
                  fillColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.grey),
                    value: selectedCategory.toString(),
                  groupValue: '2', onChanged: (value) {
                       selectBusinessCategory.value ='2';
                    },
                ),
                Text('PR',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,color: Colors.white),),

              ],
            ),
          ),

          ValueListenableBuilder(
            valueListenable: selectBusinessCategory,
            builder: (context, selectedCategory, child) =>
              textField("${selectedCategory =='1'?'Company/Organiser':'PR'} Name", companyName, isMandatory: true)),
          textField("Name", name, isMandatory: true),
          textField("Contact number", whatsaapNo, isMandatory: true),
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
              for(var d in prUserList){
                print('chekc it is list ${d['companyMame'].toString()}');
                print('chekc it is list ${d.id.toString()}');
              }




              if (emailPhone.text.isNotEmpty && name.text.isNotEmpty && whatsaapNo.text.isNotEmpty) {


                _phoneSignIn(whatsaapNo.text,userId.toString());
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
