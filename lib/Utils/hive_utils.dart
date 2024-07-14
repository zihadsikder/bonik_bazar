import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../app/app_theme.dart';
import '../app/routes.dart';
import '../data/model/user_model.dart';
import 'helper_utils.dart';
import 'hive_keys.dart';

class HiveUtils {
  ///private constructor
  HiveUtils._();

  static String getJWT() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.jwtToken);
  }

  static void dontShowChooseLocationDialoge() {
    Hive.box(HiveKeys.userDetailsBox).put("showChooseLocationDialoge", false);
  }

/*  static bool isGuest() {
    return Hive.box(HiveKeys.userDetailsBox).get("isGuest") ?? true;
  }*/

/*  static void setIsNotGuest() {
    Hive.box(HiveKeys.userDetailsBox).put("isGuest", false);
  }*/

  /* static void setIsGuest() {
    Hive.box(HiveKeys.userDetailsBox).put("isGuest", true);
  }*/

  static bool isShowChooseLocationDialoge() {
    var value = Hive.box(HiveKeys.userDetailsBox).get(
      "showChooseLocationDialoge",
    );

    if (value == null) {
      return true;
    }
    return false;
  }

  static String? getUserId() {
    return Hive.box(HiveKeys.userDetailsBox).get("id").toString();
  }

  static AppTheme getCurrentTheme() {
    var current = Hive.box(HiveKeys.themeBox).get(HiveKeys.currentTheme);

    if (current == null) {
      return AppTheme.light;
    }
    if (current == "light") {
      return AppTheme.light;
    }
    if (current == "dark") {
      return AppTheme.dark;
    }
    return AppTheme.light;
  }

  static String? getCountryCode() {
    return Hive.box(HiveKeys.userDetailsBox).get("country_code");
    //return Hive.box(HiveKeys.userDetailsBox).toMap()['countryCode'];
  }

  static void setProfileNotCompleted() async {
    await Hive.box(HiveKeys.userDetailsBox)
        .put(HiveKeys.isProfileCompleted, false);
  }

  static setCurrentTheme(AppTheme theme) {
    String newTheme;
    if (theme == AppTheme.light) {
      newTheme = "light";
    } else {
      newTheme = "dark";
    }
    Hive.box(HiveKeys.themeBox).put(HiveKeys.currentTheme, newTheme);
  }

  static void setUserData(Map data) async {
    await Hive.box(HiveKeys.userDetailsBox).putAll(data);
  }

  static dynamic getCityName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city);
  }

  static dynamic getAreaName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.area);
  }

  static dynamic getAreaId() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.areaId);
  }

  static dynamic getStateName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
  }

  static dynamic getCountryName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);
  }

  static dynamic getCurrentCityName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.currentLocationCity);
  }

  static dynamic getCurrentAreaName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.currentLocationArea);
  }

  static dynamic getCurrentStateName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.currentLocationState);
  }

  static dynamic getCurrentCountryName() {
    return Hive.box(HiveKeys.userDetailsBox)
        .get(HiveKeys.currentLocationCountry);
  }

  static dynamic getCurrentLatitude() {
    return Hive.box(HiveKeys.userDetailsBox)
        .get(HiveKeys.currentLocationLatitude);
  }

  static dynamic getCurrentLongitude() {
    return Hive.box(HiveKeys.userDetailsBox)
        .get(HiveKeys.currentLocationLongitude);
  }

  static dynamic getLatitude() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.latitudeKey);
  }

  static dynamic getLongitude() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.longitudeKey);
  }

  static void setJWT(String token) async {
    await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.jwtToken, token);
  }

  static UserModel getUserDetails() {
    return UserModel.fromJson(
        Map.from(Hive.box(HiveKeys.userDetailsBox).toMap()));
  }

  static void setUserIsAuthenticated(bool value) {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, value);
  }

/*  static setUserIsNotAuthenticated() async {
    await Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
  }*/

  static Future<void> setUserIsNotNew() {
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, false);
  }

  static bool isLocationFilled() {
    var city = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city);
    var state = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
    var country = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);

    if (city == null && state == null && country == null) {
      return false;
    } else {
      return true;
    }
  }

  static void setLocation(
      {required String city,
      required String state,
      required String country,
      String? area,
      int? areaId,
      required double latitude,
      required double longitude}) async {
    await Hive.box(HiveKeys.userDetailsBox).putAll({
      HiveKeys.city: city,
      HiveKeys.stateKey: state,
      HiveKeys.countryKey: country,
      HiveKeys.areaId: areaId,
      HiveKeys.area: area,
      HiveKeys.latitudeKey: latitude,
      HiveKeys.longitudeKey: longitude
    });
  }

  static void setCurrentLocation(
      {required String city,
      required String state,
      required String country,
      latitude,
      longitude,
      String? area}) async {
    await Hive.box(HiveKeys.userDetailsBox).putAll({
      HiveKeys.currentLocationCity: city,
      HiveKeys.currentLocationState: state,
      HiveKeys.currentLocationCountry: country,
      HiveKeys.currentLocationLatitude: latitude,
      HiveKeys.currentLocationLongitude: longitude,
      HiveKeys.currentLocationArea: area
    });
  }

  static void clearLocation() async {
    await Hive.box(HiveKeys.userDetailsBox).putAll({
      HiveKeys.city: null,
      HiveKeys.stateKey: null,
      HiveKeys.countryKey: null,
    });
  }

  static Future<bool> storeLanguage(
    dynamic data,
  ) async {
    Hive.box(HiveKeys.languageBox).put(HiveKeys.currentLanguageKey, data);
    // ..put("language", data);
    return true;
  }

  static dynamic getLanguage() {
    return Hive.box(HiveKeys.languageBox).get(HiveKeys.currentLanguageKey);
  }

  // static s(context) {
  //   HiveUtils.setUserIsNotAuthenticated();
  //   HiveUtils.clear();

  //   Future.delayed(
  //     Duration.zero,
  //     () {
  //       HelperUtils.killPreviousPages(context, Routes.login, {});
  //     },
  //   );
  // }

  @visibleForTesting
  static Future<void> setUserIsNew() {
    //Only testing purpose // not in production
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, true);
  }

  static bool isUserAuthenticated() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isAuthenticated) ?? false;
  }

  static bool isUserFirstTime() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserFirstTime) ?? true;
  }

  static logoutUser(context,
      {required VoidCallback onLogout, bool? isRedirect}) async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
    HiveUtils.setUserIsAuthenticated(false);

    //GuestChecker.set(isGuest: true);
    onLogout.call();

    Future.delayed(
      Duration.zero,
      () {
        if (isRedirect ?? true) {
          HelperUtils.killPreviousPages(context, Routes.login, {});
        }
      },
    );
  }

  static void clear() async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
    await Hive.box(HiveKeys.historyBox).clear();
    HiveUtils.setUserIsAuthenticated(false);
    //GuestChecker.set(isGuest: true);
  }
}
