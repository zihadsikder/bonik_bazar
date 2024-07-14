import 'package:flutter/material.dart';

import '../../../../utils/AppIcon.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/ui_utils.dart';

class NoInternet extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternet({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
          context: context, statusBarColor: context.color.primaryColor),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: SizedBox(
          height: context.screenHeight,
          width: context.screenWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  // width: 100,
                  // height: 150,
                  child: UiUtils.getSvg(AppIcons.no_internet)),
              const SizedBox(
                height: 20,
              ),
              Text("noInternet".translate(context))
                  .size(context.font.extraLarge)
                  .color(context.color.territoryColor)
                  .bold(weight: FontWeight.w600),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: context.screenWidth * 0.8,
                  child: Text(
                    "noInternetErrorMsg".translate(context),
                    textAlign: TextAlign.center,
                  )),
              const SizedBox(
                height: 5,
              ),
              TextButton(
                  onPressed: onRetry,
                  style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(
                          context.color.territoryColor.withOpacity(0.2))),
                  child: Text("retry".translate(context))
                      .color(context.color.territoryColor))
            ],
          ),
        ),
      ),
    );
  }
}
