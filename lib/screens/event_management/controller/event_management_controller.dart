import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as slider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';
import 'package:club/utils/app_utils.dart';

Future<void> uploadImage(
    List<File> images, String eventID, HomeController homeController,
    {required List coverImages,
    required DateTime startTime,
    required DateTime endTime,
    bool isOffer = false,
    bool isOrganiser = false}) async {
  var imageUrls = await Future.wait(images.map((image) async {
    String url = '';
    if (isOffer) {
      url = 'Events/$eventID/coverImage/coverImage${randomAlphaNumeric(4)}.jpg';
    } else {
      url = 'Events/$eventID/offerImage/offerImage${randomAlphaNumeric(4)}.jpg';
    }
    final Reference ref = FirebaseStorage.instance.ref().child(url);
    String downloadUrl = '';
    final UploadTask uploadTask = ref.putFile(image);
    await uploadTask.then((taskSnapShot) async {
      downloadUrl = await taskSnapShot.ref.getDownloadURL();
    });
    return downloadUrl;
  }));
  if (isOffer) {
    FirebaseAuth.instance.currentUser
        ?.updatePhotoURL(images.isNotEmpty ? imageUrls[0] : coverImages[0])
        .whenComplete(() {
      FirebaseFirestore.instance.collection("Events").doc(eventID).set(
          {'offerImages': images.isNotEmpty ? imageUrls : coverImages},
          SetOptions(merge: true)).whenComplete(() {
        if (!isOrganiser) {
          FirebaseFirestore.instance.collection("Club").doc(uid()).set({
            "eventOfferImages":
                images.isNotEmpty ? imageUrls[0] : coverImages[0],
          }, SetOptions(merge: true));
        }
      });
    });
  } else {
    FirebaseAuth.instance.currentUser
        ?.updatePhotoURL(images.isNotEmpty ? imageUrls[0] : coverImages[0])
        .whenComplete(() {
      FirebaseFirestore.instance.collection("Events").doc(eventID).set(
          {'coverImages': images.isNotEmpty ? imageUrls : coverImages},
          SetOptions(merge: true)).whenComplete(() {
        if (!isOrganiser) {
          FirebaseFirestore.instance.collection("Club").doc(uid()).set({
            "eventCoverImages":
                images.isNotEmpty ? imageUrls[0] : coverImages[0],
            'eventStartTime': startTime,
            'eventEndTime': endTime,
          }, SetOptions(merge: true));
        }
      });
    });
  }
}

Widget eventCarousel(List images, {bool isEdit = false, double? height}) =>
    slider.CarouselSlider(
        items: images.map((image) {
          print('image url is ${image}');
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 0.0),
                decoration: const BoxDecoration(color: Colors.amber),
                child: isEdit
                    ?
                CachedNetworkImage(
                        imageUrl: image,
                        errorWidget: (_, __, ___) {
                          return Center(
                              child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 300.h,
                          ));
                        },
                        fit: BoxFit.fill,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Image.file(
                        image!,
                        fit: BoxFit.fill,
                      ),
              );
            },
          );
        }).toList(),
        options: slider.CarouselOptions(
          // height: height ?? 400,
          aspectRatio: 9/16,
          viewportFraction: 1,
          initialPage: 0,
          enableInfiniteScroll: false,
          reverse: false,
          autoPlay: false,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          enlargeFactor: 0.3,
          scrollDirection: Axis.horizontal,
        ));

class EntranceData {
  final String categoryName;
  final List<Map<String, String>> subCategory;

  EntranceData(this.categoryName, this.subCategory);
}

Future<List> fetchEntranceDataDefault(String eventId,
    {bool isDefault = false, String clubID = ''}) async {
  final reference = FirebaseFirestore.instance
      .collection("Club")
      .doc(uid())
      .collection("DefaultEntry")
      .doc('default');

  final entranceSnapshot = await reference.get();

  final data = entranceSnapshot.data();
  return (data!['entranceList']) as List;

  final entranceDataList = await Future.wait(
    List.from(data['entranceList']).map((entranceData) async {
      final categoryName = entranceData['categoryName'] as String;

      final subCategory = List<Map<String, String>>.from(await Future.wait(
        (entranceData['subCategory'] as List<dynamic>)
            .map((subCategoryData) async {
          final entryCategoryName =
              subCategoryData['entryCategoryName'] as String;
          final totalCategoryEntry =
              subCategoryData['totalCategoryEntry'] as String;
          final entryCategoryPrice =
              subCategoryData['entryCategoryPrice'] as String;
          final categoryEntryLeft =
              subCategoryData.containsKey('categoryEntryLeft')
                  ? subCategoryData['categoryEntryLeft'] as String
                  : totalCategoryEntry;

          return {
            'entryCategoryName': entryCategoryName,
            'totalCategoryEntry': totalCategoryEntry,
            'entryCategoryPrice': entryCategoryPrice,
            'categoryEntryLeft': categoryEntryLeft,
          };
        }),
      ));

      return EntranceData(categoryName, subCategory);
    }),
  );

  return entranceDataList;
}

// Future<List<EntranceData>> fetchEntranceDataEdit(
//     String eventId, Map entranceData,
//     {bool isDefault = false, String clubID = ''}) async {
//   final entranceDataList = await Future.wait(
//     List.from(entranceData['entranceList']).map((entranceData) async {
//       final categoryName = entranceData['categoryName'] as String;
//
//       final subCategory = List<Map<String, String>>.from(await Future.wait(
//         (entranceData['subCategory'] as List<dynamic>)
//             .map((subCategoryData) async {
//           final entryCategoryName =
//               subCategoryData['entryCategoryName'].toString();
//           final totalCategoryEntry =
//               subCategoryData['entryCategoryCount'].toString();
//           final entryCategoryPrice =
//               subCategoryData['entryCategoryPrice'].toString();
//           final categoryEntryLeft =
//               subCategoryData.containsKey('categoryEntryLeft')
//                   ? subCategoryData['categoryEntryLeft'].toString()
//                   : totalCategoryEntry;
//
//           return {
//             'entryCategoryName': entryCategoryName,
//             'entryCategoryCount': totalCategoryEntry,
//             'entryCategoryPrice': entryCategoryPrice,
//             'categoryEntryLeft': categoryEntryLeft,
//           };
//         }),
//       ));
//
//       return EntranceData(categoryName, subCategory);
//     }),
//   );
//
//   return entranceDataList;
// }

class EventController extends GetxController {
  final _incVVIP = false.obs;
  final _incVIP = false.obs;
  final _incNormal = false.obs;
  final _includeTable = false.obs;
  final _includeEntrance = false.obs;
  final _includeNotes = false.obs;

  bool get incVVIP => _incVVIP.value;

  bool get incVIP => _incVIP.value;

  bool get incNormal => _incNormal.value;

  bool get includeTable => _includeTable.value;

  bool get includeEntrance => _includeEntrance.value;

  bool get includeNotes => _includeNotes.value;

  changeIncVVIP(bool val) {
    _incVVIP.value = val;
  }

  changeIncVIP(bool val) {
    _incVIP.value = val;
  }

  changeIncNormal(bool val) {
    _incNormal.value = val;
  }

  changeIncludeTable(bool val) {
    _includeTable.value = val;
  }

  changeIncludeNotes(bool val) {
    _includeNotes.value = val;
  }

  changeIncludeEntrance(bool val) {
    _includeEntrance.value = val;
  }
}

class TableTypesController extends GetxController {
  final tableTypes = 0.obs;

  incTypes() => ++tableTypes.value;

  decTypes() => --tableTypes.value;

  updateTypes(int val) => tableTypes.value = val;
}

class EntranceTypesController extends GetxController {
  final entranceTypes = 1.obs;

  incTypes() => ++entranceTypes.value;

  decTypes() => --entranceTypes.value;

  updateTypes(int val) => entranceTypes.value = val;
}

final entranceTypesController = Get.put(EntranceTypesController());

class EntranceCategoryController extends GetxController {
  final entranceCategoryTypes = List.generate(5, (index) => 1.obs);

  incTypes(int index) => ++entranceCategoryTypes[index].value;

  decTypes(int index) => --entranceCategoryTypes[index].value;

  updateTypes(int index, int val) => entranceCategoryTypes[index].value = val;
}
