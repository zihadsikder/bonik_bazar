/*
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GuestChecker {
  static final ValueNotifier<bool?> _isGuest = ValueNotifier(null);
  //static BuildContext? _context;

*/
/*  static void set() {
    _isGuest.value = HiveUtils.isUserAuthenticated();
  }*//*


*/
/*  static void setContext(BuildContext context) {
    _context = context;
  }*//*


  static void check({required Function() onNotGuest,required BuildContext context}) {


    if (_isGuest.value == true) {
      _loginBox(context);
    } else {
      onNotGuest.call();
    }
  }

*/
/*  static bool get value {
    return _isGuest.value ?? true;
  }*//*


  static ValueNotifier<bool?> listen() {
    return _isGuest;
  }

 */
/* static Widget updateUI({
    required Function(bool? isGuest) onChangeStatus,
  }) {
    return ValueListenableBuilder<bool?>(
      valueListenable: _isGuest,
      builder: (context, value, c) {
        return onChangeStatus.call(value);
      },
    );
  }*//*


  static _loginBox(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: context.color.primaryColor.darken(-5),
      enableDrag: false,
      builder: (context) {
        return Container(
          // height: 200,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Login is required to access this feature.")
                    .size(context.font.larger),
                const SizedBox(
                  height: 5,
                ),
                const Text("Tap on login to authorize")
                    .size(context.font.small),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  elevation: 0,
                  color: context.color.territoryColor,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.login,
                        arguments: {"popToCurrent": true});
                  },
                  child: const Text("Login now").color(
                    context.color.buttonColor ?? Colors.white,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
*/
