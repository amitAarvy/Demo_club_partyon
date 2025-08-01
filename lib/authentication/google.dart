import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/authentication/login_page.dart';
import 'package:club/screens/home/InfluencerHome.dart';
import 'package:club/screens/home/home.dart';
import 'package:club/screens/organiser/home/organiser_home.dart';
import 'package:club/screens/sign_up/init_signup_details.dart';
import 'package:club/screens/sign_up/select_business_category.dart';
import 'package:club/screens/signup_organiser/signup_organiser_view.dart';
import 'package:club/utils/app_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/home/homeBar.dart';
import '../screens/organiser/home/organiser_homeBar.dart';

Future<UserCredential> signInWithGoogle() async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;

    await GoogleSignIn().signOut();

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential = await auth.signInWithCredential(credential);

    print('chekc google creditation ${userCredential}');
    onSingInSuccess(userCredential);

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e, s) {
    debugPrint(e.toString());
    debugPrintStack(stackTrace: s);
    rethrow;
  }
}

void onSingInSuccess(UserCredential userCredential) async {

  print('chekck it is ${userCredential}');
  if (userCredential.user != null) {
    FirebaseFirestore.instance
        .collection("Club")
        .where("clubUID", isEqualTo: userCredential.user?.uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        if (kIsWeb) {
          FirebaseAuth.instance.signOut();
          Get.offUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false);
          Fluttertoast.showToast(
              msg: 'Given gmail is already registered as Venue');
        } else {
          saveBusinessType("club");
          Get.off(() => const HomeBar());
        }
      }else {
        FirebaseFirestore.instance
            .collection("Organiser")
            .where("organiserID", isEqualTo: userCredential.user?.uid)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            print("mainlog  2222 1");
            if (kIsWeb) {
              FirebaseAuth.instance.signOut();
              Get.offUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false);
              Fluttertoast.showToast(
                  msg: 'Given gmail is already registered as Promoter');
            } else {
              saveBusinessType("organiser");
              Get.off(() => const OrganiserHomeBar());
            }
          } else {
            FirebaseFirestore.instance
                .collection("Influencer").doc(userCredential.user?.uid)
                .get()
                .then((value) async {
                   print('influencer exists ${value.exists}') ;
                   print('influencer id ${value.id}');
              if (value.exists) {
                print("mainlog  2222 2");
                if (kIsWeb) {
                  FirebaseAuth.instance.signOut();
                  Get.offUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false);
                  Fluttertoast.showToast(
                      msg: 'Given gmail is already registered as Influencer');
                } else {
                  saveBusinessType("influencer");
                  Get.off(const InfluencerHome());
                  print('InfluencerHome called in GOOGLE');
                }
              } else {
                if (kIsWeb) {
                  String email = '';
                  String phone = '';
                  if (FirebaseAuth.instance.currentUser?.email?.isNotEmpty ==
                      true) {
                    email = FirebaseAuth.instance.currentUser?.email ?? '';
                  } else if (FirebaseAuth
                          .instance.currentUser?.phoneNumber?.isNotEmpty ==
                      true) {
                    phone =
                        FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
                  }
                  if (Uri.base.origin.contains('influencer.')) {
                    print(
                        'promoter base url : ${Uri.base.origin.contains('influencer.')}');
                    // final String? accountId = await Phyllo.getAccountIdFromPhyllo();
                      Get.off( const InfluencerHome());
                    // Phyllo.init();

                      print('User already logged in to influencer home');
                  } else if (Uri.base.origin.contains('promotor.')) {
                    print(
                        'promoter base url : ${Uri.base.origin.contains('promotor.')}');
                    Get.to(SignUpOrganiser(
                      email: email,
                      isPhone: phone.isNotEmpty,
                      phone: phone,
                    ));
                  } else if (Uri.base.origin.contains('venue.')) {
                    print(
                        'promoter base url : ${Uri.base.origin.contains('venue.')}');

                    Get.to(SignUpVenue(
                      email: email,
                      isPhone: phone.isNotEmpty,
                      phone: phone,
                    ));
                  }
                  else {
                    print('InitSignupDetails called on google 1');
                    Get.off(const InitSignupDetails());
                  }
                }
                else {
                  print('InitSignupDetails called on google 2');
                  Get.off(const InitSignupDetails());
                }
              }
            });
          }
        });
      }
    });
    // Phyllo.getSDKTokenById();
  }
  print('userCredential is null');
}
