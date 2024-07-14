import 'dart:io';

import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/Login/AppleLogin/apple_login.dart';
import 'package:eClassify/Utils/Login/EmailLogin/email_login.dart';
import 'package:eClassify/Utils/Login/GoogleLogin/google_login.dart';
import 'package:eClassify/Utils/Login/PhoneLogin/phone_login.dart';
import 'package:eClassify/Utils/Login/lib/login_system.dart';
import 'package:eClassify/Utils/helper_utils.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:eClassify/Utils/Login/lib/login_status.dart';
import 'package:eClassify/Utils/Login/lib/payloads.dart';

enum AuthenticationType {
  email,
  google,
  apple,
  phone;
}

abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationInProcess extends AuthenticationState {
  final AuthenticationType type;

  AuthenticationInProcess(this.type);
}

class AuthenticationSuccess extends AuthenticationState {
  final AuthenticationType type;
  final UserCredential credential;

  AuthenticationSuccess(this.type, this.credential);
}

class AuthenticationFail extends AuthenticationState {
  final dynamic error;

  AuthenticationFail(this.error);
}

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationInitial());
  AuthenticationType? type;
  LoginPayload? payload;
  MMultiAuthentication mMultiAuthentication = MMultiAuthentication({
    "google": GoogleLogin(),
    "email": EmailLogin(),
    if (Platform.isIOS) "apple": AppleLogin(),
    "phone": PhoneLogin()
  });

  void init() {
    mMultiAuthentication.init();
  }

  void setData(
      {required LoginPayload payload, required AuthenticationType type}) {
    this.type = type;
    this.payload = payload;
  }

  void authenticate() async {
    if (type == null && payload == null) {
      return;
    }

    try {
      emit(AuthenticationInProcess(type!));
      mMultiAuthentication.setActive(type!.name);
      mMultiAuthentication.payload = MultiLoginPayload({
        type!.name: payload!,
      });

      UserCredential? credential = await mMultiAuthentication.login();

      print("auth cubit user credentials****$credential");
      LoginPayload? payloadData = (payload);

      if (payloadData is EmailLoginPayload &&
          payloadData.type == EmailLoginType.login) {
        if (credential != null) {
          User? user = credential.user;
          if (user != null && !user.emailVerified) {
            // Handle the case when the user's email is not verified
            emit(AuthenticationFail(HelperUtils.showSnackBarMessage(
                Constant.navigatorKey.currentContext,
                "pleaseFirstVerifyUser"
                    .translate(Constant.navigatorKey.currentContext!))));
          } else {
            emit(AuthenticationSuccess(type!, credential));
          }
        }
      } else {
        emit(AuthenticationSuccess(type!, credential!));
      }
      /*if (credential != null) {
        emit(AuthenticationSuccess(type!, credential));
      }
      else
        {
          emit(AuthenticationFail(""));
        }*/
    } catch (e) {
      emit(AuthenticationFail(e));
    }
  }

  void listen(Function(MLoginState state) fn) {
    mMultiAuthentication.listen(fn);
  }

  void verify() {
    mMultiAuthentication.setActive(type!.name);
    mMultiAuthentication.payload = MultiLoginPayload({
      type!.name: payload!,
    });
    mMultiAuthentication.requestVerification();
  }
}
/*import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:eClassify/Ui/screens/Auth/login_screen.dart';
import 'package:eClassify/Ui/screens/Auth/signup_screen.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../Utils/Login/AppleLogin/apple_login.dart';
import '../../../Utils/Login/EmailLogin/email_login.dart';
import '../../../Utils/Login/GoogleLogin/google_login.dart';
import '../../../Utils/Login/PhoneLogin/phone_login.dart';
import '../../../Utils/Login/lib/login_status.dart';
import '../../../Utils/Login/lib/login_system.dart';
import '../../../Utils/Login/lib/payloads.dart';

  enum AuthenticationType {
    email,
    google,
    apple,
    phone,
  }

  abstract class AuthenticationState {}

  class AuthenticationInitial extends AuthenticationState {}

  class AuthenticationInProcess extends AuthenticationState {
    final AuthenticationType type;

    AuthenticationInProcess(this.type);
  }

  class AuthenticationSuccess extends AuthenticationState {
    final AuthenticationType type;
    final UserCredential credential;

    AuthenticationSuccess(this.type, this.credential);
  }

  class AuthenticationFail extends AuthenticationState {
    final dynamic error;

    AuthenticationFail(this.error);
  }

  class AuthenticationCubit extends Cubit<AuthenticationState> {
    AuthenticationCubit() : super(AuthenticationInitial());

    AuthenticationType? type;
    LoginPayload? payload;
    MMultiAuthentication mMultiAuthentication = MMultiAuthentication({
      "google": GoogleLogin(),
      "email": EmailLogin(),
      if (Platform.isIOS) "apple": AppleLogin(),
      "phone": PhoneLogin()
    });

    void init() {
      mMultiAuthentication.init();
    }

    void setData(
        {required LoginPayload payload, required AuthenticationType type}) {
      this.type = type;
      this.payload = payload;
    }


    void authenticate(BuildContext context) async {
      if (type == null && payload == null) {
        return;
      }

      // Determine the context (LoginScreen or SignupScreen)
      if (context.read<LoginScreen>() != null) {
        // Handle authentication for LoginScreen
        emit(AuthenticationInProcess(AuthenticationType.email));
        try {
          // Perform authentication logic specific to LoginScreen
          // Example: Call authentication API for email login
          emit(AuthenticationInProcess(type!));
          mMultiAuthentication.setActive(type!.name);
          mMultiAuthentication.payload = MultiLoginPayload({
            type!.name: payload!,
          });
          UserCredential? credential = await EmailLogin().login();
          emit(AuthenticationSuccess(AuthenticationType.email, credential!));
        } catch (e) {
          emit(AuthenticationFail(e));
        }
      } else if (context.read<SignupScreen>() != null) {
        // Handle authentication for SignupScreen
        emit(AuthenticationInProcess(AuthenticationType.google));
        try {
          // Perform authentication logic specific to SignupScreen
          // Example: Call authentication API for Google login
          emit(AuthenticationInProcess(type!));
          mMultiAuthentication.setActive(type!.name);
          mMultiAuthentication.payload = MultiLoginPayload({
            type!.name: payload!,
          });
          UserCredential? credential = await GoogleLogin().login();
          emit(AuthenticationSuccess(AuthenticationType.google, credential!));
        } catch (e) {
          emit(AuthenticationFail(e));
        }
      }
    }


    void listen(Function(MLoginState state) fn) {
      mMultiAuthentication.listen(fn);
    }

    void verify() {
      mMultiAuthentication.setActive(type!.name);
      mMultiAuthentication.payload = MultiLoginPayload({
        type!.name: payload!,
      });
      mMultiAuthentication.requestVerification();
    }
  }*/
