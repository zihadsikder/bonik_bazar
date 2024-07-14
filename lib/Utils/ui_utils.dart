import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mime_type/mime_type.dart';

import '../Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import '../Ui/screens/widgets/blurred_dialoge_box.dart';
import '../Ui/screens/widgets/full_screen_image_view.dart';
import '../Ui/screens/widgets/gallery_view.dart';
import 'AppIcon.dart';
import 'Extensions/extensions.dart';

import 'helper_utils.dart';
import 'network_to_localsvg.dart';
import 'responsiveSize.dart';

class UiUtils {
  static SvgPicture getSvg(String path,
      {Color? color, BoxFit? fit, double? width, double? height}) {
    return SvgPicture.asset(
      path,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: fit ?? BoxFit.contain,
      width: width,
      height: height,
    );
  }

  static checkUser(
      {required Function() onNotGuest, required BuildContext context}) {
    if (!HiveUtils.isUserAuthenticated()) {
      _loginBox(context);
    } else {
      onNotGuest.call();
    }
  }

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
                Text("loginIsRequiredForAccessingThisFeatures"
                        .translate(context))
                    .size(context.font.larger),
                const SizedBox(
                  height: 5,
                ),
                Text("tapOnLoginToAuthorize".translate(context))
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
                  child: Text("loginNow".translate(context)).color(
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

  static String getTranslatedLabel(BuildContext context, String labelKey) {
    return (AppLocalization.of(context)!.getTranslatedValues(labelKey) ??
            labelKey)
        .trim();
  }

  static Map<String, double> getWidgetInfo(
      BuildContext context, GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;

    final Size size = renderBox.size; // or _widgetKey.currentContext?.size

    final Offset offset = renderBox.localToGlobal(Offset.zero);

    return {
      "x": (offset.dx),
      "y": (offset.dy),
      "width": size.width,
      "height": size.height,
      "offX": offset.dx,
      "offY": offset.dy
    };
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    List<String> result = languageCode.split("-");
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static Widget getDivider() {
    return const Divider(
      endIndent: 0,
      indent: 0,
    );
  }

  static Widget getSvgImage(String url,
      {double? width,
      double? height,
      BoxFit? fit,
      String? blurHash,
      bool? showFullScreenImage,
      Color? color}) {
    return SvgPicture.network(
      url,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      width: width,
      height: height,
      fit: fit!,
      placeholderBuilder: (context) {
        return Container(
            width: width,
            color: context.color.territoryColor.withOpacity(0.1),
            height: height,
            alignment: AlignmentDirectional.center,
            child: SizedBox(
                width: width,
                height: height,
                child: getSvg(
                  AppIcons.placeHolder,
                  width: width ?? 70,
                  height: height ?? 70,
                )));
      },
    );
  }

  static Widget getImage(String url,
      {double? width,
      double? height,
      BoxFit? fit,
      String? blurHash,
      bool? showFullScreenImage}) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) {
        return Container(
            width: width,
            color: context.color.territoryColor.withOpacity(0.1),
            height: height,
            alignment: AlignmentDirectional.center,
            child: SizedBox(
                width: width,
                height: height,
                child: getSvg(
                  AppIcons.placeHolder,
                  width: width ?? 70,
                  height: height ?? 70,
                )));
      },
      errorWidget: (context, url, error) {
        return Container(
          width: width,
          color: context.color.territoryColor.withOpacity(0.1),
          height: height,
          alignment: AlignmentDirectional.center,
          child: SizedBox(
            width: width,
            height: height,
            child: getSvg(
              AppIcons.placeHolder,
              width: width ?? 70,
              height: height ?? 70,
            ),
          ),
        );
      },
    );
  }

  static Widget progress(
      {double? width,
      double? height,
      Color? normalProgressColor,
      bool? showWhite}) {
    if (Constant.useLottieProgress) {
      return LottieBuilder.asset(
        "assets/lottie/${showWhite == true ? Constant.progressLottieFileWhite : Constant.progressLottieFile}",
        width: width ?? 45,
        height: height ?? 45,
        delegates: const LottieDelegates(values: []),
      );
    } else {
      return CircularProgressIndicator(
        color: normalProgressColor,
      );
    }
  }

  ///Divider / Container

  static SystemUiOverlayStyle getSystemUiOverlayStyle(
      {required BuildContext context, required Color statusBarColor}) {
    return SystemUiOverlayStyle(
        systemNavigationBarDividerColor: Colors.transparent,
        // systemNavigationBarColor: Theme.of(context).colorScheme.secondaryColor,
        systemNavigationBarIconBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.light
                : Brightness.dark,
        //
        statusBarColor: statusBarColor,
        statusBarBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.dark
                : Brightness.light,
        statusBarIconBrightness:
            context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
                ? Brightness.light
                : Brightness.dark);
  }

/*  static PreferredSize buildAppBar(BuildContext context,
      {String? title,
      bool? showBackButton,
      List<Widget>? actions,
      List<Widget>? bottom,
      double? bottomHeight,
      bool? hideTopBorder,
      VoidCallback? onbackpress}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(55 + (bottomHeight ?? 0)),
      child: AppBar(
        backgroundColor: context.color.secondaryColor,
        elevation: hideTopBorder ?? false ? 0 : 1.5,
        title: Row(
          children: [
            if (showBackButton ?? false) ...[
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  onbackpress?.call();
                  Navigator.pop(context);
                },
              ),
            ],
            Text(
              title ?? "",
            )
                .color(context.color.textDefaultColor)
                .bold(weight: FontWeight.w600)
                .size(18),
            if (actions != null) ...[const Spacer(), ...actions],
          ],
        ),
       */ /* shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),*/ /*
        bottom: bottom != null && bottom.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(45.0),
                // Adjust the preferred size as needed
                child: Column(
                  children: bottom,
                ),
              )
            : null,
      ),
    );
  }*/

  static PreferredSize buildAppBar(BuildContext context,
      {String? title,
      bool? showBackButton,
      List<Widget>? actions,
      List<Widget>? bottom,
      double? bottomHeight,
      bool? hideTopBorder,
      VoidCallback? onBackPress,
      Color? backgroundColor}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(55 + (bottomHeight ?? 0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: RoundedBorderOnSomeSidesWidget(
              borderColor: context.color.borderColor,
              borderRadius: 0,
              borderWidth: 1.5,
              contentBackgroundColor:
                  backgroundColor ?? context.color.secondaryColor,
              bottomLeft: true,
              bottomRight: true,
              topLeft: false,
              topRight: false,
              child: Container(
                alignment: AlignmentDirectional.bottomStart,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: (showBackButton ?? false) ? 0 : 20,
                      vertical: (showBackButton ?? false) ? 0 : 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showBackButton ?? false) ...[
                        Material(
                          clipBehavior: Clip.antiAlias,
                          color: Colors.transparent,
                          type: MaterialType.circle,
                          child: InkWell(
                            onTap: () {
                              if (onBackPress != null) {
                                onBackPress.call();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: UiUtils.getSvg(AppIcons.arrowLeft,
                                  fit: BoxFit.none,
                                  color: context.color.textDefaultColor),
                            ),
                          ),
                        ),
                      ],
                      Text(
                        title ?? "",
                      )
                          .color(context.color.textDefaultColor)
                          .bold(weight: FontWeight.w600)
                          .size(18),
                      if (actions != null) ...[const Spacer(), ...actions],
                    ],
                  ),
                ),
              ),
            ),
          ),
          ...bottom ?? [const SizedBox.shrink()]
        ],
      ),
    );
  }

  static Color makeColorDark(Color color) {
    Color color0 = color;

    int red = color0.red - 10;
    int green = color0.green - 10;
    int blue = color0.blue - 10;

    return Color.fromARGB(color0.alpha, red.clamp(0, 255), green.clamp(0, 255),
        blue.clamp(0, 255));
  }

  static Color makeColorLight(Color color) {
    Color color0 = color;

    int red = color0.red + 10;
    int green = color0.green + 10;
    int blue = color0.blue + 10;

    return Color.fromARGB(color0.alpha, red.clamp(0, 255), green.clamp(0, 255),
        blue.clamp(0, 255));
  }

  static Widget buildButton(BuildContext context,
      {double? height,
      double? width,
      BorderSide? border,
      String? titleWhenProgress,
      bool? isInProgress,
      double? fontSize,
      double? radius,
      bool? autoWidth,
      Widget? prefixWidget,
      EdgeInsetsGeometry? padding,
      required VoidCallback onPressed,
      required String buttonTitle,
      bool? showProgressTitle,
      double? progressWidth,
      double? progressHeight,
      bool? showElevation,
      Color? textColor,
      Color? buttonColor,
      EdgeInsets? outerPadding,
      Color? disabledColor,
      VoidCallback? onTapDisabledButton,
      bool? disabled}) {
    String title = "";

    if (isInProgress == true) {
      title = titleWhenProgress ?? buttonTitle;
    } else {
      title = buttonTitle;
    }

    return Padding(
      padding: outerPadding ?? EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          if (disabled == true) {
            onTapDisabledButton?.call();
          }
        },
        child: MaterialButton(
          minWidth: autoWidth == true ? null : (width ?? double.infinity),
          height: height ?? 56.rh(context),
          padding: padding,
          shape: RoundedRectangleBorder(
              side: border ?? BorderSide.none,
              borderRadius: BorderRadius.circular(radius ?? 16)),
          elevation: (showElevation ?? true) ? 0.5 : 0,
          color: buttonColor ?? context.color.territoryColor,
          disabledColor: disabledColor ?? context.color.territoryColor,
          onPressed: (isInProgress == true || (disabled ?? false))
              ? null
              : () {
                  HelperUtils.unfocus();
                  onPressed.call();
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInProgress == true) ...{
                UiUtils.progress(
                    width: progressWidth ?? 16,
                    height: progressHeight ?? 16,
                    showWhite: true),
              },
              if (isInProgress != true)
                prefixWidget ?? const SizedBox.shrink(),
              if (isInProgress != true) ...[
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  )
                      .color(textColor ?? context.color.buttonColor)
                      .size(fontSize ?? context.font.larger)
                      .centerAlign(),
                ),
              ] else ...[
                if (showProgressTitle ?? false)
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    )
                        .color(context.color.buttonColor)
                        .size(fontSize ?? context.font.larger)
                        .centerAlign(),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  static NetworkToLocalSvg networkToLocalSvg = NetworkToLocalSvg();

  static Widget imageType(String url,
      {double? width, double? height, BoxFit? fit, Color? color}) {
    String? extension = mime(url);

    if (extension == "image/svg+xml") {
      return getSvgImage(
        url,
        fit: fit,
        height: height,
        width: width,
        color: color,
      );
    } else {
      return getImage(
        url,
        fit: fit,
        height: height,
        width: width,
      );
    }
  }

  static void showFullScreenImage(BuildContext context,
      {required ImageProvider provider, VoidCallback? then}) {
    Navigator.of(context)
        .push(BlurredRouter(
            sigmaX: 10,
            sigmaY: 10,
            barrierDismiss: true,
            builder: (BuildContext context) => FullScreenImageView(
                  provider: provider,
                )))
        .then((value) {
      then?.call();
    });
  }

  static void noPackageAvailableDialog(BuildContext context) async {
    UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        title: 'noPackage'.translate(context),
        acceptButtonName: 'subscribe'.translate(context),
        cancelButtonName: 'cancelLbl'.translate(context),
        acceptButtonColor: context.color.territoryColor,
        acceptTextColor: context.color.secondaryColor,
        content: StatefulBuilder(builder: (context, update) {
          return Text('plsSubscribe'.translate(context));
        }),
        isAcceptContainesPush: false,
        onAccept: () async {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushNamed(context, Routes.subscriptionPackageListRoute);
          });
        },
      ),
    );
  }

  static void imageGallaryView(BuildContext context,
      {required List images, VoidCallback? then, required int initalIndex}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                GalleryViewWidget(images: images, initalIndex: initalIndex)));
  }

  static Future showBlurredDialoge(BuildContext context,
      {required BlurDialoge dialoge, double? sigmaX, double? sigmaY}) async {
    return await Navigator.push(
      context,
      BlurredRouter(
          barrierDismiss: true,
          builder: (context) {
            if (dialoge is BlurredDialogBox) {
              return dialoge;
            } else if (dialoge is BlurredDialogBuilderBox) {
              return dialoge;
            } else if (dialoge is EmptyDialogBox) {
              return dialoge;
            }

            return Container();
          },
          sigmaX: sigmaX,
          sigmaY: sigmaY),
    );
  }

//AAA is color theory's point it means if color is AAA then it will be perfect for your app
  static bool isColorMatchAAA(Color textColor, Color background) {
    double contrastRatio = (textColor.computeLuminance() + 0.05) /
        (background.computeLuminance() + 0.05);
    if (contrastRatio < 4.5) {
      return false;
    } else {
      return true;
    }
  }

  static double getRadiansFromDegree(double radians) {
    return radians * 180 / pi;
  }

  static Color getAdaptiveTextColor(Color color) {
    int d = 0;

// Counting the perceptive luminance - human eye favors green color...
    double luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    if (luminance > 0.5) {
      d = 0;
    } else {
      d = 255;
    } // dark colors - white font

    return Color.fromARGB(color.alpha, d, d, d);
  }

  static String time24to12hour(String time24) {
    DateTime tempDate = DateFormat("hh:mm").parse(time24);
    var dateFormat = DateFormat("h:mm a");
    return dateFormat.format(tempDate);
  }
}

///Format string
extension FormatAmount on String {
  String formatAmount({bool prefix = false}) {
    return (prefix)
        ? "${Constant.currencySymbol}${toString()}"
        : "${toString()}${Constant.currencySymbol}"; // \u{20B9}"; //currencySymbol
  }

  String formatDate({
    String? format,
  }) {
    DateFormat dateFormat = DateFormat(format ?? "MMM d, yyyy");
    String formatted = dateFormat.format(DateTime.parse(this));
    return formatted;
  }

  String formatPercentage() {
    return "${toString()} %";
  }

  String formatId() {
    return " # ${toString()} "; // \u{20B9}"; //currencySymbol
  }

  String firstUpperCase() {
    String upperCase = "";
    var suffix = "";
    if (isNotEmpty) {
      upperCase = this[0].toUpperCase();
      suffix = substring(1, length);
    }
    return (upperCase + suffix);
  }
}

//scroll controller extenstion

extension ScrollEndListen on ScrollController {
  ///It will check if scroll is at the bottom or not
  bool isEndReached() {
    if (offset >= position.maxScrollExtent) {
      return true;
    }
    return false;
  }
}

class RemoveGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class RoundedBorderOnSomeSidesWidget extends StatelessWidget {
  /// Color of the content behind this widget
  final Color contentBackgroundColor;
  final Color borderColor;
  final Widget child;

  final double borderRadius;
  final double borderWidth;

  /// The sides where we want the rounded border to be
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const RoundedBorderOnSomeSidesWidget({
    super.key,
    required this.borderColor,
    required this.contentBackgroundColor,
    required this.child,
    required this.borderRadius,
    required this.borderWidth,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.only(
          topLeft: topLeft ? Radius.circular(borderRadius) : Radius.zero,
          topRight: topRight ? Radius.circular(borderRadius) : Radius.zero,
          bottomLeft: bottomLeft ? Radius.circular(borderRadius) : Radius.zero,
          bottomRight:
              bottomRight ? Radius.circular(borderRadius) : Radius.zero,
        ),
      ),
      child: Container(
        margin: EdgeInsetsDirectional.only(
          top: topLeft || topRight ? borderWidth : 0,
          start: topLeft || bottomLeft ? borderWidth : 0,
          bottom: bottomLeft || bottomRight ? borderWidth : 0,
          end: topRight || bottomRight ? borderWidth : 0,
        ),
        decoration: BoxDecoration(
          color: contentBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: topLeft
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
            topRight: topRight
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
            bottomLeft: bottomLeft
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
            bottomRight: bottomRight
                ? Radius.circular(borderRadius - borderWidth)
                : Radius.zero,
          ),
        ),
        child: child,
      ),
    );
  }
}
