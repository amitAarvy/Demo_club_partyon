import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:club/screens/insta-analytics/models/retrieve_a_profile.dart';
import 'package:club/screens/insta-analytics/models/retrieve_all_content_items.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/account_detail_view.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/post_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/app_utils.dart';

class CreatorView extends StatefulWidget {
  final String? userName;
  final String? imageURL;
  final num followerCount;
  final num followingCount;
  final num contentCount;
  final RetrieveAProfile? phylloData;
  final RetrieveAllContentItems? contentData;
  final String accountId;

  const CreatorView(
      {super.key,
      required this.userName,
      required this.imageURL,
      this.phylloData,
      required this.followerCount,
      required this.followingCount,
      required this.contentCount,
      this.contentData,
      required this.accountId});

  @override
  State<CreatorView> createState() => _CreatorViewState();
}

class _CreatorViewState extends State<CreatorView> {
  final PhylloController phylloController = Get.put(PhylloController());

  @override
  void initState() {
    initCreator();
    super.initState();
  }

  void initCreator() async {
    phylloController.creatorAudienceDemographics =
        await PhylloController.retrieveAudienceDemographics(
            creatorAccountId: widget.accountId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context,
          title: "Creator Profile", showLogo: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AccountView(
                accountName: widget.userName,
                profileURL: widget.imageURL,
                followerCount: widget.followerCount,
                followingCount: widget.followingCount,
                phylloData: widget.phylloData,
                contentCount: widget.contentCount),
            PostTabView(contentData: widget.contentData, isCreator: true),
          ],
        ),
      ),
    );
  }
}
