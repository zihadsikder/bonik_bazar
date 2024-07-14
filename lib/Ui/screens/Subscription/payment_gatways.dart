// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:eClassify/Utils/AppIcon.dart';
import 'package:eClassify/Utils/payment/gatways/stripe_service.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../Utils/ui_utils.dart';
import '../../../utils/Extensions/extensions.dart';

import '../../../utils/helper_utils.dart';

class PaymentGateways {
  static PaystackPlugin payStackPlugin = PaystackPlugin();

  static String generateReference(String email) {
    late String platform;
    if (Platform.isIOS) {
      platform = 'I';
    } else if (Platform.isAndroid) {
      platform = 'A';
    }
    String reference =
        '${platform}_${email.split("@").first}_${DateTime.now().millisecondsSinceEpoch}';
    return reference;
  }

  static Future<void> stripe(BuildContext context,
      {required double price,
      required int packageId,
      required dynamic paymentIntent}) async {
    print("payment intent****${paymentIntent["client_secret"]}");
    String paymentIntentId = paymentIntent["id"].toString();
    String clientSecret =
        paymentIntent['payment_gateway_response']["client_secret"].toString();

    await StripeService.payWithPaymentSheet(
      context: context,
      merchantDisplayName: Constant.appName,
      amount: paymentIntent["amount"].toString(),
      currency: AppSettings.stripeCurrency,
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
    );
  }

  static void initPaystack() {
    if (AppSettings.payStackStatus == 1) {
      if (!payStackPlugin.sdkInitialized) {
        payStackPlugin.initialize(publicKey: AppSettings.payStackKey);
      }
    }
  }

  static Future<void> paystack(
      {required BuildContext context,
      required price,
      required packageId,
      required orderId}) async {
    if (HiveUtils.getUserDetails().email != "" ||
        HiveUtils.getUserDetails().email != null) {
      Charge paystackCharge = Charge()
        ..amount = (price! * 100).toInt()
        ..email = HiveUtils.getUserDetails().email ?? ""
        ..currency = AppSettings.payStackCurrency
        ..reference =
            orderId; /*generateReference(HiveUtils.getUserDetails().email ?? "")*/
      /*..putMetaData("username", HiveUtils.getUserDetails().name)
        ..putMetaData("package_id", packageId)
        ..putMetaData('order_id', orderId)
        ..putMetaData("user_id", HiveUtils.getUserId());
*/
      CheckoutResponse checkoutResponse = await payStackPlugin.checkout(context,
          logo: SizedBox(
              height: 50,
              width: 50,
              child: UiUtils.getSvg(AppIcons.splashLogo)),
          charge: paystackCharge,
          method: CheckoutMethod.card);

      if (checkoutResponse.status) {
        if (checkoutResponse.verify) {
          Future.delayed(
            Duration.zero,
            () async {
              await _purchase(context);
            },
          );
        }
      } else {
        Future.delayed(
          Duration.zero,
          () {
            HelperUtils.showSnackBarMessage(
                context, UiUtils.getTranslatedLabel(context, "purchaseFailed"));
          },
        );
      }
    } else {
      HelperUtils.showSnackBarMessage(
          context, "addEmailInYourProfile".translate(context));
    }
  }

/*  static Future<void> paystack(
      BuildContext context, dynamic price, dynamic packageId) async {
    Charge paystackCharge = Charge()
      ..amount = (price! * 100).toInt()
      ..email = HiveUtils.getUserDetails().email ?? ""
      ..currency = AppSettings.payStackCurrency
      ..reference = generateReference(HiveUtils.getUserDetails().email ?? "")
      ..putMetaData("username", HiveUtils.getUserDetails().name)
      ..putMetaData("package_id", packageId)
      ..putMetaData("user_id", HiveUtils.getUserId());

    CheckoutResponse checkoutResponse = await payStackPlugin.checkout(context,
        logo: SizedBox(
            height: 50,
            width: 50,
            child: UiUtils.getSvg(AppIcons.splashLogo,
                color: context.color.territoryColor)),
        charge: paystackCharge,
        method: CheckoutMethod.card);

    if (checkoutResponse.status) {
      if (checkoutResponse.verify) {
        Future.delayed(
          Duration.zero,
          () async {
            await _purchase(context);
          },
        );
      }
    } else {
      Future.delayed(
        Duration.zero,
        () {
          HelperUtils.showSnackBarMessage(
              context, UiUtils.getTranslatedLabel(context, "purchaseFailed"));
        },
      );
    }
  }*/

  static void razorpay(
      {required BuildContext context,
      required price,
      required orderId,
      required packageId}) {
    final Razorpay razorpay = Razorpay();

    var options = {
      'key': AppSettings.razorpayKey,
      'amount': price! * 100,
      'name': HiveUtils.getUserDetails().name ?? "",
      'description': '',
      'order_id': orderId,
      'prefill': {
        'contact': HiveUtils.getUserDetails().mobile ?? "",
        'email': HiveUtils.getUserDetails().email ?? ""
      },
      "notes": {"package_id": packageId, "user_id": HiveUtils.getUserId()},
    };

    if (AppSettings.razorpayKey != "") {
      razorpay.open(options);
      razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS,
        (
          PaymentSuccessResponse response,
        ) async {
          await _purchase(context);
        },
      );
      razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR,
        (PaymentFailureResponse response) {
          HelperUtils.showSnackBarMessage(
              context, UiUtils.getTranslatedLabel(context, "purchaseFailed"));
        },
      );
      razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET,
        (e) {},
      );
    } else {
      HelperUtils.showSnackBarMessage(
          context, UiUtils.getTranslatedLabel(context, "setAPIkey"));
    }
  }

  /*static void razorpay(
    BuildContext context, {
    required price,
    required package,
  }) {
    final Razorpay razorpay = Razorpay();

    var options = {
      'key': AppSettings.razorpayKey,
      'amount': price! * 100,
      'name': package.name,
      'description': '',
      'prefill': {
        'contact': HiveUtils.getUserDetails().mobile ?? "",
        'email': HiveUtils.getUserDetails().email ?? ""
      },
      "notes": {"package_id": package.id, "user_id": HiveUtils.getUserId()},
    };

    if (AppSettings.razorpayKey != "") {
      razorpay.open(options);
      razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS,
        (
          PaymentSuccessResponse response,
        ) async {
          await _purchase(context);
        },
      );
      razorpay.on(
        Razorpay.EVENT_PAYMENT_ERROR,
        (PaymentFailureResponse response) {
          HelperUtils.showSnackBarMessage(
              context, UiUtils.getTranslatedLabel(context, "purchaseFailed"));
        },
      );
      razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET,
        (e) {},
      );
    } else {
      HelperUtils.showSnackBarMessage(
          context, UiUtils.getTranslatedLabel(context, "setAPIkey"));
    }
  }*/

  static Future<void> _purchase(BuildContext context) async {
    try {
      Future.delayed(
        Duration.zero,
        () {
          HelperUtils.showSnackBarMessage(
              context, UiUtils.getTranslatedLabel(context, "success"),
              type: MessageType.success, messageDuration: 5);

          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    } catch (e) {
      HelperUtils.showSnackBarMessage(
          context, UiUtils.getTranslatedLabel(context, "purchaseFailed"),
          type: MessageType.error);
    }
  }
}
