import 'package:eClassify/Utils/Login/lib/login_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:eClassify/Utils/Login/lib/login_system.dart';


class AppleLogin extends LoginSystem {
  OAuthCredential? credential;
  OAuthProvider? oAuthProvider;
  @override
  void init() async {}

  Future<UserCredential?> login() async {
    try {
      emit(MProgress());
      final AuthorizationCredentialAppleID appleIdCredential =
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      oAuthProvider = OAuthProvider('apple.com');
      if (oAuthProvider != null) {
        credential = oAuthProvider!.credential(
          idToken: appleIdCredential.identityToken,
          accessToken: appleIdCredential.authorizationCode,
        );
        final userCredential =
        await firebaseAuth.signInWithCredential(credential!);
        emit(MSuccess(/*userCredential, type: "apple"*/));

        print("apple user credentials***$userCredential");

        return userCredential;
      }
      return null;
    } catch (e) {
      emit(MFail(e));
      throw e;
    }
  }

  @override
  void onEvent(MLoginState state) {
    print("Login state is $state");
  }
}

/*class AppleLogin extends LoginSystem {
  OAuthCredential? credential;

  @override
  void init() async {
    final AuthorizationCredentialAppleID appleIdCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
    credential = oAuthProvider.credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );
  }

  @override
  Future<UserCredential?> login() async {
    if (credential != null) {
      try {
        final userCredential =
            await firebaseAuth.signInWithCredential(credential!);

        emit(MSuccess());

        return userCredential;
      } catch (e) {
        emit(MFail(e));
      }
    }
    return null;
  }

  @override
  void onEvent(MLoginState state) {}
}*/
