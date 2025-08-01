import 'dart:io';
import 'package:club/screens/home/home.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/screens/sign_up/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddClubDetails extends StatefulWidget {
  final int businessCategory;
  final String clubName, email, description, category,gst;

  const AddClubDetails(
      {super.key, required this.clubName,
        required this.category,
        required this.description,
        required this.gst,
        required this.email, required this.businessCategory});

  @override
  State<AddClubDetails> createState() => _AddClubDetailsState();
}

class _AddClubDetailsState extends State<AddClubDetails> {
  File? uploadCover, uploadLayout;
  final ImagePicker imagePicker = ImagePicker();
  String openTime = "", closingTime = "";
  final TextEditingController _averageCost = TextEditingController();

  _getFromGallery(String file) async {
    // Map<Permission, PermissionStatus> permission = await [
    //   Permission.storage,
    // ].request();
    //
    // if (permission[Permission.storage] == PermissionStatus.granted) {
    await cropImage().then((value) {
      if (value != null) {
        setState(() {
          file == "cover"
              ? uploadCover = File(value.path)
              : file == "layout"
              ? uploadLayout = File(value.path)
              : null;
        });
      }
    });
    // } else {
    //   Fluttertoast.showToast(
    //       msg: "Kindly enable storage permissions in your app settings");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Club Details"),
      resizeToAvoidBottomInset: false,
      backgroundColor: matte(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: (Get.width - 100.w) * 9 / 16,
                  width: Get.width - 100.w,
                  decoration:
                  BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: uploadCover == null
                      ? Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 300.h,
                      ))
                      : Image.file(
                    uploadCover!,
                    fit: BoxFit.cover,
                  ),
                ).marginAll(20),
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: 110.h,
                      width: 110.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              uploadCover = null;
                            });
                          },
                        ),
                      ),
                    )).marginOnly(top: 75.h, right: 75.w)
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                _getFromGallery("cover");
              },
              style: ButtonStyle(
                  shape: WidgetStateProperty.resolveWith((states) =>
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.black)),
              child: Text("Upload ${widget.businessCategory!= 1 ? 'Brand' : 'Cover'} Image"),
            ),
            SizedBox(
              height: 30.h,
            ),
            if(widget.businessCategory == 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  textField("Average cost for two", _averageCost, isNum: true),
                  SizedBox(
                    height: 20.h,
                  ),
                  Container(
                    height: 175.h,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(openTime != "" ? "Opening Time : $openTime" : "",
                            style: GoogleFonts.ubuntu(
                                color: Colors.white, fontSize: 16)),
                        openTime != ""
                            ? SizedBox(
                          width: 50.w,
                        )
                            : Container(),
                        ElevatedButton(
                          onPressed: () async {
                            await showTimePicker(
                                context: context,
                                initialTime: const TimeOfDay(hour: 0, minute: 0))
                                .then((time) => setState(() {
                              if (time != null) {
                                openTime =
                                "${time.hour.isGreaterThan(12) == true ? ((time.hour) - 12) : time.hour} : ${time.minute < 10 ? '0${time.minute}' : time.minute} ${time.hour.isGreaterThan(11) == true ? 'P.M.' : 'A.M.'}";
                              }
                            }));
                          },
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                      (states) => Colors.orange)),
                          child: const Text("Opening Time"),
                        )
                      ],
                    ),
                  ).marginAll(20.w),
                  Container(
                    height: 175.h,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(closingTime != "" ? "Closing Time : $closingTime" : "",
                            style: GoogleFonts.ubuntu(
                                color: Colors.white, fontSize: 16)),
                        closingTime != ""
                            ? SizedBox(
                          width: 50.w,
                        )
                            : Container(),
                        ElevatedButton(
                          onPressed: () async {
                            await showTimePicker(
                                context: context,
                                initialTime: const TimeOfDay(hour: 0, minute: 0))
                                .then((time) => setState(() {
                              if (time != null) {
                                closingTime =
                                "${time.hour.isGreaterThan(12) == true ? ((time.hour) - 12) : time.hour} : ${time.minute < 10 ? '0${time.minute}' : time.minute} ${time.hour.isGreaterThan(11) == true ? 'P.M.' : 'A.M.'}";
                              }
                            }));
                          },
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                      (states) => Colors.orange)),
                          child: const Text("Closing Time"),
                        )
                      ],
                    ),
                  ).marginAll(20.w),
                  SizedBox(
                    height: 30.h,
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: () {
                if (uploadCover != null &&
                    (widget.businessCategory != 1 || openTime != "") &&
                    (widget.businessCategory != 1 || closingTime != "") &&
                    (widget.businessCategory != 1 || _averageCost.text.isNotEmpty)) {
                  // Get.off(const ClubHome());
                  Get.to(Address(
                    clubName: widget.clubName,
                    category: widget.category,
                    description: widget.description,
                    email: widget.email,
                    gst: widget.gst,
                    openTime: openTime,
                    closeTime: closingTime,
                    averageCost: _averageCost.text,
                    uploadCover: uploadCover,
                    businessCategory: widget.businessCategory,
                  ));
                } else {
                  Fluttertoast.showToast(msg: "Kindly fill all fields");
                }
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.green)),
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}