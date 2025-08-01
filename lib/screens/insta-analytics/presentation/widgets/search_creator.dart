import 'package:club/screens/insta-analytics/controller/phyllo_controller.dart';
import 'package:club/screens/insta-analytics/models/retrieve_all_content_items.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/creator_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SearchCreator extends StatefulWidget {
  final RetrieveAllContentItems? contentData;

  const SearchCreator({super.key, this.contentData});

  @override
  State<SearchCreator> createState() => _SearchCreatorState();
}

class _SearchCreatorState extends State<SearchCreator> {
  final TextEditingController userNameTextController = TextEditingController();
  final PhylloController phylloController = Get.put(PhylloController());

  void initCreatorContent(String username) async {
    try {
      phylloController.creatorProfile =
          await PhylloController.retrieveCreatorProfilesData(username);
      if (phylloController.creatorProfile != null) {
        Get.to(CreatorView(
          userName: phylloController.creatorProfile?.username,
          imageURL: phylloController.creatorProfile?.imageUrl,
          followerCount:
              phylloController.creatorProfile?.reputation?.followerCount ?? 0,
          followingCount:
              phylloController.creatorProfile?.reputation?.followingCount ?? 0,
          phylloData: phylloController.creatorProfile,
          contentCount:
              phylloController.creatorProfile?.reputation?.contentCount ?? 0,
          contentData: widget.contentData,
          accountId: phylloController.creatorProfile?.account?.id ?? '',
        ));
        print('userName ${phylloController.creatorProfile?.username}');
      } else {
        Fluttertoast.showToast(msg: 'No data found for this username.');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      phylloController.isLoading = false;
    }
  }

  @override
  void dispose() {
    userNameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 130.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.pink, width: 2),
                  color: Colors.white,
                ),
                child: const Icon(
                  FontAwesomeIcons.instagram,
                  color: Colors.pink,
                  size: 40,
                ),
              ),
              Container(
                width: 520.w,
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  border: Border.all(color: Colors.pink, width: 2),
                ),
                child: TextField(
                  controller: userNameTextController,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink, width: 1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    prefixText: '@',
                    prefixStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 44.sp,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: 36.sp,
                    ),
                    hintText: 'Search using username',
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 44.sp,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xfff9ce34),
                      Color(0xffee2a7b),
                      Color(0xff6228d7),
                    ],
                  ),
                ),
                height: 120.h,
                child: ElevatedButton(
                  onPressed: () {
                    String username = userNameTextController.text;
                    if (username.isNotEmpty) {
                      initCreatorContent(username);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Please enter a valid username and try again.',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 8,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding:
                        EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
                  ),
                  child: Text(
                    'Get Results',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
