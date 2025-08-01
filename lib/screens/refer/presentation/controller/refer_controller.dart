import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/authentication/login_page.dart';
import 'package:club/core/app_const/hive_const.dart';
import 'package:club/dynamic_link/dynamic_link.dart';
import 'package:club/local_db/hive_db.dart';
import 'package:club/screens/refer/data/models/refer_model.dart';
import 'package:club/screens/refer/presentation/views/widgets/refer_bottomsheet.dart';
import 'package:club/utils/app_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';



//Refers Earnings
class ReferController extends GetxController {
  static Future<String> generateCouponCode() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    String couponCode = '';
    final String? email = user?.email;
    final String uid;
    if (user != null) {
      if (email != null && email.isNotEmpty) {
        final String emailIdentifier = email.substring(0, min(4, email.length));
        final String randomNumber = Random().nextInt(100).toString();
        couponCode = '$emailIdentifier$randomNumber';
      } else {
        uid = user.uid;
        final String uidCode = uid.substring(0, min(4, uid.length));
        final String randomNumber = Random().nextInt(100).toString();
        couponCode = '$uidCode$randomNumber';
      }
    } else {
      Fluttertoast.showToast(msg: 'No user found. Login to Continue');
      Get.to(const LoginPage());
    }
    return couponCode;
  }

  static Future<List<ReferModel>> getReferList() async {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('Refer').doc(uid).get();
    if (documentSnapshot.exists) {
      var referListData = getKeyValueFirestore(documentSnapshot, 'referList') ?? [];
      String data = jsonEncode(referListData);
      return ((jsonDecode(data) ?? []) as List)
          .map((e) => ReferModel.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }

  static Future<String> referralLinkMessage(String referURL) async {
    String referType = await getReferCollectionName();
    if (referType == 'organiser') {
      return "Let's set the vibe together! Join me on #PartyOn to connect, create, and amplify every event. Let's build the ultimate party experience! $referURL";
    } else if (referType == 'club' || referType == 'venue') {
      return "Get ready to elevate the scene! Join #PartyOn and connect with the best venues around. Let's make every event unforgettable—together! $referURL";
    } else if (referType == 'influencer') {
      return "Take your events to the next level! Join me on #PartyOn and connect with a network that's ready to amplify your reach. Let's create unforgettable moments! $referURL";
    } else {
      return " $referURL";
    }
  }

  static Future<String> getReferredById() async {
    Box box = await HiveDB.openBox();
    final Map referMap = await HiveDB.getKey(box, HiveConst.referMap) ?? {};
    if (referMap.isNotEmpty && referMap.containsKey("referId")) {
      return referMap["referId"];
    } else {
      return "";
    }
  }

  static Future<void> updateReferral(String businessType, String name) async {
    Box box = await HiveDB.openBox();
    final Map referMap = await HiveDB.getKey(box, HiveConst.referMap) ?? {};
    if (referMap.isNotEmpty && referMap.containsKey("uid")) {
      FirebaseFirestore.instance.collection("Refer").doc(referMap["uid"]).set({
        "referList": FieldValue.arrayUnion([
          {
            "name": name,
            "type": businessType,
            "uid": FirebaseAuth.instance.currentUser?.uid ?? '',
            "date": DateFormat('yyyy-MM-dd').format(DateTime.now())
          }
        ])
      }, SetOptions(merge: true));
    }
  }

  static Future<void> onSaveCouponCode(String couponCode) async {
    String collectionName = (await getReferCollectionName()).toUpperFirst();
    await FirebaseFirestore.instance.collection(collectionName).doc(uid()).set(
      {
        "couponCode": couponCode,
      },
      SetOptions(merge: true),
    ).onError((e, s) {
      print(e);
    });
  }

  static void onTapReferButton() async {
    String collectionName = (await getReferCollectionName()).toUpperFirst();
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(uid())
        .get();
    
    // Convert DocumentSnapshot data to a serializable format
    Map<String, dynamic> data = {};
    if (documentSnapshot.exists) {
      Map<String, dynamic> originalData = documentSnapshot.data() as Map<String, dynamic>;
      originalData.forEach((key, value) {
        if (value is Timestamp) {
          data[key] = value.toDate().toIso8601String();
        } else {
          data[key] = value;
        }
      });
    }
    
    String couponCode = '';
    if (data.containsKey('couponCode')) {
      couponCode = data['couponCode'];
    } else {
      couponCode = await generateCouponCode();
    }

    if (data.containsKey('referralLink')) {
      Get.bottomSheet(ReferBottomSheet(
        referURL: data['referralLink'],
        isEditableCode: !data.containsKey('couponCode'),
        couponCode: couponCode,
      ));
    } else {
      String referralId = data["referralId"] ?? randomAlphaNumeric(8);
      final String referralLink =
          await FirebaseDynamicLinkEvent.createReferLink(
        referId: referralId,
        uid: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      FirebaseFirestore.instance.collection(collectionName).doc(uid()).set(
        {
          "referralLink": referralLink,
          "referralId": referralId,
        },
        SetOptions(merge: true),
      );

      Get.bottomSheet(ReferBottomSheet(
        referURL: referralLink,
        isEditableCode: !data.containsKey('couponCode'),
        couponCode: couponCode,
      ));
    }
  }

  static Future<String> getReferCollectionName() async {
    Box box = await HiveDB.openBox();
    final key = await HiveDB.getKey(box, HiveConst.businessType);
    return key;
  }
}
