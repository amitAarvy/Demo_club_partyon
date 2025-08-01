import 'package:club/screens/insta-analytics/models/instagram_data_model.dart';
import 'package:club/screens/insta-analytics/models/shared_posts_model.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/account_detail_view.dart';
import 'package:club/utils/app_utils.dart';
import 'package:flutter/material.dart';

class SharedPostView extends StatelessWidget {
  final String accountName;
  final SharedPostsModel? sharedPostsModel;

  const SharedPostView(
      {super.key, required this.accountName, this.sharedPostsModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(context, title: accountName),
        body: AccountView(
          accountName: accountName,
          profileURL: sharedPostsModel?.profilePictureUrl,
          instagramData: InstagramDataModel(
              instagramBusinessAccount: InstagramBusinessAccount(
                  username: sharedPostsModel?.username,
                  profilePictureUrl: sharedPostsModel?.profilePictureUrl,
                  media: Media(
                      data: sharedPostsModel?.sharedMedia
                          ?.map((e) => MediaData(
                              mediaUrl: e.mediaUrl,
                              mediaType: e.mediaType,
                              id: e.mediaId,
                              thumbnailUrl: e.thumbnailUrl))
                          .toList()),
                  id: sharedPostsModel?.instagramId)),
          followerCount: 120,
          followingCount: 120,
          contentCount: 120,
        ));
  }
}
