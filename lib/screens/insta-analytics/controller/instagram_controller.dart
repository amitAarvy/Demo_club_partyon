
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/authentication/facebook/facebook_controller.dart';
import 'package:club/screens/insta-analytics/const/url_const.dart';
import 'package:club/screens/insta-analytics/models/engaged_data_model.dart';
import 'package:club/screens/insta-analytics/models/instagram_data_model.dart';
import 'package:club/screens/insta-analytics/models/instagram_media_model.dart';
import 'package:club/screens/insta-analytics/models/shared_posts_model.dart';
import 'package:club/screens/insta-analytics/presentation/widgets/save_bottomsheet.dart';
import 'package:club/utils/app_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InstagramController extends GetxController {
  final RxString _currentAgeIndex = 'All'.obs;
  final RxBool _isShareMode = false.obs;
  final RxList<SharedMedia> _sharedPosts = <SharedMedia>[].obs;
  final RxList<String> _accessIds = <String>[].obs;

  bool get isShareMode => _isShareMode.value;

  List<String> get accessIds => _accessIds.value;

  final RxList<SharedMedia> _shareModePosts = <SharedMedia>[].obs;

  List<SharedMedia> get sharedPosts => _sharedPosts.value;

  List<SharedMedia> get shareModePosts => _shareModePosts.value;

  void addAccessId(String val) {
    if (!accessIds.contains(val)) {
      List<String> tempList = [..._accessIds.value];
      tempList.add(val);
      _accessIds.clear();
      _accessIds.addAll(tempList);
    }
  }

  void addAllAccessIds(List<String> val) {
    _accessIds.clear();
    _accessIds.addAll(val);
  }

  void removeAccessId(String val) {
    List<String> tempList = [..._accessIds.value];
    tempList.remove(val);
    _accessIds.clear();
    _accessIds.addAll(tempList);
  }

  void addSharedPost(SharedMedia val) {
    if (!sharedPosts.contains(val)) {
      List<SharedMedia> tempList = [..._sharedPosts.value];
      tempList.add(val);
      _sharedPosts.clear();
      _sharedPosts.addAll(tempList);
    }
  }

  void addAllSharedPost(List<SharedMedia> val) {
    _sharedPosts.clear();
    _sharedPosts.addAll(val);
  }

  void removeSharedPost(SharedMedia val) {
    List<SharedMedia> tempList = [..._sharedPosts.value];
    tempList.remove(val);
    _sharedPosts.clear();
    _sharedPosts.addAll(tempList);
  }

  void addShareModePost(SharedMedia val) {
    if (!shareModePosts.contains(val)) {
      List<SharedMedia> tempList = [..._shareModePosts.value];
      tempList.add(val);
      _shareModePosts.clear();
      _shareModePosts.addAll(tempList);
    }
  }

  void removeShareModePost(SharedMedia val) {
    List<SharedMedia> tempList = [..._shareModePosts.value];
    tempList.removeWhere((e) => e.mediaId == val.mediaId);
    _shareModePosts.clear();
    _shareModePosts.addAll(tempList);
  }

  void addAllShareModePost(List<SharedMedia> val) {
    _shareModePosts.clear();
    _shareModePosts.addAll(val);
  }

  set isShareMode(bool val) => _isShareMode.value = val;

  final RxString _viewsType = 'Post'.obs;

  String get postViews => _viewsType.value;

  set postViews(String views) => _viewsType.value = views;

  static Future<InstagramDataModel?> getInstagramData() async {
    String token = (await FacebookController.accessToken()) ?? '';
    http.Response response =
        await http.get(Uri.parse(InstagramURL.getInstaData(token)));
    if (response.statusCode == 200) {
      return InstagramDataModel.fromJson(jsonDecode(response.body)["data"][0]);
    }
    return null;
  }

  static Future<EngagedDataModel?> getEngagedAudienceDemographics(
      String breakdown) async {
    InstagramDataModel? instagramData = await getInstagramData();

    if (instagramData != null &&
        instagramData.instagramBusinessAccount != null) {
      String id = instagramData.instagramBusinessAccount!.id!;
      String token = (await FacebookController.accessToken()) ?? '';

      http.Response response = await http.get(
        Uri.parse(InstagramURL.getEngagedAudienceDemographicsData(
            id, token, breakdown)),
      );

      print('${response.body}');

      if (response.statusCode == 200) {
        return EngagedDataModel.fromJson(jsonDecode(response.body));
      }
    }

    return null;
  }

  Future<List<SharedMedia>> getSharePosts() async {
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("SharedPosts")
        .doc(uid())
        .get();
    final String data = jsonEncode(
        (getKeyValueFirestore(documentSnapshot, "shared_media") ?? []));
    final List mediaList = jsonDecode(data);
    if (documentSnapshot.exists && (mediaList.isNotEmpty)) {
      return mediaList.map((e) => SharedMedia.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<List<String>> getSharedAccessIds() async {
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("SharedPosts")
        .doc(uid())
        .get();
    if (documentSnapshot.exists) {
      final String data = jsonEncode(
          (getKeyValueFirestore(documentSnapshot, "access_ids") ?? []));
      final List mediaList = jsonDecode(data);
      if (documentSnapshot.exists && (mediaList.isNotEmpty)) {
        return mediaList.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  String getMediaURL(String mediaType, String mediaId, String token) {
    switch (mediaType) {
      case "IMAGE":
        return InstagramURL.getMediaData(mediaId, token);
      case "CAROUSEL_ALBUM":
        return InstagramURL.getMediaData(mediaId, token);
      case "VIDEO":
        return InstagramURL.getReelsData(mediaId, token);
      default:
        return "";
    }
  }

  Future<InstagramMediaModel?> getMediaData(
      String mediaId, String mediaType) async {
    String token = (await FacebookController.accessToken()) ?? '';
    String url = getMediaURL(mediaType, mediaId, token);
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return InstagramMediaModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<List<SharedPostsModel?>> getShareWithMeData() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("SharedPosts")
        .where('access_ids', arrayContainsAny: [
      FirebaseAuth.instance.currentUser?.email ?? '',
      FirebaseAuth.instance.currentUser?.phoneNumber ?? ''
    ]).get();
    final List<DocumentSnapshot> docSnapList = querySnapshot.docs;
    List<SharedPostsModel> sharedAccounts = [];
    for (DocumentSnapshot documentSnapshot in docSnapList) {
      final String data = jsonEncode(documentSnapshot.data());
      final Map mapData = jsonDecode(data);
      if (documentSnapshot.exists && (mapData.isNotEmpty)) {
        sharedAccounts.add(SharedPostsModel.fromJson(mapData));
      }
    }
    return sharedAccounts;
  }

  void onTapSaveShare(
      InstagramDataModel? instagramData, List<String> accessIdList) async {
    Get.bottomSheet(SaveBottomSheet(
        accessIds: accessIdList,
        onTap: () async {
          addAllSharedPost(shareModePosts);
          final SharedPostsModel sharedPostsModel = SharedPostsModel(
              uid: uid(),
              accessIds: accessIds,
              accessToken: await FacebookController.accessToken(),
              profilePictureUrl:
                  instagramData?.instagramBusinessAccount?.profilePictureUrl,
              username: instagramData?.instagramBusinessAccount?.username,
              instagramId: instagramData?.instagramBusinessAccount?.id,
              name: instagramData?.instagramBusinessAccount?.name,
              sharedMedia: sharedPosts);
          await FirebaseFirestore.instance
              .collection("SharedPosts")
              .doc(uid())
              .set(sharedPostsModel.toJson(), SetOptions(merge: true))
              .whenComplete(() {
            isShareMode = false;
            Get.back();
            Fluttertoast.showToast(msg: "Added successfully");
          }).onError((e, _) {
            Fluttertoast.showToast(msg: "Something went wrong");
          });
        }));
  }

  void onTapShareMode() {
    isShareMode = !isShareMode;
    shareModePosts.clear();
    shareModePosts.addAll(sharedPosts);
  }

  static int? mediaInsightCount(InstagramMediaModel? mediaModel, String name) {
    final valueList =
        mediaModel?.data?.where((e) => e.name == name).toList() ?? [];
    if (valueList.isNotEmpty) {
      return valueList.first.values?.first.value?.toInt();
    }
    return null;
  }

  static List<Results>? demographicInsightCount(
      EngagedDataModel? enhancedDemo, String name) {
    final valueList =
        enhancedDemo?.data?.where((e) => e.name == name).toList() ?? [];
    if (valueList.isNotEmpty) {
      return valueList.first.totalValue?.breakdowns?.first.results;
    }
    return null;
  }
}
