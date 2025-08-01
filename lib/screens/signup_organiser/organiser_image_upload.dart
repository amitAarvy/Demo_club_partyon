import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/screens/sign_up/address.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../authentication/login_page.dart';
import 'organiser_address.dart';

class AddOrganiserImage extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const AddOrganiserImage(
      {super.key, required this.id, required this.data,
       });

  @override
  State<AddOrganiserImage> createState() => _AddOrganiserImageState();
}

class _AddOrganiserImageState extends State<AddOrganiserImage> {
  File? uploadCover, uploadLayout;
  final ImagePicker imagePicker = ImagePicker();
  ValueNotifier<bool> isLoadingContinue = ValueNotifier(false);
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
    return WillPopScope(
      onWillPop: ()async {
        await FirebaseFirestore.instance.collection("Organiser").doc(widget.id).delete().then((e){
          Get.back();
        });
        return false;
      },
      child: Scaffold(
        appBar: appBar(context, title: "Promoter Details",),
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
                child: Text("Upload Image"),
              ),
              SizedBox(
                height: 30.h,
              ),
              ValueListenableBuilder(
                valueListenable: isLoadingContinue,
                builder: (context, bool isLoading, child) =>
                 ElevatedButton(
                  onPressed: ()async {
                    try {
                      isLoadingContinue.value = true;
                      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
                      Reference ref = FirebaseStorage.instance.ref().child("Club/${widget.id}/coverImage/$fileName.jpg");
                      UploadTask uploadTask = ref.putFile(uploadCover!);
                      TaskSnapshot snapshot = await uploadTask;
                      String downloadUrl = await snapshot.ref.getDownloadURL();
                      widget.data.addAll({
                        "profile_image": downloadUrl,
                      });

                      print('check all field add ${widget.data}');

                      Get.to(AddressOrganiser(id:widget.id.toString(), data: widget.data,));
                      setState(() {
                        uploadCover = null;
                      });
                      // await FirebaseFirestore.instance.collection("Organiser").doc(widget.id).update({
                      //   "profile_image": downloadUrl,
                      // }).onError((error, stackTrace) async {
                      //   Fluttertoast.showToast(msg: 'Something went wrong');
                      //   await FirebaseFirestore.instance.collection("Organiser").doc(widget.id).delete().then((e){
                      //     Get.offAll(const LoginPage());
                      //   });
                      //
                      // }).whenComplete(() async {
                      //   // await ReferController.updateReferral(
                      //   //     "organiser", companyName.text);
                      //   // saveBusinessType("organiser");
                      //   // // Fluttertoast.showToast(
                      //   // //     msg: 'Organiser registered successfully');
                      //   Get.to(AddressOrganiser(id:widget.id.toString()));
                      //   // Get.off(const OrganiserHome());
                      // });
                      //
                      // print("Image uploaded: $downloadUrl");
                      //
                      // setState(() {
                      //   uploadCover = null;
                      // });
                    } catch (e) {
                      print("Error uploading image: $e");
                    } finally {
                      isLoadingContinue.value = false;
                      // setState(() => isLoading.v = false);
                    }
                    // if (uploadCover != null &&
                    //     (widget.businessCategory != 1 || openTime != "") &&
                    //     (widget.businessCategory != 1 || closingTime != "") &&
                    //     (widget.businessCategory != 1 || _averageCost.text.isNotEmpty)) {
                    //   Get.to(Address(
                    //     clubName: widget.clubName,
                    //     category: widget.category,
                    //     description: widget.description,
                    //     email: widget.email,
                    //     openTime: openTime,
                    //     closeTime: closingTime,
                    //     averageCost: _averageCost.text,
                    //     uploadCover: uploadCover,
                    //     businessCategory: widget.businessCategory,
                    //   ));
                    // } else {
                    //   Fluttertoast.showToast(msg: "Kindly fill all fields");
                    // }
                  },
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => Colors.green)),
                  child:  isLoading?SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white,)):Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
