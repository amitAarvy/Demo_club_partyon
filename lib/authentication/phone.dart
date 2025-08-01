import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/authentication/login_page.dart';
import 'package:club/screens/home/home.dart';
import 'package:club/screens/organiser/home/organiser_home.dart';
import 'package:club/screens/sign_up/init_signup_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../screens/home/InfluencerHome.dart';
import '../screens/home/homeBar.dart';
import '../screens/organiser/home/organiser_homeBar.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({Key? key}) : super(key: key);

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  String theme = '';
  final c = Get.put(OtpController());

  @override
  void initState() {
    super.initState();
  }

  void startTimer() async {
    c.updateCount();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (c.count > 0) {
        c.decCount();
      } else {
        timer.cancel();
      }
    });
  }

  var sendOtp = false;
  final TextEditingController _phoneController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void phoneSignIn(var phone) async {
    TextEditingController otpController = TextEditingController();
    int? resendToken;
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: ('+91$phone').toString(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // ANDROID ONLY!

          // Sign the user in (or link) with the auto-generated credential
          await auth
              .signInWithCredential(credential)
              .then((UserCredential result) {
            if (result.user != null) {
              FirebaseFirestore.instance
                  .collection("Club")
                  .doc(result.user?.uid)
                  .get()
                  .then((value) {
                if (value.exists) {
                  Get.off(() => const HomeBar());
                } else {
                  print('InitSignupDetails called on phone 2');
                  Get.off(const InitSignupDetails());
                }
              });
            } else {
              Fluttertoast.showToast(msg: "User does not exist");
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            if (kDebugMode) {
              print('The provided phone number is not valid.');
            }
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          startTimer();
          resendToken = resendToken;
          EasyLoading.dismiss();
          Get.defaultDialog(
            title: "Enter OTP",
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PinCodeTextField(
                  length: 6,
                  appContext: context,
                  autoFocus: true,
                  controller: otpController,
                  onChanged: (String val) {},
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.black)),
                child: const Text("Confirm"),
                onPressed: () async {
                  final code = otpController.text.trim();

                  try {
                    AuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: verificationId, smsCode: code);

                    UserCredential result =
                        await auth.signInWithCredential(credential);
                    if (result.user != null) {
                      FirebaseFirestore.instance
                          .collection("Club")
                          .doc(result.user?.uid)
                          .get()
                          .then((value) {
                        if (value.exists) {
                          Get.off(() => const HomeBar());
                        } else {
                          FirebaseFirestore.instance
                              .collection("Organiser")
                              .doc(result.user?.uid)
                              .get()
                              .then((value) {
                            if (value.exists) {
                              Get.off(() => const OrganiserHomeBar());
                            } else {
                              FirebaseFirestore.instance
                                  .collection("Influencer")
                                  .doc(result.user?.uid)
                                  .get()
                                  .then((value) {
                                if (value.exists) {
                                  Get.off(() => const InfluencerHome());
                                } else {
                                  print('InitSignupDetails called on phone 1');
                                  Get.off(const InitSignupDetails());
                                }
                              });
                            }
                          });
                        }
                      });
                    } else {
                      Fluttertoast.showToast(msg: "User does not exist");
                    }
                  } catch (e) {
                    otpController.clear();
                    Fluttertoast.showToast(msg: e.toString());
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    if (c.count.value == 0) {
                      Get.back();
                      phoneSignIn(phone);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.white),
                  ),
                  child: Obx(() => Text(
                        c.count.value == 0
                            ? 'Resend'
                            : 'Resend in ${c.count.value}',
                        style: GoogleFonts.ubuntu(color: Colors.white),
                      )))
            ],
          );
        },
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 30),
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      EasyLoading.dismiss();
      Fluttertoast.showToast(msg: "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          colorBack(),
          SingleChildScrollView(
            child: Center(
              child: Container(
                width: kIsWeb ? 600 : null,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      theme == "light" ? Container() : logoHead(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Login through Mobile",
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                      SizedBox(
                        height: 100.h,
                      ),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            color:
                                theme == "light" ? Colors.black26 : Colors.white,
                          ),
                          child: TextField(
                              autofocus: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10)
                              ],
                              keyboardType: TextInputType.number,
                              controller: _phoneController,
                              decoration: InputDecoration(
                                  prefixText: '+91',
                                  border: InputBorder.none,
                                  hintStyle: GoogleFonts.ubuntu(
                                      color: theme == "light"
                                          ? Colors.white
                                          : Colors.black),
                                  icon: Icon(
                                    Icons.call,
                                    color: theme == "light"
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  hintText: "Enter mobile number"))),
                      SizedBox(
                        height: 30.h,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          return theme == "light"
                              ? Colors.black45
                              : Colors.white38;
                        })),
                        onPressed: () {
                          _phoneController.value.text.length < 10
                              ? Fluttertoast.showToast(
                                  msg: "Enter a valid number",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 45.sp)
                              : phoneSignIn(_phoneController.text);
                        },
                        child: const Text("Send OTP"),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          return theme == "light"
                              ? Colors.black45
                              : Colors.white38;
                        })),
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("Back to Login"),
                      ),
                      SizedBox(
                        height: 50.h,
                      ),
                    ]),
              ),
    )
    )
]
    ));
  }
}

class OtpController extends GetxController {
  var count = 30.obs;

  updateCount() => count.value = 30;

  decCount() => --count.value;
}
