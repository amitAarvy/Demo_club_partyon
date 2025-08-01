import 'package:club/authentication/facebook/facebook_controller.dart';
import 'package:club/authentication/login_page.dart';
import 'package:club/screens/insta-analytics/view_file/instagram_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class FacebookLoginView extends StatefulWidget {
  const FacebookLoginView({super.key});

  @override
  State<FacebookLoginView> createState() => _FacebookLoginViewState();
}

class _FacebookLoginViewState extends State<FacebookLoginView> {
  String theme = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          colorBack(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/fb_login.jpg',
                fit: BoxFit.fill,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 800.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // 'Connect Facebook',
                    'Connect Account',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 90.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 40.w,
                  ),
                ],
              ),
              SizedBox(
                height: 40.h,
              ),
              ElevatedButton.icon(
                iconAlignment: IconAlignment.start,
                icon: Icon(
                  FontAwesomeIcons.instagram,
                  size: 70.h,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if ((await FacebookController.accessToken()) != null) {
                    Get.to(const InstagramView());
                  } else {
                    FacebookController.signInWithFB();
                  }
                },
                style: ButtonStyle(
                    padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h)),
                    backgroundColor: WidgetStateColor.resolveWith(
                        (states) => const Color(0xff5851DB))),
                label: Text(
                  'Connect Now',
                  style: TextStyle(fontSize: 60.sp),
                ),
              ),
            ],
          ),
          if (theme != "light") logoHead(isWeb: kIsWeb),
        ],
      ),
    );
  }
}
