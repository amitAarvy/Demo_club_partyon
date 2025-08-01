// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:club/authentication/facebook/facebook_login.dart';
import 'package:club/screens/insta-analytics/view_file/instagram_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';


class FacebookController {
  static void signInWithFB() async {
    final LoginResult result = await FacebookAuth.instance.login(permissions: [
      'email',
      'instagram_basic',
      'instagram_manage_insights',
      'pages_read_engagement',
      'business_management'
    ]);
    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);
      try {
        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
      } catch (e) {
        debugPrint(e.toString());
      }
      Get.to(const InstagramView());
    } else {
      Fluttertoast.showToast(msg: 'Login Failed');
    }
  }


  static Future<String?> accessToken() async {
    AccessToken? accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null && !accessToken.isExpired)
      return accessToken.token;
    else {
      Get.to(const FacebookLoginView());
      return null;
    }
  }
}
