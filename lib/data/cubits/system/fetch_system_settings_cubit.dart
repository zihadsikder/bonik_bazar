
import 'package:eClassify/exports/main_export.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../utils/Network/networkAvailability.dart';
import '../../Repositories/system_repository.dart';
import '../../model/system_settings_model.dart';

abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  final Map settings;

  FetchSystemSettingsSuccess({
    required this.settings,
  });

  Map<String, dynamic> toMap() {
    return {
      'settings': settings,
    };
  }

  factory FetchSystemSettingsSuccess.fromMap(Map<String, dynamic> map) {
    return FetchSystemSettingsSuccess(
      settings: map['settings'] as Map,
    );
  }
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  final String errorMessage;

  FetchSystemSettingsFailure(this.errorMessage);
}

class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState>
    with HydratedMixin {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial());
  final SystemRepository _systemRepository = SystemRepository();

  Future<void> fetchSettings({bool? forceRefresh}) async {
    try {
      if (forceRefresh != true) {
        if (state is FetchSystemSettingsSuccess) {
          await Future.delayed(
              const Duration(seconds: AppSettings.hiddenAPIProcessDelay));
        } else {
          emit(FetchSystemSettingsInProgress());
        }
      } else {
        emit(FetchSystemSettingsInProgress());
      }

      if (forceRefresh == true) {
        Map settings = await _systemRepository.fetchSystemSettings();
        Constant.currencySymbol =
            _getSetting(settings, SystemSetting.currencySymball);
        Constant.maintenanceMode =
            _getSetting(settings, SystemSetting.maintenanceMode);
        Constant.isGoogleBannerAdsEnabled =
            _getSetting(settings, SystemSetting.bannerAdStatus);
        Constant.isGoogleInterstitialAdsEnabled =
            _getSetting(settings, SystemSetting.interstitialAdStatus);
        Constant.bannerAdIdAndroid =
            _getSetting(settings, SystemSetting.bannerAdAndroidAd)??"";
        Constant.bannerAdIdIOS =
            _getSetting(settings, SystemSetting.bannerAdiOSAd)??"";
        Constant.interstitialAdIdAndroid =
            _getSetting(settings, SystemSetting.interstitialAdAndroidAd)??"";
        Constant.interstitialAdIdIOS =
            _getSetting(settings, SystemSetting.interstitialAdiOSAd)??"";

        emit(FetchSystemSettingsSuccess(settings: settings));
      } else {
        if (state is! FetchSystemSettingsSuccess) {
          Map settings = await _systemRepository.fetchSystemSettings();
          Constant.currencySymbol =
              _getSetting(settings, SystemSetting.currencySymball);
          Constant.maintenanceMode =
              _getSetting(settings, SystemSetting.maintenanceMode);
          Constant.isGoogleBannerAdsEnabled =
              _getSetting(settings, SystemSetting.bannerAdStatus);
          Constant.isGoogleInterstitialAdsEnabled =
              _getSetting(settings, SystemSetting.interstitialAdStatus);
          Constant.bannerAdIdAndroid =
              _getSetting(settings, SystemSetting.bannerAdAndroidAd)??"";
          Constant.bannerAdIdIOS =
              _getSetting(settings, SystemSetting.bannerAdiOSAd)??"";
          Constant.interstitialAdIdAndroid =
              _getSetting(settings, SystemSetting.interstitialAdAndroidAd)??"";
          Constant.interstitialAdIdIOS =
              _getSetting(settings, SystemSetting.interstitialAdiOSAd)??"";

          emit(FetchSystemSettingsSuccess(settings: settings));
        } else {
          await CheckInternet.check(
            onInternet: () async {
              Map settings = await _systemRepository.fetchSystemSettings();

              Constant.currencySymbol =
                  _getSetting(settings, SystemSetting.currencySymball);
              Constant.maintenanceMode =
                  _getSetting(settings, SystemSetting.maintenanceMode);

              Constant.isGoogleBannerAdsEnabled =
                  _getSetting(settings, SystemSetting.bannerAdStatus);
              Constant.isGoogleInterstitialAdsEnabled =
                  _getSetting(settings, SystemSetting.interstitialAdStatus);
              Constant.bannerAdIdAndroid =
                  _getSetting(settings, SystemSetting.bannerAdAndroidAd)??"";
              Constant.bannerAdIdIOS =
                  _getSetting(settings, SystemSetting.bannerAdiOSAd)??"";
              Constant.interstitialAdIdAndroid =
                  _getSetting(settings, SystemSetting.interstitialAdAndroidAd)??"";
              Constant.interstitialAdIdIOS =
                  _getSetting(settings, SystemSetting.interstitialAdiOSAd)??"";

              emit(FetchSystemSettingsSuccess(settings: settings));
            },
            onNoInternet: () {
           
              emit(FetchSystemSettingsSuccess(
                  settings: (state as FetchSystemSettingsSuccess).settings));
            },
          );
        }
      }

    } catch (e, st) {
      emit(FetchSystemSettingsFailure(st.toString()));
    }
  }

  dynamic getSetting(SystemSetting selected) {
    if (state is FetchSystemSettingsSuccess) {
      Map settings = (state as FetchSystemSettingsSuccess).settings['data'];
      if (selected == SystemSetting.subscription) {
        //check if we have subscribed to any package if true then return this data otherwise return empty list
        if (settings['subscription'] == true) {
          return settings['package']['user_purchased_package'] as List;
        } else {
          return [];
        }
      }

      if (selected == SystemSetting.language) {
        return settings['languages'];
      }

      if (selected == SystemSetting.demoMode) {
        if (settings.containsKey("demo_mode")) {
          return settings['demo_mode'];
        } else {
          return false;
        }
      }

      /// where selected is equals to type
      var selectedSettingData =
          (settings[Constant.systemSettingKeys[selected]]);

      return selectedSettingData;
    }
  }

  Map getRawSettings() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).settings['data'];
    }
    return {};
  }

  dynamic _getSetting(Map settings, SystemSetting selected) {
    var selectedSettingData =
        settings['data'][Constant.systemSettingKeys[selected]];

    return selectedSettingData;
  }

  @override
  FetchSystemSettingsState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['cubit_state'] == "FetchSystemSettingsSuccess") {
        FetchSystemSettingsSuccess fetchSystemSettingsSuccess =
            FetchSystemSettingsSuccess.fromMap(json);

        return fetchSystemSettingsSuccess;
      }
    } catch (e) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchSystemSettingsState state) {
    try {
      if (state is FetchSystemSettingsSuccess) {
        Map<String, dynamic> mapped = state.toMap();
        mapped['cubit_state'] = "FetchSystemSettingsSuccess";
        return mapped;
      }
    } catch (e) {}

    return null;
  }
}
