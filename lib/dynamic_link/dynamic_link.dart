// ignore_for_file: deprecated_member_use

import 'package:club/core/app_const/hive_const.dart';
import 'package:club/init/main_init.dart';
import 'package:club/local_db/hive_db.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FirebaseDynamicLinkEvent {
  static Future<String> createDynamicLink(
      {bool short = false,
      required String eventID,
      required String organiserID,
      String promoterID = '',
        String clubUID = '',
        String venueName= '',
      bool isVenue = false
      }) async {
    String linkMessage;
    print('event id ${eventID}');
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://partyonndemo.page.link',
      link: Uri.parse(
        'https://partyonndemo.page.link.com?eventID=$eventID&clubUID=$clubUID&organiserID=${organiserID.toString()}&isVenue=${isVenue}&promoterID=$promoterID',
      ),
      androidParameters:  AndroidParameters(
        packageName: 'com.partyon.userDemo',
          minimumVersion: 1,
          fallbackUrl: Uri.parse('https://club.partyon.co.in/?eventId=$eventID&clubUid=$clubUID'),
      ),
      iosParameters:  IOSParameters(
          bundleId: 'com.partyon.userDemo',
          fallbackUrl: Uri.parse('https://club.partyon.co.in/?eventId=$eventID&clubUid=$clubUID')
      ),
      navigationInfoParameters: const NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
    );

    final ShortDynamicLink url;
    print('dyanmic link is abc ${parameters}');
    url = await FirebaseDynamicLinks.instance.buildShortLink(
      parameters,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    print('dyanmic link is abc ${url}');
    linkMessage = url.shortUrl.toString();
    return linkMessage;
  }

  static Future<Map<String, String>> getParametersFromExistingLink(
      String existingLink) async {
    // Resolve the short link to the long link
    final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance
        .getDynamicLink(Uri.parse(existingLink));
    final Uri? longLink = data?.link;

    if (longLink != null) {
      Map<String, String> queryParams = longLink.queryParameters;
      return queryParams;
    } else {
      return {};
    }
  }

  static Future<void> initDynamicLinks() async {
    // PendingDynamicLinkData? data =
    //     await FirebaseDynamicLinks.instance.getInitialLink();
    // Uri? deepLink = data?.link;
    // final Map<String, String>? queryParams = deepLink?.queryParameters;
    // if (queryParams?.isNotEmpty == true) {
    //   FirebaseDynamicLinkEvent.getParametersFromExistingLink(
    //       deepLink.toString());
    // }
    // print('queryParams Start $queryParams');
    FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData dynamicLinkData) async {
      Uri deepLink = dynamicLinkData.link;
      final Map<String, String> queryParams = deepLink.queryParameters;
      Box box = await HiveDB.openBox();
      await HiveDB.putKey(box, HiveConst.referMap, queryParams);
      debugPrint('DynamicLinks onLink $deepLink');
    }, onError: (e) async {
      debugPrint('DynamicLinks onError $e');
    });
  }

  static Future<void> initReferDynamicLinks() async {
    Map<String, String>? queryParams = {};
    bool isFirstInstall = await MainInit.checkFirstInstall();
    PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null && isFirstInstall) {
      Uri? deepLink = data.link;
      queryParams = deepLink.queryParameters;
      if (queryParams.isNotEmpty) {
        Box box = await HiveDB.openBox();
        await HiveDB.putKey(box, HiveConst.referMap, queryParams);
      }
    }
    FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData dynamicLinkData) async {
      Uri deepLink = dynamicLinkData.link;
      final Map<String, String> queryParams = deepLink.queryParameters;
      if (await MainInit.checkFirstInstall()) {
        Box box = await HiveDB.openBox();
        await HiveDB.putKey(box, HiveConst.referMap, queryParams);
      }
      debugPrint('DynamicLinks onLink $deepLink');
    }, onError: (e) async {
      debugPrint('DynamicLinks onError $e');
    });
  }

  static Future<String> createReferLink (
      {bool short = false,
      required String referId,
      required String uid}) async {
    String linkMessage;
    String uriPrefix = 'https://partyonndemo.page.link';
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: Uri.parse('$uriPrefix.com?referId=$referId&uid=$uid'),
      androidParameters: const AndroidParameters(
        packageName: 'hashtag.partyonDemo.partner',
      ),
      iosParameters: const IOSParameters(
        bundleId: 'hashtag.partyonDemo.partner',
      ),
    );

    final ShortDynamicLink url;
    url = await FirebaseDynamicLinks.instance.buildShortLink(
      parameters,
      shortLinkType: ShortDynamicLinkType.unguessable,
    );

    linkMessage = url.shortUrl.toString();
    return linkMessage;
  }
}
