import 'package:cached_network_image/cached_network_image.dart';
import 'package:club/screens/insta-analytics/models/instagram_data_model.dart';
import 'package:club/screens/insta-analytics/models/retrieve_a_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountView extends StatelessWidget {
  final String? accountName;
  final String? profileURL;
  final num followerCount;
  final num followingCount;
  final num contentCount;
  final InstagramDataModel? instagramData;
  final RetrieveAProfile? phylloData;

  const AccountView({
    super.key,
    required this.accountName,
    required this.profileURL,
    this.instagramData,
    this.phylloData,
    required this.followerCount,
    required this.followingCount,
    required this.contentCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                  maxRadius: 150.h,
                  backgroundImage:
                      CachedNetworkImageProvider(profileURL ?? ''))),
          Text(
            '$accountName' ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48.sp,
            ),
          ),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: contentCount.toString() ?? '',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: '  posts',
                    style: TextStyle(color: Colors.white),
                  ),
                ]),
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: followerCount.toString() ?? '',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: '  follower',
                    style: TextStyle(color: Colors.white),
                  ),
                ]),
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: followingCount.toString() ?? '',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: '  following',
                    style: TextStyle(color: Colors.white),
                  ),
                ]),
              ),
            ],
          ),
          SizedBox(height: 40.h),
          Divider(color: Colors.white, height: 8.h, thickness: 2.w),
        ],
      ),
    );
  }
}
