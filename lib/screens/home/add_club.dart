import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'club_model.dart';

Future<List<String>> addClub(BuildContext context) async {
  try {
    List<String> errorEmailList = [];
    FilePickerResult? filePickerResult =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (filePickerResult != null) {
      final input = File(filePickerResult.paths[0]!).openRead();
      final rowsAsListOfValues = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();
      print(rowsAsListOfValues);
      List keyList = rowsAsListOfValues.first.map((e) => e.toString()).toList();
      print(keyList);
      confirmationDialog(() async {
        Get.back();
        for (var data in rowsAsListOfValues) {
          try {
            final clubData = ClubModel(
                activeStatus: true,
                bookingActiveStatus: false,
                galleryImages: data[getKeyIndex(keyList, 'galleryImages')]
                        .toString()
                        .split(" ")
                        .toList() ??
                    [],
                closeTime: data[getKeyIndex(keyList, 'closeTime')].toString(),
                openTime: data[getKeyIndex(keyList, 'openTime')].toString(),
                relationAgreement: "",
                clubName: data[getKeyIndex(keyList, 'clubName')].toString(),
                clubUID: data[getKeyIndex(keyList, 'clubUID')].toString(),
                email: data[getKeyIndex(keyList, 'email')].toString(),
                clubID: "",
                category: [data[getKeyIndex(keyList, 'category')]],
                state: data[getKeyIndex(keyList, 'state')].toString(),
                coverImage:
                    data[getKeyIndex(keyList, 'coverImage')].toString() ?? "",
                logo: "",
                isClub: true,
                pplCert: "",
                description:
                    data[getKeyIndex(keyList, 'description')].toString(),
                city: data[getKeyIndex(keyList, 'city')].toString(),
                area: data[getKeyIndex(keyList, 'area')].toString(),
                date: DateTime.now(),
                gstCert: "",
                landmark: data[getKeyIndex(keyList, 'landmark')].toString(),
                latitude: double.tryParse(
                    data[getKeyIndex(keyList, 'latitude')].toString()),
                layoutImage: "",
                locality: data[getKeyIndex(keyList, 'locality')].toString(),
                longitude: double.tryParse(
                    data[getKeyIndex(keyList, 'longitude')].toString()),
                address: data[getKeyIndex(keyList, 'address')].toString(),
                averageCost: int.tryParse(
                    data[getKeyIndex(keyList, 'averageCost')].toString()),
                pinCode: data[getKeyIndex(keyList, 'pinCode')].toString());
            await FirebaseFirestore.instance
                .collection('Club')
                .doc(clubData.clubUID)
                .set(clubData.toJson());
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
            errorEmailList.add(data[getKeyIndex(keyList, 'email')]);
          }
        }
      }, title: 'Are you sure you want to add clubs from csv?');
    }
    return errorEmailList;
  } catch (e) {
    print(e);
    Fluttertoast.showToast(msg: "Something went wrong. Please try again");
    return [];
  }
}

int getKeyIndex(List keyList, String keyName) {
  return keyList.indexOf(keyName);
}

void confirmationDialog(Function() onTapYes, {String? title}) =>
    Get.defaultDialog(
        title: title ?? "Are you sure?",
        content: SizedBox(
            child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: () => onTapYes(),
                        icon: const Icon(FontAwesomeIcons.check)),
                    const Text("Yes"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.close)),
                    const Text("No")
                  ],
                )
              ],
            ),
          ],
        )));
