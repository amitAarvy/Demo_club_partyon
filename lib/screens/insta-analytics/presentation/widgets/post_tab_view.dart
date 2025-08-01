import 'package:club/core/app_const/hive_const.dart';
import 'package:club/screens/insta-analytics/models/instagram_data_model.dart';
import 'package:club/screens/insta-analytics/models/retrieve_all_content_items.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class PostTabView extends StatefulWidget {
  final InstagramDataModel? instagramData;
  final RetrieveAllContentItems? contentData;
  final bool isCreator;

  const PostTabView({
    super.key,
    this.instagramData,
    this.contentData,
    this.isCreator = false,
  });

  @override
  State<PostTabView> createState() => _PostTabViewState();
}

class _PostTabViewState extends State<PostTabView>
    with SingleTickerProviderStateMixin {
  late TabController postTabController;

  @override
  void initState() {
    postTabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List videoContents =
        widget.contentData?.data?.where((e) => e.type == "VIDEO").toList() ??
            [];
    final List postContents =
        widget.contentData?.data?.where((e) => e.type == "POST").toList() ?? [];
    final List feedContents =
        widget.contentData?.data?.where((e) => e.type == "FEED").toList() ?? [];
    final List storyContents =
        widget.contentData?.data?.where((e) => e.type == "STORY").toList() ??
            [];

    final List reelContents =
        widget.contentData?.data?.where((e) => e.type == "REELS").toList() ??
            [];

    print('storyContents ${storyContents.length}');
    print('reelContents ${reelContents.length}');
    print('videoContents ${videoContents.length}');


    final List reelVideoContents = [...videoContents, ...reelContents];
    final List imageContents = [...postContents, ...feedContents];


    void storetoHive() async {
      Box box = await Hive.openBox(HiveConst.phylloBox);
      box.put(HiveConst.instaTotalPost, imageContents.length);
      box.put(HiveConst.instaTotalReels, reelVideoContents.length);
      box.put(HiveConst.instaTotalStory, storyContents.length);
    }

    return Column(
      children: [
        TabBar(
            controller: postTabController,
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: false,
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
            indicator: BoxDecoration(
              color: const Color(0xFF008080),
              borderRadius: BorderRadius.circular(16),
            ),
            tabs: [
              Tab(
                child: Text(
                  'Posts',
                  style: TextStyle(color: Colors.white, fontSize: 40.sp),
                ),
              ),
              Tab(
                child: Text(
                  'Videos / Reels',
                  style: TextStyle(color: Colors.white, fontSize: 40.sp),
                ),
              ),
              Tab(
                child: Text(
                  'Story',
                  style: TextStyle(color: Colors.white, fontSize: 40.sp),
                ),
              )
            ]),
        SizedBox(
          height: Get.height / 1.67,
          child: TabBarView(controller: postTabController, children: [
            if (imageContents.isEmpty)
              Center(
                child: Text(
                  'Oops! No data to show...Try again later! 😅 ',
                  style: TextStyle(
                    fontSize: 48.sp,
                    color: Colors.white,
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                itemCount: imageContents.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) => PostCard(
                    mediaData: imageContents[index],
                    contentData: widget.contentData,
                    isCreator: widget.isCreator),
              ),
            if (reelVideoContents.isEmpty)
              Center(
                child: Text(
                  'Oops! No data to show...Try again later! 😅 ',
                  style: TextStyle(
                    fontSize: 48.sp,
                    color: Colors.white,
                  ),
                ),
              )
            else
              GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: reelVideoContents.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) => PostCard(
                    mediaData: reelVideoContents[index],
                    contentData: widget.contentData,
                    isCreator: widget.isCreator),
              ),
            if (storyContents.isEmpty)
              Center(
                child: Text(
                  'Oops! No data to show...Try again later! 😅 ',
                  style: TextStyle(
                    fontSize: 48.sp,
                    color: Colors.white,
                  ),
                ),
              )
            else
              GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: storyContents.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, index) => PostCard(
                    mediaData: storyContents[index],
                    contentData: widget.contentData,
                    isCreator: widget.isCreator),
              ),
          ]),
        ),
      ],
    );
  }
}
