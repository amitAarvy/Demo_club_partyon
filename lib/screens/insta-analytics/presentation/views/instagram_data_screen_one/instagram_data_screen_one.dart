import 'package:club/screens/insta-analytics/models/retrieve_all_content_items.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/likes/likes.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_one/widgets/story_data_tile/data_tile.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_data_screen_two/presentation/widgets/instagram_data_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InstagramDataScreenOne extends StatefulWidget {
  final UserData? mediaData;

  final String mediaUrl;

  const InstagramDataScreenOne({
    super.key,
    required this.mediaUrl,
    this.mediaData,
  });

  @override
  State<InstagramDataScreenOne> createState() => _InstagramDataScreenOneState();
}

class _InstagramDataScreenOneState extends State<InstagramDataScreenOne> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
        child: Column(children: [
          if (widget.mediaUrl.isNotEmpty)
            InstagramDataCard(
              isFutureBuilder: false,
              child: Likes(
                replayCount: widget.mediaData?.engagement?.replayCount ?? 0,
                viewCount: widget.mediaData?.engagement?.viewCount ?? 0,
                totalLikes:
                    widget.mediaData?.engagement?.likeCount?.toInt() ?? 0,
                totalComments:
                    widget.mediaData?.engagement?.commentCount?.toInt() ?? 0,
                saveCount: widget.mediaData?.engagement?.saveCount ?? 0,
                shareCount: widget.mediaData?.engagement?.shareCount ?? 0,
                impressionOrganicCount:
                    widget.mediaData?.engagement?.impressionOrganicCount ?? 0,
                reachOrganicCount:
                    widget.mediaData?.engagement?.reachOrganicCount ?? 0,
                mediaData: widget.mediaData,
              ),
            ),
          SizedBox(height: 20.h),
          DataTile(
              iconImage: 'assets/organic_count.jpg',
              title: 'Total Impression Organic Count',
              value: widget.mediaData?.engagement?.impressionOrganicCount ?? 0),
          SizedBox(height: 20.h),
          DataTile(
              iconImage: 'assets/reach_organic.jpg',
              title: 'Total Reach Organic Count',
              value: widget.mediaData?.engagement?.reachOrganicCount ?? 0),
          SizedBox(height: 20.h),
          DataTile(
              iconImage: 'assets/comments.jpg',
              title: 'Total Comments Count',
              value: widget.mediaData?.engagement?.commentCount as int ?? 0),
          SizedBox(height: 20.h),
          DataTile(
              iconImage: 'assets/save.jpg',
              title: 'Total Save Count',
              value: widget.mediaData?.engagement?.saveCount ?? 0),
          SizedBox(height: 20.h),
          DataTile(
              iconImage: 'assets/share_count.jpg',
              title: 'Total Share Count',
              value: widget.mediaData?.engagement?.shareCount ?? 0),
          SizedBox(height: 20.h),
          DataTile(
              iconImage: 'assets/view.jpg',
              title: 'Total Views Count',
              value: widget.mediaData?.engagement?.viewCount ?? 0),
          SizedBox(height: 20.h),
          DataTile(
              iconImage: 'assets/replays.jpg',
              title: 'Total Replay Count',
              value: widget.mediaData?.engagement?.replayCount ?? 0),
          SizedBox(height: 20.h),
          DataTile(
              iconImage: 'assets/like.jpg',
              title: 'Total Likes Count',
              value: widget.mediaData?.engagement?.likeCount as int ?? 0),
          SizedBox(height: 20.h),
        ]),
      ),
    );
  }
}
