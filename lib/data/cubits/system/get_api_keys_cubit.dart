/*
// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:eClassify/Utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetApiKeysCubit extends Cubit<GetApiKeysState> {
  GetApiKeysCubit() : super(GetApiKeysInitial());

  Future<void> fetch() async {
    try {
      emit(GetApiKeysInProgress());

      Map<String, dynamic> result = await Api.get(
        url: Api.getPaymentSettingsApi,
      );

      var data = result['data'];

      emit(GetApiKeysSuccess(
          stripeCurrency: data['Stripe']['currency_code'],
          stripePublishableKey: data['Stripe']['api_key'].toString(),
          stripeSecretKey: ''));
    } catch (e) {
      emit(GetApiKeysFail(e.toString()));
    }
  }

  dynamic _getDataFromKey(List data, String key) {
    try {
      return data.where((element) => element['type'] == key).first['data'];
    } catch (e) {
      if (e.toString().contains("Bad state")) {
        throw "The key>>> $key is not comming from API";
      }
    }
  }
}

abstract class GetApiKeysState {}

class GetApiKeysInitial extends GetApiKeysState {}

class GetApiKeysInProgress extends GetApiKeysState {}

class GetApiKeysSuccess extends GetApiKeysState {
  final String? razorPayApiKey;
  final String? razorPayCurrency;
  final int? razorPayStatus;
  final String? payStackApiKey;
  final int? payStackStatus;
  final String? payStackCurrency;
  final String? stripeCurrency;
  final String? stripePublishableKey;
  final int? stripeStatus;

  GetApiKeysSuccess({
     this.razorPayApiKey,
     this.razorPayCurrency,
     this.razorPayStatus,
     this.payStackApiKey,
     this.payStackStatus,
     this.payStackCurrency,
     this.stripeCurrency,
     this.stripePublishableKey,
     this.stripeStatus,
  });

  @override
  String toString() {
    // return 'GetApiKeysSuccess(razorPayKey: $razorPayKey, razorPaySecret: $razorPaySecret, paystackPublicKey: $paystackPublicKey, paystackSecret: $paystackSecret, paystackCurrency: $paystackCurrency, enabledPaymentGatway: $enabledPaymentGatway, stripeCurrency: $stripeCurrency, stripePublishableKey: $stripePublishableKey, stripeSecretKey: $stripeSecretKey)';
    return 'GetApiKeysSuccess(razorPayApiKey:$razorPayApiKey,razorPayCurrency"$razorPayCurrency,razorPayStatus:$razorPayStatus,payStackStatus:$payStackStatus,payStackCurrency:$payStackCurrency,payStackApiKey:$payStackApiKey,stripeCurrency: $stripeCurrency, stripePublishableKey: $stripePublishableKey, stripeStatus: $stripeStatus)';
  }
}

class GetApiKeysFail extends GetApiKeysState {
  final dynamic error;

  GetApiKeysFail(this.error);
}
*/



// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';
import 'package:eClassify/Utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetApiKeysCubit extends Cubit<GetApiKeysState> {
  GetApiKeysCubit() : super(GetApiKeysInitial());

  Future<void> fetch() async {
    try {
      emit(GetApiKeysInProgress());

      Map<String, dynamic> result = await Api.get(
        url: Api.getPaymentSettingsApi,
      );

      var data = result['data'];

      emit(GetApiKeysSuccess(
        razorPayApiKey: _getDataFromMap(data, 'Razorpay', 'api_key'),
        razorPayCurrency: _getDataFromMap(data, 'Razorpay', 'currency_code'),
        razorPayStatus: int.tryParse(_getDataFromMap(data, 'Razorpay', 'status') ?? '0'),
        payStackApiKey: _getDataFromMap(data, 'Paystack', 'api_key'),
        payStackStatus: int.tryParse(_getDataFromMap(data, 'Paystack', 'status') ?? '0'),
        payStackCurrency: _getDataFromMap(data, 'Paystack', 'currency_code'),
        stripeCurrency: _getDataFromMap(data, 'Stripe', 'currency_code'),
        stripePublishableKey: _getDataFromMap(data, 'Stripe', 'api_key'),
        stripeStatus: int.tryParse(_getDataFromMap(data, 'Stripe', 'status') ?? '0'),
      ));
    } catch (e) {
      emit(GetApiKeysFail(e.toString()));
    }
  }

  String? _getDataFromMap(Map<String, dynamic> data, String paymentType, String key) {
    try {
      return data[paymentType]?[key]?.toString();
    } catch (e) {
      log("The key>>> $key for $paymentType is not coming from API");
      return null;
    }
  }
}

abstract class GetApiKeysState {}

class GetApiKeysInitial extends GetApiKeysState {}

class GetApiKeysInProgress extends GetApiKeysState {}

class GetApiKeysSuccess extends GetApiKeysState {
  final String? razorPayApiKey;
  final String? razorPayCurrency;
  final int? razorPayStatus;
  final String? payStackApiKey;
  final int? payStackStatus;
  final String? payStackCurrency;
  final String? stripeCurrency;
  final String? stripePublishableKey;
  final int? stripeStatus;

  GetApiKeysSuccess({
    this.razorPayApiKey,
    this.razorPayCurrency,
    this.razorPayStatus,
    this.payStackApiKey,
    this.payStackStatus,
    this.payStackCurrency,
    this.stripeCurrency,
    this.stripePublishableKey,
    this.stripeStatus,
  });

  @override
  String toString() {
    return 'GetApiKeysSuccess(razorPayApiKey:$razorPayApiKey, razorPayCurrency:$razorPayCurrency, razorPayStatus:$razorPayStatus, payStackApiKey:$payStackApiKey, payStackStatus:$payStackStatus, payStackCurrency:$payStackCurrency, stripeCurrency:$stripeCurrency, stripePublishableKey:$stripePublishableKey, stripeStatus:$stripeStatus)';
  }
}

class GetApiKeysFail extends GetApiKeysState {
  final dynamic error;

  GetApiKeysFail(this.error);
}

