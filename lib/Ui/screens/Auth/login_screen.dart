import 'dart:async';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:device_region/device_region.dart';
import 'package:eClassify/Ui/screens/Home/home_screen.dart';
import 'package:eClassify/Ui/screens/Widgets/custom_text_form_field.dart';
import 'package:eClassify/Utils/Login/lib/login_status.dart';
import 'package:eClassify/Utils/api.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../Utils/AppIcon.dart';
import '../../../Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/Login/lib/payloads.dart';
import '../../../Utils/helper_utils.dart';
import '../../../Utils/ui_utils.dart';
import '../../../data/helper/widgets.dart';
import '../../../exports/main_export.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';

class LoginScreen extends StatefulWidget {
  final bool? isDeleteAccount;
  final bool? popToCurrent;

  const LoginScreen({super.key, this.isDeleteAccount, this.popToCurrent});

  @override
  State<LoginScreen> createState() => LoginScreenState();

  static BlurredRouter route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return BlurredRouter(
        builder: (_) => LoginScreen(
              isDeleteAccount: args?['isDeleteAccount'],
              popToCurrent: args?['popToCurrent'],
            ));
  }
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailMobileTextController = TextEditingController(
      text: Constant.isDemoModeOn ? Constant.demoMobileNumber : "");
  bool isOtpSent = false;
  String? phone, otp, countryCode, countryName, flagEmoji;

  Timer? timer;
  late Size size;
  CountryService countryCodeService = CountryService();
  bool isLoginButtonDisabled = true;
  bool isMobileNumberField = false;
  String numberOrEmail = "";
  bool sendMailClicked = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isObscure = true;
  late PhoneLoginPayload phoneLoginPayload =
      PhoneLoginPayload(emailMobileTextController.text, countryCode!);
  bool isBack = false;

  @override
  void initState() {
    super.initState();

    if (Constant.isDemoModeOn) {
      isMobileNumberField = true;
      numberOrEmail = Constant.demoMobileNumber;
    }

    context.read<AuthenticationCubit>().init();
    context.read<FetchSystemSettingsCubit>().fetchSettings();
    context.read<AuthenticationCubit>().listen((MLoginState state) {
      if (state is MOtpSendInProgress) {
        if (mounted) Widgets.showLoader(context);
      }

      if (state is MVerificationPending) {
        if (mounted) {
          Widgets.hideLoder(context);

          // Widgets.showLoader(context);

          isOtpSent = true;
          setState(() {});
          if (isMobileNumberField) {
            HelperUtils.showSnackBarMessage(
                context, "optsentsuccessflly".translate(context));
          }
        }
      }

      if (state is MFail) {
        //Widgets.hideLoder(context);

        if (!isOtpSent && isMobileNumberField) {
          Widgets.hideLoder(context);
        }

        if (isOtpSent && _otpController.text.isEmpty) {
          HelperUtils.showSnackBarMessage(context,
              "${"weSentCodeOnNumber".translate(context)}\t${emailMobileTextController.text}",
              type: MessageType.error);
        } else {
          if (state.error is FirebaseAuthException) {
            try {
              HelperUtils.showSnackBarMessage(context,
                  (state.error as FirebaseAuthException).message!.toString());
            } catch (e) {}
          } else {
            HelperUtils.showSnackBarMessage(context, state.error.toString());
          }
          /*HelperUtils.showSnackBarMessage(context, state.error.toString(),
              type: MessageType.error);*/
        }
      }
      if (state is MSuccess) {
        // Widgets.hideLoder(context);
      }
    });
    getSimCountry().then((value) {
      print("value country***$value");
      countryCode = value.phoneCode;

      flagEmoji = value.flagEmoji;
      setState(() {});
    });
  }

  /// it will return user's sim cards country code
  Future<Country> getSimCountry() async {
    List<Country> countryList = countryCodeService.getAll();
    String? simCountryCode;

    try {
      simCountryCode = await DeviceRegion.getSIMCountryCode();
      print("simCountryCode***$simCountryCode");
    } catch (e) {}

    Country simCountry = countryList.firstWhere(
      (element) {
        if (Constant.isDemoModeOn) {
          return countryList.any(
            (element) => element.phoneCode == Constant.defaultCountryCode,
          );
        } else {
          return element.phoneCode == simCountryCode;
        }
      },
      orElse: () {
        return countryList
            .where(
              (element) => element.phoneCode == Constant.defaultCountryCode,
            )
            .first;
      },
    );

    if (Constant.isDemoModeOn) {
      simCountry = countryList
          .where((element) => element.phoneCode == Constant.demoCountryCode)
          .first;
    }

    return simCountry;
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }

    _passwordController.dispose();
    emailMobileTextController.dispose();
    _otpController.dispose();

    super.dispose();
  }

  void _onTapContinue() {
    if (isMobileNumberField) {
      // isOtpSent = true;
      phoneLoginPayload =
          PhoneLoginPayload(emailMobileTextController.text, countryCode!);

      context
          .read<AuthenticationCubit>()
          .setData(payload: phoneLoginPayload, type: AuthenticationType.phone);
      context.read<AuthenticationCubit>().verify();

      setState(() {});
    } else {
      sendMailClicked = true;
      setState(() {});
    }
  }

  Future<void> sendVerificationCode() async {
    if (widget.isDeleteAccount ?? false) {
      isOtpSent = true;

      context
          .read<AuthenticationCubit>()
          .setData(payload: phoneLoginPayload, type: AuthenticationType.phone);
      context.read<AuthenticationCubit>().verify();

      setState(() {});
    }
    final form = _formKey.currentState;

    if (form == null) return;
    form.save();
    //checkbox value should be 1 before Login/SignUp
    if (form.validate()) {
      if (widget.isDeleteAccount ?? false) {
      } else {
        _onTapContinue();
      }

      // firebaseLoginProcess();
    }
    // showSnackBar( UiUtils.getTranslatedLabel(context, "acceptPolicy"), context);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    if (emailMobileTextController.text == Constant.demoMobileNumber) {
      _otpController.text = Constant.demoModeOTP;
    } else {
      _otpController.text = "";
    }

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.backgroundColor,
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: PopScope(
            canPop: isBack,
            onPopInvoked: (didPop) {
              if (widget.isDeleteAccount ?? false) {
                Navigator.pop(context);
              } else {
                if (isOtpSent) {
                  setState(() {
                    isOtpSent = false;
                    isMobileNumberField = true;
                  });
                } else if (sendMailClicked) {
                  setState(() {
                    sendMailClicked = false;
                  });
                } else {
                  setState(() {
                    isBack = true;
                  });
                  return;
                }
              }
              setState(() {
                isBack = false;
              });
              return;
            },
            child: AnnotatedRegion(
              value: SystemUiOverlayStyle(
                statusBarColor: context.color.backgroundColor,
              ),
              child: Scaffold(
                backgroundColor: context.color.backgroundColor,
                bottomNavigationBar: !isOtpSent && !sendMailClicked
                    ? termAndPolicyTxt()
                    : SizedBox.shrink(),
                body: BlocListener<LoginCubit, LoginState>(
                  listener: (context, state) {
                    if (state is LoginSuccess) {
                      HiveUtils.setUserIsAuthenticated(true);
                      //GuestChecker.set(isGuest: false);
                      //context.read<AuthCubit>().updateFCM(context);

                      context
                          .read<UserDetailsCubit>()
                          .fill(HiveUtils.getUserDetails());
                      if (state.isProfileCompleted) {
                        print(
                            "HiveUtils.getCityName()******${HiveUtils.getCityName()}");
                        if (HiveUtils.getCityName() != null &&
                            HiveUtils.getCityName() != "") {
                          HelperUtils.killPreviousPages(
                              context, Routes.main, {"from": "login"});
                        } else {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.locationPermissionScreen,
                              (route) => false);
                        }
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          Routes.completeProfile,
                          arguments: {
                            "from": "login",
                            "popToCurrent": false,
                            "type": isMobileNumberField
                                ? AuthenticationType.phone
                                : AuthenticationType.email,
                            "extraData": {
                              "email": state.credential.user?.email ??
                                  state.apiResponse['email'],
                              "username": state.apiResponse['name'],
                              "mobile": state.apiResponse['mobile'],
                              "countryCode": countryCode
                            }
                          },
                        );
                      }
                    }

                    if (state is LoginFailure) {
                      HelperUtils.showSnackBarMessage(
                          context, state.errorMessage.toString());
                    }
                  },
                  child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
                    listener: (context, state) {
                      if (state is AuthenticationSuccess) {
                        Widgets.hideLoder(context);

                        if (state.type == AuthenticationType.email) {
                          //FirebaseAuth.instance.currentUser?.sendEmailVerification();
                          if (state.credential.user!.emailVerified) {
                            context.read<LoginCubit>().login(
                                phoneNumber: isMobileNumberField
                                    ? emailMobileTextController.text.trim()
                                    : null,
                                firebaseUserId: state.credential.user!.uid,
                                type: state.type.name,
                                credential: state.credential,
                                countryCode: isMobileNumberField
                                    ? "+${countryCode}"
                                    : null);
                          } else {
                            // HelperUtils.showSnackBarMessage(context,"Please Verify Your email first" );
                          }
                        } else {
                          context.read<LoginCubit>().login(
                              phoneNumber: isMobileNumberField
                                  ? emailMobileTextController.text.trim()
                                  : null,
                              firebaseUserId: state.credential.user!.uid,
                              type: state.type.name,
                              credential: state.credential,
                              countryCode: isMobileNumberField
                                  ? "+${countryCode}"
                                  : null);
                        }
                      }

                      if (state is AuthenticationFail) {
                        Widgets.hideLoder(context);
                      }

                      if (state is AuthenticationInProcess) {
                        Widgets.showLoader(context);
                      }
                    },
                    builder: (context, state) {
                      return Builder(builder: (context) {
                        return Form(
                          key: _formKey,
                          child: isOtpSent
                              ? verifyOTPWidget()
                              : sendMailClicked
                                  ? enterPasswordWidget()
                                  : buildLoginWidget(),
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoginWidget() {
    return SingleChildScrollView(
      child: SizedBox(
        height: context.screenHeight - 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: FittedBox(
                  fit: BoxFit.none,
                  child: MaterialButton(
                    onPressed: () {
                      //HiveUtils.setUserIsNotNew();

                      Navigator.pushNamed(
                        context,
                        Routes.main,
                        arguments: {
                          "from": "login",
                          "isSkipped": true,
                        },
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: context.color.forthColor.withOpacity(0.102),
                    elevation: 0,
                    height: 28,
                    minWidth: 64,
                    child: Text("skip".translate(context))
                        .color(context.color.forthColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 66,
              ),
              Text("welcomeback".translate(context))
                  .size(context.font.extraLarge)
                  .color(context.color.textDefaultColor),
              const SizedBox(
                height: 8,
              ),
              Text("loginToBonikBazar".translate(context))
                  .size(context.font.large)
                  .color(
                    context.color.textColorDark,
                  ),
              const SizedBox(
                height: 24,
              ),
              CustomTextFormField(
                controller: emailMobileTextController,
                fillColor: context.color.secondaryColor,
                borderColor: context.color.borderColor.darken(30),
                onChange: (value) {
                  bool isNumber =
                      value.toString().contains(RegExp(r'^[0-9]+$'));

                  isMobileNumberField = isNumber;

                  numberOrEmail = value;
                  setState(() {});
                },
                validator: isMobileNumberField
                    ? CustomTextFieldValidator.phoneNumber
                    : CustomTextFieldValidator.email,
                fixedPrefix: (isMobileNumberField)
                    ? SizedBox(
                        width: 55,
                        child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: GestureDetector(
                              onTap: () {
                                showCountryCode();
                              },
                              child: Container(
                                // color: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8),
                                child: Center(
                                    child: Text("+$countryCode")
                                        .size(context.font.large)
                                        .centerAlign()),
                              ),
                            )),
                      )
                    : null,
                hintText: "emailOrPhone".translate(context),
              ),
              const SizedBox(
                height: 46,
              ),
              UiUtils.buildButton(context,
                  onPressed: sendVerificationCode,
                  buttonTitle: "continue".translate(context),
                  radius: 10,
                  disabled: numberOrEmail.isEmpty,
                  disabledColor: const Color.fromARGB(255, 104, 102, 106)),
              const SizedBox(
                height: 68,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("dontHaveAcc".translate(context))
                          .color(context.color.textColorDark.brighten(50)),
                      const SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.signup);
                        },
                        child: Text("signUp".translate(context))
                            .underline()
                            .color(context.color.territoryColor),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text("orSignInWith".translate(context))
                      .color(context.color.textDefaultColor),
                  const SizedBox(
                    height: 24,
                  ),
                  UiUtils.buildButton(context,
                      prefixWidget: Padding(
                        padding: EdgeInsetsDirectional.only(end: 10.0),
                        child: UiUtils.getSvg(AppIcons.googleIcon,
                            width: 22, height: 22),
                      ),
                      showElevation: false,
                      buttonColor: secondaryColor_,
                      border: context.watch<AppThemeCubit>().state.appTheme !=
                          AppTheme.dark?BorderSide(
                          color:
                              context.color.textDefaultColor.withOpacity(0.5)):null,
                      textColor: textDarkColor, onPressed: () {
                    context.read<AuthenticationCubit>().setData(
                        payload: GoogleLoginPayload(),
                        type: AuthenticationType.google);
                    context.read<AuthenticationCubit>().authenticate();
                  },
                      radius: 8,
                      height: 46,
                      buttonTitle: "continueWithGoogle".translate(context)),
                  const SizedBox(
                    height: 12,
                  ),
                  if (Platform.isIOS)
                    UiUtils.buildButton(context,
                        prefixWidget: Padding(
                          padding: EdgeInsetsDirectional.only(end: 10.0),
                          child: UiUtils.getSvg(AppIcons.appleIcon,
                              width: 22, height: 22),
                        ),
                        showElevation: false,
                        buttonColor: secondaryColor_,
                        border: context.watch<AppThemeCubit>().state.appTheme !=
                            AppTheme.dark?BorderSide(
                            color:
                            context.color.textDefaultColor.withOpacity(0.5)):null,
                        textColor: textDarkColor,
                        onPressed: () {
                      context.read<AuthenticationCubit>().setData(
                          payload: AppleLoginPayload(),
                          type: AuthenticationType.apple);
                      context.read<AuthenticationCubit>().authenticate();
                    },
                        height: 46,
                        radius: 8,
                        buttonTitle: "continueWithApple".translate(context)),
                ],
              ),
              /* const Spacer(),
              termAndPolicyTxt()*/
            ],
          ),
        ),
      ),
    );
  }

  Widget termAndPolicyTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 15.0, start: 25.0, end: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("bySigningUpLoggingIn".translate(context))
              .centerAlign()
              .size(context.font.small)
              .color(context.color.textLightColor.withOpacity(0.8)),
          const SizedBox(
            height: 3,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            InkWell(
                child: Text("termsOfService".translate(context))
                    .underline()
                    .color(context.color.territoryColor)
                    .size(context.font.small),
                onTap: () => Navigator.pushNamed(
                        context, Routes.profileSettings, arguments: {
                      'title': "termsConditions".translate(context),
                      'param': Api.termsAndConditions
                    })),
            /*CustomTextButton(
                text:Text("termsOfService".translate(context)).underline().color(context.color.teritoryColor).size(context.font.small),
                onPressed: () => Navigator.pushNamed(
                        context, Routes.profileSettings,
                        arguments: {
                          'title': UiUtils.getTranslatedLabel(
                              context, "termsConditions"),
                          'param': Api.termsAndConditions
                        })),*/
            const SizedBox(
              width: 5.0,
            ),
            Text("andTxt".translate(context))
                .size(context.font.small)
                .color(context.color.textLightColor.withOpacity(0.8)),
            const SizedBox(
              width: 5.0,
            ),
            InkWell(
                child: Text("privacyPolicy".translate(context))
                    .underline()
                    .color(context.color.territoryColor)
                    .size(context.font.small),
                onTap: () => Navigator.pushNamed(
                        context, Routes.profileSettings, arguments: {
                      'title': "privacyPolicy".translate(context),
                      'param': Api.privacyPolicy
                    })),
            /*CustomTextButton(
                text:
                    Text("privacyPolicy".translate(context)).underline().color(context.color.teritoryColor).size(context.font.small),
                onPressed: () => Navigator.pushNamed(
                      context,
                      Routes.profileSettings,
                      arguments: {
                        'title': UiUtils.getTranslatedLabel(
                            context, "privacyPolicy"),
                        'param': Api.privacyPolicy
                      },
                    )),*/
          ]),
        ],
      ),
    );
  }

  Future<bool> onBackPress() {
    if (widget.isDeleteAccount ?? false) {
      Navigator.pop(context);
    } else {
      if (isOtpSent == true) {
        setState(() {
          isOtpSent = false;
        });
      } else {
        return Future.value(true);
      }
    }
    return Future.value(false);
  }

  void showCountryCode() {
    showCountryPicker(
      context: context,
      showWorldWide: false,
      showPhoneCode: true,
      countryListTheme:
          CountryListThemeData(borderRadius: BorderRadius.circular(11)),
      onSelect: (Country value) {
        flagEmoji = value.flagEmoji;
        countryCode = value.phoneCode;
        setState(() {});
      },
    );
  }

  Widget verifyOTPWidget() {
    /* _otpController = TextEditingController(
        text: emailMobileTextController.text == Constant.demoMobileNumber
            ? Constant.demoModeOTP
            : "");*/
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sidePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: FittedBox(
              fit: BoxFit.none,
              child: MaterialButton(
                onPressed: () {
                  HelperUtils.killPreviousPages(context, Routes.main, {
                    "from": "login",
                    "isSkipped": true,
                  });
                  /* Navigator.pushReplacementNamed(
                    context,
                    Routes.main,
                    arguments: {
                      "from": "login",
                      "isSkipped": true,
                    },
                  );*/
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: context.color.forthColor.withOpacity(0.102),
                elevation: 0,
                height: 28,
                minWidth: 64,
                child: Text("skip".translate(context))
                    .color(context.color.forthColor),
              ),
            ),
          ),
          const SizedBox(
            height: 66,
          ),
          Text("signInWithMob".translate(context))
              .size(context.font.extraLarge),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Text("+${phoneLoginPayload.countryCode}\t${phoneLoginPayload.phoneNumber}")
                  .size(context.font.large),
              const SizedBox(
                width: 5,
              ),
              InkWell(
                  child: Text("change".translate(context))
                      .underline()
                      .color(context.color.territoryColor)
                      .size(context.font.large),
                  onTap: () => Navigator.pushNamed(context, Routes.login)),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          CustomTextFormField(
              controller: _otpController,
              keyboard: TextInputType.number,
              hintText: "enterOTPHere".translate(context),
              //maxLength: 6,
              validator: CustomTextFieldValidator.otpSix),
          const SizedBox(
            height: 8,
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: MaterialButton(
              onPressed: () {
                context.read<AuthenticationCubit>().setData(
                      payload: phoneLoginPayload,
                      type: AuthenticationType.phone,
                    );
                context.read<AuthenticationCubit>().verify();
              },
              child: Text("resendOTP".translate(context))
                  .color(context.color.textColorDark.withOpacity(0.7)),
            ),
          ),
          const SizedBox(
            height: 19,
          ),
          UiUtils.buildButton(
            context,
            onPressed: () {
              /* if (_otpController.text.length != 6) {
                HelperUtils.showSnackBarMessage(
                    context, "lblEnterOtp".translate(context));
              } else {*/

              phoneLoginPayload.setOTP(_otpController.text);
              context.read<AuthenticationCubit>().authenticate();
              //}
            },
            buttonTitle: "signIn".translate(context),
            radius: 8,
          ),
        ],
      ),
    );
  }

  Widget enterPasswordWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sidePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: FittedBox(
              fit: BoxFit.none,
              child: MaterialButton(
                onPressed: () {
                  HelperUtils.killPreviousPages(context, Routes.main, {
                    "from": "login",
                    "isSkipped": true,
                  });
                  /* Navigator.pushReplacementNamed(
                    context,
                    Routes.main,
                    arguments: {
                      "from": "login",
                      "isSkipped": true,
                    },
                  );*/
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: context.color.forthColor.withOpacity(0.102),
                elevation: 0,
                height: 28,
                minWidth: 64,
                child: Text("skip".translate(context))
                    .color(context.color.forthColor),
              ),
            ),
          ),
          const SizedBox(
            height: 66,
          ),
          Text("signInWithEmail".translate(context))
              .size(context.font.extraLarge),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Text(emailMobileTextController.text).size(context.font.large),
              const SizedBox(
                width: 5,
              ),
              InkWell(
                  child: Text("change".translate(context))
                      .underline()
                      .color(context.color.territoryColor)
                      .size(context.font.large),
                  onTap: () => Navigator.pushNamed(context, Routes.login)),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          CustomTextFormField(
            hintText: "${"password".translate(context)}*",
            controller: _passwordController,
            obscureText: isObscure,
            suffix: IconButton(
              onPressed: () {
                isObscure = !isObscure;
                setState(() {});
              },
              icon: Icon(
                !isObscure ? Icons.visibility : Icons.visibility_off,
                color: context.color.textColorDark.withOpacity(0.3),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: MaterialButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.forgotPassword);
              },
              child: Text("${"forgotPassword".translate(context)}?")
                  .color(context.color.textLightColor)
                  .size(context.font.normal),
            ),
          ),
          const SizedBox(
            height: 19,
          ),
          UiUtils.buildButton(
            context,
            onPressed: () {
              context.read<AuthenticationCubit>().setData(
                  payload: EmailLoginPayload(
                      email: emailMobileTextController.text,
                      password: _passwordController.text,
                      type: EmailLoginType.login),
                  type: AuthenticationType.email);
              context.read<AuthenticationCubit>().authenticate();
            },
            buttonTitle: "signIn".translate(context),
            radius: 8,
          ),
        ],
      ),
    );
  }
}
