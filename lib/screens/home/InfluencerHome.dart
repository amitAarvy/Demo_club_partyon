import 'package:club/screens/home/influencer_home_pages/elite_pass_screen.dart';
import 'package:club/screens/home/influencer_home_pages/influ_home.dart';
import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:club/utils/app_utils.dart';
import 'package:club/screens/home/home_provider.dart';
import 'package:club/screens/home/home_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:get/get.dart';
import '../refer/presentation/views/referal_earning.dart';
import 'influencer_home_pages/influ_home_widgets/nightlife_categories/accepted_promotions.dart';

class InfluencerHome extends StatefulWidget {
  const InfluencerHome({Key? key}) : super(key: key);

  @override
  State<InfluencerHome> createState() => _InfluencerHomeState();
}

class _InfluencerHomeState extends State<InfluencerHome> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final homeController = Get.put(HomeController());
  final PhylloController phylloController = Get.put(PhylloController());
  List<Widget> pages = [];
  bool isLoading = false;

  int favCount = 0;

  ValueNotifier<int> currentPage = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    homeController.updateInfluencerName(
        (FirebaseAuth.instance.currentUser?.displayName) ?? 'NA');
    print("the initLoadingData calling in process");
    initializePages();
  }

  void initializePages() async {
    pages = [
      const InfluHome(),
      const ReferralEarning(isInf: 'yes',),
      const ElitePassScreen(),
      Container(),
      AcceptedPromotions(),
      // InfluencerProfile(isWeb: true, isFromHome: true,isLoading: isLoading),
      // const PromotionEventList(isOrganiser: true),

    ];
    // setState(() {
    //   isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitPopup(context),
      child: Scaffold(
        key: _key,
        backgroundColor: matte(),
        appBar: appBar(context,
            title: "Home",
            showLogo: true,
            key: _key,
            showBack: false,
            showTitle: false),
        drawer: drawer(isInf: true,isOrganiser: true,context: context),
        body:

     /*   isLoading
            ? const Center(child: CircularProgressIndicator())
            : */
        ValueListenableBuilder(
                valueListenable: currentPage,
                builder: (context, int index, child) {
                  return pages[index];
                },
              ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: currentPage,
          builder: (context, int index, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  bottomBarItem(
                    title: "Home",
                    icon: Icons.home_outlined,
                    selected: index == 0,
                    onTap: () {
                      currentPage.value = 0;
                    },
                  ),
                  bottomBarItem(
                    title: "Referral",
                    icon: PhosphorIcons.share_bold,
                    selected: index == 1,
                    onTap: () {
                      currentPage.value = 1;
                    },
                  ),
                  bottomBarItem(
                    title: "Elite Pass",
                    icon: PhosphorIcons.exam_light,
                    selected: index == 2,
                    onTap: () {
                      currentPage.value = 2;
                    },
                  ),
                  bottomBarItem(
                    title: "Earning",
                    icon: Icons.wallet_membership_outlined,
                    selected: index == 3,
                    onTap: () {
                      currentPage.value = 3;
                    },
                  ),
                  bottomBarItem(
                    title: "Accept",
                    icon: PhosphorIcons.user,
                    selected: index == 4,
                    onTap: () {
                      currentPage.value = 4;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget bottomBarItem(
    {required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: selected ? Colors.orange : Colors.white),
        const SizedBox(height: 5),
        Text(title,
            style: TextStyle(
                fontSize: 13, color: selected ? Colors.orange : Colors.white))
      ],
    ),
  );
}
