import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:club/screens/profile/profile_utils.dart';
import 'package:club/screens/sign_up/signup_utils.dart';
import 'package:club/utils/cities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfile extends StatefulWidget {
  final bool isOrganiser;

  const EditProfile({Key? key, this.isOrganiser = false}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final editNameController = TextEditingController();
  String? organiserName;
  bool dialogOther = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final TextEditingController _otherCity = TextEditingController();
  var user = FirebaseAuth.instance.currentUser;
  final picker = ImagePicker();
  final homeController = Get.put(HomeController());
  late File _image;
  String dropdownState = '', dropdownCity = '', dropdownCategory = '';
  List category = [];
  bool isClub = false,
      isRoof = false,
      isLounge = false,
      isConcert = false,
      isDayClub = false,
      isNightClub = false,
      isSports = false;

  void editProfileImage() {
    Get.bottomSheet(Container(
      color: Colors.black,
      height: 450.h,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        InkWell(
          onTap: _takeAndUploadPicture,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            const Icon(Icons.camera_alt, color: Colors.white).paddingOnly(left: 10),
            Text(
              'Take a Picture',
              style: GoogleFonts.ubuntu(color: Colors.white),
            ).paddingOnly(left: 10),
          ]),
        ),
        Divider(
          color: Colors.grey,
          height: 15.h,
        ).paddingOnly(left: 10),
        InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.image, color: Colors.white).paddingOnly(left: 10),
                Text('Choose from Photos',
                        style: GoogleFonts.ubuntu(color: Colors.white))
                    .paddingOnly(left: 10)
              ],
            ),
            onTap: () =>
                _selectAndUploadPicture().whenComplete(() => getCurrentClub()))
      ]),
    ));
  }

  void checkCategory() {
    if (kDebugMode) {
      print(homeController.category);
    }
    homeController.category.contains("Club") == true ? isClub = true : false;
    homeController.category.contains("Lounge") == true
        ? isLounge = true
        : false;
    homeController.category.contains("Roof Top") == true
        ? isRoof = true
        : false;
    homeController.category.contains("Concert Venue") == true
        ? isConcert = true
        : false;
    homeController.category.contains("Day Club") == true
        ? isDayClub = true
        : false;
    homeController.category.contains("Night Club") == true
        ? isNightClub = true
        : false;
    homeController.category.contains("Sports Bar") == true
        ? isSports = true
        : false;
    "";
  }

  @override
  void initState() {
    if (widget.isOrganiser) {
      homeController.updateOrganiserName(
          (FirebaseAuth.instance.currentUser?.displayName)!);
    } else {
      dropdownState = homeController.state.value;
      dropdownCity = homeController.city.value;
      checkCategory();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget checkBox(String title, bool val) => CheckboxListTile(
        checkColor: Colors.orange,
        tileColor: Colors.white,
        activeColor: Colors.white,
        title: Text(title),
        value: val,
        onChanged: (value) {
          setState(() {
            title == "Club"
                ? isClub = value!
                : title == "Lounge"
                    ? isLounge = value!
                    : title == "Roof Top"
                        ? isRoof = value!
                        : title == "Concert Venue"
                            ? isConcert = value!
                            : title == "Day Club"
                                ? isDayClub = value!
                                : title == "Night Club"
                                    ? isNightClub = value!
                                    : title == "Sports Bar"
                                        ? isSports = value!
                                        : "";
          });
          if (value == true) {
            try {
              EasyLoading.show();
              FirebaseFirestore.instance.collection("Club").doc(uid()).update({
                "category": FieldValue.arrayUnion([title])
              }).whenComplete(() {
                getCurrentClub().whenComplete(() {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(msg: "Changes successfully applied");
                });
              });
            } catch (e) {
              Fluttertoast.showToast(msg: "Something went wrong.");
            }
          } else {
            try {
              EasyLoading.show();
              FirebaseFirestore.instance.collection("Club").doc(uid()).update({
                "category": FieldValue.arrayRemove([title])
              }).whenComplete(() {
                getCurrentClub().whenComplete(() {
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(msg: "Changes successfully applied");
                  setState(() {});
                });
              });
            } catch (e) {
              Fluttertoast.showToast(msg: "Something went wrong.");
            }
          }
        });
    if (dropdownCity == "Other") {
      setState(() {
        dialogOther = true;
      });
    } else {
      setState(() {
        _otherCity.text = "";
        dialogOther = false;
      });
    }
    List stateCity = getStateCity(dropdownState);

    List<String> itemsCity = [
      "Select City",
      ...stateCity,
      stateCity.contains(dropdownCity) == true || dropdownCity == "Select City"
          ? ""
          : dropdownCity
    ];
    return Scaffold(
      key: _key,
      appBar: appBar(context, title: "Edit Details", key: _key),
      drawer: drawer(context: context),
      backgroundColor: matte(),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
              child: Column(
            children: [
              SizedBox(
                height: 50.h,
              ),
              GestureDetector(
                onTap: () {
                  editProfileImage();
                },
                child: Obx(
                  () => Container(
                    height: 300.h,
                    width: 300.h,
                    decoration: const BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    child: homeController.profileLogo.value != ""
                        ? CircleAvatar(
                            radius: 150.h,
                            backgroundColor: Colors.transparent,
                            backgroundImage: CachedNetworkImageProvider(
                                homeController.profileLogo.value),
                            onBackgroundImageError: (_, __) => [
                              Container(
                                height: 300.h,
                                width: 300.h,
                                color: Colors.white,
                                child: Image.asset(
                                  "assets/profile.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          )
                        : CircleAvatar(
                            radius: 150.h,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                const AssetImage("assets/profile.png"),
                            onBackgroundImageError: (_, __) => [
                              Container(
                                height: 300.h,
                                width: 300.h,
                                color: Colors.white,
                                child: Image.asset(
                                  "assets/profile.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                  ),
                ).marginAll(20.h),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Tap on image to edit",
                style: GoogleFonts.ubuntu(fontSize: 42.sp, color: Colors.white),
              ),
              SizedBox(
                width: 200.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150.w,
                  ),
                  Obx(() => Text(
                      toBeginningOfSentenceCase(widget.isOrganiser
                              ? homeController.organiserName.value
                              : homeController.clubName.value) ??
                          "Loading",
                      style: GoogleFonts.roboto(
                          color:
                              // theme == "light" ? Colors.black :
                              Colors.white,
                          fontSize: 60.sp))).paddingOnly(bottom: 20.h),
                  editIcon(
                      context,
                      widget.isOrganiser ? "Name" : "clubName",
                      20,
                      widget.isOrganiser
                          ? homeController.organiserName.value
                          : homeController.clubName.value,
                      isName: true,
                      isEditOrganiser: true),
                ],
              ).paddingOnly(bottom: 100.h),
              if (!widget.isOrganiser)
                Column(
                  children: [
                    Card(
                        elevation: 10,
                        color: Colors.black,
                        shadowColor: Colors.white38,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: SizedBox(
                            width: 1200.w,
                            child: Obx(() => Column(
                                  children: [
                                    Row(
                                      children: [
                                        info("Address",
                                            homeController.address.value),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(context, "address", 30,
                                            homeController.address.value),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        info("Area", homeController.area.value),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(
                                          context,
                                          "area",
                                          30,
                                          homeController.area.value,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        info("Landmark",
                                            homeController.landmark.value),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(
                                          context,
                                          "landmark",
                                          30,
                                          homeController.landmark.value,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        info("Description",
                                            homeController.description.value),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(context, "description", 500,
                                            homeController.description.value),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        info(
                                          "Open Time",
                                          homeController.openTime.value,
                                        ),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(context, "openTime", 20,
                                            homeController.openTime.value,
                                            isTime: true),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        info("Close Time",
                                            homeController.closeTime.value),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(context, "closeTime", 20,
                                            homeController.closeTime.value,
                                            isTime: true),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        info(
                                          "Average Cost",
                                          homeController.avgCost.value,
                                        ),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(context, "averageCost", 20,
                                            homeController.avgCost.value,
                                            isNum: true, isAmount: true),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        info("Pin Code",
                                            homeController.pinCode.value),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(context, "pinCode", 6,
                                            homeController.pinCode.value,
                                            isNum: true),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        info("Gst",
                                            homeController.gst.value),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(context, "gst", 20,
                                            homeController.gst.value,
                                            isNum: false),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        info("Description",
                                            homeController.description.value),
                                        SizedBox(
                                          width: 20.w,
                                        ),
                                        editIcon(context, "description", 20,
                                            homeController.description.value,
                                            isNum: false),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        EasyLoading.show();
                                        await getGeoLocationPosition()
                                            .then((value) {
                                          EasyLoading.dismiss();
                                          Get.defaultDialog(
                                              title: "Are you sure?",
                                              content: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            EasyLoading.show();
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "Club")
                                                                .doc(uid())
                                                                .update({
                                                              "latitude": value
                                                                  .latitude,
                                                              "longitude": value
                                                                  .longitude
                                                            }).whenComplete(() {
                                                              getCurrentClub();
                                                              Get.back();
                                                              EasyLoading
                                                                  .dismiss();
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          "Updated successfully");
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons.check,
                                                            color: Colors.green,
                                                          )),
                                                      const Text("Yes")
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            Get.back();
                                                          },
                                                          icon: const Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          )),
                                                      const Text("No")
                                                    ],
                                                  )
                                                ],
                                              ));
                                        });
                                      },
                                      style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.resolveWith(
                                                  (states) => Colors.orange)),
                                      child: const Text(
                                          "Update Club Geo Coordinates"),
                                    ),
                                    Container(
                                      height: 130.h,
                                      width: 800.w,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: Center(
                                        child: DropdownButton<String>(
                                          alignment: Alignment.center,
                                          items: states
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              alignment: Alignment.center,
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? val) {
                                            setState(() {
                                              dropdownState = val!;
                                              dropdownCity = "Select City";
                                            });
                                            Fluttertoast.showToast(
                                                msg: "Select city to continue");
                                          },
                                          value: dropdownState,
                                          style: const TextStyle(
                                              color: Colors.white70),
                                          dropdownColor: Colors.black,
                                        ),
                                      ),
                                    ).marginOnly(
                                        left: 30.w,
                                        right: 30.w,
                                        bottom: 30.h,
                                        top: 20.h),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Container(
                                      height: 130.h,
                                      width: 800.w,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey)),
                                      child: Center(
                                        child: DropdownButton<String>(
                                          alignment: Alignment.center,
                                          items: (itemsCity)
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              alignment: Alignment.center,
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? val) {
                                            setState(() {
                                              dropdownCity = val!;
                                            });
                                            dropdownCity != "Other" &&
                                                    dropdownCity !=
                                                        "Select City"
                                                ? Get.defaultDialog(
                                                    title: "Change City",
                                                    content: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            IconButton(
                                                                onPressed: () {
                                                                  if (dropdownCity !=
                                                                          "Select City" ||
                                                                      dropdownCity !=
                                                                          "Other") {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "Club")
                                                                        .doc(
                                                                            uid())
                                                                        .set({
                                                                      "state":
                                                                          dropdownState,
                                                                      "city":
                                                                          dropdownCity
                                                                    }, SetOptions(merge: true)).whenComplete(
                                                                            () {
                                                                      getCurrentClub();
                                                                      Get.back();
                                                                      Fluttertoast.showToast(
                                                                              msg:
                                                                                  "Updated Successfully")
                                                                          .whenComplete(() =>
                                                                              setState(() {}));
                                                                    });
                                                                  } else {
                                                                    Get.back();
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                "Enter a valid city");
                                                                  }
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .green,
                                                                )),
                                                            const Text("Yes"),
                                                          ],
                                                        ),
                                                        Column(
                                                          children: [
                                                            IconButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .red,
                                                                )),
                                                            const Text("No"),
                                                          ],
                                                        )
                                                      ],
                                                    ))
                                                : Container();
                                          },
                                          value: dropdownCity,
                                          style: const TextStyle(
                                              color: Colors.white70),
                                          dropdownColor: Colors.black,
                                        ),
                                      ),
                                    ).marginOnly(
                                        left: 30.w,
                                        right: 30.w,
                                        bottom: 30.h,
                                        top: 20.h),
                                    dialogOther == true
                                        ? ElevatedButton(
                                            onPressed: () {
                                              showDialog<void>(
                                                context: context,
                                                // false = user must tap button, true = tap outside dialog
                                                builder: (BuildContext
                                                    dialogContext) {
                                                  return AlertDialog(
                                                      title: const Text(
                                                          "Enter City name"),
                                                      content: SizedBox(
                                                        height: 300.0,
                                                        width: 300.0,
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              TextField(
                                                                controller:
                                                                    _otherCity,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        labelText:
                                                                            "Enter city name"),
                                                              ).marginSymmetric(
                                                                  horizontal:
                                                                      50.w),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  if (_otherCity
                                                                      .text
                                                                      .isEmpty) {
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                "Enter a valid city name");
                                                                  } else {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "Club")
                                                                        .doc(
                                                                            uid())
                                                                        .set({
                                                                      "state":
                                                                          dropdownState,
                                                                      "city":
                                                                          _otherCity
                                                                              .text
                                                                    }, SetOptions(merge: true)).whenComplete(
                                                                            () {
                                                                      getCurrentClub();
                                                                      Get.back();
                                                                      Fluttertoast.showToast(
                                                                              msg:
                                                                                  "Updated Successfully")
                                                                          .whenComplete(() =>
                                                                              setState(() {}));
                                                                    });
                                                                  }
                                                                },
                                                                style: ButtonStyle(
                                                                    backgroundColor:
                                                                        WidgetStateProperty.resolveWith((states) =>
                                                                            Colors.green)),
                                                                child: const Text(
                                                                    "Continue"),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    dropdownCity =
                                                                        "Select City";
                                                                    dialogOther =
                                                                        false;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                style: ButtonStyle(
                                                                    backgroundColor:
                                                                        WidgetStateProperty.resolveWith((states) =>
                                                                            Colors.red)),
                                                                child: const Text(
                                                                    "Cancel"),
                                                              ),
                                                            ]),
                                                      ));
                                                },
                                              );
                                            },
                                            style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStateProperty
                                                        .resolveWith((states) =>
                                                            Colors.black)),
                                            child:
                                                const Text("Choose Other City"),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Text(
                                      "Category",
                                      style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 55.sp,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.fade,
                                    ),
                                    SizedBox(
                                      width: 150.w,
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                    Column(
                                      children: [
                                        checkBox("Club", isClub),
                                        checkBox("Lounge", isLounge),
                                        checkBox("Roof Top", isRoof),
                                        checkBox("Concert Venue", isConcert),
                                        checkBox("Day Club", isDayClub),
                                        checkBox("Night Club", isNightClub),
                                        checkBox("Sports Bar", isSports),
                                      ],
                                    ),
                                  ],
                                ).marginSymmetric(
                                    vertical: 50.h, horizontal: 30.w)))),
                    SizedBox(height: 50.h),
                    SizedBox(
                      height: 30.h,
                    ),
                  ],
                ),
            ],
          ))),
    );
  }

  Future _takeProfilePicture() async {
    var pickedFile = await picker.pickImage(
        source: ImageSource.camera, maxHeight: 480, maxWidth: 640);

    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future _selectProfilePicture() async {
    var pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);

    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _uploadProfilePicture() async {
    EasyLoading.show();
    // ignore: non_constant_identifier_names
    final Reference ref = FirebaseStorage.instance
        .ref()
        .child('Club/${uid()}/${uid()}_profileLogo.jpg');
    final UploadTask uploadTask = ref.putFile(_image);

    // ignore: non_constant_identifier_names
    try {
      await uploadTask.then((taskSnapShot) async {
        var photoUrl = await taskSnapShot.ref.getDownloadURL();

        FirebaseAuth.instance.currentUser
            ?.updatePhotoURL(photoUrl)
            .whenComplete(() => EasyLoading.dismiss())
            .whenComplete(() {
          FirebaseFirestore.instance.collection("Club").doc(uid()).set(
              {"logo": photoUrl}, SetOptions(merge: true)).whenComplete(() {
            Get.back();
            getCurrentClub();
            Fluttertoast.showToast(msg: 'Profile Picture updated');
          });
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

  Future<void> _selectAndUploadPicture() async {
    try {
      await _selectProfilePicture();
      await _uploadProfilePicture();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Something went wrong.',
      );
    }
  }

  void _takeAndUploadPicture() async {
    try {
      await _takeProfilePicture();
      await _uploadProfilePicture();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Something went wrong.',
      );
    }
  }
}
