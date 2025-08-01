import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/core/app_const/hive_const.dart';
import 'package:club/local_db/hive_db.dart';
import 'package:club/screens/coupon_code/model/data/coupon_code_model.dart';
import 'package:club/utils/app_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

// save the coupon code info to the firebase
class CouponCodeController extends GetxController {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static String? uid = FirebaseAuth.instance.currentUser?.uid;
  final RxString _startDate = ''.obs;
  final RxString _endDate = ''.obs;

  String get startDate => _startDate.value;

  String get endDate => _endDate.value;

  set startDate(String value) => _startDate.value = value;

  set endDate(String value) => _endDate.value = value;

  static Future<void> saveCouponToFirebase(
      String couponCategory,
      String validFrom,
      String validTill,
      String couponCode,
      String discount) async {
    String? type = await getBusinessType();
    if (uid != null) {
      Map couponData = {
        'uid': uid,
        'couponCategory': couponCategory,
        'couponCode': couponCode,
        'discount': discount,
        'type': type,
        'validFrom': validFrom,
        'validTill': validTill,
      };
      try {
        if (couponCategory == 'Entry Management') {
          await firestore.collection('CouponCode').doc(uid).set({
            'entryManagement': FieldValue.arrayUnion([couponData]),
          }, SetOptions(merge: true)).then((_) {
            debugPrint('Entry Management Document Stored Successfully');
          }).catchError((e) {
            debugPrint('Could Not Store Entry Management Document: $e');
          });
        } else if (couponCategory == 'Table Management') {
          await firestore.collection('CouponCode').doc(uid).set({
            'tableManagement': FieldValue.arrayUnion([couponData]),
          }, SetOptions(merge: true)).then((_) {
            debugPrint('Event Management Document Stored');
          }).catchError((e) {
            debugPrint('Could Not Store Event: $e');
          });
        } else {
          debugPrint('Unknown category: $couponCategory');
        }
      } catch (e) {
        print("Error is $e");
      }
    }
  }

  // get the saved coupon code info from firebase
  static Future<List<CouponModel>> savedCouponCodes({String? venueId}) async {
    DocumentSnapshot documentSnapshot =
        await firestore.collection('CouponCode').doc(venueId??uid).get();

    if (documentSnapshot.exists) {
      List<CouponModel> coupons = [];
      dynamic entryData =
          getKeyValueFirestore(documentSnapshot, 'entryManagement');
      if (entryData != null) {
        String entryJson = jsonEncode(entryData);
        coupons.addAll(((jsonDecode(entryJson) ?? []) as List)
            .map((e) => CouponModel.fromJson(e))
            .toList());
      }
      dynamic eventData =
          getKeyValueFirestore(documentSnapshot, 'tableManagement');
      if (eventData != null) {
        String eventJson = jsonEncode(eventData);
        coupons.addAll(((jsonDecode(eventJson) ?? []) as List)
            .map((e) => CouponModel.fromJson(e))
            .toList());
      }

      return coupons;
    } else {
      print('Document does not exist!');
      return [];
    }
  }

  //apply the coupon code
  static Future<void> applyCouponCode(String couponCode, double amount) async {
    DocumentSnapshot documentSnapshot =
        await firestore.collection('CouponCode').doc(uid).get();
    if (documentSnapshot.exists) {
      List couponCodeList = documentSnapshot['couponCodeList'];
      print('couponCodeList: $couponCodeList ');

      bool couponExists =
          couponCodeList.any((e) => e['couponCode'].contains(couponCode));
      if (couponExists) {
        String discountPercent = couponCode.substring(couponCode.length - 2);
        double discount = (amount * (double.parse(discountPercent))) / 100;
        double discountedAmount = amount - discount;

        if (discountedAmount < 0) {
          discountedAmount = 0;
          print('Coupon applied! New amount: $discountedAmount');
        }
      }
    } else {
      Fluttertoast.showToast(msg: 'Opps! Coupon code does not exist!');
    }
  }

//get the type of the user
  static Future<String> getBusinessType() async {
    Box box = await HiveDB.openBox();
    String businessType =
        await HiveDB.getKey(box, HiveConst.businessType) ?? '';
    return businessType;
  }
}
