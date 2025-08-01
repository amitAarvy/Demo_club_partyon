import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../insta-analytics/models/retrieve_a_profile.dart';

class InfluencerProfileMobileUi extends StatelessWidget {
  final String? userName;
  final String? imageURL;
  final num followerCount;
  final num followingCount;
  final num reels;
  final num post;
  final num story;
  final RetrieveAProfile? phylloData;

  const InfluencerProfileMobileUi(
      {super.key,
      this.userName,
      this.imageURL,
      required this.followerCount,
      required this.followingCount,
      required this.reels,
      required this.post,
      required this.story,
      this.phylloData});

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
                      CachedNetworkImageProvider(imageURL ?? ''))),
          Text(
            '$userName' ?? '',
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
                    text: followerCount.toString() ?? '',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: '  Followers',
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
                    text: '  Following',
                    style: TextStyle(color: Colors.white),
                  ),
                ]),
              ),
            ],
          ),
          SizedBox(height: 40.h),
          Divider(color: Colors.white, height: 8.h, thickness: 1.w, indent: 20, endIndent: 20),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: reels.toString() ?? '',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: '  Reels',
                    style: TextStyle(color: Colors.white),
                  ),
                ]),
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: post.toString() ?? '',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: '  Post',
                    style: TextStyle(color: Colors.white),
                  ),
                ]),
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: story.toString() ?? '',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: '  Story',
                    style: TextStyle(color: Colors.white),
                  ),
                ]),
              ),
            ],
          ),
          SizedBox(height: 40.h),
          Divider(color: Colors.white, height: 12.h, thickness: 2.w, indent: 20, endIndent: 20),
        ],
      ),
    );
  }
}
