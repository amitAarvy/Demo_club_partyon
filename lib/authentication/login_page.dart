import 'package:club/authentication/google.dart';
import 'package:club/authentication/phone.dart';
import 'package:club/utils/app_utils.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var obsText = true;
  String theme = '';
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            colorBack(),
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    theme == "light"
                        ? Container()
                        : logoHead(isWeb: kIsWeb == true ? true : false),
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 180.h,
                      width: kIsWeb ? 400 : 900.w,
                      child: Center(
                        child: Image.asset("assets/gold_heading.png"),
                      ),
                    ).paddingOnly(bottom: 100.h),
                    Container(
                      width: kIsWeb ? 600 : null,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(children: [
                        textField('Enter Email', emailTextController),
                        textField('Enter Password', passTextController,
                            obscureText: true),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (emailTextController.text.isNotEmpty &&
                                passTextController.text.isNotEmpty &&
                                EmailValidator.validate(
                                    emailTextController.text)) {
                              try {
                                EasyLoading.show();
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: emailTextController.text,
                                        password: passTextController.text)
                                    .then((userCredential) =>
                                        onSingInSuccess(userCredential));
                                print('user loggeded in going to onSingInSuccess');
                              } on FirebaseAuthException catch (e, s) {
                                if (kDebugMode) {
                                  print(e);
                                }
                                Fluttertoast.showToast(msg: "Login Failed");
                              } finally {
                                EasyLoading.dismiss();
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Enter valid email or password');
                            }
                          },
                          style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.orange)),
                          child: const Text('Login'),
                        ),
                        const Text('OR',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20))
                            .paddingSymmetric(vertical: 50.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Get.to(const PhoneLogin());
                                },
                                icon: Icon(
                                  Icons.call,
                                  size: 75.h,
                                  color: theme == "light"
                                      ? Colors.black87
                                      : Colors.white,
                                )),
                            SizedBox(
                              width: 20.w,
                            ),
                            IconButton(
                                onPressed: () {
                                  signInWithGoogle();
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.google,
                                  color: Colors.redAccent,
                                )
                            ),
                          ],
                        )
                      ]),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

Widget colorBack() => Container(
    height: Get.height,
    width: Get.width,
    color: const Color(0XFF0F0F0F),
    child: ClipPath(
      clipper: ProsteBezierCurve(
        position: ClipPosition.bottom,
        list: [
          BezierCurveSection(
            start: const Offset(0, 150),
            top: Offset(Get.width / 2, 200),
            end: Offset(Get.width, 150),
          ),
        ],
      ),
      child: Container(height: 200.h, color: const Color(0XFF0F0F0F)
          //Color.fromRGBO(247, 0, 67, 1),
          ),
    ));

Widget logoHead({bool isWeb = false}) => Image.asset(
      height: 200,
      "assets/newLogo.png",
    );
