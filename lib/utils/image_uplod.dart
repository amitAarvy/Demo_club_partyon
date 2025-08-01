import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/utils/crop_image.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({Key? key}) : super(key: key);

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final homeController = Get.put(HomeController());
  File? uploadCover, uploadLayout;
  final ImagePicker imagePicker = ImagePicker();
  int currentIndex = 0, menuIndex = 0;
  List<CroppedFile>? imageFileList = [];
  List<CroppedFile>? menuList = [];

  void selectImages({bool menu = false}) async {
    await imagePicker
        .pickMultiImage(maxHeight: 1080, maxWidth: 1920)
        .then((value) async {
      if (value.isNotEmpty) {
        for (var i in value) {
          await ImageCropper().cropImage(
            compressQuality: 100,
            sourcePath: (i.path).toString(),
            aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
            uiSettings: [
              AndroidUiSettings(
                  toolbarTitle: 'Cropper',
                  toolbarColor: Colors.black,
                  toolbarWidgetColor: Colors.white,
                  aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
                  initAspectRatio: CropAspectRatioPreset.ratio16x9,
                  lockAspectRatio: false),
              IOSUiSettings(
                title: 'Cropper',
                aspectRatioPresets: [CropAspectRatioPreset.ratio16x9],
              ),
            ],
          ).then((value) => menu == true
              ? menuList?.add(value!)
              : imageFileList?.add(value!));
        }
      }
    });

    setState(() {});
  }

  _getFromGallery(String file) async {
    await cropImage().then((value) {
      if (value != null) {
        setState(() {
          file == "cover"
              ? uploadCover = File((value.path).toString())
              : file == "layout"
                  ? uploadLayout = File((value.path).toString())
                  : null;
        });
      }
    });
  }

  Future<void> uploadImage(File image,
      {bool isCover = false, bool isLayout = false}) async {
    String url = isCover == true
        ? 'Club/${uid()}/coverImage/coverImage.jpg'
        : isLayout == true
            ? 'Club/${uid()}/layoutImage/layoutImage.jpg'
            : "";
    final Reference ref = FirebaseStorage.instance.ref().child(url);
    final UploadTask uploadTask = ref.putFile(image);

    // ignore: non_constant_identifier_names
    try {
      await uploadTask.then((taskSnapShot) async {
        var photoUrl = await taskSnapShot.ref.getDownloadURL();

        FirebaseAuth.instance.currentUser
            ?.updatePhotoURL(photoUrl)
            .whenComplete(() {
          FirebaseFirestore.instance.collection("Club").doc(uid()).set({
            isCover == true
                ? "coverImage"
                : isLayout == true
                    ? "layoutImage"
                    : "": photoUrl
          }, SetOptions(merge: true));
        });
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "An unknown error occurred.Please try again");
      if (kDebugMode) {
        print(e);
      }
      EasyLoading.dismiss();
    }
  }

  Future<List<String>> uploadFiles(List<File> images,
      {bool menu = false}) async {
    var imageUrls =
        await Future.wait(images.map((image) => uploadFile(image, menu: menu)));
    if (kDebugMode) {
      print(imageUrls);
    }
    return imageUrls;
  }

  Future<String> uploadFile(File image, {bool menu = false}) async {
    final Reference storageReference = FirebaseStorage.instance.ref().child(
        'Club/${FirebaseAuth.instance.currentUser?.uid}/${menu == true ? "menuImages" : "galleryImages"}/${randomAlphaNumeric(8)}');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() {
      if (kDebugMode) {
        print("upload2");
      }
    });

    return await storageReference.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: "Images Upload"),
      backgroundColor: matte(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Obx(() => Container(
                        height: (Get.width - 100.w) * 9 / 16,
                        width: Get.width - 100.w,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: uploadCover != null
                            ? Image.file(
                                uploadCover!,
                                fit: BoxFit.cover,
                              )
                            : homeController.coverImage.value.isNotEmpty &&
                                    homeController.coverImage.value.isNotEmpty
                                ? Obx(() => CachedNetworkImage(
                                      imageUrl: homeController.coverImage.value,
                                      placeholder: (_, __) => const Center(
                                          child: CircularProgressIndicator()),
                                      fit: BoxFit.fill,
                                    ))
                                : Center(
                                    child: Icon(
                                    Icons.image,
                                    color: Colors.white,
                                    size: 300.h,
                                  )))
                    .marginAll(20)),
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
              child: const Text("Upload Cover Image"),
            ),
            Stack(
              children: [
                Container(
                  height: 600.h,
                  width: Get.width - 100.w,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: uploadLayout == null
                      ? Center(
                          child: Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 300.h,
                        ))
                      : Image.file(
                          uploadLayout!,
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
                              uploadLayout = null;
                            });
                          },
                        ),
                      ),
                    )).marginOnly(top: 75.h, right: 75.w)
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                _getFromGallery("layout");

                //FirebaseStorage.instance.refFromURL("https://firebasestorage.googleapis.com/v0/b/partyon-artist.appspot.com/o/Club%2FqPDyKDM73TVsmAIIFGKva8DSiXG3%2FgalleryImages%2FO35Ei4X3?alt=media&token=d89c01c3-a728-4573-b1fa-4fefb93d71ad").delete();
              },
              style: ButtonStyle(
                  shape: WidgetStateProperty.resolveWith((states) =>
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.black)),
              child: const Text("Upload Club Layout"),
            ),
            menuList!.isNotEmpty
                ? Container(
                    height: 600.h,
                    width: Get.width - 100.w,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Center(
                        child: Image.file(
                      File((menuList?[menuIndex].path).toString()),
                      fit: BoxFit.cover,
                    )),
                  ).marginAll(20)
                : Container(),
            SizedBox(
              height: 50.h,
            ),
            SizedBox(
              height: menuList!.isNotEmpty ? 250.h : 600.h,
              width: Get.width - 100.w,
              child: Padding(
                padding: EdgeInsets.all(8.h),
                child: menuList!.isNotEmpty
                    ? GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: menuList!.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1),
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    menuIndex = index;
                                  });
                                },
                                child: SizedBox(
                                  height: 300.h,
                                  width: 16 / 9 * 300.h,
                                  child: Image.file(
                                    File(menuList![index].path),
                                    fit: BoxFit.cover,
                                  ).marginAll(5.h),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  height: 75.h,
                                  width: 75.h,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        size: 35.h,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          setState(() {
                                            menuIndex = 0;
                                          });
                                          menuList!.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ).marginOnly(bottom: 20.h)
                            ],
                          );
                        })
                    : Container(
                        height: (Get.width - 100.w) * 9 / 16,
                        width: Get.width - 100.w,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: Center(
                            child: Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 300.h,
                        )),
                      ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                selectImages(menu: true);
              },
              style: ButtonStyle(
                  shape: WidgetStateProperty.resolveWith((states) =>
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.black)),
              child: const Text('Upload Menu Images'),
            ).marginAll(20.h),
            imageFileList!.isNotEmpty
                ? Container(
                    height: 600.h,
                    width: Get.width - 100.w,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Center(
                        child: Image.file(
                      File((imageFileList?[currentIndex].path).toString()),
                      fit: BoxFit.cover,
                    )),
                  ).marginAll(20)
                : Container(),
            SizedBox(
              height: 50.h,
            ),
            SizedBox(
              height: imageFileList!.isNotEmpty ? 250.h : 600.h,
              width: Get.width - 100.w,
              child: Padding(
                padding: EdgeInsets.all(8.h),
                child: imageFileList!.isNotEmpty
                    ? GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageFileList!.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1),
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentIndex = index;
                                  });
                                },
                                child: SizedBox(
                                  height: 300.h,
                                  width: 16 / 9 * 300.h,
                                  child: Image.file(
                                    File(imageFileList![index].path),
                                    fit: BoxFit.cover,
                                  ).marginAll(5.h),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  height: 75.h,
                                  width: 75.h,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        size: 35.h,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          setState(() {
                                            currentIndex = 0;
                                          });
                                          imageFileList!.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ).marginOnly(bottom: 20.h)
                            ],
                          );
                        })
                    : Container(
                        height: (Get.width - 100.w) * 9 / 16,
                        width: Get.width - 100.w,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)),
                        child: Center(
                            child: Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 300.h,
                        )),
                      ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                selectImages();
              },
              style: ButtonStyle(
                  shape: WidgetStateProperty.resolveWith((states) =>
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.black)),
              child: const Text('Upload Gallery Images'),
            ).marginAll(20.h),
            ElevatedButton(
              onPressed: () async {
                if (imageFileList?.isNotEmpty == true ||
                    uploadCover != null ||
                    uploadLayout != null ||
                    menuList?.isNotEmpty == true) {
                  try {
                    if (uploadCover != null) {
                      EasyLoading.show();
                      uploadImage(uploadCover!, isCover: true).then((value) =>
                          getCurrentClub()
                              .whenComplete(() => EasyLoading.dismiss()));
                    }
                    if (uploadLayout != null) {
                      EasyLoading.show();
                      uploadImage(uploadLayout!, isLayout: true)
                          .whenComplete(() => EasyLoading.dismiss());
                    }

                    if (menuList?.isNotEmpty == true) {
                      EasyLoading.show();
                      List<File> imageFiles = [];

                      for (var i in menuList!) {
                        imageFiles.add(File(i.path));
                      }
                      List<String> imagesURL =
                          await uploadFiles(imageFiles, menu: true);

                      FirebaseFirestore.instance
                          .collection("Club")
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .set({"menuImages": FieldValue.arrayUnion(imagesURL)},
                              SetOptions(merge: true)).whenComplete(() {
                        EasyLoading.dismiss();
                      });
                    }

                    if (imageFileList?.isNotEmpty == true) {
                      int countImage = 0;
                      await FirebaseFirestore.instance
                          .collection("Club")
                          .doc(uid())
                          .get()
                          .then((value) {
                        if (value.exists) {
                          List img = value["galleryImages"] ?? [];
                          setState(() {
                            countImage = img.length;
                            if (kDebugMode) {
                              print("count image $countImage");
                            }
                          });
                        }
                      });
                      if (countImage <= 50) {
                        EasyLoading.show();

                        if (imageFileList?.isNotEmpty == true) {
                          List<File> imageFiles = [];

                          for (var i in imageFileList!) {
                            imageFiles.add(File(i.path));
                          }
                          List<String> imagesURL =
                              await uploadFiles(imageFiles);

                          FirebaseFirestore.instance
                              .collection("Club")
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .set({
                            "galleryImages": FieldValue.arrayUnion(imagesURL)
                          }, SetOptions(merge: true)).whenComplete(() {
                            EasyLoading.dismiss();
                          });
                        }
                      } else {
                        Fluttertoast.showToast(
                            msg:
                                "You cannot upload more than 50 gallery images");
                      }
                    }
                    Fluttertoast.showToast(msg: "Uploaded Successfully");
                    Get.back();
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Something went wrong");
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "Select at least one image to upload");
                }
              },
              style: ButtonStyle(
                  shape: WidgetStateProperty.resolveWith((states) =>
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.orange)),
              child: const Text('Save'),
            ).marginAll(10.h),
          ],
        ),
      ),
    );
  }
}
