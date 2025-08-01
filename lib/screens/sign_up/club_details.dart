import 'dart:io';

import 'package:club/utils/app_utils.dart';
import 'package:club/utils/provider_utils.dart';
import 'package:club/authentication/login_page.dart';
import 'package:club/screens/sign_up/add_club_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ClubDetails extends StatefulWidget {
  final int businessCategory;
  final String email, phone;
  final bool isPhone;

  const ClubDetails(
      {this.phone = "", this.isPhone = false, required this.email, Key? key, required this.businessCategory})
      : super(key: key);

  @override
  State<ClubDetails> createState() => _ClubDetailsState();
}

class _ClubDetailsState extends State<ClubDetails> {
  final TextEditingController _clubName = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController gstNumber = TextEditingController();
  File? uploadLogo;
  bool uploadShow = false;
  String dropValue = "Select a category";
  late final TextEditingController _email;

  final items = <String>[
    "Select a category",
    "Club",
    "Lounge",
    "Roof Top",
    "Bar",
    "Concert Venue",
    "Day Club",
    "Night Club",
    "Sports Bar"
  ];
  final loginProvider = Get.put(LoginProvider());

  @override
  void initState() {
    // TODO: implement initState

    _email = TextEditingController(
        text: widget.isPhone ? widget.phone : widget.email);
    super.initState();
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Club Details",
                  style: GoogleFonts.ubuntu(
                      color: Colors.orange,
                      fontSize: 60.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ).marginOnly(left: 40.w, bottom: 40.w),
            textField(widget.businessCategory != 1 ? "Brand Name" : "Club Name", _clubName),
            textField("Email / Phone", _email,
                isEmail: true, isPhone: widget.isPhone,),
            textField("GST No.", gstNumber),
            textField(widget.businessCategory != 1 ? "Product / Brand Description" : "Description", _description,isInfo: true),
            if(widget.businessCategory == 1)
              Container(
                height: 130.h,
                width: Get.width - 100.w,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                child: Center(
                  child: DropdownButton<String>(
                    items: items.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: Alignment.center,
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() {
                        dropValue = val!;
                      });
                    },
                    value: dropValue,
                    style: const TextStyle(color: Colors.white70),
                    dropdownColor: Colors.black,
                  ),
                ),
              ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
            // textField("Description", _description, isInfo: true),
            // Container(
            //   height: 130.h,
            //   width: Get.width - 100.w,
            //   decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            //   child: Center(
            //     child: DropdownButton<String>(
            //       items: items.map<DropdownMenuItem<String>>((String value) {
            //         return DropdownMenuItem<String>(
            //           alignment: Alignment.center,
            //           value: value,
            //           child: Text(value),
            //         );
            //       }).toList(),
            //       onChanged: (String? val) {
            //         setState(() {
            //           dropValue = val!;
            //         });
            //       },
            //       value: dropValue,
            //       style: const TextStyle(color: Colors.white70),
            //       dropdownColor: Colors.black,
            //     ),
            //   ),
            // ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
            // SizedBox(
            //   height: 40.h,
            // ),
            SizedBox(height: 30.h),
            GestureDetector(
              onTap: () {
                loginProvider.changeLogin(
                    clubName: _clubName.text,
                    email: _email.text,
                    gst: gstNumber.text,
                    description: _description.text,
                    category: dropValue);
                if (loginProvider.clubName.isNotEmpty &&
                    (widget.businessCategory != 1 || loginProvider.category.isNotEmpty) &&
                    loginProvider.description.isNotEmpty &&
                    loginProvider.email.isNotEmpty &&
                    (widget.businessCategory != 1 || loginProvider.category.value != "Select a category")) {
                  Get.to(AddClubDetails(
                    clubName: _clubName.text,
                    category: dropValue,
                    description: _description.text,
                    email: _email.text,
                    gst:gstNumber.text,
                    businessCategory: widget.businessCategory,
                  ));
                } else {
                  Fluttertoast.showToast(
                      msg: "Kindly fill all required fields");
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
                    "Save Details",
                    style: GoogleFonts.ubuntu(
                        color: Colors.white, fontSize: 35.sp),
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
                    backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.black)),
                child: const Text("Back to Login"))
          ]),
        ));
  }
}
