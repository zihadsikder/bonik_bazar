import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:eClassify/Ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/Ui/screens/widgets/image_cropper.dart';
import 'package:eClassify/Utils/AppIcon.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/Utils/ui_utils.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../exports/main_export.dart';
import '../../../utils/helper_utils.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';

class UserProfileScreen extends StatefulWidget {
  final String from;
  final bool? navigateToHome;
  final bool? popToCurrent;
  final AuthenticationType? type;
  final Map<String, dynamic>? extraData;

  const UserProfileScreen({
    super.key,
    required this.from,
    this.navigateToHome,
    this.popToCurrent,
    required this.type,
    this.extraData,
  });

  @override
  State<UserProfileScreen> createState() => UserProfileScreenState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return BlurredRouter(
      builder: (_) => UserProfileScreen(
        from: arguments['from'] as String,
        popToCurrent: arguments['popToCurrent'] as bool?,
        type: arguments['type'],
        navigateToHome: arguments['navigateToHome'] as bool?,
        extraData: arguments['extraData'],
      ),
    );
  }
}

class UserProfileScreenState extends State<UserProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  dynamic size;
  dynamic city, _state, country;
  double? latitude, longitude;
  String? name, email, address;
  File? fileUserimg;
  bool isNotificationsEnabled = true;
  bool? isLoading;
  String? countryCode = "+${Constant.defaultCountryCode}";

  @override
  void initState() {
    super.initState();

    city = HiveUtils.getCityName();
    _state = HiveUtils.getStateName();
    country = HiveUtils.getCountryName();
    latitude = HiveUtils.getLatitude();
    longitude = HiveUtils.getLongitude();

    nameController.text = (HiveUtils.getUserDetails().name) ?? "";
    emailController.text = HiveUtils.getUserDetails().email ?? "";
    addressController.text = HiveUtils.getUserDetails().address ?? "";
    if (widget.from == "login") {
      isNotificationsEnabled = true;
    } else {
      isNotificationsEnabled =
          HiveUtils.getUserDetails().notification == 1 ? true : false;
    }

    if (HiveUtils.getCountryCode() != null) {
      countryCode = (HiveUtils.getCountryCode() != null
          ? HiveUtils.getCountryCode()!
          : "");
      phoneController.text = HiveUtils.getUserDetails().mobile != null
          ? HiveUtils.getUserDetails().mobile!.replaceFirst("+$countryCode", "")
          : "";
    } else {
      phoneController.text = HiveUtils.getUserDetails().mobile != null
          ? HiveUtils.getUserDetails().mobile!
          : "";
    }
  }

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
  }

  /* void _onTapChooseLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      */ /*    if (Constant.isDemoModeOn) {
        HelperUtils.showSnackBarMessage(context, "Not valid in demo mode");

        return;
      }*/ /*
    }

    var result = await showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      context: context,
      builder: (context) {
        return const ChooseLocatonBottomSheet();
      },
    );
    if (result != null) {
      GooglePlaceModel place = (result as GooglePlaceModel);

      city = place.city;
      country = place.country;
      _state = place.state;
      latitude = double.parse(place.latitude);
      longitude = double.parse(place.longitude);
    }
  }*/

  void _onTapVerifyPhoneNumber() {
    //verify phone number before update
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: safeAreaCondition(
        child: Scaffold(
          backgroundColor: context.color.primaryColor,
          appBar: widget.from == "login"
              ? null
              : UiUtils.buildAppBar(context, showBackButton: true),
          body: Stack(
            children: [
              ScrollConfiguration(
                behavior: RemoveGlow(),
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Align(
                                  alignment: AlignmentDirectional.center,
                                  child: buildProfilePicture(),
                                ),
                                buildTextField(
                                  context,
                                  title: "fullName",
                                  controller: nameController,
                                  validator: CustomTextFieldValidator.nullCheck,
                                ),
                                buildTextField(
                                  context,
                                  readOnly: HiveUtils.getUserDetails().type ==
                                              AuthenticationType.email.name ||
                                          HiveUtils.getUserDetails().type ==
                                              AuthenticationType.google.name ||
                                          HiveUtils.getUserDetails().type ==
                                              AuthenticationType.apple.name
                                      ? true
                                      : false,
                                  title: "emailAddress",
                                  controller: emailController,
                                  validator: CustomTextFieldValidator.email,
                                ),
                                phoneWidget(),
                                buildAddressTextField(
                                  context,
                                  title: "addressLbl",
                                  controller: addressController,
                                ),
                                SizedBox(
                                  height: 10.rh(context),
                                ),
                                Text(
                                  "notification".translate(context),
                                ),
                                SizedBox(
                                  height: 10.rh(context),
                                ),
                                buildNotificationEnableDisableSwitch(context),
                                SizedBox(
                                  height: 25.rh(context),
                                ),
                                UiUtils.buildButton(
                                  context,
                                  onPressed: () {
                                    if (widget.from == 'login') {
                                      validateData();
                                    } else {
                                      if (city != null && city != "") {
                                        HiveUtils.setCurrentLocation(
                                            city: city,
                                            state: _state,
                                            country: country,
                                            latitude: latitude,
                                            longitude: longitude);

                                        context
                                            .read<SliderCubit>()
                                            .fetchSlider(context);
                                      } else {
                                        HiveUtils.clearLocation();

                                        context
                                            .read<SliderCubit>()
                                            .fetchSlider(context);
                                      }
                                      validateData();
                                    }
                                  },
                                  height: 48.rh(context),
                                  buttonTitle:
                                      "updateProfile".translate(context),
                                )
                              ])),
                    )),
              ),
              if (isLoading != null && isLoading!)
                Center(
                  child: UiUtils.progress(
                    normalProgressColor: context.color.territoryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget phoneWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 10.rh(context),
      ),
      Text("phoneNumber".translate(context))
          .color(context.color.textDefaultColor),
      SizedBox(
        height: 10.rh(context),
      ),
      CustomTextFormField(
        controller: phoneController,
        validator: CustomTextFieldValidator.phoneNumber,
        keyboard: TextInputType.phone,
        isReadOnly:
            HiveUtils.getUserDetails().type == AuthenticationType.phone.name
                ? true
                : false,
        fillColor: context.color.secondaryColor,
        // borderColor: context.color.borderColor.darken(10),
        onChange: (value) {
          setState(() {});
        },
        /* suffix: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _onTapVerifyPhoneNumber,
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: SizedBox(
                  child: Text("verify".translate(context))
                      .bold()
                      .color(context.color.territoryColor),
                ),
              ),
            ),
          ],
        ),*/
        fixedPrefix: SizedBox(
          width: 55,
          child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                onTap: () {
                  showCountryCode();
                },
                child: Container(
                  // color: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                  child: Center(
                      child: Text("$countryCode")
                          .size(context.font.large)
                          .centerAlign()),
                ),
              )),
        ),
        hintText: "phoneNumber".translate(context),
      )
    ]);
  }

  /* Widget locationWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.color.borderColor.darken(40),
                    width: 1.5,
                  )),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10.0),
                    child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: (city != "" && city != null)
                            ? Text("$city,$_state,$country")
                            : Text(
                                "selectLocationOptional".translate(context))),
                  ),
                  const Spacer(),
                  if (city != "" && city != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          city = "";
                          _state = "";
                          country = "";
                          latitude = null;
                          longitude = null;
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close,
                          color: context.color.textColorDark,
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: _onTapChooseLocation,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.color.borderColor.darken(40),
                    width: 1.5,
                  )),
              child: Icon(
                Icons.location_searching_sharp,
                color: context.color.territoryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  Widget safeAreaCondition({required Widget child}) {
    if (widget.from == "login") {
      return SafeArea(child: child);
    }
    return child;
  }

  Widget buildNotificationEnableDisableSwitch(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: context.color.borderColor.darken(40),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          color: context.color.secondaryColor),
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text((isNotificationsEnabled
                        ? "enabled".translate(context)
                        : "disabled".translate(context))
                    .translate(context))
                .size(context.font.large),
          ),
          CupertinoSwitch(
            activeColor: context.color.territoryColor,
            value: isNotificationsEnabled,
            onChanged: (value) {
              isNotificationsEnabled = value;
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  Widget buildTextField(BuildContext context,
      {required String title,
      required TextEditingController controller,
      CustomTextFieldValidator? validator,
      bool? readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        Text(title.translate(context)).color(context.color.textDefaultColor),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          controller: controller,
          isReadOnly: readOnly,
          validator: validator,
          // formaters: [FilteringTextInputFormatter.deny(RegExp(","))],
          fillColor: context.color.secondaryColor,
        ),
      ],
    );
  }

  Widget buildAddressTextField(BuildContext context,
      {required String title,
      required TextEditingController controller,
      CustomTextFieldValidator? validator,
      bool? readOnly}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10.rh(context),
        ),
        Text(title.translate(context)),
        SizedBox(
          height: 10.rh(context),
        ),
        CustomTextFormField(
          controller: controller,
          maxLine: 5,
          action: TextInputAction.newline,
          isReadOnly: readOnly,
          fillColor: context.color.secondaryColor,
        ),
        /*const SizedBox(
          width: 10,
        ),
        locationWidget(context),
        const SizedBox(
          height: 10,
        ),
        Text("enablesNewSection".translate(context))
            .size(context.font.small)
            .bold(weight: FontWeight.w300)
            .color(
          context.color.textColorDark
              .withOpacity(0.8),
        ),*/
      ],
    );
  }

  Widget getProfileImage() {
    if (fileUserimg != null) {
      return Image.file(
        fileUserimg!,
        fit: BoxFit.cover,
      );
    } else {
      if (widget.from == "login") {
        if (HiveUtils.getUserDetails().profile != "" &&
            HiveUtils.getUserDetails().profile != null) {
          return UiUtils.getImage(
            HiveUtils.getUserDetails().profile!,
            fit: BoxFit.cover,
          );
        }

        return UiUtils.getSvg(
          AppIcons.defaultPersonLogo,
          color: context.color.territoryColor,
          fit: BoxFit.none,
        );
      } else {
        if ((HiveUtils.getUserDetails().profile ?? "").isEmpty) {
          return UiUtils.getSvg(
            AppIcons.defaultPersonLogo,
            color: context.color.territoryColor,
            fit: BoxFit.none,
          );
        } else {
          return UiUtils.getImage(
            HiveUtils.getUserDetails().profile!,
            fit: BoxFit.cover,
          );
        }
      }
    }
  }

  Widget buildProfilePicture() {
    return Stack(
      children: [
        Container(
          height: 124.rh(context),
          width: 124.rw(context),
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: context.color.territoryColor, width: 2)),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.color.territoryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            width: 106.rw(context),
            height: 106.rh(context),
            child: getProfileImage(),
          ),
        ),
        PositionedDirectional(
          bottom: 0,
          end: 0,
          child: InkWell(
            onTap: showPicker,
            child: Container(
                height: 37.rh(context),
                width: 37.rw(context),
                alignment: AlignmentDirectional.center,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: context.color.buttonColor, width: 1.5),
                    shape: BoxShape.circle,
                    color: context.color.territoryColor),
                child: SizedBox(
                    width: 15.rw(context),
                    height: 15.rh(context),
                    child: UiUtils.getSvg(AppIcons.edit))),
          ),
        )
      ],
    );
  }

  Future<void> validateData() async {
    if (_formKey.currentState!.validate()) {
      profileupdateprocess();
    }
  }

  profileupdateprocess() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await context.read<AuthCubit>().updateuserdata(context,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          fileUserimg: fileUserimg,
          address: addressController.text,
          mobile: phoneController.text,
          notification: isNotificationsEnabled == true ? "1" : "0");

      Future.delayed(
        Duration.zero,
        () {
          context
              .read<UserDetailsCubit>()
              .copy(UserModel.fromJson(response['data']));
        },
      );

      Future.delayed(
        Duration.zero,
        () {
          setState(() {
            isLoading = false;
          });
          HelperUtils.showSnackBarMessage(
            context,
            response['message'],
          );
          if (widget.from != "login") {
            Navigator.pop(context);
          }
        },
      );

      if (widget.from == "login" && widget.popToCurrent != true) {
        Future.delayed(
          Duration.zero,
          () {
            if (HiveUtils.getCityName() != null &&
                HiveUtils.getCityName() != "") {
              HelperUtils.killPreviousPages(
                  context, Routes.main, {"from": widget.from});
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.locationPermissionScreen, (route) => false);
            }
          },
        );
      } else if (widget.from == "login" && widget.popToCurrent == true) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context)
            ..pop()
            ..pop();
        });
      }
    } catch (e) {
      Future.delayed(Duration.zero, () {
        setState(() {
          isLoading = false;
        });
        HelperUtils.showSnackBarMessage(context, e.toString());
      });
    }
  }

  void showPicker() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(10)),
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text("gallery".translate(context)),
                    onTap: () {
                      _imgFromGallery(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text("camera".translate(context)),
                  onTap: () {
                    _imgFromGallery(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                if (fileUserimg != null && widget.from == 'login')
                  ListTile(
                    leading: const Icon(Icons.clear_rounded),
                    title: Text("lblremove".translate(context)),
                    onTap: () {
                      fileUserimg = null;

                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
              ],
            ),
          );
        });
  }

  _imgFromGallery(ImageSource imageSource) async {
    CropImage.init(context);

    final pickedFile = await ImagePicker().pickImage(source: imageSource);

    if (pickedFile != null) {
      CroppedFile? croppedFile;
      croppedFile = await CropImage.crop(
        filePath: pickedFile.path,
      );
      if (croppedFile == null) {
        fileUserimg = null;
      } else {
        fileUserimg = File(croppedFile.path);
      }
    } else {
      fileUserimg = null;
    }
    setState(() {});
  }

  void showCountryCode() {
    showCountryPicker(
      context: context,
      showWorldWide: false,
      showPhoneCode: true,
      countryListTheme:
          CountryListThemeData(borderRadius: BorderRadius.circular(11)),
      onSelect: (Country value) {
        countryCode = value.phoneCode;
        setState(() {});
      },
    );
  }
}
