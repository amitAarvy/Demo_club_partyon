import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/authentication/phyllo_integration/secrets.dart';
import 'package:club/core/app_const/hive_const.dart';
import 'package:club/screens/insta-analytics/view_file/phyllo_view.dart';
import 'package:club/utils/app_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:phyllo_connect/phyllo_connect.dart';
import 'package:random_string/random_string.dart';

import '../../screens/home/InfluencerHome.dart';
import '../../screens/home/influencer_home_pages/influencer_profile.dart';
import '../../screens/sign_up/init_signup_details.dart';

String get pyhlloBaseURL => 'https://api.insightiq.ai';
FirebaseFirestore firestore = FirebaseFirestore.instance;

class Phyllo {
  static String phylloToken() {
    const String token =
        "${PhylloSecrets.clientId}:${PhylloSecrets.clientSecret}";
    final bytes = utf8.encode(token);
    final base64Token = base64.encode(bytes);
    print('phyllotoken printed: $base64Token');
    return base64Token;
  }

  //get account id
  static Future<String?> getAccountIdFromPhyllo() async {
    try {
      // Define headers for the request
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Basic ${phylloToken()}'
      };

      // Create the GET request
      var request = http.Request(
          'GET', Uri.parse('https://api.insightiq.ai/v1/accounts'));
      request.headers.addAll(headers);

      // Send the request and get the response
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response body
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        List<dynamic> accounts = jsonResponse['data'];
        if (accounts.isNotEmpty) {
          String accountId = accounts[0]['id'];

          // Store the 'id' in Hive
          Box box = await Hive.openBox(HiveConst.phylloBox);
          box.put(HiveConst.phylloAccountId, accountId);

          print("Account ID stored in Hive: $accountId");
          return accountId; // Return the 'id'
        } else {
          Fluttertoast.showToast(msg: "No accounts found in the response.");
          return null;
        }
      } else {
        print("Error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Exception occurred: $e");
      return null;
    }
  }

    // get account Id from hive db
  static Future<String?> getAccountIdFromHive() async {
    Box box = await Hive.openBox(HiveConst.phylloBox);
    String? accountId = box.get(HiveConst.phylloAccountId);
    print('accountId xxx: $accountId');
    if (accountId != null) {
      return accountId;
    }
    else {
      await getAccountIdFromPhyllo();
      // await Phyllo.init();
      // await getAccountId();
      return null;
    }
  }

  // static Future<String?> getAccountIdFromFirebase() async {
  //   Box box = await Hive.openBox(HiveConst.phylloBox);
  //   String? accountId = box.get(HiveConst.phylloAccountId);
  //   print('accountId xxx: $accountId');
  //   if (accountId != null) {
  //     return accountId;
  //   }
  //   else {
  //     await getAccountIdFromPhyllo();
  //     // await Phyllo.init();
  //     // await getAccountId();
  //     return null;
  //   }
  // }

  //create a new user
  static Future<http.StreamedResponse> createUser() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic ${phylloToken()}',
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('$pyhlloBaseURL/v1/users'));
    Map body = {
      "name": FirebaseAuth.instance.currentUser?.displayName ??
          "User ${randomAlphaNumeric(5)}",
      "external_id": uid()
    };
    print('body of create user is $body');
    print('body of create user is $headers');
    request.body = json.encode(body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print('reasonlala ${response.reasonPhrase}');
    return response;
  }

  static Future<String?> retrieveUserId() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic ${phylloToken()}'
    };
    var request = http.Request(
        'GET', Uri.parse('$pyhlloBaseURL/v1/users/external_id/${uid()}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map body = jsonDecode(await response.stream.bytesToString());
      Box box = await Hive.openBox(HiveConst.phylloBox);
      await box.put(HiveConst.userId, body['id']);
      print('userid is ${body['id']}');
      return body['id'];
    } else {
      print(response.reasonPhrase);
      return null;
    }
  }

  static Future<String?> refreshAccountData() async {
    Box box = await Hive.openBox(HiveConst.phylloBox);
    String accountId = box.get(HiveConst.phylloAccountId);
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic ${phylloToken()}'
    };
    var request = http.Request(
        'GET', Uri.parse('$pyhlloBaseURL/v1/social/contents/refresh'));
    request.body = json.encode({"account_id": accountId});
    request.headers.addAll(headers);
    print(request.headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Map body = jsonDecode(await response.stream.bytesToString());
      Box box = await Hive.openBox(HiveConst.phylloBox);
      print('get the body $body');
      await box.put(HiveConst.userId, body['id']);
      return body['id'];
    } else {
      print(response.reasonPhrase);
      return null;
    }
  }

  static Future<Map?> getSDKToken() async {
    String? userId = await retrieveUserId();
    print('get user Id $userId');
    if (userId != null) {
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Basic ${phylloToken()}',
        'Content-Type': 'application/json'
      };
      var request =
      http.Request('POST', Uri.parse('$pyhlloBaseURL/v1/sdk-tokens'));
      request.body = json.encode({
        "user_id": userId,
        "products": [
          "IDENTITY",
          "IDENTITY.AUDIENCE",
          "ENGAGEMENT",
          "ENGAGEMENT.AUDIENCE",
          "PUBLISH.CONTENT",
          "ACTIVITY"
        ]
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print('statuscode of sdktoken ${response.statusCode}');
      if (response.statusCode == 201) {
        Box box = await Hive.openBox(HiveConst.phylloBox);
        Map body = jsonDecode(await response.stream.bytesToString());
        print("body1 $body");
        box.put(HiveConst.sdkToken, body);
        return body;
      } else {
        return null;
      }
    } else if (userId == null) {
      var headers = {
        'Accept': 'application/json',
        'Authorization': 'Basic ${phylloToken()}',
        'Content-Type': 'application/json'
      };
      var request =
      http.Request('POST', Uri.parse('$pyhlloBaseURL/v1/sdk-tokens'));
      request.body = json.encode({
        "user_id": uid(),
        "products": [
          "IDENTITY",
          "IDENTITY.AUDIENCE",
          "ENGAGEMENT",
          "ENGAGEMENT.AUDIENCE",
          "PUBLISH.CONTENT",
          "ACTIVITY"
        ]
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 201) {
        Box box = await Hive.openBox(HiveConst.phylloBox);
        Map body = jsonDecode(await response.stream.bytesToString());
        box.put(HiveConst.sdkToken, body);
        print("body2 $body");
        return body;
      }
    }
  }

  //
  // static void getSDKTokenById() async {
  //   Box box = await Hive.openBox(HiveConst.phylloBox);
  //   Map? sdkTokenData = await getSDKToken();
  //   if (sdkTokenData == null) {
  //     box.put('sdkToken', sdkTokenData);
  //     // print(box.get('sdkToken'));
  //   } else {
  //     await createUser();
  //     print('calling creatuser');
  //     Map? sdkTokenNewUser = await getSDKToken();
  //     box.put(HiveConst.sdkToken, sdkTokenNewUser);
  //     // print(box.get(HiveConst.sdkToken));
  //   }
  // }

  static Future<void> saveAccountToFirebase(String userId, String accountId,
      String username, String profileId, {required uid}) async {
    print('Document saveAccountToFirebase initiated!');
    try {
      await FirebaseFirestore.instance
          .collection('Influencer') // Collection name
          .doc(uid()) // Document ID (in this case, the user's UID)
          .set(
        {
          'username': username,
          'accountId': accountId,
          'userId': userId,
          'profileId': profileId,
        },
        SetOptions(
            merge: true), // Merge ensures existing fields are not overwritten
      );

      print('Document successfully stored!');
    } catch (e) {
      // Handle errors
      print('Error writing document: $e');
    }
  }


  static void getAccountContent() async {
    Box box = await Hive.openBox(HiveConst.phylloBox);
    String accountId = box.get(HiveConst.phylloAccountId);
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic ${phylloToken()}'
    };
    var request = http.Request('GET',
        Uri.parse('$pyhlloBaseURL/v1/social/contents?account_id=$accountId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  static Future<Map<String, dynamic>> config() async {
    Box box = await Hive.openBox(HiveConst.phylloBox);
    String userId = await box.get(HiveConst.userId) ?? '';
    Map sdkTokenData = await box.get(HiveConst.sdkToken) ?? {};
    return {
      'clientDisplayName': 'Partyon',
      'environment': PhylloSecrets.environment.name,
      'userId': userId,
      'singleAccount': true,
      'token': sdkTokenData['sdk_token'],
      'workPlatformId': PhylloSecrets.instagramDirectWorkPlatformId
    };
  }

  static Future<bool> init() async {
    try {
      Box box = await Hive.openBox(HiveConst.phylloBox);
      http.StreamedResponse response = await createUser();
      print('statuscode of create user: ${response.statusCode}');
      if (response.statusCode == 201) {
        Map body = jsonDecode(await response.stream.bytesToString());
        print('body $body');
        Map? sdkTokenData = await getSDKToken();
        print('sdktoken $sdkTokenData');
        if (sdkTokenData != null) {
          print(sdkTokenData);
          PhylloConnect phylloConnect = PhylloConnect.instance;
          await phylloConnect.initialize(await config());
          await phylloConnectCallback(phylloConnect);
          print('phylloConnectCallback');
          await phylloConnect.open();
          return true;
        }
      }
      // else if (response.statusCode == 400) {
      //   String? userId = await retrieveUserId();
      //   print('get user Id of init $userId');
      //   // Fluttertoast.showToast(msg: 'User Already Connected with This Account');
      //   // Get.off(const InfluencerHome());
      // }
      else {
        Fluttertoast.showToast(msg: '${response.reasonPhrase}');
      }
    } catch (e) {
      log('Error in init: $e');
    }
    return false;
  }

  static Future<void> phylloConnectCallback(PhylloConnect phylloConnect) async {
    Box box = await Hive.openBox(HiveConst.phylloBox);
    phylloConnect.onConnectCallback(
      onAccountConnected: (accountId, workPlatformId, userId) async {
        if (accountId != null && workPlatformId != null && userId != null) {
          print(uid());
          FirebaseFirestore.instance
              .collection('Influencer')
              .doc(uid())
              .set({
            'accountId': accountId,
            "workPlatformId": workPlatformId,
            "userId": userId
          }, SetOptions(merge: true))
              .then((_) => print('User successfully saved'))
              .catchError(
                  (error) => print('the error in storing user data $error'));
        }
        await box.put(HiveConst.phylloAccountId, accountId);
        await box.put(HiveConst.userId, userId);
        log('onAccountConnected: $accountId, $workPlatformId, $userId');
      },
      onAccountDisconnected: (accountId, workPlatformId, userId) async {
        FirebaseFirestore.instance
            .collection('Influencer')
            .doc(uid())
            .delete()
            .then((_) {
          print('Document deleted successfully');
        }).catchError((error) {
          print('Failed to delete document: $error');
        });
        await box.get(HiveConst.userId);
        Get.off(const InfluencerProfile(isWeb: false));
        print('Redirecting to InfluencerProfile');
        log('onAccountDisconnected: $accountId, $workPlatformId, $userId');
      },
      onTokenExpired: (userId) {
        getSDKToken();
        log('onTokenExpired: $userId');
      },
      onExit: (String? reason, String? userId) async {
        if (reason == "DONE_CLICKED") {
          Get.off(const InfluencerProfile(isWeb: false));
          print('Redirecting to InfluencerProfile');
        }
        log('onExit: $reason, $userId');
      },
      onConnectionFailure:
          (String? reason, String? workPlatformId, String? userId) async {
        log('onConnectionFailure: $reason, $workPlatformId, $userId');
      },
    );
  }
}
