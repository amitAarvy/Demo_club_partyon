import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/local_db/hive_db.dart';
import 'package:club/screens/home/home.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../home/homeBar.dart';

class UploadDocs extends StatefulWidget {
  final bool isHome;

  const UploadDocs({this.isHome = false, Key? key}) : super(key: key);

  @override
  State<UploadDocs> createState() => _UploadDocsState();
}

class _UploadDocsState extends State<UploadDocs> {
  File? uploadLogo, uploadGST, uploadPPL, uploadAgreement;
  final c = Get.put(HomeController());

  _getFromGallery(String file) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      setState(() {
        file == "logo"
            ? uploadLogo = File(pickedFile.path)
            : file == "gst"
                ? uploadGST = File(pickedFile.path)
                : file == "ppl"
                    ? uploadPPL = File(pickedFile.path)
                    : null;
      });
    }
  }

  Future<void> uploadDocs(File file,
      {bool isLogo = false,
      bool isGST = false,
      bool isPPL = false,
      isRA = false}) async {
    EasyLoading.show();

    // ignore: non_constant_identifier_names
    try {
      String url = isLogo == true
          ? 'Club/${uid()}/docs/logo'
          : isGST == true
              ? 'Club/${uid()}/docs/gstCertificate'
              : isPPL == true
                  ? 'Club/${uid()}/docs/pplCertificate'
                  : isRA == true
                      ? 'Club/${uid()}/docs/relationAgreement'
                      : "";
      final Reference ref = FirebaseStorage.instance.ref().child(url);
      final UploadTask uploadTask = ref.putFile(file);
      await uploadTask.then((taskSnapShot ) async {
        var fileURL = await taskSnapShot.ref.getDownloadURL();

        FirebaseAuth.instance.currentUser
            ?.updatePhotoURL(fileURL)
            .whenComplete(() {
          FirebaseFirestore.instance.collection("Club").doc(uid()).set({
            isLogo == true
                ? "logo"
                : isGST == true
                    ? "gst_cert"
                    : isPPL == true
                        ? "ppl_cert"
                        : isRA == true
                            ? "relationAgreement"
                            : "": fileURL
          }, SetOptions(merge: true)).whenComplete(() => EasyLoading.dismiss());
        });
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "An unknown error occured.Please try again");
      if (kDebugMode) {
        print(e);
      }
      EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Uploads"),
      backgroundColor: matte(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.isHome == true
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Get.off(const HomeBar()),
                        child: Text(
                          "Skip",
                          style: GoogleFonts.ubuntu(
                              color: Colors.orange,
                              fontSize: 40.sp,
                              decoration: TextDecoration.underline),
                        ),
                      ).marginAll(40.h),
                    ],
                  ),

            Row(
              children: [
                Text(
                  widget.isHome == true
                      ? "Hello ${c.clubName.value.capitalizeFirst} ,"
                      : "Hello,",
                  style: GoogleFonts.kaushanScript(
                      color: Colors.white, fontSize: 90.sp),
                ).marginOnly(left: 100.w, top: 80.h),
              ],
            ),
            // Container(
            //   child: Stack(
            //     children: [
            //       Container(
            //         height: 600.h,
            //         width: Get.width - 100.w,
            //         decoration:
            //             BoxDecoration(border: Border.all(color: Colors.grey)),
            //         child: uploadLogo == null
            //             ? Center(
            //                 child: Icon(
            //                 Icons.image,
            //                 color: Colors.white,
            //                 size: 300.h,
            //               ))
            //             : Container(
            //                 child: Image.file(
            //                   uploadLogo!,
            //                   fit: BoxFit.cover,
            //                 ),
            //               ),
            //       ).marginAll(20),
            //       Align(
            //           alignment: Alignment.topRight,
            //           child: Container(
            //             height: 110.h,
            //             width: 110.h,
            //             decoration: BoxDecoration(
            //               shape: BoxShape.circle,
            //               color: Colors.black,
            //             ),
            //             child: Center(
            //               child: IconButton(
            //                 icon: Icon(
            //                   Icons.close,
            //                   color: Colors.orange,
            //                 ),
            //                 onPressed: () {
            //                   setState(() {
            //                     uploadLogo = null;
            //                   });
            //                 },
            //               ),
            //             ),
            //           )).marginOnly(top: 75.h, right: 75.w)
            //     ],
            //   ),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     _getFromGallery("logo");
            //   },
            //   style: ButtonStyle(
            //       backgroundColor: WidgetStateProperty.resolveWith(
            //           (states) => Colors.red)),
            //   child: const Text("Upload Logo"),
            // ),
            SizedBox(
              height: 150.h,
            ),
            widget.isHome == true
                ? Container()
                : SizedBox(
                    height: 180.h,
                    child: Stack(
                      children: [
                        Center(
                            child: GestureDetector(
                          onTap: () {
                            _getFromGallery("logo");
                          },
                          child: Container(
                            height: 150.h,
                            width: 800.w,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "Upload Logo",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.white, fontSize: 40.sp),
                                ).marginOnly(),
                                Icon(
                                  Icons.attach_file,
                                  color: Colors.white,
                                  size: 65.h,
                                ).marginOnly(left: 100.w),
                              ],
                            ),
                          ),
                        )),
                        uploadLogo != null
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      uploadLogo = null;
                                    });
                                  },
                                  child: Container(
                                    height: 75.h,
                                    width: 75.h,
                                    decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle),
                                    child: const Center(
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ).marginAll(20.w)
                            : Container()
                      ],
                    ),
                  ),

            SizedBox(
              height: 120.h,
            ),
            SizedBox(
              height: 180.h,
              child: Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        final mimeType = lookupMimeType(
                            (result?.files.single.path).toString());
                        if (mimeType == "application/pdf") {
                          if (result != null) {
                            setState(() {
                              uploadGST = File(result.files.single.path!);
                            });
                          } else {
                            // User canceled the picker
                          }
                        } else {
                          Fluttertoast.showToast(msg: "Only PDF files allowed");
                        }
                      },
                      child:
                          // Showcase(
                          //     showcaseBackgroundColor: Colors.orange,
                          //     textColor: Colors.white,
                          //     shapeBorder: const CircleBorder(),
                          //     radius: const BorderRadius.all(Radius.circular(40)),
                          //     blurValue: 1,
                          //     overlayPadding: const EdgeInsets.all(5),
                          //     animationDuration: const Duration(milliseconds: 750),
                          //     key: _one,
                          //     description: 'This is Upload GST info',
                          //     child:
                          Container(
                        height: 150.h,
                        width: 800.w,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Upload GST",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white, fontSize: 40.sp),
                            ).marginOnly(),
                            Icon(
                              Icons.attach_file,
                              color: Colors.white,
                              size: 65.h,
                            ).marginOnly(left: 100.w),
                          ],
                        ),
                      ),
                    ),
                    //)
                  ),
                  uploadGST != null
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                uploadGST = null;
                              });
                            },
                            child: Container(
                              height: 75.h,
                              width: 75.h,
                              decoration: const BoxDecoration(
                                  color: Colors.orange, shape: BoxShape.circle),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ).marginAll(20.w)
                      : Container()
                ],
              ),
            ),
            SizedBox(
              height: 120.h,
            ),
            SizedBox(
              height: 180.h,
              child: Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        final mimeType = lookupMimeType(
                            (result?.files.single.path).toString());
                        if (mimeType == "application/pdf") {
                          if (result != null) {
                            setState(() {
                              uploadPPL = File(result.files.single.path!);
                            });
                          } else {
                            // User canceled the picker
                          }
                        } else {
                          Fluttertoast.showToast(msg: "Only PDF files allowed");
                        }
                      },
                      child: Container(
                        height: 150.h,
                        width: 800.w,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "Upload PPL",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white, fontSize: 40.sp),
                            ).marginOnly(),
                            Icon(
                              Icons.attach_file,
                              color: Colors.white,
                              size: 65.h,
                            ).marginOnly(left: 100.w),
                          ],
                        ),
                      ),
                    ),
                  ),
                  uploadPPL != null
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                uploadPPL = null;
                              });
                            },
                            child: Container(
                              height: 75.h,
                              width: 75.h,
                              decoration: const BoxDecoration(
                                  color: Colors.orange, shape: BoxShape.circle),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ).marginAll(20.w)
                      : Container()
                ],
              ),
            ),
            SizedBox(
              height: 120.h,
            ),
            SizedBox(
              height: 180.h,
              child: Stack(
                children: [
                  Center(
                      child: GestureDetector(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      final mimeType = lookupMimeType(
                          (result?.files.single.path).toString());
                      if (mimeType == "application/pdf") {
                        if (result != null) {
                          setState(() {
                            uploadAgreement = File(result.files.single.path!);
                          });
                        } else {
                          // User canceled the picker
                        }
                      } else {
                        Fluttertoast.showToast(msg: "Only PDF files allowed");
                      }
                    },
                    child: Container(
                      height: 150.h,
                      width: 800.w,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Upload Relationship \nAgreement",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                                color: Colors.white, fontSize: 37.sp),
                          ).marginOnly(),
                          Icon(
                            Icons.attach_file,
                            color: Colors.white,
                            size: 65.h,
                          ).marginOnly(left: 100.w),
                        ],
                      ),
                    ),
                  )),
                  uploadAgreement != null
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                uploadAgreement = null;
                              });
                            },
                            child: Container(
                              height: 75.h,
                              width: 75.h,
                              decoration: const BoxDecoration(
                                  color: Colors.orange, shape: BoxShape.circle),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ).marginAll(20.w)
                      : Container()
                ],
              ),
            ),
            SizedBox(
              height: 150.h,
            ),
            ElevatedButton(
              onPressed: () async {
                if (uploadLogo != null ||
                    uploadGST != null ||
                    uploadPPL != null ||
                    uploadAgreement != null) {
                  if (uploadLogo != null) {
                    await uploadDocs(uploadLogo!, isLogo: true);
                  }
                  if (uploadGST != null) {
                    await uploadDocs(uploadGST!, isGST: true);
                  }
                  if (uploadPPL != null) {
                    await uploadDocs(uploadPPL!, isPPL: true);
                  }
                  if (uploadAgreement != null) {
                    await uploadDocs(uploadAgreement!, isRA: true);
                  }
                  Fluttertoast.showToast(msg: "Uploaded Successfully");
                  Box box = await HiveDB.openBox();
                  HiveDB.putKey(box, 'isOrganiser', false);
                  Get.off(const HomeBar());
                } else {
                  Fluttertoast.showToast(
                      msg: "Kindly select at least one file to upload");
                }
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.orange)),
              child: Text(
                "Confirm",
                style: GoogleFonts.ubuntu(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
