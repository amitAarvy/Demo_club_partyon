import 'package:cached_network_image/cached_network_image.dart';
import 'package:club/screens/insta-analytics/controller/instagram_controller.dart';
import 'package:club/screens/insta-analytics/models/instagram_data_model.dart';
import 'package:club/screens/insta-analytics/models/shared_posts_model.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/account_detail_view.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/shared_post_view.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';

class InstagramView extends StatefulWidget {
  const InstagramView({super.key});

  @override
  State<InstagramView> createState() => _InstagramViewState();
}

class _InstagramViewState extends State<InstagramView>
    with SingleTickerProviderStateMixin {
  late Future<InstagramDataModel?> instagramData;
  late Future<List<SharedPostsModel?>> sharedWithMePostsData;
  final InstagramController instagramController =
      Get.put(InstagramController());
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    instagramData = InstagramController.getInstagramData();
    sharedWithMePostsData = instagramController.getShareWithMeData();
    getSharePosts();
    super.initState();
  }

  void getSharePosts() async {
    List<SharedMedia> sharedMediaDataList =
        await instagramController.getSharePosts();
    instagramController.addAllSharedPost(sharedMediaDataList);
    instagramController.addAllShareModePost(sharedMediaDataList);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
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
                child: Text('Search Profile',
                    style: TextStyle(color: Colors.white, fontSize: 40.sp)),
              )
            ])),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<InstagramDataModel?>(
              future: instagramData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: Get.height / 1.7,
                    child:  const Center(
                      child: LoadingIndicator(
                          indicatorType: Indicator.ballSpinFadeLoader,
                          colors: [
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                            Colors.green,
                            Colors.blue,
                            Colors.indigo,
                            Colors.purple,
                          ],
                          strokeWidth: 2,
                          backgroundColor: Colors.transparent,
                          pathBackgroundColor: Colors.black
                      ),
                    ),
                  );
                } else {
                  final profileData = snapshot.data;
                  return SizedBox(
                    width: Get.width,
                    child: TabBarView(controller: tabController, children: [
                      AccountView(
                        accountName:
                            profileData?.instagramBusinessAccount?.name,
                        profileURL: profileData
                            ?.instagramBusinessAccount?.profilePictureUrl,
                        instagramData: profileData,
                        followerCount: 3837,
                        followingCount: 6,
                        contentCount: 55,
                      ),
                      FutureBuilder<List<SharedPostsModel?>>(
                          future: sharedWithMePostsData,
                          builder: (context, data) {
                            if (data.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: LoadingIndicator(
                                    indicatorType: Indicator.ballSpinFadeLoader,
                                    colors: [
                                      Colors.red,
                                      Colors.orange,
                                      Colors.yellow,
                                      Colors.green,
                                      Colors.blue,
                                      Colors.indigo,
                                      Colors.purple,
                                    ],
                                    strokeWidth: 2,
                                    backgroundColor: Colors.transparent,
                                    pathBackgroundColor: Colors.black
                                ),
                              );
                            } else {
                              final sharedList = data.data ?? [];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GridView.builder(
                                    itemCount: sharedList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) => InkWell(
                                      onTap: () => Get.to(SharedPostView(
                                          sharedPostsModel: sharedList[index],
                                          accountName:
                                              sharedList[index]?.name ?? '')),
                                      child: Card(
                                        child: Column(
                                          children: [
                                            CachedNetworkImage(
                                                imageUrl: sharedList[index]
                                                        ?.profilePictureUrl ??
                                                    ''),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  "${sharedList[index]?.name}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 40.sp),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            mainAxisExtent: 600.h,
                                            crossAxisCount: 2),
                                  ),
                                ],
                              );
                            }
                          }),
                    ]),
                  );
                }
              }),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FutureBuilder<InstagramDataModel?>(
                future: instagramData,
                builder: (context, instagramData) {
                  if (instagramData.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        value: 10,
                      ),
                    );
                  } else {
                    return Obx(() => instagramController.isShareMode
                        ? IconButton(
                            onPressed: () async =>
                                instagramController.onTapSaveShare(
                                    instagramData.data,
                                    (await instagramController
                                        .getSharedAccessIds())),
                            icon: const Icon(Icons.save, color: Colors.white))
                        : const SizedBox());
                  }
                }),
            IconButton(
                onPressed: () {
                  tabController.index = 0;
                  instagramController.onTapShareMode();
                },
                icon: const Icon(Icons.share, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
