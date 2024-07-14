import 'dart:async';

import 'package:eClassify/Utils/AppIcon.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../data/cubits/auth/authentication_cubit.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  EmailVerificationScreen(
      {super.key,
      required this.email,
      required this.password,
      required this.username});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? timer;
  bool isVerified = false;

  @override
  void initState() {
    initFunction();
    super.initState();
  }

  void initFunction() {
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      bool? emailVerified = FirebaseAuth.instance.currentUser?.emailVerified;
      await FirebaseAuth.instance.currentUser?.reload();
      if (emailVerified == true) {
        Future.delayed(
          Duration.zero,
          () async {
            if (isVerified == false) {
              isVerified = true;
              setState(() {});

              await Future.delayed(const Duration(seconds: 2));
              // HelperUtils.killPreviousPages(
              //     context, Routes.main, {"from": "login"});
              /* Navigator.pushReplacementNamed(
                context,
                Routes.main,
                arguments: {"from": "login"},
              );*/

              Navigator.pushReplacementNamed(context, Routes.login
              );
              return;
            }
            // timer.cancel();
          },
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocConsumer<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) async {
            if (state is AuthenticationSuccess) {
              // if (state.type == AuthenticationType.email) {
              //   HiveUtils.setUserIsAuthenticated(true);
              //
              //   context.read<AuthCubit>().updateFCM(context);
              //   //GuestChecker.set(isGuest: false);
              //   FirebaseAuth.instance.currentUser?.sendEmailVerification();
              //
              //   Navigator.pushReplacementNamed(context, Routes.login);
              //   /* context.read<LoginCubit>().login(
              //       // phoneNumber: phoneNumber,
              //       credential: state.credential,
              //       firebaseUserId: state.credential.user!.uid,
              //       type: state.type.name);*/
              // }
            }

            if (state is AuthenticationFail) {
              // Navigator.pop<Map>(context, {
              //   "type":"Error",
              //   "error":state.error
              // });
            }
          },
          builder: (context, state) {
            if (state is AuthenticationInProcess) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is AuthenticationSuccess) {
              return Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppIcons.verificationMail),
                      const SizedBox(
                        height: 38,
                      ),
                      Text("youHaveGotEmail".translate(context))
                          .size(context.font.extraLarge)
                          .bold(weight: FontWeight.w600),
                      const SizedBox(
                        height: 14,
                      ),
                      Text("clickLinkInYourEmail".translate(context)),
                      const SizedBox(
                        height: 58,
                      ),
                      MaterialButton(
                        onPressed: () {
                          if (!isVerified) {
                            openEmailAppToList();
                            /*HelperUtils.launchPathURL(
                                isTelephone: false,
                                isSMS: false,
                                isMail: true,
                                value: '',
                                context: context);*/
                          }
                        },
                        elevation: 0,
                        minWidth: double.infinity,
                        height: 46,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: isVerified
                            ? context.color.territoryColor
                            : context.color.textLightColor,
                        child: Text(isVerified
                                ? "verified".translate(context)
                                : "checkMail".translate(context))
                            .color(context.color.buttonColor)
                            .size(context.font.large),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is AuthenticationFail) {
              return Center(
                child: Text(state.error.toString()),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }

  void openEmailAppToList() async {
    const String customUriScheme = 'email://inbox'; // Example URI
    if (await canLaunchUrlString(customUriScheme)) {
      await launchUrlString(customUriScheme);
    } else {
      // Handle case where custom URI scheme cannot be launched

      // Fallback to opening the email app normally
      await launchUrlString(
          'mailto:'); // Opens the email app without specifying the inbox
    }
  }
}
