import 'dart:io';

import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Utils/AppIcon.dart';
import '../../Utils/hive_Utils.dart';
import '../../Utils/ui_utils.dart';
import '../../app/routes.dart';
import 'Widgets/AnimatedRoutes/blur_page_route.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  LocationPermissionScreenState createState() =>
      LocationPermissionScreenState();

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(builder: (_) => const LocationPermissionScreen());
  }
}

class LocationPermissionScreenState extends State<LocationPermissionScreen>
    with WidgetsBindingObserver {
  bool _openedAppSettings = false;

  @override
  void initState() {
    // _checkLocationPermission();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _openedAppSettings) {
      _openedAppSettings = false;

      // Reset the flag
      _getCurrentLocation();
      setState(() {}); // Call the method to fetch the current location
    }
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    // Check location permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      if (Platform.isAndroid) {
        _getCurrentLocation();
      }
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle permission not granted for while in use or always
        _showLocationServiceInstructions();
      } else {
        _getCurrentLocation();
      }
    } else {
      _getCurrentLocationAndNavigate();
    }
  }

  void _showLocationServiceInstructions() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
        Text('pleaseEnableLocationServicesManually'.translate(context)),
        action: SnackBarAction(
          label: 'ok'.translate(context),
          textColor: context.color.secondaryColor,
          onPressed: () {
            openAppSettings();
            setState(() {
              _openedAppSettings = true;
            });

            // Optionally handle action button press
          },
        ),
      ),
    );
  }

  Future<void> _getCurrentLocationAndNavigate() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];

        HiveUtils.setLocation(
          area: placemark.subLocality,
          city: placemark.locality!,
          state: placemark.administrativeArea!,
          country: placemark.country!,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        Navigator.of(context)
            .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
      }
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.backgroundColor,
      ),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: FittedBox(
                    fit: BoxFit.none,
                    child: MaterialButton(
                      onPressed: () {
                        //HiveUtils.setUserIsNotNew();

                        Navigator.pushNamed(
                          context,
                          Routes.main,
                          arguments: {
                            "from": "login",
                            "isSkipped": true,
                          },
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: context.color.forthColor.withOpacity(0.102),
                      elevation: 0,
                      height: 28,
                      minWidth: 64,
                      child: Text("skip".translate(context))
                          .color(context.color.forthColor),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UiUtils.getSvg(AppIcons.locationAccessIcon),
                  const SizedBox(height: 19),
                  Text(
                    "whatsYourLocation".translate(context),
                  ).size(context.font.extraLarge).bold(weight: FontWeight.w600),
                  const SizedBox(height: 14),
                  Text(
                    'weNeedLocationAvailableLbl'.translate(context),
                  )
                      .size(context.font.larger)
                      .color(context.color.textDefaultColor.withOpacity(0.65))
                      .centerAlign(),
                  const SizedBox(height: 58),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12),
                    child: UiUtils.buildButton(context,
                        showElevation: false,
                        buttonColor: context.color.territoryColor,
                        textColor: context.color.secondaryColor,
                        onPressed: () {
                          // Check location permission when the button is pressed
                          _getCurrentLocation();
                        },
                        radius: 8,
                        height: 46,
                        buttonTitle: "allowLocationAccess".translate(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12),
                    child: UiUtils.buildButton(context,
                        showElevation: false,
                        buttonColor: context.color.backgroundColor,
                        border: BorderSide(color: context.color.territoryColor),
                        textColor: context.color.territoryColor,
                        onPressed: () {
                          /// navigate direct country screen
                          Navigator.pushNamed(context, Routes.statesScreen,
                              arguments: {
                                "countryId": 19,
                                "countryName": "Bangladesh",
                                "from": "location"
                              });
                          // Navigator.pushNamed(context, Routes.countriesScreen,
                          //     arguments: {"from": "location"});
                        },
                        radius: 8,
                        height: 46,
                        buttonTitle: "enterManually".translate(context)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
