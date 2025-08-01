import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

//List of States
List<String> states = [
  "Andhra Pradesh",
  "Arunachal Pradesh",
  "Assam",
  "Bihar",
  "Chhattisgarh",
  // "Delhi",
  "Delhi NCR",
  "Goa",
  "Gujarat",
  "Haryana",
  "Himachal Pradesh",
  "Jammu and Kashmir",
  "Jharkhand",
  "Karnataka",
  "Kerala",
  "Madhya Pradesh",
  "Maharashtra",
  "Manipur",
  "Meghalaya",
  "Mizoram",
  "Nagaland",
  "Odisha",
  "Punjab",
  "Rajasthan",
  "Sikkim",
  "Tamil Nadu",
  "Telangana",
  "Tripura",
  "Uttar Pradesh",
  "Uttarakhand",
  "West Bengal"
];
// List of category of clubs
List<String> clubCategory = [
  "Club",
  "Lounge",
  "Roof Top",
  "Bar",
  "Concert Venue",
  "Day Club",
  "Night Club",
  "Sports Bar"
];
//edit Icon
Widget editIcon(BuildContext context, var edit, int length, currentVal,
    {bool isNum = false,
    bool isEditOrganiser = false,
    isState = false,
    isName = false,
    isAmount = false,
    isTime = false}) {
  TextEditingController edit0 = TextEditingController();
  final HomeController homeController = Get.put(HomeController());
  return IconButton(
      onPressed: () async {
        if (isTime == true) {
          await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 0, minute: 0))
              .then((time) {
            if (time != null) {
              String updatedTime =
                  "${time.hour.isGreaterThan(12) == true ? ((time.hour) - 12) : time.hour} : ${time.minute < 10 ? '0${time.minute}' : time.minute} ${time.hour.isGreaterThan(11) == true ? 'P.M.' : 'A.M.'}";
              EasyLoading.show();
              FirebaseFirestore.instance
                  .collection("Club")
                  .doc(uid())
                  .update({"$edit": updatedTime}).whenComplete(() {
                getCurrentClub();
                EasyLoading.dismiss();
                Fluttertoast.showToast(msg: "Updated successfully");
              });
            }
          });
        } else {
          Get.defaultDialog(
              backgroundColor: matte(),
              title: "Edit $edit",
              titleStyle: GoogleFonts.ubuntu(color: Colors.white),
              content: SizedBox(
                width: 400.w,
                height: 400.w,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      style: GoogleFonts.ubuntu(color: Colors.white),
                      controller: edit0..text = currentVal,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(length)
                      ],
                      keyboardType: isNum == true
                          ? TextInputType.number
                          : TextInputType.text,
                      decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          prefixText: isAmount == true ? "₹" : ""),
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.black)),
                        onPressed: () async {
                          if (edit0.text.isNotEmpty) {
                            if (edit0.text != currentVal) {
                              try {
                                EasyLoading.show();
                                if (isEditOrganiser) {
                                  FirebaseAuth.instance.currentUser
                                      ?.updateDisplayName(edit0.text.capitalizeFirstOfEach)
                                      .whenComplete(() {
                                    homeController.updateOrganiserName(
                                        (FirebaseAuth.instance.currentUser
                                            ?.displayName)!);
                                    Get.back();
                                    EasyLoading.dismiss();
                                  });
                                } else {
                                  FirebaseFirestore.instance
                                      .collection("Club")
                                      .doc(uid())
                                      .update({
                                    "$edit": edit0.text
                                  }).whenComplete(() {
                                    getCurrentClub();
                                    Get.back();
                                    EasyLoading.dismiss();
                                    Fluttertoast.showToast(
                                        msg: "Updated successfully");
                                  });
                                }
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg: "Something went wrong.");
                              }
                            } else {
                              Fluttertoast.showToast(msg: "No updates found");
                            }
                          } else {
                            Fluttertoast.showToast(msg: "Enter valid details");
                          }
                        },
                        child: const Text("Save Changes"))
                  ],
                ),
              ));
        }
      },
      icon: const Icon(
        Icons.edit,
        color: Colors.white,
      ));
}

//Info Profile
Widget info(var name, var value) {
  TextEditingController controller = TextEditingController(text: value);

  return SizedBox(
          height: 100.h,
          width: Get.width - 275.w,
          child: TextField(
              controller: controller,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1.0)),
                  hintStyle: GoogleFonts.ubuntu(),
                  labelText: name,
                  labelStyle:
                      TextStyle(color: Colors.white70, fontSize: 40.sp))))
      .marginSymmetric(horizontal: 10.h, vertical: 30.h);
}
