import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/authentication/phyllo_integration/pyllo_init.dart';
import 'package:club/core/app_const/hive_const.dart';
import 'package:club/screens/insta-analytics/const/url_const.dart';
import 'package:club/screens/insta-analytics/models/audience_demographics.dart';
import 'package:club/screens/insta-analytics/models/retrieve_a_profile.dart';
import 'package:club/screens/insta-analytics/models/retrieve_all_content_items.dart';
import 'package:club/screens/insta-analytics/models/retrieve_all_profiles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../../utils/app_utils.dart';

class PhylloController extends GetxController {
  final RxBool _isReadOnly = false.obs;
  final RxString _gender = 'Males'.obs;
  final RxString demographicDataType = 'Countries'.obs;
  final Rx<RetrieveAProfile?> _creatorProfile = RetrieveAProfile().obs;

  final RxBool _isLoading = false.obs;
  final Rx<RetrieveAllContentItems?> _contentData =
      RetrieveAllContentItems().obs;

  final Rx<RetrieveAProfile?> _profileData = RetrieveAProfile().obs;

  final Rx<RetrieveAudienceDemographics?> _audienceDemographics =
      RetrieveAudienceDemographics().obs;

  final Rx<RetrieveAudienceDemographics?> _creatorAudienceDemographics =
      RetrieveAudienceDemographics().obs;

  bool get isReadOnly => _isReadOnly.value;
  set isReadOnly(bool val) => _isReadOnly.value = val;

  bool get isLoading => _isLoading.value;

  RetrieveAProfile? get creatorProfile => _creatorProfile.value;

  RetrieveAllContentItems? get contentData => _contentData.value;

  RetrieveAProfile? get profileData => _profileData.value;

  RetrieveAudienceDemographics? get audienceDemographics =>
      _audienceDemographics.value;

  RetrieveAudienceDemographics? get creatorAudienceDemographics =>
      _creatorAudienceDemographics.value;

  set creatorProfile(RetrieveAProfile? val) => _creatorProfile.value = val;

  set isLoading(bool val) => _isLoading.value = val;

  set contentData(RetrieveAllContentItems? val) => _contentData.value = val;

  set audienceDemographics(RetrieveAudienceDemographics? val) =>
      _audienceDemographics.value = val;

  set creatorAudienceDemographics(RetrieveAudienceDemographics? val) =>
      _creatorAudienceDemographics.value = val;

  set profileData(RetrieveAProfile? val) => _profileData.value = val;

  String get gender => _gender.value;

  set gender(String genderType) => _gender.value = genderType;

  //function to get audience demographics data
  static Future<RetrieveAudienceDemographics?> retrieveAudienceDemographics(
      {String? creatorAccountId}) async {
    String? accountId = creatorAccountId ?? await Phyllo.getAccountIdFromPhyllo();
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic ${Phyllo.phylloToken()}'
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://api.insightiq.ai/v1/audience?account_id=$accountId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      return RetrieveAudienceDemographics.fromJson(jsonDecode(result));
    } else {
      return null;
    }
  }

// function to get basic profile data such as username, image, follower count, etc
  static Future<RetrieveAProfile?> retrieveProfileData(

      {String? profileIdCreator}) async {
    Box box = await Hive.openBox(HiveConst.phylloBox);
    String profileId = profileIdCreator ?? box.get(HiveConst.profileId);
    print('profile id is $profileId');

    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic ${Phyllo.phylloToken()}'
    };
    var request = http.Request('GET',
        Uri.parse('https://api.insightiq.ai/v1/profiles/$profileId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      if (profileIdCreator == null) {
        Map data = jsonDecode(result);
        print('profile data is $data');
        String? username = data['account']['username'];
        print("User name is $username");
        String? userId = await Phyllo.retrieveUserId();
        String? accountId = await Phyllo.getAccountIdFromPhyllo();
        await Phyllo.saveAccountToFirebase(
            userId ?? '', accountId ?? '', username ?? '', profileId ?? '', uid: uid);
        print('info saved to firebase');
      }
      return RetrieveAProfile.fromJson(jsonDecode(result));
    } else {
      print('error 123 : ${response.reasonPhrase}');
      return null;
    }
  }

//retrieve all profile
  static Future<RetrieveAllProfiles?> retrieveAllProfileData() async {
    Box box = await Hive.openBox(HiveConst.phylloBox);
    String? profileId = box.get(HiveConst.profileId);
    if (profileId == null || profileId.isEmpty) {
      String? accountId = await Phyllo.getAccountIdFromPhyllo();
      if (accountId == null || accountId.isEmpty) {
        print('Account ID is null or empty. $accountId');
        return null;
      }
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Basic ${Phyllo.phylloToken()}'
      };
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api.insightiq.ai/v1/profiles?account_id=$accountId'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String result = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = jsonDecode(result);

        if (jsonResponse.containsKey('data') &&
            (jsonResponse['data'] as List).isNotEmpty) {
          String profileId = jsonResponse['data'][0]['id'];
          print('Extracted ID: $profileId');
          await box.put(HiveConst.profileId, profileId);
          print('ID stored in Hive: $profileId');
        } else {
          print('No data found in the response.');
        }

        return RetrieveAllProfiles.fromJson(jsonResponse);
      } else {
        print('Error for not loading: ${response.reasonPhrase}');
        return null;
      }
    }
  }

// get profile details of a creator
  static Future<RetrieveAProfile?> retrieveCreatorProfilesData(
      String username) async {
    QuerySnapshot firestoreDoc = await FirebaseFirestore.instance
        .collection('Influencer')
        .where('username', isEqualTo: username)
        .get();
    if (firestoreDoc.docs.isEmpty) {
      Fluttertoast.showToast(
          msg: 'User  has not connected their account with Partyon.');
      return null;
    }
    return await retrieveProfileData(
        profileIdCreator: firestoreDoc.docs.first.get('profileId'));
  }

  //function to get all contents of all accounts
  static Future<RetrieveAllContentItems?> retrieveAllContentItems() async {
   print('calling retrieveAllContentItems');
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic ${Phyllo.phylloToken()}'
    };
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://api.insightiq.ai/v1/social/contents?account_id=${await Phyllo.getAccountIdFromPhyllo()}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      print('data pro max $result');
      return RetrieveAllContentItems.fromJson(jsonDecode(result));
    } else {
      print(response.reasonPhrase);
      return null;
    }
  }
}
