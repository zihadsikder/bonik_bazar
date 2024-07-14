import 'dart:io';

import 'package:eClassify/Ui/screens/main_activity.dart';
import 'package:eClassify/Utils/ui_utils.dart';
import 'package:eClassify/data/cubits/chatCubits/blocked_users_list_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favoriteCubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/cubits/Report/update_report_items_list_cubit.dart';
import '../../../data/cubits/auth/authentication_cubit.dart';
import '../../../data/cubits/auth/delete_user_cubit.dart';
import '../../../data/cubits/chatCubits/get_buyer_chat_users_cubit.dart';
import '../../../data/model/system_settings_model.dart';
import '../../../exports/main_export.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/Network/apiCallTrigger.dart';
import '../../../utils/api.dart';

import '../../../utils/helper_utils.dart';

import '../../../utils/responsiveSize.dart';
import '../widgets/blurred_dialoge_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  ValueNotifier isDarkTheme = ValueNotifier(false);
  final InAppReview _inAppReview = InAppReview.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //bool isGuest = false;
  String username = "";
  String email = "";

  @override
  void initState() {
    var settings = context.read<FetchSystemSettingsCubit>();

    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) ?? false;
    }

    super.initState();
  }

  void userData() {
    //isGuest = !HiveUtils.isUserAuthenticated();
    if (HiveUtils.isUserAuthenticated()) {
      username = (HiveUtils.getUserDetails().name ?? "").firstUpperCase();
      email = ((HiveUtils.getUserDetails().email ?? ""));
    } else {
      Future.delayed(Duration.zero, () {
        username = "anonymous".translate(context);
        email = "loginFirst".translate(context);
      });
    }
  }

  @override
  void didChangeDependencies() {
    isDarkTheme.value = context.read<AppThemeCubit>().isDarkMode();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isDarkTheme.dispose();
    super.dispose();
  }

  Widget setIconButtons({
    required String assetName,
    required void Function() onTap,
    Color? color,
    double? height,
    double? width,
  }) {
    return Container(
      height: 36,
      width: 36,
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: context.color.textDefaultColor.withOpacity(0.1))),
      child: InkWell(
          onTap: onTap,
          child: SvgPicture.asset(
            assetName,
            height: 24,
            width: 24,
            colorFilter: color == null
                ? ColorFilter.mode(
                context.color.territoryColor, BlendMode.srcIn)
                : ColorFilter.mode(color, BlendMode.srcIn),
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
  int? a;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    userData();
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
          context: context, statusBarColor: context.color.secondaryColor),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: UiUtils.buildAppBar(context,
            showBackButton: false,
            bottomHeight: 10,
            title: "myProfile".translate(context),
            actions: [
              if (HiveUtils.isUserAuthenticated())
                setIconButtons(
                  assetName: AppIcons.logout,
                  onTap: () {
                    logOutConfirmWidget();
                  },
                  color: context.color.textDefaultColor,
                ),
            ]),
        body: ScrollConfiguration(
          behavior: RemoveGlow(),
          child: SingleChildScrollView(
            controller: profileScreenController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(children: <Widget>[
                Container(
                  height: 91,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.5,
                      color: context.color.borderColor,
                    ),
                    color: context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: profileImgWidget(),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.015,
                        ),
                        SizedBox(
                          // height: 77,
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                width: context.screenWidth * 0.35,
                                child: Text(username)
                                    .color(context.color.textColorDark)
                                    .size(context.font.large)
                                    .bold(weight: FontWeight.w700)
                                    .setMaxLines(lines: 1),
                              ),
                              SizedBox(
                                width: context.screenWidth * 0.35,
                                child: Text(email)
                                    .color(context.color.textColorDark)
                                    .size(context.font.small)
                                    .setMaxLines(lines: 1),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        !HiveUtils.isUserAuthenticated()
                            ? MaterialButton(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: context.color.borderColor,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              Routes.login,
                              arguments: {"popToCurrent": true},
                            );
                          },
                          child: Text("loginLbl".translate(context)),
                        )
                            : InkWell(
                          onTap: () {
                            HelperUtils.goToNextPage(
                                Routes.completeProfile, context, false,
                                args: {"from": "profile"});
                          },
                          child: Container(
                            width: 40.rw(context),
                            height: 40.rh(context),
                            decoration: BoxDecoration(
                              color: context.color.secondaryColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: context.color.borderColor,
                                width: 1.5,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.none,
                              child: SizedBox(
                                width: 12.rw(context),
                                height: 22.rh(context),
                                child: UiUtils.getSvg(
                                  AppIcons.arrowRight,
                                  color: context.color.textColorDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    // customTile(
                    //   context,
                    //   title: "ONLY FOR DEVELOPMENT",
                    //   svgImagePath: AppIcons.enquiry,
                    //   onTap: () async {
                    //     var s = await FirebaseMessaging.instance.getToken();
                    //     Navigator.push(context, MaterialPageRoute(
                    //       builder: (context) {
                    //         return Scaffold(
                    //           body: Padding(
                    //             padding: const EdgeInsets.all(20.0),
                    //             child: Center(
                    //               child: SelectableText(s.toString()),
                    //             ),
                    //           ),
                    //         );
                    //       },
                    //     ));
                    //   },
                    // ),
                    //
                    // customTile(
                    //   context,
                    //   title: UiUtils.getTranslatedLabel(context, "myEnquiry"),
                    //   svgImagePath: AppIcons.enquiry,
                    //   onTap: () {
                    //     Navigator.pushNamed(context, Routes.myEnquiry);
                    //   },
                    // ),
                    //
                    //THIS IS EXPERIMENTAL

                    customTile(
                      context,
                      title: "myFeaturedAds".translate(context),
                      svgImagePath: AppIcons.promoted,
                      onTap: () async {
                        APICallTrigger.trigger();
                        UiUtils.checkUser(
                            onNotGuest: () {
                              Navigator.pushNamed(
                                  context, Routes.myAdvertisment,
                                  arguments: {});
                            },
                            context: context);
                      },
                    ),

                    customTile(
                      context,
                      title: "subscription".translate(context),
                      svgImagePath: AppIcons.subscription,
                      onTap: () async {
                        //TODO: change it once @End

                        UiUtils.checkUser(
                            onNotGuest: () {
                              Navigator.pushNamed(
                                  context, Routes.subscriptionPackageListRoute);
                            },
                            context: context);
                      },
                    ),

                    customTile(
                      context,
                      title: "transactionHistory".translate(context),
                      svgImagePath: AppIcons.transaction,
                      onTap: () {
                        UiUtils.checkUser(
                            onNotGuest: () {
                              Navigator.pushNamed(
                                  context, Routes.transactionHistory);
                            },
                            context: context);
                      },
                    ),

                    /*   customTile(
                      context,
                      title: "personalized".translate(context),
                      svgImagePath: AppIcons.magic,
                      onTap: () {
                        GuestChecker.check(onNotGuest: () {
                          Navigator.pushNamed(
                              context, Routes.personalizedItemScreen,
                              arguments: {
                                "type": PersonalizedVisitType.Normal
                              });
                        });
                      },
                    ),*/

                    customTile(
                      context,
                      title: "language".translate(context),
                      svgImagePath: AppIcons.language,
                      onTap: () {
                        Navigator.pushNamed(
                            context, Routes.languageListScreenRoute);
                      },
                    ),

                    ValueListenableBuilder(
                        valueListenable: isDarkTheme,
                        builder: (context, v, c) {
                          return customTile(
                            context,
                            title: "darkTheme".translate(context),
                            svgImagePath: AppIcons.darkTheme,
                            isSwitchBox: true,
                            onTapSwitch: (value) {
                              context.read<AppThemeCubit>().changeTheme(
                                  value == true
                                      ? AppTheme.dark
                                      : AppTheme.light);
                              setState(() {
                                isDarkTheme.value = value;
                              });
                            },
                            switchValue: v,
                            onTap: () {},
                          );
                        }),

                    customTile(
                      context,
                      title: "notifications".translate(context),
                      svgImagePath: AppIcons.notification,
                      onTap: () {
                        UiUtils.checkUser(
                            onNotGuest: () {
                              Navigator.pushNamed(
                                  context, Routes.notificationPage);
                            },
                            context: context);
                      },
                    ),

                    customTile(
                      context,
                      title: "blogs".translate(context),
                      svgImagePath: AppIcons.articles,
                      onTap: () {
                        UiUtils.checkUser(
                            onNotGuest: () {
                              Navigator.pushNamed(
                                context,
                                Routes.blogsScreenRoute,
                              );
                            },
                            context: context);
                      },
                    ),

                    customTile(
                      context,
                      title: "favorites".translate(context),
                      svgImagePath: AppIcons.favorites,
                      onTap: () {
                        UiUtils.checkUser(
                            onNotGuest: () {
                              Navigator.pushNamed(
                                  context, Routes.favoritesScreen);
                            },
                            context: context);
                      },
                    ),


                    customTile(
                      context,
                      title: "shareApp".translate(context),
                      svgImagePath: AppIcons.shareApp,
                      onTap: shareApp,
                    ),

                    customTile(
                      context,
                      title: "rateUs".translate(context),
                      svgImagePath: AppIcons.rateUs,
                      onTap: rateUs,
                    ),

                    customTile(
                      context,
                      title: "contactUs".translate(context),
                      svgImagePath: AppIcons.contactUs,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.contactUs,
                        );
                        // Navigator.pushNamed(context, Routes.ab);
                      },
                    ),

                    customTile(
                      context,
                      title: "aboutUs".translate(context),
                      svgImagePath: AppIcons.aboutUs,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.profileSettings,
                            arguments: {
                              'title': "aboutUs".translate(context),
                              'param': Api.aboutUs
                            });
                        // Navigator.pushNamed(context, Routes.ab);
                      },
                    ),

                    customTile(
                      context,
                      title: "termsConditions".translate(context),
                      svgImagePath: AppIcons.terms,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.profileSettings,
                            arguments: {
                              'title': "termsConditions".translate(context),
                              'param': Api.termsAndConditions
                            });
                      },
                    ),

                    customTile(
                      context,
                      title: "privacyPolicy".translate(context),
                      svgImagePath: AppIcons.privacy,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.profileSettings,
                          arguments: {
                            'title': "privacyPolicy".translate(context),
                            'param': Api.privacyPolicy
                          },
                        );
                      },
                    ),
                    if (Constant.isUpdateAvailable == true) ...[
                      updateTile(
                        context,
                        isUpdateAvailable: Constant.isUpdateAvailable,
                        title: "update".translate(context),
                        newVersion: Constant.newVersionNumber,
                        svgImagePath: AppIcons.update,
                        onTap: () async {
                          if (Platform.isIOS) {
                            await launchUrl(Uri.parse(Constant.appstoreURLios));
                          } else if (Platform.isAndroid) {
                            await launchUrl(
                                Uri.parse(Constant.playstoreURLAndroid));
                          }
                        },
                      ),
                    ],

                    if (HiveUtils.isUserAuthenticated()) ...[
                      customTile(
                        context,
                        title: "deleteAccount".translate(context),
                        svgImagePath: AppIcons.delete,
                        onTap: () {
                          if (Constant.isDemoModeOn) {
                            if (HiveUtils.getUserDetails().mobile !=
                                null) if (Constant
                                .demoMobileNumber ==
                                (HiveUtils.getUserDetails()
                                    .mobile!
                                    .replaceFirst(
                                    "+${HiveUtils.getCountryCode()}",
                                    ""))) {
                              HelperUtils.showSnackBarMessage(context,
                                  "thisActionNotValidDemo".translate(context));
                              return;
                            }
                          }
                          deleteConfirmWidget();
                        },
                      ),
                    ],
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),

                // profileInfo(),
                // Expanded(
                //   child: profileMenus(),
                // )
              ]),
            ),
          ),
        ),
      ),
    );
  }

/*  Padding dividerWithSpacing() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: UiUtils.getDivider(),
    );
  }*/

  Widget updateTile(BuildContext context,
      {required String title,
        required String newVersion,
        required bool isUpdateAvailable,
        required String svgImagePath,
        Function(dynamic value)? onTapSwitch,
        dynamic switchValue,
        required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: () {
          if (isUpdateAvailable) {
            onTap.call();
          }
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.color.territoryColor
                    .withOpacity(0.10000000149011612),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                  fit: BoxFit.none,
                  child: isUpdateAvailable == false
                      ? const Icon(Icons.done)
                      : UiUtils.getSvg(svgImagePath,
                      color: context.color.territoryColor)),
            ),
            SizedBox(
              width: 25.rw(context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isUpdateAvailable == false
                    ? "uptoDate".translate(context)
                    : title)
                    .bold(weight: FontWeight.w700)
                    .color(context.color.textColorDark),
                if (isUpdateAvailable)
                  Text("v$newVersion")
                      .bold(weight: FontWeight.w300)
                      .color(context.color.textColorDark)
                      .size(context.font.small)
                      .italic()
              ],
            ),
            if (isUpdateAvailable) ...[
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border:
                  Border.all(color: context.color.borderColor, width: 1.5),
                  color: context.color.secondaryColor
                      .withOpacity(0.10000000149011612),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.none,
                  child: SizedBox(
                    width: 8,
                    height: 15,
                    child: UiUtils.getSvg(
                      AppIcons.arrowRight,
                      color: context.color.textColorDark,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

//eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Rlc3Ricm9rZXJodWIud3J0ZWFtLmluL2FwaS91c2VyX3NpZ251cCIsImlhdCI6MTY5Njg1MDQyNCwibmJmIjoxNjk2ODUwNDI0LCJqdGkiOiJxVTNpY1FsRFN3MVJ1T3M5Iiwic3ViIjoiMzg4IiwicHJ2IjoiMWQwYTAyMGFjZjVjNGI2YzQ5Nzk4OWRmMWFiZjBmYmQ0ZThjOGQ2MyIsImN1c3RvbWVyX2lkIjozODh9.Y8sQhZtz6xGROEMvrTwA6gSSfPK-YwuhwDDc7Yahfg4
  Widget customTile(BuildContext context,
      {required String title,
        required String svgImagePath,
        bool? isSwitchBox,
        Function(dynamic value)? onTapSwitch,
        dynamic switchValue,
        required VoidCallback onTap}) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 0.5, bottom: 3),
      decoration: BoxDecoration(
        /*border: Border.all(
          width: 1.5,
          color: context.color.borderColor,
        ),*/
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            absorbing: !(isSwitchBox ?? false),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.color.territoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FittedBox(
                      fit: BoxFit.none,
                      child: UiUtils.getSvg(svgImagePath,
                          height: 24,
                          width: 24,
                          color: context.color.territoryColor)),
                ),
                SizedBox(
                  width: 25.rw(context),
                ),
                Expanded(
                  flex: 3,
                  child: Text(title)
                      .bold(weight: FontWeight.w700)
                      .color(context.color.textColorDark),
                ),
                const Spacer(),
                if (isSwitchBox != true)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.color.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FittedBox(
                      fit: BoxFit.none,
                      child: SizedBox(
                        width: 8,
                        height: 15,
                        child: UiUtils.getSvg(
                          AppIcons.arrowRight,
                          color: context.color.textColorDark,
                        ),
                      ),
                    ),
                  ),
                if (isSwitchBox ?? false)
                // CupertinoSwitch(value: value, onChanged: onChanged)
                  SizedBox(
                    height: 40,
                    width: 30,
                    child: CupertinoSwitch(
                      activeColor: context.color.territoryColor,
                      value: switchValue ?? false,
                      onChanged: (value) {
                        onTapSwitch?.call(value);
                      },
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• "),
        SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  deleteConfirmWidget() {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: (_auth.currentUser != null)
            ? "deleteProfileMessageTitle".translate(context)
            : "deleteAlertTitle".translate(context),
        content: _auth.currentUser != null
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            bulletPoint("yourAdsAndTransactionDelete".translate(context)),
            bulletPoint("accDetailsCanNotRecovered".translate(context)),
            bulletPoint("subscriptionsCancelled".translate(context)),
            bulletPoint(
                "savedPreferencesAndMessagesLost".translate(context)),
          ],
        )
            : Text("deleteRelogin".translate(context),
            textAlign: TextAlign.center),
        cancelButtonName: (_auth.currentUser != null)
            ? 'no'.translate(context)
            : 'cancelLbl'.translate(context),
        acceptButtonName: (_auth.currentUser != null)
            ? "deleteBtnLbl".translate(context)
            : 'logout'.translate(context),
        cancelTextColor: context.color.textColorDark,
        svgImagePath: AppIcons.deleteIcon,
        isAcceptContainesPush: true,
        onAccept: () async {
          (_auth.currentUser != null)
              ? proceedToDeleteProfile()
              : askToLoginAgain();
          /*Navigator.of(context).pop();
          if (callDel) {
            Future.delayed(
              const Duration(microseconds: 100),
                  () {
                Navigator.pushNamed(context, Routes.login,
                    arguments: {"isDeleteAccount": true});
              },
            );
          } else {
            HiveUtils.logoutUser(
              context,
              onLogout: () {},
            );
          }*/
        },
      ),
    );
  }

  askToLoginAgain() {
    HelperUtils.showSnackBarMessage(context, 'loginReqMsg'.translate(context));
    HiveUtils.clear();
    Constant.favoriteItemList.clear();
    context.read<UserDetailsCubit>().clear();
    context.read<FavoriteCubit>().resetState();
    context.read<UpdatedReportItemCubit>().clearItem();
    context.read<GetBuyerChatListCubit>().resetState();
    context.read<BlockedUsersListCubit>().resetState();
    HiveUtils.logoutUser(
      context,
      onLogout: () {},
    );
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }

  Future<void> signOut(AuthenticationType? type) async {
    if (type == AuthenticationType.google) {
      _googleSignIn.signOut();
    } else {
      _auth.signOut();
    }
  }

  proceedToDeleteProfile() async {
    //delete user from firebase
    try {
      await _auth.currentUser!.delete().then((value) {
        //delete user prefs from App-local
        context.read<DeleteUserCubit>().deleteUser().then((value) {
          HelperUtils.showSnackBarMessage(context, (value["message"]));
          for (int i = 0; i < AuthenticationType.values.length; i++) {
            if (AuthenticationType.values[i].name ==
                HiveUtils.getUserDetails().type) {
              signOut(AuthenticationType.values[i]).then((value) {
                HiveUtils.clear();
                Constant.favoriteItemList.clear();
                context.read<UserDetailsCubit>().clear();
                context.read<FavoriteCubit>().resetState();
                context.read<UpdatedReportItemCubit>().clearItem();
                context.read<GetBuyerChatListCubit>().resetState();
                context.read<BlockedUsersListCubit>().resetState();

                HiveUtils.logoutUser(
                  context,
                  onLogout: () {},
                );
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.login, (route) => false);
              });
            }
          }
        });
      });
    } on FirebaseAuthException catch (error) {
      if (error.code == "requires-recent-login") {
        for (int i = 0; i < AuthenticationType.values.length; i++) {
          if (AuthenticationType.values[i].name ==
              HiveUtils.getUserDetails().type) {
            signOut(AuthenticationType.values[i]).then((value) {
              HiveUtils.clear();
              Constant.favoriteItemList.clear();
              context.read<UserDetailsCubit>().clear();
              context.read<FavoriteCubit>().resetState();
              context.read<UpdatedReportItemCubit>().clearItem();
              context.read<GetBuyerChatListCubit>().resetState();
              context.read<BlockedUsersListCubit>().resetState();
              HiveUtils.logoutUser(
                context,
                onLogout: () {},
              );
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.login, (route) => false);
            });
          }
        }
      } else {
        throw HelperUtils.showSnackBarMessage(context, '${error.message}');
      }
    } catch (e) {
      debugPrint("unable to delete user - ${e.toString()}");
    }
  }

  Widget profileImgWidget() {
    return GestureDetector(
      onTap: () {
        if (HiveUtils.getUserDetails().profile != "" &&
            HiveUtils.getUserDetails().profile != null) {
          UiUtils.showFullScreenImage(
            context,
            provider: NetworkImage(
                context.read<UserDetailsCubit>().state.user?.profile ?? ""),
          );
        }
      },
      child: (context.watch<UserDetailsCubit>().state.user?.profile ?? "")
          .trim()
          .isEmpty
          ? buildDefaultPersonSVG(context)
          : Image.network(
        context.watch<UserDetailsCubit>().state.user?.profile ?? "",
        fit: BoxFit.cover,
        width: 49,
        height: 49,
        errorBuilder: (BuildContext context, Object exception,
            StackTrace? stackTrace) {
          return buildDefaultPersonSVG(context);
        },
        loadingBuilder: (BuildContext context, Widget? child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child!;
          return buildDefaultPersonSVG(context);
        },
      ),
    );
  }

  Widget buildDefaultPersonSVG(BuildContext context) {
    return Container(
      width: 49,
      height: 49,
      color: context.color.territoryColor.withOpacity(0.1),
      child: FittedBox(
        fit: BoxFit.none,
        child: UiUtils.getSvg(AppIcons.defaultPersonLogo,
            color: context.color.territoryColor, width: 30, height: 30),
      ),
    );
  }

  void shareApp() {
    try {
      if (Platform.isAndroid) {
        Share.share(
            '${Constant.appName}\n${Constant.playstoreURLAndroid}\n${Constant.shareappText}',
            subject: Constant.appName);
      } else {
        Share.share(
            '${Constant.appName}\n${Constant.appstoreURLios}\n${Constant.shareappText}',
            subject: Constant.appName);
      }
    } catch (e) {
      HelperUtils.showSnackBarMessage(context, e.toString());
    }
  }

/*  Future<void> rateUs() async {
    LaunchReview.launch(
      androidAppId: Constant.androidPackageName,
      iOSAppId: Constant.iOSAppId,
    );
  }*/

  Future<void> rateUs() => _inAppReview.openStoreListing(
      appStoreId: Constant.iOSAppId, microsoftStoreId: 'microsoftStoreId');

  void logOutConfirmWidget() {
    UiUtils.showBlurredDialoge(context,
        dialoge: BlurredDialogBox(
            title: "confirmLogoutTitle".translate(context),
            onAccept: () async {
              Future.delayed(
                Duration.zero,
                    () {
                  HiveUtils.clear();
                  Constant.favoriteItemList.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<FavoriteCubit>().resetState();
                  context.read<UpdatedReportItemCubit>().clearItem();
                  context.read<GetBuyerChatListCubit>().resetState();
                  context.read<BlockedUsersListCubit>().resetState();
                  HiveUtils.logoutUser(
                    context,
                    onLogout: () {},
                  );
                },
              );
            },
            cancelTextColor: context.color.textColorDark,
            svgImagePath: AppIcons.logoutIcon,
            content: Text("confirmLogOutMsg".translate(context))));
  }
}
