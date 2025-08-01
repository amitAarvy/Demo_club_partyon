import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/event_management/promotion_event_list.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../booking_management_promoter/booking_promotion.dart';
import '../../event_management/model/list_anaylsis_tabs.dart';
import '../../event_management/offers_and_promotions.dart';
import '../../pr_companies/Analystics/PromotionEventAnalytics.dart';
import '../../pr_companies/campaigns_page.dart';
import '../../refer/presentation/views/referal_earning.dart';
import '../event_management/offer_and_promotion_organiser/offer_and_promotion.dart';
import '../event_management/offer_promotion_list.dart';
import 'package:club/screens/refer/presentation/views/refer_page.dart';
import 'package:shared_preferences/shared_preferences.dart';



class OrganiserHome extends StatefulWidget {
  const OrganiserHome({Key? key}) : super(key: key);

  @override
  State<OrganiserHome> createState() => _OrganiserHomeState();
}

class _OrganiserHomeState extends State<OrganiserHome> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final homeController = Get.put(HomeController());
  int favCount = 0;

  @override
  void initState() {
    homeController.updateOrganiserName((FirebaseAuth.instance.currentUser?.displayName) ?? '');
    super.initState();
    fetchPlan();
    fetchEditEventsPromotion();
  }
String category = '';
  int followFount = 0;
  void fetchEditEventsPromotion() async {
    try {
      await FirebaseFirestore.instance
          .collection('Follow')
          .where('uid', isEqualTo: uid())
          .get()
          .then((value) {
        // if (value.exists) {
          int data = value.docs.length;
          setState(() {
            followFount = data;
          });
        // }
      });

      print('check follow count is ${followFount}');
      await FirebaseFirestore.instance
          .collection("Organiser")
          .doc(uid())
          .get()
          .then((doc) async {
        if (doc.exists) {
          category = getKeyValueFirestore(doc, 'businessCategory') ?? '';
          // instaUserName.text = getKeyValueFirestore(doc, 'instaUserName') ?? '';
          // promoterName.text = getKeyValueFirestore(doc, 'name') ?? '';
          // agencyName.text = getKeyValueFirestore(doc, 'companyMame') ?? '';
          // whatsappNumber.text = getKeyValueFirestore(doc, 'whatsaapNo') ?? '';
          // emailName.text = getKeyValueFirestore(doc, 'emailPhone') ?? '';
          // dropdownCity = getKeyValueFirestore(doc, 'city') ?? 'Select City';
          // dropdownState = getKeyValueFirestore(doc, 'state') ?? 'Andhra Pradesh';
          // // offerImage = getKeyValueFirestore(doc, 'profile_image') ?? [];
          // offerImage.add(getKeyValueFirestore(doc, 'profile_image'));
          setState(() {});
        } else {
          Fluttertoast.showToast(msg: "no data");
        }
      });
      // await getEntranceFieldValues();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  fetchPlan()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    QuerySnapshot data = await   FirebaseFirestore.instance
        .collection("BookingPlan")
        .where('id',
        isEqualTo: uid())
        .get();

    if(data.docs.isNotEmpty){
      print('check plan is ${data.docs[0]['planDetail']}');
      Map<String,dynamic> planData = data.docs[0]['planDetail'];
      pref.setString('planData',jsonEncode(planData) );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        key: _key,
        backgroundColor: matte(),
        appBar: appBar(context, title: "Home", showLogo: true, key: _key, showBack: false),
        drawer: drawer(isOrganiser: true,context: context),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Opacity(
                opacity: 0.2,
                child: SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/newLogo.png"),
                      SizedBox(
                        height: 200.h,
                      ),
                    ],
                  ),
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if(followFount!=0)
                    Text(
                      "$followFount",
                      style: GoogleFonts.ubuntu(
                          color: Colors.white, fontSize: 50.sp),
                    ),
                    if(followFount!=0)
                    SizedBox(
                      width: 30.w,
                    ),
                    if(followFount!=0)
                    Text(
                      "Follower",
                      style: GoogleFonts.ubuntu(
                          color: Colors.white, fontSize: 50.sp),
                    ),
                    if(followFount!=0)
                    SizedBox(
                      width: 30.w,
                    ),
                    const Icon(
                      FontAwesomeIcons.solidHeart,
                      color: Colors.pink,
                    ),
                    SizedBox(
                      width: 30.w,
                    ),
                    Text(
                      "$favCount",
                      style: GoogleFonts.ubuntu(
                          color: Colors.white, fontSize: 50.sp),
                    )
                  ],
                ).paddingSymmetric(horizontal: 50.w),
                SizedBox(
                  height: 10.h,
                ),
                if(category == '2')
                  ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        tile(
                            "Promotions",
                            const Icon(
                              FontAwesomeIcons.gift,
                              color: Colors.white,
                            ),
                            page:
                            const OfferPromotionListInPromotor(isOrganiser: true,)
                        ),
                        tile(
                            "Booking Management",
                            const Icon(FontAwesomeIcons.calendarCheck,
                                color: Colors.white),
                            page: const BookingPromotion(
                              isOrganiser: true,
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        tile(
                            "Analytics",
                            const Icon(
                              FontAwesomeIcons.campground,
                              color: Colors.white,
                            ),
                            page:
                            const PromotionEvent()
                        ),
                        tile(
                          "Refers\n&\nEarnings",
                          const Icon(
                            FontAwesomeIcons.share,
                            color: Colors.white,
                          ),
                          // page: const ReferralEarning(),
                          page: const ReferView(),
                        ),
                      ],
                    )
                  ],
                if(category != '2')
                  ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        tile(
                            "Events \n Management",
                            const Icon(
                              FontAwesomeIcons.calendar,
                              color: Colors.white,
                            ),
                            isOrganiser: true,
                            isEVM: true),
                        tile(
                            "Booking Management",
                            const Icon(FontAwesomeIcons.calendarCheck,
                                color: Colors.white),
                            page: const PromotionEventList(
                              isOrganiser: true,
                            )
                        ),


                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        tile(
                            "Offers & \n Promotion",
                            const Icon(
                              Icons.add_business_outlined,
                              color: Colors.white,
                            ),
                            page: const OffersAndPromotionsOrganiser()),

                        tile(
                          "Refers\n&\nEarnings",
                          const Icon(
                            FontAwesomeIcons.share,
                            color: Colors.white,
                          ),
                          page: const ReferralEarning(),
                        ),
                      ],
                    ),
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
