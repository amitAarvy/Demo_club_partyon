import 'package:club/core/app_const/hive_const.dart';
import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/loader/phyllo_loader.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/account_detail_view.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/post_tab_view.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/search_creator.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class PhylloView extends StatefulWidget {
  const PhylloView({super.key});

  @override
  State<PhylloView> createState() => _PhylloViewState();
}

class _PhylloViewState extends State<PhylloView>
    with SingleTickerProviderStateMixin {
  final PhylloController phylloController = Get.put(PhylloController());
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    initLoadingData();
    super.initState();
  }

  void initLoadingData() async {
    phylloController.isLoading = true;
    try {
      await PhylloController.retrieveAllProfileData();
      phylloController.profileData =
          await PhylloController.retrieveProfileData();
      phylloController.contentData =
          await PhylloController.retrieveAllContentItems();
      phylloController.creatorAudienceDemographics =
          await PhylloController.retrieveAudienceDemographics();
      phylloController.audienceDemographics =
          await PhylloController.retrieveAudienceDemographics();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error Is This: $e');
    } finally {
      phylloController.isLoading = false;
    }
  }

  void storeDataToHive() async {
    Box box = await Hive.openBox(HiveConst.phylloBox);
    box.put(HiveConst.instaProfileImg,
        phylloController.profileData?.imageUrl ?? null);
    box.put(HiveConst.instaUserName,
        phylloController.profileData?.platformUsername ?? null);
    box.put(HiveConst.instaFollowers,
        phylloController.profileData?.reputation?.followerCount ?? 0);
    box.put(HiveConst.instaContentCount,
        phylloController.profileData?.reputation?.contentCount ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBar(context,
            title: "Instagram Profile",
            bottom: TabBar(controller: tabController, tabs: [
              Tab(
                child: Text(
                  'My Profile',
                  style: TextStyle(color: Colors.white, fontSize: 40.sp),
                ),
              ),
              Tab(
                child: Text('Discover Creator',
                    style: TextStyle(color: Colors.white, fontSize: 40.sp)),
              )
            ])),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: Get.width,
            child: Obx(
              () => TabBarView(
                controller: tabController,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        if (phylloController.isLoading)
                          SizedBox(
                            height: Get.height / 1.7,
                            child: const Center(
                              child: PhylloLoader(),
                            ),
                          )
                        else ...[
                          AccountView(
                              phylloData: phylloController.profileData ?? null,
                              accountName: phylloController
                                      .profileData?.platformUsername ??
                                  null,
                              profileURL:
                                  phylloController.profileData?.imageUrl ??
                                      null,
                              followerCount: phylloController
                                      .profileData?.reputation?.followerCount ??
                                  0,
                              followingCount: phylloController.profileData
                                      ?.reputation?.followingCount ??
                                  0,
                              contentCount: phylloController
                                      .profileData?.reputation?.contentCount ??
                                  0),
                          PostTabView(
                              contentData: phylloController.contentData,
                              isCreator: false),
                        ],
                      ],
                    ),
                  ),
                  SearchCreator(contentData: phylloController.contentData),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
