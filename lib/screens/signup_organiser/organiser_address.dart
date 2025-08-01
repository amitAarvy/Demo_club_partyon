import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/home.dart';
import 'package:club/utils/app_const.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/cities.dart';
import 'package:club/utils/provider_utils.dart';
import 'package:club/utils/relationship_agreement.dart';
import 'package:club/screens/sign_up/signup_utils.dart';
import 'package:club/screens/sign_up/upload_docs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:random_string/random_string.dart';
import 'package:share_plus/share_plus.dart';

import '../../authentication/login_page.dart';
import '../organiser/home/organiser_home.dart';
import '../organiser/home/organiser_homeBar.dart';
import '../refer/presentation/controller/refer_controller.dart';

class AddressOrganiser extends StatefulWidget {

  final String id;
  final Map<String, dynamic> data;


  const AddressOrganiser({super.key,
        required this.id, required this.data,});

  @override
  State<AddressOrganiser> createState() => _AddressOrganiserState();
}

class _AddressOrganiserState extends State<AddressOrganiser> with WidgetsBindingObserver {
  String address = "", locality = "", pincode = "";
  dynamic latitude, longitude;
  String location = 'Null, Press Button';
  bool dialogOther = false;
  bool isChecked = false;
  late final c = Get.put(LoginProvider());

  String dropState = "Andhra Pradesh",
      dropValueCity = "Select City",
      dropND = "Select Locality",
      dropGM = "Select Locality";
  final TextEditingController _clubAddress = TextEditingController();

  final TextEditingController _clubArea = TextEditingController();
  final TextEditingController _clubLandMark = TextEditingController();
  final TextEditingController _pinCode = TextEditingController();
  final TextEditingController _otherCity = TextEditingController();
  ValueNotifier<bool> isLoadingContinue = ValueNotifier(false);


  // Future<void> uploadImage(File image,
  //     {bool isCover = false, bool isLayout = false}) async {
  //   String url = isCover == true
  //       ? 'Club/${uid()}/coverImage/coverImage.jpg'
  //       : isLayout == true
  //       ? 'Club/${uid()}/layoutImage/layoutImage.jpg'
  //       : "";
  //   final Reference ref = FirebaseStorage.instance.ref().child(url);
  //   final UploadTask uploadTask = ref.putFile(image);
  //   try {
  //     await uploadTask.then((taskSnapShot) async {
  //       var photoUrl = await taskSnapShot.ref.getDownloadURL();
  //
  //       FirebaseAuth.instance.currentUser
  //           ?.updatePhotoURL(photoUrl)
  //           .whenComplete(() {
  //         FirebaseFirestore.instance.collection("Club").doc(uid()).set({
  //           isCover == true
  //               ? "coverImage"
  //               : isLayout == true
  //               ? "layoutImage"
  //               : "": photoUrl
  //         }, SetOptions(merge: true));
  //       });
  //     });
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "An unknown error occurred.Please try again");
  //     EasyLoading.dismiss();
  //   }
  // }

  List<String> itemsGM = ["Select Locality", "Cyber City"];

  Future<void> getAddressFromLatLong(Position position) async {
    List<Placemark> placeMarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placeMarks[0];

    setState(() {
      _clubAddress.text = "${place.street}";
      _clubArea.text = place.subLocality!;
      _pinCode.text = place.postalCode!;

      latitude = position.latitude;
      longitude = position.longitude;
      for (var i in itemsState) {
        if (i == place.administrativeArea) {
          dropState = place.administrativeArea!;
        } else if (place.administrativeArea == "Delhi") {
          dropState = "Delhi NCR";
        }
      }
    });
  }

  Future<void> getAddress() async {
    PermissionStatus status = await Permission.location.request();
    EasyLoading.show();
    try {
      Position position = await getGeoLocationPosition();
      location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
      getAddressFromLatLong(position);
      print('calling getAddress');
    } catch (e) {
      print('error is ${e}');
      Fluttertoast.showToast(msg: "$e");
    }
    finally{
      EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getAddress();

  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getAddress();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dropValueCity == "Other") {
      setState(() {
        dialogOther = true;
      });
    } else {
      setState(() {
        _otherCity.text = "";
        dialogOther = false;
      });
    }
    List stateCity = getStateCity(dropState);

    List<String> itemsCity = ["Select City", ...stateCity];

    return Scaffold(
      appBar: appBar(context, title: "Address"),
      backgroundColor: matte(),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 150.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                     "Promoter Address" ,
                    style: GoogleFonts.ubuntu(
                        fontSize: 60.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                ],
              ).marginOnly(left: 40.w, bottom: 40.w),
              textField("Enter Address", _clubAddress),
              textField("Road / Area", _clubArea),
              textField("Landmark (Optional)", _clubLandMark),
              textField("Pin Code", _pinCode, isNum: true, isPinCode: true),
              SizedBox(
                height: 20.h,
              ),
              Container(
                height: 130.h,
                width: Get.width - 100.w,
                decoration:
                BoxDecoration(border: Border.all(color: Colors.grey)),
                child: Center(
                  child: DropdownButton<String>(
                    items: itemsState
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: Alignment.center,
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() {
                        dropState = val!;
                        dropValueCity = "Select City";
                      });
                    },
                    value: dropState,
                    style: const TextStyle(color: Colors.white70),
                    dropdownColor: Colors.black,
                  ),
                ),
              ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
              SizedBox(
                height: 50.h,
              ),
              Container(
                height: 130.h,
                width: Get.width - 100.w,
                decoration:
                BoxDecoration(border: Border.all(color: Colors.grey)),
                child: Center(
                  child: DropdownButton<String>(
                    items: (itemsCity)
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: Alignment.center,
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() {
                        dropValueCity = val!;
                      });
                    },
                    value: dropValueCity,
                    style: const TextStyle(color: Colors.white70),
                    dropdownColor: Colors.black,
                  ),
                ),
              ).marginOnly(left: 30.w, right: 30.w, bottom: 30.h, top: 20.h),
              dialogOther == true
                  ? ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    // false = user must tap button, true = tap outside dialog
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                          title: const Text("Enter City name"),
                          content: SizedBox(
                            height: 300.0,
                            width: 300.0,
                            child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  TextField(
                                    controller: _otherCity,
                                    decoration: const InputDecoration(
                                        labelText: "Enter city name"),
                                  ).marginSymmetric(horizontal: 50.w),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_otherCity.text.isEmpty) {
                                        Fluttertoast.showToast(
                                            msg:
                                            "Enter a valid city name");
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStateProperty
                                            .resolveWith((states) =>
                                        Colors.green)),
                                    child: const Text("Continue"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        dropValueCity = "Select City";
                                        dialogOther = false;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                        MaterialStateProperty
                                            .resolveWith((states) =>
                                        Colors.red)),
                                    child: const Text("Cancel"),
                                  ),
                                ]),
                          ));
                    },
                  );
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.black)),
                child: const Text("Choose Other City"),
              )
                  : Container(),
              dropValueCity == "New Delhi"
                  ? Container(
                height: 130.h,
                width: Get.width - 100.w,
                decoration:
                BoxDecoration(border: Border.all(color: Colors.grey)),
                child: Center(
                  child: DropdownButton<String>(
                    items: itemsND
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: Alignment.center,
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() {
                        dropND = val!;
                      });
                    },
                    value: dropND,
                    style: const TextStyle(color: Colors.white70),
                    dropdownColor: Colors.black,
                  ),
                ),
              ).marginOnly(
                  left: 30.w, right: 30.w, bottom: 30.h, top: 20.h)
                  : Container(),
              dropValueCity == "Gurugram"
                  ? Container(
                height: 130.h,
                width: Get.width - 100.w,
                decoration:
                BoxDecoration(border: Border.all(color: Colors.grey)),
                child: Center(
                  child: DropdownButton<String>(
                    items: itemsGM
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        alignment: Alignment.center,
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      setState(() {
                        dropGM = val!;
                      });
                    },
                    value: dropGM,
                    style: const TextStyle(color: Colors.white70),
                    dropdownColor: Colors.black,
                  ),
                ),
              ).marginOnly(
                  left: 30.w, right: 30.w, bottom: 30.h, top: 20.h)
                  : Container(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Checkbox(
              //         activeColor: Colors.orange,
              //         checkColor: Colors.orange,
              //         fillColor: MaterialStateProperty.resolveWith(
              //                 (states) => Colors.white),
              //         tristate: false,
              //         value: isChecked,
              //         onChanged: (val) {
              //           setState(() {
              //             isChecked = val!;
              //           });
              //         }),
              //     Text(
              //       "I agree to the ",
              //       style: GoogleFonts.ubuntu(color: Colors.white),
              //     ),
              //     GestureDetector(
              //       onTap: () async {
              //         if (widget.clubName != "" &&
              //             _clubAddress.text.isNotEmpty &&
              //             dropValueCity != "Select City" &&
              //             _pinCode.text.isNotEmpty &&
              //             _clubArea.text.isNotEmpty &&
              //             dropState != "") {
              //           if (dropValueCity == "Other" &&
              //               _otherCity.text.isEmpty) {
              //             Fluttertoast.showToast(
              //                 msg: "Kindly provide other city name ");
              //           } else {
              //             Map<Permission, PermissionStatus> permission = await [
              //               Permission.storage,
              //             ].request();
              //             if (permission[Permission.storage] ==
              //                 PermissionStatus.granted) {
              //               EasyLoading.show();
              //               final pdf = pw.Document();
              //               DateTime date = DateTime.now();
              //
              //               pdf.addPage(pw.MultiPage(
              //                   pageFormat: PdfPageFormat.a4,
              //                   build: (pw.Context context) {
              //                     return [
              //                       pw.Center(
              //                           child: pw.RichText(
              //                             text: pw.TextSpan(children: [
              //                               pw.TextSpan(
              //                                   text: agreement(
              //                                       clubName: widget.clubName,
              //                                       clubAdress:
              //                                       "${_clubAddress.text}, ${_clubArea.text} ${dropValueCity != "Other" ? dropValueCity : _otherCity.text}, $dropState ${_pinCode.text} ",
              //                                       date: date.day,
              //                                       month: date.month,
              //                                       year: date.year),
              //                                   style: pw.TextStyle(
              //                                       font: pw.Font.times())),
              //                               // pw.TextSpan(text: agreementPart2,style: pw.TextStyle(font: pw.Font.times()))
              //                             ]),
              //                           ))
              //                     ];
              //                   }));
              //               pdf.addPage(pw.Page(
              //                   pageFormat: PdfPageFormat.a4,
              //                   build: (pw.Context context) {
              //                     return pw.Center(
              //                         child: pw.RichText(
              //                           text: pw.TextSpan(children: [
              //                             pw.TextSpan(
              //                                 text: agreementPart2,
              //                                 style: pw.TextStyle(
              //                                     font: pw.Font.times()))
              //                           ]),
              //                         ));
              //                   })); // Page
              //               final output = await getTemporaryDirectory();
              //               final file = File(
              //                   "${output.path}/Relationship_Agreement.pdf");
              //
              //               await file
              //                   .writeAsBytes(await pdf.save())
              //                   .whenComplete(() => EasyLoading.dismiss());
              //               Share.shareXFiles([XFile(file.path)]);
              //             } else {
              //               Fluttertoast.showToast(
              //                   msg:
              //                   "Kindly grant storage permission in your app settings");
              //             }
              //           }
              //         } else {
              //           Fluttertoast.showToast(
              //               msg: "Kindly fill the required fields first.");
              //         }
              //       },
              //       child: Text(
              //         "Relationship Agreement ",
              //         style: GoogleFonts.ubuntu(
              //             color: Colors.white,
              //             decoration: TextDecoration.underline),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 50.h,
              ),
              GestureDetector(
                onTap: () async {
                  try {
                    isLoadingContinue.value = true;
                    widget.data.addAll({
                      "activeStatus":'New',
                      "address": _clubAddress.text,
                      "area": _clubArea.text,
                      "landmark": _clubLandMark.text,
                      "state": dropState,
                      "city": dropValueCity == "Other"
                          ? _otherCity.text
                          : dropValueCity,
                      "pinCode": _pinCode.text,
                      "latitude": latitude,
                      "longitude": longitude,
                    });
                    print('wiget.id check is ${widget.data}');
                    await FirebaseFirestore.instance.collection("Organiser").doc(widget.id).set(widget.data).onError((error, stackTrace) async {
                      Fluttertoast.showToast(msg: 'Something went wrong');
                      await FirebaseFirestore.instance.collection("Organiser").doc(widget.id).delete().then((e){
                        Get.offAll(const LoginPage());
                      });
                    }).whenComplete(() async {
                      await ReferController.updateReferral(
                          "organiser", widget.data['companyMame']);
                      // await ReferController.updateReferral(
                      //     "organiser", companyName.text);
                      saveBusinessType("organiser");
                      Fluttertoast.showToast(
                          msg: 'Organiser registered successfully');
                      // Get.to(AddressOrganiser(id:widget.id.toString()));
                      Get.off(const OrganiserHomeBar());
                    });


                  } catch (e) {
                    print("Error uploading image: $e");
                  } finally {
                    isLoadingContinue.value = false;
                    // setState(() => isLoading.v = false);
                  }
                  // c.changeLogin(
                  //     address: _clubAddress.text,
                  //     locality: _clubArea.text,
                  //     landmark: _clubLandMark.text,
                  //     state: dropState,
                  //     city: dropValueCity);
                  // if (kDebugMode) {
                  //   print(c.clubName.value +
                  //       c.email.value +
                  //       c.description.value +
                  //       c.category.value);
                  // }
                  // if (isChecked == true) {
                  //   if (widget.clubName.isNotEmpty &&
                  //       widget.category.isNotEmpty &&
                  //       _clubAddress.text.isNotEmpty &&
                  //       dropValueCity != "Select City" &&
                  //       _pinCode.text.isNotEmpty &&
                  //       _clubArea.text.isNotEmpty &&
                  //       dropState.isNotEmpty) {
                  //     if (dropValueCity != null && dropValueCity == "Other" && _otherCity.text.isEmpty) {
                  //       Fluttertoast.showToast(msg: "Kindly provide other city name");
                  //     } else {
                  //       if ((dropValueCity == "New Delhi" &&
                  //           dropND == "Select Locality") ||
                  //           (dropValueCity == "Gurugram" &&
                  //               dropGM == "Select Locality")) {
                  //         Fluttertoast.showToast(msg: "Select a locality");
                  //       } else {
                  //         String clubID = randomAlphaNumeric(8);
                  //         // String referredById =
                  //         // await ReferController.getReferredById();
                  //         EasyLoading.show();
                  //         FirebaseFirestore.instance
                  //             .collection("Club")
                  //             .doc(FirebaseAuth.instance.currentUser?.uid)
                  //             .set({
                  //           "clubName": widget.clubName,
                  //           "email": widget.email,
                  //           "description": widget.description,
                  //           "category":
                  //           FieldValue.arrayUnion([widget.category]),
                  //           "address": _clubAddress.text,
                  //           "area": _clubArea.text,
                  //           "landmark": _clubLandMark.text,
                  //           "state": dropState,
                  //           "city": dropValueCity == "Other"
                  //               ? _otherCity.text
                  //               : dropValueCity,
                  //           "pinCode": _pinCode.text,
                  //           "latitude": latitude,
                  //           "longitude": longitude,
                  //           "businessCategory": widget.businessCategory,
                  //           "coverImage": "",
                  //           "galleryImages": [],
                  //           "layoutImage": "",
                  //           "logo": "",
                  //           "gstCert": "",
                  //           "pplCert": "",
                  //           "relationAgreement": "",
                  //           "openTime": widget.openTime,
                  //           "closeTime": widget.closeTime,
                  //           "averageCost": widget.averageCost,
                  //           'clubUID': FirebaseAuth.instance.currentUser?.uid,
                  //           'clubID': clubID,
                  //           'uid': uid(),
                  //           "locality": dropValueCity == "New Delhi"
                  //               ? dropND
                  //               : dropValueCity == "Gurugram"
                  //               ? dropGM
                  //               : "",
                  //           'date': DateFormat('DD-MM-YYYY').format(DateTime.now()),
                  //           "activeStatus": true,
                  //           "isClub": true,
                  //           "liveURL": '',
                  //           "businessType": "venue",
                  //           "referralId": randomAlphaNumeric(8),
                  //           // "referredBy": referredById
                  //         }, SetOptions(merge: true))
                  //         // .whenComplete(() => FirebaseFirestore.instance
                  //         //         .collection("Admin")
                  //         //         .doc("Club")
                  //         //         .collection('clubList')
                  //         //         .doc(uid())
                  //         //         .set({
                  //         //       "clubName": widget.clubName,
                  //         //       "email": widget.email,
                  //         //       'clubUID':
                  //         //           FirebaseAuth.instance.currentUser?.uid,
                  //         //       'clubID': clubID,
                  //         //       'date': Timestamp.now(),
                  //         //       "activeStatus": false
                  //         //     }))
                  //             .whenComplete(() async {
                  //           // await ReferController.updateReferral("venue",widget.clubName);
                  //           saveBusinessType("club");
                  //           if (widget.uploadCover != null) {
                  //             EasyLoading.show();
                  //             uploadImage(widget.uploadCover!, isCover: true)
                  //                 .whenComplete(() => EasyLoading.dismiss());
                  //           }
                  //         }).whenComplete(() async{
                  //           EasyLoading.dismiss();
                  //           await const FlutterSecureStorage().write(key: "businessCategory", value: "${widget.businessCategory}");
                  //           if(widget.businessCategory == 1){
                  //             Get.offAll(const UploadDocs());
                  //           }else{
                  //             Get.off(const ClubHome());
                  //           }
                  //         });
                  //       }
                  //     }
                  //   } else {
                  //     Fluttertoast.showToast(
                  //         msg: "Kindly fill all required fields");
                  //   }
                  // } else {
                  //   Fluttertoast.showToast(
                  //       msg: "Please agree to the Relationship Agreement ");
                  // }
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
                      "Save",
                      style: GoogleFonts.ubuntu(
                          color: Colors.white, fontSize: 35.sp),
                    ),
                  ),
                ),
              ).marginAll(20.h),
            ],
          ),
        ],
      ),
    );
  }
}