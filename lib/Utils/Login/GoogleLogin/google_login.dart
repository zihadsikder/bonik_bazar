import 'package:eClassify/Utils/Login/lib/login_status.dart';
import 'package:eClassify/Utils/Login/lib/login_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin extends LoginSystem {
  GoogleSignIn? _googleSignIn;

  @override
  void init() async {
    _googleSignIn = GoogleSignIn();
  }

  @override
  Future<UserCredential?> login() async {
    try {
      emit(MProgress());
      GoogleSignInAccount? googleSignIn = await _googleSignIn?.signIn();
      if (googleSignIn == null) {
        print("google-terminated");
        throw ErrorDescription("google-terminated");
      }
      GoogleSignInAuthentication? googleAuth =
          await googleSignIn.authentication;

      AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(authCredential);
      emit(MSuccess());

      return userCredential;
    } catch (e) {
      if (e is ErrorDescription) {
        print("Error if: google-terminated");
        emit(MFail("google-terminated"));
      } else {
        print("Error else: ${e.toString()}");
        emit(MFail(e.toString()));
      }

      rethrow;
    }
  }

  @override
  void onEvent(MLoginState state) {
    // TODO: implement onEvent
  }
}
