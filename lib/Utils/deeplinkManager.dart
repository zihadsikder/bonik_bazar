/*
// ignore_for_file: file_names

import 'dart:io';

import 'package:eClassify/data/Repositories/Item/item_repository.dart';

import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/exports/main_export.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class DeepLinkManager {
  static void initDeepLinks() async {
    // when app is open or in background then this method will be called
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      Future.delayed(Duration.zero, () {
        _handleDeepLinks(Constant.navigatorKey.currentContext!, dynamicLink);
      });
    }, onError: (e) async {
      debugPrint(e.toString());
    });

    // when your App Is Killed Or Open From Play store then this method will be called
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null) {
      if (Platform.isAndroid) {
        Future.delayed(Duration.zero, () {
          _handleDeepLinks(Constant.navigatorKey.currentContext!, data);
        });
      }
    }
  }

*/
/*  static void initDeepLinks(*//*
 */
/*BuildContext context*//*
 */
/*) async {
    PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    Future.delayed(Duration.zero, () {
      _handleDeepLinks(Constant.navigatorKey.currentContext!, data);
    });

    FirebaseDynamicLinks.instance.onLink.listen((data) {
      _handleDeepLinks(Constant.navigatorKey.currentContext!, data);
    });
  }*//*


  static Future<void> _handleDeepLinks(
      BuildContext context, PendingDynamicLinkData? data) async {
    final Uri? deepLink = data?.link;

    if (deepLink == null) {
      return;
    }
    int itemId = int.parse(deepLink.queryParameters['item_id']!);
    DataOutput<ItemModel> dataOutput =
        await ItemRepository().fetchItemFromItemId(itemId);

    Future.delayed(
      Duration.zero,
      () {
        Navigator.pushNamed(context, Routes.adDetailsScreen, arguments: {
          "model": dataOutput.modelList[0],
        });
        */
/*HelperUtils.goToNextPage(Routes.adDetailsScreen,
            Constant.navigatorKey.currentContext!, false,
            args: {
              "from": "home",
              "model": dataOutput.modelList[0],
            });*//*

      },
    );
    */
/*Navigator.pushNamed(context, Routes.adDetailsScreen, arguments: {
      "from": "home",
      "model": dataOutput.modelList[0],
    });*//*


//
//
  }

  static Future<String> buildDynamicLink(
    int itemId, {
    SocialMetaTagParameters? metaTags,
  }) async {
    Uri uri = Uri.parse("http://${AppSettings.deepLinkName}?item_id=$itemId");

    DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      link: uri,
      uriPrefix: AppSettings.deepLinkPrefix,
      navigationInfoParameters:
          const NavigationInfoParameters(forcedRedirectEnabled: true),
      androidParameters: const AndroidParameters(
          packageName: AppSettings.andoidPackageName, minimumVersion: 1),
      iosParameters: const IOSParameters(
          bundleId: AppSettings.andoidPackageName, minimumVersion: "1"),
    );

    ///
    ///
    final ShortDynamicLink dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(
      dynamicLinkParameters,
      shortLinkType: ShortDynamicLinkType.short,
    );

    ///

    return dynamicLink.shortUrl.toString();
  }
}
*/
