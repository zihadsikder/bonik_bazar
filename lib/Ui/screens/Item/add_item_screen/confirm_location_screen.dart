/*
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/cloudState/cloud_state.dart';
import 'package:eClassify/Utils/helper_utils.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/data/cubits/item/manage_item_cubit.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../Utils/AppIcon.dart';
import '../../../../Utils/ui_utils.dart';
import '../../../../Utils/validator.dart';
import '../../../../data/Repositories/location_repository.dart';
import '../../../../data/helper/widgets.dart';
import '../../../../data/model/google_place_model.dart';
import '../../../../data/model/item/item_model.dart';
import '../../Widgets/AnimatedRoutes/blur_page_route.dart';

//import 'package:google_maps_webservice/places.dart';

import '../../widgets/blurred_dialoge_box.dart';
import '../my_item_tab_screen.dart';

class ConfirmLocationScreen extends StatefulWidget {
  final bool? isEdit;
  final File? mainImage;
  final List<File>? otherImage;

  const ConfirmLocationScreen({
    Key? key,
    required this.isEdit,
    required this.mainImage,
    required this.otherImage,
  }) : super(key: key);

  static BlurredRouter route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;

    return BlurredRouter(
      builder: (context) {
        return BlocProvider(
          create: (context) => ManageItemCubit(),
          child: ConfirmLocationScreen(
            isEdit: arguments?['isEdit'] ?? false,
            mainImage: arguments?['mainImage'],
            otherImage: arguments?['otherImage'],
          ),
        );
      },
    );
  }

  @override
  _ConfirmLocationScreenState createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends CloudState<ConfirmLocationScreen>
    with WidgetsBindingObserver {
  */
/*final GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: Constant.googlePlaceAPIkey);*/ /*

  final TextEditingController _searchController = TextEditingController();
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = Set();

  //List<Prediction> _cityPredictions = [];
  bool _showCityList = false;
  AddressComponent? formatedAddress;

  //Map<String, dynamic> addressComponent = {};
  CameraPosition? _cameraPosition;
  var markerMove;
  var latlong;
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController cityTextController = TextEditingController();
  TextEditingController countryTextController = TextEditingController();
  bool _openedAppSettings = false;
  dynamic cubitReference;
  Timer? delayTimer;
  int previousLength = 0;

  @override
  void initState() {
    super.initState();
    //initSearchController();
    WidgetsBinding.instance.addObserver(this);
    _getCurrentLocation();
  }

  void initSearchController(value) {
    context
        .read<GooglePlaceAutocompleteCubit>()
        .getLocationFromText(text: value);
    _showCityList = true;
    setState(() {});
  }


  @override
  void dispose() {
    _searchController.dispose();
    delayTimer?.cancel();
    cubitReference.clearCubit();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    cubitReference = context.read<GooglePlaceAutocompleteCubit>();
    super.didChangeDependencies();
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

  Set<Factory<OneSequenceGestureRecognizer>> getMapGestureRecognizers() {
    return <Factory<OneSequenceGestureRecognizer>>{}
      ..add(Factory<PanGestureRecognizer>(
          () => PanGestureRecognizer()..onUpdate = (dragUpdateDetails) {}))
      ..add(Factory<ScaleGestureRecognizer>(
          () => ScaleGestureRecognizer()..onStart = (dragUpdateDetails) {}))
      ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
      ..add(Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer()
            ..onDown = (dragUpdateDetails) {
              if (markerMove == false) {
              } else {
                setState(() {
                  markerMove = false;
                });
              }
            }));
  }

  preFillLocationWhileEdit() {
    ItemModel itemModel = getCloudData('edit_request') as ItemModel;
    _currentLocation = LatLng(itemModel.latitude!, itemModel.longitude!);

    _cameraPosition = CameraPosition(
      target: LatLng(itemModel.latitude!, itemModel.longitude!),
      zoom: 14.4746,
      bearing: 0,
    );
    getLocationFromLatitudeLongitude(
        latLng: LatLng(itemModel.latitude!, itemModel.longitude!));
    _markers.add(Marker(
      markerId: const MarkerId('currentLocation'),
      position: _currentLocation!,
    ));

    setState(() {});
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
        defaultLocation();
        _showLocationServiceInstructions();
      } else {
        _getCurrentLocation();
      }
    } else {
      // Permission is granted, proceed to get the current location
      defaultLocation();
    }
  }

  defaultLocation() async {
    if (widget.isEdit == true) {
      preFillLocationWhileEdit();
    } else {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        _currentLocation = LatLng(position.latitude, position.longitude);
        _cameraPosition = CameraPosition(
          target: _currentLocation!,
          zoom: 14.4746,
          bearing: 0,
        );
        getLocationFromLatitudeLongitude(latLng: _currentLocation);
        _markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentLocation!,
        ));
        setState(() {});
        // Handle getting the current location as needed
      } on PlatformException {
        // Handle platform exceptions such as location services disabled
      }
    }
  }

  void _showLocationServiceInstructions() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('pleaseEnableLocationServicesManually'.translate(context)),
        action: SnackBarAction(
          label: 'ok'.translate(context),
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

  void _onCitySelected(GooglePlaceModel prediction) async {
    double lat = double.parse(prediction.latitude);
    double lng = double.parse(prediction.longitude);
    _currentLocation = LatLng(lat, lng);
    _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
    getLocationFromLatitudeLongitude(latLng: _currentLocation);
    _cameraPosition =
        CameraPosition(target: _currentLocation!, zoom: 14.4746, bearing: 0);
    _mapController
        .animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(prediction.placeId),
        position: _currentLocation!,
      ));
      _showCityList = false;
    });
  }

  getLocationFromLatitudeLongitude({LatLng? latLng}) async {
    try {
      Placemark? placeMark = (await placemarkFromCoordinates(
              latLng?.latitude ?? _cameraPosition!.target.latitude,
              latLng?.longitude ?? _cameraPosition!.target.longitude))
          .first;



      formatedAddress = AddressFormatter(placeMark).format();

      setState(() {});
    } catch (e) {
      log(e.toString());
      formatedAddress = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        Future.delayed(Duration(milliseconds: 500), () {
          return;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: UiUtils.buildAppBar(
          context,
          onBackPress: () {
            Future.delayed(Duration(milliseconds: 500), () {
              Navigator.pop(context);
            });
          },
          showBackButton: true,
          title: "confirmLocation".translate(context),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 18.0, right: 18),
          child: UiUtils.buildButton(context, onPressed: () async {
            if (formatedAddress == null || formatedAddress!.city == "") {
              HelperUtils.showSnackBarMessage(
                  context, "cityRequired".translate(context));
              Future.delayed(Duration(seconds: 2), () {
                dialogueBottomSheet(
                    controller: cityTextController,
                    title: "enterCity".translate(context),
                    hintText: "city".translate(context),
                    from: 1);
              });
            } else if (formatedAddress == null ||
                formatedAddress!.country == "") {
              HelperUtils.showSnackBarMessage(
                  context, "countryRequired".translate(context));
              Future.delayed(Duration(seconds: 2), () {
                dialogueBottomSheet(
                    controller: countryTextController,
                    title: "enterCountry".translate(context),
                    hintText: "country".translate(context),
                    from: 3);
              });
            } else {
              try {
                Map<String, dynamic> cloudData =
                    getCloudData("with_more_details") ?? {};

                cloudData['address'] = formatedAddress?.mixed;
                cloudData['latitude'] = _currentLocation!.latitude;
                cloudData['longitude'] = _currentLocation!.longitude;
                cloudData['country'] = formatedAddress!.country;
                cloudData['city'] = formatedAddress!.city;
                cloudData['state'] = formatedAddress!.state;

                if (widget.isEdit == true) {
                  context.read<ManageItemCubit>().manage(ManageItemType.edit,
                      cloudData, widget.mainImage, widget.otherImage!);
                  return;
                } else {
                  context.read<ManageItemCubit>().manage(ManageItemType.add,
                      cloudData, widget.mainImage!, widget.otherImage!);
                  return;
                }
              } catch (e, st) {
                throw st;
              }
            }

            return;
            //}
          },
              height: 48.rh(context),
              fontSize: context.font.large,
              autoWidth: false,
              radius: 8,
              width: double.maxFinite,
              buttonTitle: "postNow".translate(context)),
        ),
        body: _currentLocation != null
            ? BlocConsumer<ManageItemCubit, ManageItemState>(
                listener: (context, state) {
                  if (state is ManageItemInProgress) {
                    Widgets.showLoader(context);
                  }
                  if (state is ManageItemSuccess) {
                    Widgets.hideLoder(context);
                    //This will locally update item model
                    myAdsCubitReference[getCloudData("edit_from")]
                        ?.edit(state.model);
                    Future.delayed(Duration(milliseconds: 500), () {
                      if (mounted) {
                        Navigator.pushNamed(context, Routes.successItemScreen,
                            arguments: {
                              'model': state.model,
                              'isEdit': widget.isEdit
                            });
                      }
                    });
                  }

                  if (state is ManageItemFail) {
                    HelperUtils.showSnackBarMessage(
                        context, state.error.toString());
                    Widgets.hideLoder(context);
                  }
                },
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 50,
                        alignment: AlignmentDirectional.center,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 14),
                        child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                initSearchController(value);
                                //_searchCities(value);
                              }
                            },
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              hintText:
                                  "Search Your address".translate(context),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchController.text = '';
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: context.color.territoryColor,
                                  )),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: context.color.territoryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: context.color.territoryColor),
                              ),
                            )),
                      ),
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: GoogleMap(


                                    onCameraMove: (position) {
                                      _cameraPosition = position;
                                    },
                                    onCameraIdle: () async {
                                      if (markerMove == false) {
                                        if (latlong ==
                                            LatLng(
                                                _cameraPosition!
                                                    .target.latitude,
                                                _cameraPosition!
                                                    .target.longitude)) {
                                        } else {
                                          getLocationFromLatitudeLongitude();
                                        }
                                      }
                                    },
                                    initialCameraPosition: _cameraPosition!,


                                    markers: _markers,
                                    zoomControlsEnabled: false,
                                    minMaxZoomPreference:
                                        const MinMaxZoomPreference(0, 16),
                                    compassEnabled: true,
                                    indoorViewEnabled: true,
                                    mapToolbarEnabled: true,
                                    myLocationButtonEnabled: true,
                                    mapType: MapType.normal,
                                    gestureRecognizers:
                                        getMapGestureRecognizers(),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      Future.delayed(
                                              const Duration(milliseconds: 500))
                                          .then((value) {
                                        _mapController = (controller);
                                        _mapController.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            _cameraPosition!,
                                          ),
                                        );
                                        //preFillLocationWhileEdit();
                                      });
                                    },
                                    onTap: (latLng) {
                                      setState(() {
                                        _markers
                                            .clear(); // Clear existing markers
                                        _markers.add(Marker(
                                          markerId:
                                              MarkerId('selectedLocation'),
                                          position: latLng,
                                        ));
                                        _currentLocation =
                                            latLng; // Update current location
                                        getLocationFromLatitudeLongitude(
                                            latLng:
                                                latLng); // Get location details
                                      });
                                    }),
                              ),
                            ),
                            Visibility(
                              visible: _showCityList,
                              child: Positioned.directional(
                                textDirection: Directionality.of(context),
                                top: 0,
                                // Adjust this value as needed
                                start: 0,
                                end: 0,
                                height: 200.rh(context),
                                // Adjust this value as needed
                                child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: context.color.secondaryColor,
                                        border: Border.all(
                                            color: context.color.borderColor
                                                .darken(30))),
                                    child: BlocBuilder<
                                        GooglePlaceAutocompleteCubit,
                                        GooglePlaceAutocompleteState>(
                                      builder: (context,
                                          GooglePlaceAutocompleteState
                                              googlePlaceState) {
                                        if (googlePlaceState
                                            is GooglePlaceAutocompleteSuccess) {
                                          if (googlePlaceState
                                              .autocompleteResult.isNotEmpty) {
                                            return ListView.builder(
                                                itemCount: googlePlaceState
                                                    .autocompleteResult.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, int i) {
                                                  return ListTile(
                                                    onTap: () async {
                                                      ///This will fetch place details from given PlaceId
                                                      var cordinates =
                                                          await GooglePlaceRepository()
                                                              .getPlaceDetailsFromPlaceId(
                                                                  googlePlaceState
                                                                      .autocompleteResult[
                                                                          i]
                                                                      .placeId);

                                                      GooglePlaceModel
                                                          placeModel =
                                                          googlePlaceState
                                                              .autocompleteResult[i];

                                                      ///Now we have place Model
                                                      placeModel =
                                                          placeModel.copyWith(
                                                              latitude:
                                                                  cordinates[
                                                                          'lat']
                                                                      .toString(),
                                                              longitude:
                                                                  cordinates[
                                                                          'lng']
                                                                      .toString());
                                                      _onCitySelected(
                                                          placeModel);



                                                    },
                                                    leading: const Icon(
                                                        Icons.location_city),
                                                    title: Text(googlePlaceState
                                                        .autocompleteResult[i]
                                                        .description
                                                        .toString()),
                                                  );
                                                });
                                          }
                                          return Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(top: 8.0),
                                            child: Center(
                                                child: Text('nodatafound'
                                                    .translate(context))),
                                          );
                                        }

                                        ///Show progress when loading
                                        if (googlePlaceState
                                            is GooglePlaceAutocompleteInProgress) {
                                          return Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(top: 8.0),
                                            child: Center(
                                              child: UiUtils.progress(
                                                  normalProgressColor: context
                                                      .color.territoryColor),
                                            ),
                                          );
                                        }
                                        return Container();
                                      },
                                    )

                                    ),
                              ),
                            ),
                            PositionedDirectional(
                              end: 30,
                              bottom: 15,
                              child: InkWell(
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: context.color.borderColor,
                                      width: Constant.borderWidth,
                                    ),
                                    color: context.color.secondaryColor,
                                    // Adjust the opacity as needed
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.my_location_sharp,
                                    // Change the icon color if needed
                                  ),
                                ),
                                onTap: () async {
                                  Position position =
                                      await Geolocator.getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high,
                                  );
                                  _currentLocation = LatLng(
                                      position.latitude, position.longitude);
                                  _cameraPosition = CameraPosition(
                                    target: _currentLocation!,
                                    zoom: 14.4746,
                                    bearing: 0,
                                  );
                                  getLocationFromLatitudeLongitude();

                                  _mapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        _cameraPosition!),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          // height: 12,
                          width: context.screenWidth,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child:
                                  LayoutBuilder(builder: (context, constrains) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: context
                                                    .color.territoryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    width: Constant.borderWidth,
                                                    color: context
                                                        .color.borderColor),
                                              ),
                                              child: SizedBox(
                                                  width: 8.11,
                                                  height: 5.67,
                                                  child: SvgPicture.asset(
                                                    AppIcons.location,
                                                    fit: BoxFit.none,
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                            context.color
                                                                .territoryColor,
                                                            BlendMode.srcIn),
                                                  )),
                                            ),
                                            SizedBox(
                                              width: 10.rw(context),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(formatedAddress == null ||
                                                            formatedAddress!
                                                                    .city ==
                                                                ""
                                                        ? "____"
                                                        : formatedAddress!.city)
                                                    .size(context.font.large),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                    "${formatedAddress == null || formatedAddress?.state == "" ? "____" : formatedAddress?.state},${formatedAddress == null || formatedAddress!.country == "" ? "____" : formatedAddress!.country}")
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            : shimmerEffect(),
      ),
    );
  }

  void dialogueBottomSheet(
      {required String title,
      required TextEditingController controller,
      required String hintText,
      required int from}) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        content: dialogueWidget(title, controller, hintText),
        acceptButtonName: "add".translate(context),
        isAcceptContainesPush: true,
        onAccept: () => Future.value().then((_) {
          if (_formKey.currentState!.validate()) {
            setState(() {
              if (from == 1) {
                formatedAddress = AddressComponent.copyWithFields(
                    formatedAddress!,
                    newCity: controller.text);
                Navigator.pop(context);
                return;
              }
              if (from == 2) {
                formatedAddress = AddressComponent.copyWithFields(
                    formatedAddress!,
                    newState: controller.text);
                Navigator.pop(context);
                return;
              }
              if (from == 3) {
                formatedAddress = AddressComponent.copyWithFields(
                    formatedAddress!,
                    newCountry: controller.text);
                Navigator.pop(context);
                return;
              }
            });
          }
        }),
      ),
    );
  }

  Widget dialogueWidget(
      String title, TextEditingController controller, String hintText) {
    double bottomPadding = (MediaQuery.of(context).viewInsets.bottom - 50);
    bool isBottomPaddingNagative = bottomPadding.isNegative;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title).size(context.font.larger).centerAlign().bold(),
              Divider(
                thickness: 1,
                color: context.color.borderColor.darken(30),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    bottom: isBottomPaddingNagative ? 0 : bottomPadding,
                    start: 20,
                    end: 20,
                    top: 18),
                child: TextFormField(
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.color.textDefaultColor.withOpacity(0.5)),
                  controller: controller,
                  cursorColor: context.color.territoryColor,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return Validator.nullCheckValidator(val,
                          context: context);
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      fillColor: context.color.borderColor.darken(20),
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      hintText: hintText,
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              context.color.textDefaultColor.withOpacity(0.5)),
                      focusColor: context.color.territoryColor,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.borderColor.darken(60))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.borderColor.darken(60))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: context.color.territoryColor))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget shimmerEffect() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
          highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            alignment: AlignmentDirectional.center,
            margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14),
          ),
        ),
        Expanded(
            child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
          highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
          child: Container(
            height: 400,
            margin: EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
          ),
        )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
            highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
              height: 146,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ),
      ],
    );
  }
}

class AddressFormatter {
  final Placemark placemark;

  AddressFormatter(this.placemark);

  List<String> removableKeys = [
    "name",
    "isoCountryCode",
    "postalCode",
    "subAdministrativeArea",
    "thoroughfare",
    "subThoroughfare"
  ];

  AddressComponent format() {
    Map<String, dynamic> finalLocationMap = placemark.toJson()
      ..removeWhere((key, value) => removableKeys.contains(key));

    return AddressComponent.fromMap(finalLocationMap);
  }

  AddressFormatter copyWith({
    String? locality,
    String? administrativeArea,
    String? country,
  }) {
    var updatedPlacemark = Placemark(
      name: placemark.name,
      isoCountryCode: placemark.isoCountryCode,
      postalCode: placemark.postalCode,
      subAdministrativeArea: placemark.subAdministrativeArea,
      thoroughfare: placemark.thoroughfare,
      subThoroughfare: placemark.subThoroughfare,
      locality: locality ?? placemark.locality,
      administrativeArea: administrativeArea ?? placemark.administrativeArea,
      country: country ?? placemark.country,
    );

    return AddressFormatter(updatedPlacemark);
  }

*/
/*  AddressComponent format(
      {String? newCity, String? newState, String? newCountry}) {
    Map<String, dynamic> finalLocationMap = placemark.toJson()
      ..removeWhere((key, value) => removableKeys.contains(key));

    // Update the city, state, and country if new values are provided
    if (newCity != null) finalLocationMap["locality"] = newCity;
    if (newState != null) finalLocationMap["administrativeArea"] = newState;
    if (newCountry != null) finalLocationMap["country"] = newCountry;

    return AddressComponent.fromMap(finalLocationMap);
  }*/ /*

}

class AddressComponent {
  //final String streetWithArea;
  //final String cityNameWithState;
  //final String areaWithCity;
  //final String stateWithCountry;
  //final String streetAndAreaAndCity;
  final String mixed;
  final String country;
  final String state;
  final String city;
  final String street;
  final String subLocality;
  final String locality;
  final String administrativeArea;

  AddressComponent({
    // required this.streetWithArea,
    // required this.cityNameWithState,
    // required this.areaWithCity,
    //  required this.stateWithCountry,
    // required this.streetAndAreaAndCity,
    required this.mixed,
    required this.country,
    required this.state,
    required this.city,
    required this.administrativeArea,
    required this.subLocality,
    required this.locality,
    required this.street,
  });

  AddressComponent.copyWithFields(
    AddressComponent original, {
    String? newCity,
    String? newState,
    String? newCountry,
  })  : */
/*streetWithArea = original.streetWithArea,
        cityNameWithState = original.cityNameWithState,
        areaWithCity = original.areaWithCity,
        stateWithCountry = original.stateWithCountry,
        streetAndAreaAndCity = original.streetAndAreaAndCity,*/ /*

        mixed = original.mixed,
        country = newCountry ?? original.country,
        state = newState ?? original.state,
        city = newCity ?? original.city,
        administrativeArea = newState ?? original.administrativeArea,
        street = original.street,
        locality = newCity ?? original.locality,
        subLocality = original.subLocality;

  Map<String, dynamic> toMap() {
    return {
      */
/*'streetWithArea': streetWithArea,
      'cityNameWithState': cityNameWithState,
      'areaWithCity': areaWithCity,
      'stateWithCountry': stateWithCountry,
      'streetAndAreaAndCity': streetAndAreaAndCity,*/ /*

      'mixed': mixed,
      'country': country,
      'state': state,
      'city': city,
      'street': street,
      'administrativeArea': administrativeArea,
      'locality': locality,
      'subLocality': subLocality,
    };
  }

  factory AddressComponent.fromMap(Map<String, dynamic> map) {
    var street = map["street"];
    var subLocality = map["subLocality"];
    var locality = map["locality"];
    var administrativeArea = map["administrativeArea"];
    var country = map["country"];
    String join(List<String> components) {
      List<String> list = components..removeWhere((element) => element == "");
      return list.join(",");
    }

    return AddressComponent(
        */
/*streetWithArea: join([street, subLocality]),
        cityNameWithState: join([locality, administrativeArea]),
        areaWithCity: join([subLocality, locality]),
        stateWithCountry: join([administrativeArea, country]),
        streetAndAreaAndCity: join([street, subLocality, locality]),*/ /*

        administrativeArea: administrativeArea,
        locality: locality,
        street: street,
        subLocality: subLocality,
        mixed: join([locality, administrativeArea, country]),
        city: locality,
        state: administrativeArea,
        country: country);
  }

  @override
  String toString() {
    return 'AddressComponent{administrativeArea: $administrativeArea, locality: $locality, street: $street, subLocality: $subLocality, mixed: $mixed,state:$state,city:$city,country:$country}';
  }
}
*/

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/cloudState/cloud_state.dart';
import 'package:eClassify/Utils/helper_utils.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/data/cubits/item/manage_item_cubit.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shimmer/shimmer.dart';

import '../../../../Utils/AppIcon.dart';
import '../../../../Utils/ui_utils.dart';
import '../../../../Utils/validator.dart';

import '../../../../data/helper/widgets.dart';
import '../../../../data/model/item/item_model.dart';
import '../../Widgets/AnimatedRoutes/blur_page_route.dart';

import '../../widgets/blurred_dialoge_box.dart';
import '../my_item_tab_screen.dart';

class ConfirmLocationScreen extends StatefulWidget {
  final bool? isEdit;
  final File? mainImage;
  final List<File>? otherImage;

  const ConfirmLocationScreen({
    Key? key,
    required this.isEdit,
    required this.mainImage,
    required this.otherImage,
  }) : super(key: key);

  static BlurredRouter route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;

    return BlurredRouter(
      builder: (context) {
        return BlocProvider(
          create: (context) => ManageItemCubit(),
          child: ConfirmLocationScreen(
            isEdit: arguments?['isEdit'] ?? false,
            mainImage: arguments?['mainImage'],
            otherImage: arguments?['otherImage'],
          ),
        );
      },
    );
  }

  @override
  _ConfirmLocationScreenState createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends CloudState<ConfirmLocationScreen>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController cityTextController = TextEditingController();
  TextEditingController countryTextController = TextEditingController();
  String currentLocation = '';
  AddressComponent? formatedAddress;
  double? latitude, longitude;
  CameraPosition? _cameraPosition;
  final Set<Marker> _markers = Set();
  late GoogleMapController _mapController;
  var markerMove;
  bool _openedAppSettings = false;

  @override
  void initState() {
    _getCurrentLocation();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    cityTextController.dispose();
    countryTextController.dispose();
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

  preFillLocationWhileEdit() async {
    if (widget.isEdit!) {
      ItemModel itemModel = getCloudData('edit_request') as ItemModel;

      currentLocation = [
        itemModel.area,
        itemModel.city,
        itemModel.state,
        itemModel.country
      ].where((part) => part != null && part.isNotEmpty).join(', ');
      formatedAddress = AddressComponent(
          area: itemModel.area,
          areaId: itemModel.areaId,
          city: itemModel.city,
          country: itemModel.country,
          state: itemModel.state);
      latitude = itemModel.latitude;
      longitude = itemModel.longitude;
      _cameraPosition = CameraPosition(
        target: LatLng(itemModel.latitude!, itemModel.longitude!),
        zoom: 14.4746,
        bearing: 0,
      );

      _markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(itemModel.latitude!, itemModel.longitude!),
      ));
    } else {
      currentLocation = [
        HiveUtils.getCurrentAreaName(),
        HiveUtils.getCurrentCityName(),
        HiveUtils.getCurrentStateName(),
        HiveUtils.getCurrentCountryName()
      ].where((part) => part != null && part.isNotEmpty).join(', ');
      if (currentLocation == "") {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        _cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.4746,
          bearing: 0,
        );
        getLocationFromLatitudeLongitude(
            latLng: LatLng(position.latitude, position.longitude));
        _markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
        ));
        latitude = position.latitude;
        longitude = position.longitude;
      } else {
        formatedAddress = AddressComponent(
            area: HiveUtils.getCurrentAreaName(),
            areaId: null,
            city: HiveUtils.getCurrentCityName(),
            country: HiveUtils.getCurrentCountryName(),
            state: HiveUtils.getCurrentStateName());
        latitude = HiveUtils.getCurrentLatitude();
        longitude = HiveUtils.getCurrentLongitude();
        _cameraPosition = CameraPosition(
          target: LatLng(latitude!, longitude!),
          zoom: 14.4746,
          bearing: 0,
        );
        getLocationFromLatitudeLongitude(latLng: LatLng(latitude!, longitude!));
        _markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(latitude!, longitude!),
        ));
      }
    }

    setState(() {});
  }

  getLocationFromLatitudeLongitude({LatLng? latLng}) async {
    try {
      Placemark? placeMark = (await placemarkFromCoordinates(
              latLng?.latitude ?? _cameraPosition!.target.latitude,
              latLng?.longitude ?? _cameraPosition!.target.longitude))
          .first;

      formatedAddress = AddressComponent(
          area: placeMark.subLocality,
          areaId: null,
          city: placeMark.locality,
          country: placeMark.country,
          state: placeMark.administrativeArea);

      setState(() {});
    } catch (e) {
      log(e.toString());
      formatedAddress = null;
      setState(() {});
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
      // Permission is granted, proceed to get the current location
      preFillLocationWhileEdit();
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

/*  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      if (mounted)
        setState(() {
          currentLocation = [
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country,
          ].where((part) => part != null && part.isNotEmpty).join(', ');

          formatedAddress = AddressComponent(
              area: placemark.subLocality,
              areaId: null,
              city: placemark.locality,
              country: placemark.country,
              state: placemark.administrativeArea);

          latitude = position.latitude;
          longitude = position.longitude;
        });

      HiveUtils.setCurrentLocation(
          area: placemark.subLocality,
          city: placemark.locality!,
          state: placemark.administrativeArea!,
          country: placemark.country!,
          latitude: position.latitude,
          longitude: position.longitude);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        Future.delayed(Duration(milliseconds: 500), () {
          return;
        });
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: UiUtils.buildAppBar(context, onBackPress: () {
            Future.delayed(Duration(milliseconds: 500), () {
              Navigator.pop(context);
            });
          }, showBackButton: true, title: "confirmLocation".translate(context)),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 18.0, right: 18),
            child: UiUtils.buildButton(context, onPressed: () async {
              if (formatedAddress == null ||
                  (formatedAddress!.city == "" ||
                      formatedAddress!.city == null)) {
                HelperUtils.showSnackBarMessage(
                    context, "cityRequired".translate(context));
                Future.delayed(Duration(seconds: 2), () {
                  dialogueBottomSheet(
                      controller: cityTextController,
                      title: "enterCity".translate(context),
                      hintText: "city".translate(context),
                      from: 1);
                });
              } else if (formatedAddress == null ||
                  (formatedAddress!.country == "" ||
                      formatedAddress!.country == null)) {
                HelperUtils.showSnackBarMessage(
                    context, "countryRequired".translate(context));
                Future.delayed(Duration(seconds: 2), () {
                  dialogueBottomSheet(
                      controller: countryTextController,
                      title: "enterCountry".translate(context),
                      hintText: "country".translate(context),
                      from: 3);
                });
              } else {
                try {
                  Map<String, dynamic> cloudData =
                      getCloudData("with_more_details") ?? {};

                  cloudData['address'] = formatedAddress?.mixed;
                  if (latitude != null) cloudData['latitude'] = latitude;
                  if (longitude != null) cloudData['longitude'] = longitude;
                  cloudData['country'] = formatedAddress!.country;
                  cloudData['city'] = formatedAddress!.city;
                  cloudData['state'] = formatedAddress!.state;
                  if (formatedAddress!.areaId != null)
                    cloudData['area_id'] = formatedAddress!.areaId;

                  if (widget.isEdit == true) {
                    context.read<ManageItemCubit>().manage(ManageItemType.edit,
                        cloudData, widget.mainImage, widget.otherImage!);
                    return;
                  } else {
                    context.read<ManageItemCubit>().manage(ManageItemType.add,
                        cloudData, widget.mainImage!, widget.otherImage!);
                    return;
                  }
                } catch (e, st) {
                  throw st;
                }
              }

              return;
            },
                height: 48.rh(context),
                fontSize: context.font.large,
                autoWidth: false,
                radius: 8,
                width: double.maxFinite,
                buttonTitle: "postNow".translate(context)),
          ),
          body: bodyData()),
    );
  }

  Widget bodyData() {
    return BlocConsumer<ManageItemCubit, ManageItemState>(
        listener: (context, state) {
      if (state is ManageItemInProgress) {
        Widgets.showLoader(context);
      }
      if (state is ManageItemSuccess) {
        Widgets.hideLoder(context);
        //This will locally update item model
        myAdsCubitReference[getCloudData("edit_from")]?.edit(state.model);
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushNamed(context, Routes.successItemScreen,
                arguments: {'model': state.model, 'isEdit': widget.isEdit});
          }
        });
      }

      if (state is ManageItemFail) {
        HelperUtils.showSnackBarMessage(context, state.error.toString());
        Widgets.hideLoder(context);
      }
    }, builder: (context, state) {
      return _cameraPosition != null
          ? Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    "locationItemSellingLbl".translate(context),
                  )
                      .bold(weight: FontWeight.bold)
                      .size(context.font.larger)
                      .centerAlign(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, right: 15, left: 15),
                  child: UiUtils.buildButton(context, height: 48,
                      onPressed: () {
                    Navigator.pushNamed(context, Routes.countriesScreen,
                        arguments: {"from": "addItem"}).then((value) {
                      if (value != null) {
                        Map<String, dynamic> location =
                            value as Map<String, dynamic>;
                        //getCloudData('add_item_location_detail');
                        print("value location****$value");

                        if (mounted)
                          setState(() {
                            currentLocation = [
                              location["area"] ?? null,
                              location["city"] ?? null,
                              location["state"] ?? null,
                              location["country"] ?? null,
                            ]
                                .where(
                                    (part) => part != null && part.isNotEmpty)
                                .join(', ');

                            formatedAddress = AddressComponent(
                                area: location["area"] ?? null,
                                areaId: location["area_id"] ?? null,
                                city: location["city"] ?? null,
                                country: location["country"] ?? null,
                                state: location["state"] ?? null);

                            print(
                                "latitude****${location["latitude"]}*****${location["longitude"]}");
                            latitude = location["latitude"] ?? null;
                            longitude = location["longitude"] ?? null;

                            print(
                                "latitude11****${location["latitude"]}*****${location["longitude"]}");
                            _cameraPosition = CameraPosition(
                              target: LatLng(latitude!, longitude!),
                              zoom: 14.4746,
                              bearing: 0,
                            );

                            _mapController.animateCamera(
                              CameraUpdate.newCameraPosition(_cameraPosition!),
                            );
                            _markers.add(Marker(
                              markerId: const MarkerId('currentLocation'),
                              position: LatLng(latitude!, longitude!),
                            ));
                          });
                      }
                    });
                  },
                      fontSize: 14,
                      buttonTitle: "somewhereElseLbl".translate(context),
                      textColor: context.color.textDefaultColor,
                      buttonColor: context.color.secondaryColor,
                      border: BorderSide(
                          color:
                              context.color.textDefaultColor.withOpacity(0.3),
                          width: 1.5),
                      radius: 5),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GoogleMap(
                              onCameraMove: (position) {
                                _cameraPosition = position;
                              },
                              onCameraIdle: () async {
                                if (markerMove == false) {
                                  if (LatLng(latitude!, longitude!) ==
                                      LatLng(_cameraPosition!.target.latitude,
                                          _cameraPosition!.target.longitude)) {
                                  } else {
                                    getLocationFromLatitudeLongitude();
                                  }
                                }
                              },
                              initialCameraPosition: _cameraPosition!,
                              markers: _markers,
                              zoomControlsEnabled: false,
                              minMaxZoomPreference:
                                  const MinMaxZoomPreference(0, 16),
                              compassEnabled: true,
                              indoorViewEnabled: true,
                              mapToolbarEnabled: true,
                              myLocationButtonEnabled: true,
                              mapType: MapType.normal,
                              gestureRecognizers: getMapGestureRecognizers(),
                              onMapCreated: (GoogleMapController controller) {
                                Future.delayed(
                                        const Duration(milliseconds: 500))
                                    .then((value) {
                                  _mapController = (controller);
                                  _mapController.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      _cameraPosition!,
                                    ),
                                  );
                                  //preFillLocationWhileEdit();
                                });
                              },
                              onTap: (latLng) {
                                setState(() {
                                  _markers.clear(); // Clear existing markers
                                  _markers.add(Marker(
                                    markerId: MarkerId('selectedLocation'),
                                    position: latLng,
                                  ));
                                  latitude = latLng.latitude;
                                  longitude = latLng.longitude;

                                  getLocationFromLatitudeLongitude(
                                      latLng: latLng); // Get location details
                                });
                              }),
                        ),
                      ),
                      PositionedDirectional(
                        end: 30,
                        bottom: 15,
                        child: InkWell(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: context.color.borderColor,
                                width: Constant.borderWidth,
                              ),
                              color: context.color.secondaryColor,
                              // Adjust the opacity as needed
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.my_location_sharp,
                              // Change the icon color if needed
                            ),
                          ),
                          onTap: () async {
                            Position position =
                                await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );

                            _cameraPosition = CameraPosition(
                              target:
                                  LatLng(position.latitude, position.longitude),
                              zoom: 14.4746,
                              bearing: 0,
                            );
                            getLocationFromLatitudeLongitude();

                            _mapController.animateCamera(
                              CameraUpdate.newCameraPosition(_cameraPosition!),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                /* Padding(
            padding: EdgeInsets.only(top: 35, right: 15, left: 15),
            child: UiUtils.buildButton(context, height: 48, onPressed: () {
              _getCurrentLocation();
            },
                fontSize: 14,
                buttonTitle:
                "${"currentLocationLbl".translate(context)}${currentLocation != "" ? ": ${currentLocation}" : ""}",
                prefixWidget: Padding(
                  padding: EdgeInsetsDirectional.only(end: 8.0),
                  child: Icon(
                    Icons.my_location,
                    size: 20,
                  ),
                ),
                textColor: context.color.textDefaultColor,
                buttonColor: context.color.secondaryColor,
                border: BorderSide(
                    color: context.color.textDefaultColor.withOpacity(0.3),
                    width: 1.5),
                radius: 5),
          ),*/

                Container(
                  // height: 12,
                  width: context.screenWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: LayoutBuilder(builder: (context, constrains) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: context.color.territoryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            width: Constant.borderWidth,
                                            color: context.color.borderColor),
                                      ),
                                      child: SizedBox(
                                          width: 8.11,
                                          height: 5.67,
                                          child: SvgPicture.asset(
                                            AppIcons.location,
                                            fit: BoxFit.none,
                                            colorFilter: ColorFilter.mode(
                                                context.color.territoryColor,
                                                BlendMode.srcIn),
                                          )),
                                    ),
                                    SizedBox(
                                      width: 10.rw(context),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(formatedAddress == null ||
                                                    (formatedAddress!.city ==
                                                            "" ||
                                                        formatedAddress!.city ==
                                                            null)
                                                ? "____"
                                                : (formatedAddress!.area !=
                                                                "" &&
                                                            formatedAddress!
                                                                    .area !=
                                                                null
                                                        ? "${formatedAddress!.area},"
                                                        : "") +
                                                    formatedAddress!.city!)
                                            .size(context.font.large),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                            "${formatedAddress == null || (formatedAddress?.state == "" || formatedAddress?.state == null) ? "____" : formatedAddress?.state},${formatedAddress == null || formatedAddress!.country == "" ? "____" : formatedAddress!.country}")
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ]),
            )
          : shimmerEffect();
    });
  }

  void dialogueBottomSheet(
      {required String title,
      required TextEditingController controller,
      required String hintText,
      required int from}) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        content: dialogueWidget(title, controller, hintText),
        acceptButtonName: "add".translate(context),
        isAcceptContainesPush: true,
        onAccept: () => Future.value().then((_) {
          if (_formKey.currentState!.validate()) {
            setState(() {
              if (formatedAddress != null) {
                // Update existing formatedAddress
                if (from == 1) {
                  formatedAddress = AddressComponent.copyWithFields(
                      formatedAddress!,
                      newCity: controller.text);
                } else if (from == 2) {
                  formatedAddress = AddressComponent.copyWithFields(
                      formatedAddress!,
                      newState: controller.text);
                } else if (from == 3) {
                  formatedAddress = AddressComponent.copyWithFields(
                      formatedAddress!,
                      newCountry: controller.text);
                }
              } else {
                // Create a new AddressComponent if formatedAddress is null
                if (from == 1) {
                  formatedAddress = AddressComponent(
                    area: "",
                    areaId: null,
                    city: controller.text,
                    country: "",
                    state: "",
                  );
                } else if (from == 2) {
                  formatedAddress = AddressComponent(
                    area: "",
                    areaId: null,
                    city: "",
                    country: "",
                    state: controller.text,
                  );
                } else if (from == 3) {
                  formatedAddress = AddressComponent(
                    area: "",
                    areaId: null,
                    city: "",
                    country: controller.text,
                    state: "",
                  );
                }
              }
              Navigator.pop(context);
            });
          }
        }),
      ),
    );
  }

  Widget dialogueWidget(
      String title, TextEditingController controller, String hintText) {
    double bottomPadding = (MediaQuery.of(context).viewInsets.bottom - 50);
    bool isBottomPaddingNagative = bottomPadding.isNegative;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title).size(context.font.larger).centerAlign().bold(),
              Divider(
                thickness: 1,
                color: context.color.borderColor.darken(30),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    bottom: isBottomPaddingNagative ? 0 : bottomPadding,
                    start: 20,
                    end: 20,
                    top: 18),
                child: TextFormField(
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.color.textDefaultColor.withOpacity(0.5)),
                  controller: controller,
                  cursorColor: context.color.territoryColor,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return Validator.nullCheckValidator(val,
                          context: context);
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      fillColor: context.color.borderColor.darken(20),
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      hintText: hintText,
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              context.color.textDefaultColor.withOpacity(0.5)),
                      focusColor: context.color.territoryColor,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.borderColor.darken(60))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.borderColor.darken(60))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: context.color.territoryColor))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Set<Factory<OneSequenceGestureRecognizer>> getMapGestureRecognizers() {
    return <Factory<OneSequenceGestureRecognizer>>{}
      ..add(Factory<PanGestureRecognizer>(
          () => PanGestureRecognizer()..onUpdate = (dragUpdateDetails) {}))
      ..add(Factory<ScaleGestureRecognizer>(
          () => ScaleGestureRecognizer()..onStart = (dragUpdateDetails) {}))
      ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
      ..add(Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer()
            ..onDown = (dragUpdateDetails) {
              if (markerMove == false) {
              } else {
                setState(() {
                  markerMove = false;
                });
              }
            }));
  }

  Widget shimmerEffect() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
          highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            alignment: AlignmentDirectional.center,
            margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14),
          ),
        ),
        Expanded(
            child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
          highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
          child: Container(
            height: 400,
            margin: EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
          ),
        )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
            highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
              height: 146,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ),
      ],
    );
  }
}

class AddressComponent {
  final String? area;
  final int? areaId;
  final String? city;
  final String? state;
  final String? country;
  final String mixed;

  AddressComponent({
    this.area,
    this.areaId,
    this.city,
    this.state,
    this.country,
  }) : mixed = _generateMixedString(area, city, state, country);

  AddressComponent.copyWithFields(
    AddressComponent original, {
    String? newArea,
    int? newAreaId,
    String? newCity,
    String? newState,
    String? newCountry,
  })  : area = newArea ?? original.area,
        areaId = newAreaId ?? original.areaId,
        city = newCity ?? original.city,
        state = newState ?? original.state,
        country = newCountry ?? original.country,
        mixed = _generateMixedString(
          newArea ?? original.area,
          newCity ?? original.city,
          newState ?? original.state,
          newCountry ?? original.country,
        );

  static String _generateMixedString(
      String? area, String? city, String? state, String? country) {
    return [area, city, state, country]
        .where((element) => element != null && element.isNotEmpty)
        .join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'area': area,
      'areaId': areaId,
      'city': city,
      'state': state,
      'country': country,
      'mixed': mixed,
    };
  }

  factory AddressComponent.fromMap(Map<String, dynamic> map) {
    return AddressComponent(
      area: map['area'],
      areaId: map['areaId'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
    );
  }

  @override
  String toString() {
    return 'AddressComponent{area: $area, areaId: $areaId, city: $city, state: $state, country: $country, mixed: $mixed}';
  }
}
