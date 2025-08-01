import 'package:club/authentication/phyllo_integration/pyllo_init.dart';
import 'package:club/screens/sign_up/select_business_category.dart';
import 'package:club/utils/app_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:club/screens/signup_organiser/signup_organiser_view.dart';

import '../promoter_onboarding/onboarding.dart';
import '../signUp_influencer/SignUpInfluencer.dart';
import '../venue_onboarding/onboarding_page.dart';


class InitSignupDetails extends StatefulWidget {
  const InitSignupDetails({Key? key}) : super(key: key);

  @override
  State<InitSignupDetails> createState() => _InitSignupDetailsState();
}

class _InitSignupDetailsState extends State<InitSignupDetails> {
  String email = '';
  String phone = '';
  bool isLoading = true;

  void getEmailPhone() {
    if (FirebaseAuth.instance.currentUser?.email?.isNotEmpty == true) {
      email = FirebaseAuth.instance.currentUser?.email ?? '';
    } else if (FirebaseAuth.instance.currentUser?.phoneNumber?.isNotEmpty ==
        true) {
      phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
    }
    setState(() {});
  }

  @override
  void initState() {
    getEmailPhone();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: matte(),
      appBar: appBar(context, title: 'Choose Category', showBack: false),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    saveBusinessType("club");
                    Get.to(OnBoardingVenue(email: email,isPhone: phone.isNotEmpty,phone:phone));
                    // Get.to(SignUpVenue(
                    //   email: email,
                    //   isPhone: phone.isNotEmpty,
                    //   phone: phone,
                    // ));
                  },
                  child: Image.asset(
                    'assets/venues.jpeg',
                    fit: BoxFit.fill,
                  )),
            ),
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    saveBusinessType("organiser");


                    Get.to(OnBoardingPromoter(email: email,isPhone: phone.isNotEmpty,phone:phone));

                    // Get.to(SignUpOrganiser(
                    //   email: email,
                    //   isPhone: phone.isNotEmpty,
                    //   phone: phone,
                    // ));
                  },
                  child: Image.asset(
                    'assets/organiser.jpeg',
                    fit: BoxFit.fill,
                  )),
            ),
            // Expanded(
            //   child: GestureDetector(
            //       onTap: () async {
            //         // saveBusinessType("influencer");
            //         // print('BusinessType saved');
            //         // // Get.off(Phyllo.init());
            //         // Phyllo.init();
            //         // print('Phylloinit called in INIT');
            //         Get.to(SignUpInfluencer(
            //           email: email,
            //           isPhone: phone.isNotEmpty,
            //           phone: phone,
            //         ));
            //       },
            //       child: Image.asset(
            //         'assets/influencer.jpeg',
            //         fit: BoxFit.fill,
            //       )),
            // )
          ],
        ),
      ),
    );
  }
}
