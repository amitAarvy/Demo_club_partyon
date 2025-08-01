import 'package:cached_network_image/cached_network_image.dart';
import 'package:club/screens/insta-analytics/const/const.dart';
import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:club/screens/insta-analytics/models/audience_demographics.dart';
import 'package:club/screens/insta-analytics/models/retrieve_all_content_items.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/instagram_data_screen_one.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'instagram_data_screen_two/presentation/widgets/instagram_data_screen_two.dart';

class InstagramMediaView extends StatefulWidget {
  final RetrieveAllContentItems? contentData;
  final UserData? mediaData;
  final RetrieveAudienceDemographics? demographicsData;
  final bool isCreator;

  final String mediaURL;

  const InstagramMediaView({
    super.key,
    required this.mediaURL,
    this.contentData,
    required this.mediaData,
    this.demographicsData,
    this.isCreator = false,
  });

  @override
  State<InstagramMediaView> createState() => _InstagramMediaViewState();
}

class _InstagramMediaViewState extends State<InstagramMediaView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final PhylloController phylloController = Get.put(PhylloController());

  @override
  void initState() {
    tabController = TabController(
        length: InstagramDataConst.instagramTabList.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context,
          title: 'Instagram Analytics',
          bottom: TabBar(
              controller: tabController,
              tabs: InstagramDataConst.instagramTabList
                  .map((e) => Tab(
                        text: e,
                      ))
                  .toList()),
          shapeBorder:
              const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
      backgroundColor: matte(),
      body: DefaultTabController(
        length: InstagramDataConst.instagramTabList.length,
        child: TabBarView(controller: tabController, children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 700.h,
                      width: 500.w,
                      padding: const EdgeInsets.all(8.0),
                      child: CachedNetworkImage(
                        errorWidget: (_, __, ___) =>
                            Container(color: Colors.transparent),
                        imageUrl:
                            '${widget.mediaData?.thumbnailUrl ?? widget.mediaData?.mediaUrl}',
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          softWrap: true,
                          overflow: TextOverflow.clip,
                          widget.mediaData?.description ??
                              'No description available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 40.h,
                  thickness: 4,
                  color: Colors.white,
                  indent: 8,
                  endIndent: 8,
                ),
                InstagramDataScreenOne(
                    mediaUrl: widget.mediaURL, mediaData: widget.mediaData),
              ],
            ),
          ),
          InstagramDataScreenTwo(
              demographicsData: widget.isCreator
                  ? phylloController.creatorAudienceDemographics
                  : phylloController.audienceDemographics),
        ]),
      ),
    );
  }
}
