// import 'dart:async';

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eClassify/Ui/screens/widgets/Errors/no_internet.dart';
import 'package:eClassify/Utils/AppIcon.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/Utils/ui_utils.dart';
import 'package:eClassify/data/Repositories/system_repository.dart';

// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../app/routes.dart';
import 'package:eClassify/data/model/system_settings_model.dart';

// import 'package:eClassify/main.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../exports/main_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  //late OldAuthenticationState authenticationState;

  bool isTimerCompleted = false;
  bool isSettingsLoaded = false; //TODO: temp
  bool isLanguageLoaded = false;
  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool hasInternet = true;

  @override
  void initState() {
    //locationPermission();
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        hasInternet = (!result.contains(ConnectivityResult.none));
        //hasInternet = result != ConnectivityResult.none;
      });
      if (hasInternet) {
        getDefaultLanguage();

        checkIsUserAuthenticated();
        startTimer();
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

/*  Future<void> locationPermission() async {
    if ((await Permission.location.status) == PermissionStatus.denied) {
      await Permission.location.request();
    }
  }*/

  Future getDefaultLanguage() async {
    try {
      Map result = await SystemRepository().fetchSystemSettings();

      var code = (result['data']['default_language']);

      if (HiveUtils.getLanguage() == null ||
          HiveUtils.getLanguage()?['data'] == null) {
        context.read<FetchLanguageCubit>().getLanguage(code);
      } else if (HiveUtils.isUserFirstTime() == true &&
          code != HiveUtils.getLanguage()?['code']) {
        context.read<FetchLanguageCubit>().getLanguage(code);
      } else {
        isLanguageLoaded = true;
        setState(() {});
      }
    } catch (e) {
      log("Error while load default language $e");
    }
  }

  void checkIsUserAuthenticated() async {
    context.read<FetchSystemSettingsCubit>().fetchSettings(forceRefresh: true);
  }

  Future<void> startTimer() async {
    Timer(const Duration(seconds: 1), () {
      isTimerCompleted = true;
      if (mounted) setState(() {});
    });
  }

  void navigateCheck() {
    if (isTimerCompleted && isSettingsLoaded && isLanguageLoaded) {
      navigateToScreen();
    }
  }

  void navigateToScreen() async {
    if (context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.maintenanceMode) ==
        "1") {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
        }
      });
    } else if (HiveUtils.isUserFirstTime() == true) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.onboarding);
        }
      });
    } else if (HiveUtils.isUserAuthenticated()) {
      if ((HiveUtils.getUserDetails().name == null ||
              HiveUtils.getUserDetails().name == "") ||
          (HiveUtils.getUserDetails().email == null ||
              HiveUtils.getUserDetails().email == "") ||
          (HiveUtils.getUserDetails().mobile == null ||
              HiveUtils.getUserDetails().mobile == "")) {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            Navigator.pushReplacementNamed(
              context,
              Routes.completeProfile,
              arguments: {
                "from": "login",
              },
            );
          },
        );
      } else {
        if (HiveUtils.getCityName() != null && HiveUtils.getCityName() != "") {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(Routes.main,
                  arguments: {'from': "main"});
            }
          });
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.locationPermissionScreen, (route) => false);
            }
          });
        }
      }
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      });
    }
  }

/*  void navigateToScreen() {
    if (context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.maintenanceMode) ==
        "1") {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
        }
      });
    } else if (HiveUtils.isUserFirstTime() == true) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.onboarding);
        }
      });
    } else if (HiveUtils.isUserAuthenticated()) {
      if ((HiveUtils.getUserDetails().name == null ||
              HiveUtils.getUserDetails().name == "") ||
          (HiveUtils.getUserDetails().email == null ||
              HiveUtils.getUserDetails().email == "") ||
          (HiveUtils.getUserDetails().mobile == null ||
              HiveUtils.getUserDetails().mobile == "")) {
        Future.delayed(
          const Duration(seconds: 1),
          () {
            Navigator.pushReplacementNamed(
              context,
              Routes.completeProfile,
              arguments: {
                "from": "login",
              },
            );
          },
        );
      } else {

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context)
                .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
          }
        });
      }
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        }
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    /* SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );*/

    navigateCheck();

    return hasInternet
        ? BlocListener<FetchLanguageCubit, FetchLanguageState>(
            listener: (context, state) {
              if (state is FetchLanguageSuccess) {
                Map<String, dynamic> map = state.toMap();

                var data = map['file_name'];
                map['data'] = data;
                map.remove("file_name");

                HiveUtils.storeLanguage(map);
                context.read<LanguageCubit>().emit(LanguageLoader(map));
                isLanguageLoaded = true;
                if (mounted) {
                  setState(() {});
                }
              }
            },
            child: BlocListener<FetchSystemSettingsCubit,
                FetchSystemSettingsState>(
              listener: (context, state) {
                if (state is FetchSystemSettingsSuccess) {
                  Constant.isDemoModeOn = context
                      .read<FetchSystemSettingsCubit>()
                      .getSetting(SystemSetting.demoMode);

                  isSettingsLoaded = true;
                  setState(() {});
                }
                if (state is FetchSystemSettingsFailure) {}
              },
              child: AnnotatedRegion(
                value: SystemUiOverlayStyle(
                  statusBarColor: context.color.territoryColor,
                ),
                child: Scaffold(
                  backgroundColor: Colors.white,
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: UiUtils.getSvg(AppIcons.companyLogo),
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.center,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0.rh(context)),
                          child: SizedBox(
                            width: 150.rw(context),
                            height: 150.rh(context),
                            child: UiUtils.getSvg(AppIcons.splashLogo),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(top: 10.0.rh(context)),
                      //   child: Column(
                      //     children: [
                      //       Text("eClassifyLogoText".translate(context))
                      //           .size(context.font.xxLarge)
                      //           .color(context.color.secondaryColor)
                      //           .centerAlign()
                      //           .bold(weight: FontWeight.w600),
                      //       Text("\"${"buyAndSellAnything".translate(context)}\"")
                      //           .size(context.font.smaller)
                      //           .color(context.color.secondaryColor)
                      //           .centerAlign(),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : NoInternet(
            onRetry: () {
              setState(() {});
            },
          );
  }
}
