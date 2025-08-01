import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/home.dart';
import 'package:club/screens/organiser/home/organiser_home.dart';
import 'package:club/screens/sign_up/init_signup_details.dart';
import 'package:club/utils/app_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../screens/home/homeBar.dart';

Future loginPin(String pin, BuildContext context) {
  TextEditingController controller = TextEditingController();
  return Get.defaultDialog(
      title: "Enter Login Pin",
      content: Column(
        children: [
          Center(
            child: PinCodeTextField(
              controller: controller,
              appContext: context,
              autoFocus: true,
              keyboardType: TextInputType.number,
              length: 4,
              onChanged: (String val) {},
              pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  selectedColor: Colors.black,
                  inactiveColor: Colors.grey),
            ),
          ),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.black)),
              onPressed: () {
                if (controller.text.isNotEmpty && controller.text == pin) {
                  Get.off(const HomeBar());
                } else {
                  Fluttertoast.showToast(msg: "Invalid Pin");
                  controller.clear();
                }
              },
              child: const Text("Login")),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.black)),
              onPressed: () {
                Get.back();
              },
              child: const Text("Back")),
        ],
      ));
}

// Future signInUser(var email, var pass, BuildContext buildContext) async {
//   try {
//     EasyLoading.show(dismissOnTap: false);
//     final credential = await FirebaseAuth.instance
//         .signInWithEmailAndPassword(email: email, password: pass)
//         .whenComplete(() => EasyLoading.dismiss());
//     try {
//       FirebaseFirestore.instance
//           .collection("Club")
//           .doc(credential.user?.uid)
//           .get()
//           .then((value) {
//         if (value.exists) {
//           saveBusinessType("club");
//           Get.off(() => const ClubHome());
//         } else {
//           FirebaseFirestore.instance
//               .collection("Organiser")
//               .doc(credential.user?.uid)
//               .get()
//               .then((value) {
//             if (value.exists) {
//               saveBusinessType("organiser");
//               Get.off(() => const OrganiserHome());
//             } else {
//               Get.off(const InitSignupDetails());
//             }
//           });
//         }
//       });
//     } catch (e) {
//       Get.off(const InitSignupDetails());
//     }
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'user-not-found') {
//       Fluttertoast.showToast(msg: 'No user found for that email.');
//     } else if (e.code == 'wrong-password') {
//       Fluttertoast.showToast(msg: 'Wrong password provided for that user.');
//     }
//   }
// }
