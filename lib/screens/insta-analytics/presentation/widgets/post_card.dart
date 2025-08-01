import 'package:cached_network_image/cached_network_image.dart';
import 'package:club/screens/insta-analytics/models/retrieve_all_content_items.dart';
import 'package:club/screens/insta-analytics/presentation/views/instagram_media_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class PostCard extends StatefulWidget {
  final UserData? mediaData;
  final RetrieveAllContentItems? contentData;
  final bool isCreator;

  const PostCard(
      {super.key, this.mediaData, this.contentData, this.isCreator = false});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    final userData = widget.mediaData;
    return InkWell(
      onTap: () => Get.to(InstagramMediaView(
        contentData: widget.contentData,
        mediaURL: widget.mediaData?.mediaUrl ?? '',
        mediaData: userData,
        isCreator: widget.isCreator,
      )),
      child: SizedBox(
        child: Stack(
          children: [
            Center(
              child: CachedNetworkImage(
                errorWidget: (_, __, ___) => Container(
                  color: Colors.black,
                ),
                imageUrl: '${userData?.thumbnailUrl ?? userData?.mediaUrl}',
              ),
            ),
            Container(color: Colors.black45),
            Positioned(
              right: 0,
              bottom: 0,
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(FontAwesomeIcons.solidHeart,
                        color: Colors.red),
                    label: Text('${userData?.engagement?.likeCount ?? 0}',
                        style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
