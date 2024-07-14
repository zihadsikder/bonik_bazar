// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:eClassify/Utils/api.dart';
import 'package:eClassify/Utils/hive_utils.dart';
import 'package:eClassify/data/Repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final bool isProfileCompleted;
  final UserCredential credential;
  final Map<String, dynamic> apiResponse;

  LoginSuccess({
    required this.isProfileCompleted,
    required this.credential,
    required this.apiResponse,
  });
}

class LoginFailure extends LoginState {
  final dynamic errorMessage;

  LoginFailure(this.errorMessage);
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final AuthRepository _authRepository = AuthRepository();

  void login(
      {String? phoneNumber,
      required String firebaseUserId,
      required String type,
      required UserCredential credential,
      String? countryCode}) async {
    try {
      emit(LoginInProgress());

      String? token = await FirebaseMessaging.instance.getToken();

      Map<String, dynamic> result = await _authRepository.numberLoginWithApi(
          phone: phoneNumber ?? credential.user!.providerData[0].phoneNumber,
          type: type,
          uid: firebaseUserId,
          fcmId: token!,
          email: credential.user!.providerData[0].email,
          name: credential.user!.providerData[0].displayName,
          profile: credential.user!.providerData[0].photoURL,
          countryCode: countryCode);

      ///Storing data to local database {HIVE}
      HiveUtils.setJWT(result['token']);

      if ((result['data']['name'] == "" || result['data']['name'] == null) ||
          (result['data']['email'] == "" || result['data']['email'] == null) ||
          (result['data']['mobile'] == "" ||
              result['data']['mobile'] == null)) {
        HiveUtils.setProfileNotCompleted();

        var data = result['data'];
        //data['countryCode'] = countryCode;
        HiveUtils.setUserData(data);
        emit(LoginSuccess(
            apiResponse: Map<String, dynamic>.from(result['data']),
            isProfileCompleted: false,
            credential: credential));
      } else {
        var data = result['data'];
        //data['countryCode'] = countryCode;
        HiveUtils.setUserData(data);
        emit(LoginSuccess(
            apiResponse: Map<String, dynamic>.from(result['data']),
            isProfileCompleted: true,
            credential: credential));
      }
    } catch (e) {
      if (e is ApiException) {}

      emit(LoginFailure(e));
    }
  }
}
