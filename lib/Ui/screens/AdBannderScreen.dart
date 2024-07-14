import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../exports/main_export.dart';

class AdBannerWidget extends StatefulWidget {
  @override
  _AdBannerWidgetState createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  late BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? Constant.bannerAdIdAndroid ///Android key
          : Constant.bannerAdIdIOS, ///ios key
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdWidget(
      ad: _bannerAd,
    );
  }
}
