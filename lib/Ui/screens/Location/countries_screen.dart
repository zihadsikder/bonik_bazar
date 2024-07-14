import 'dart:async';

import 'package:eClassify/data/cubits/Location/fetch_countries_cubit.dart';
import 'package:eClassify/data/model/Location/countriesModel.dart';

import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Utils/api.dart';

import '../../../data/cubits/Home/fetch_home_all_items_cubit.dart';
import '../../../data/cubits/Home/fetch_home_screen_cubit.dart';
import '../../../exports/main_export.dart';
import '../Widgets/Errors/no_internet.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Errors/something_went_wrong.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import '../../../Utils/helper_utils.dart';
import '../../../utils/ui_utils.dart';

class CountriesScreen extends StatefulWidget {
  final String from;

  const CountriesScreen({
    super.key,
    required this.from,
  });

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;

    return BlurredRouter(
      builder: (context) => BlocProvider(
          create: (context) => FetchCountriesCubit(),
          child: CountriesScreen(
            from: arguments!['from'] ?? "",
          )),
    );
  }

  @override
  CountriesScreenState createState() => CountriesScreenState();
}

class CountriesScreenState extends State<CountriesScreen> {
  bool isFocused = false;
  String previousSearchQuery = "";
  TextEditingController searchController =
      TextEditingController(text: null);
  final ScrollController controller = ScrollController();
  Timer? _searchDelay;
  String _locationStatus = 'enableLocation'; // Initial status
  String _currentLocation = '';
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    context
        .read<FetchCountriesCubit>()
        .fetchCountries(search: searchController.text);

    searchController = TextEditingController();

    searchController.addListener(searchItemListener);
    controller.addListener(pageScrollListen);
    defaultLocation();
  }

  void pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<FetchCountriesCubit>().hasMoreData()) {
        context.read<FetchCountriesCubit>().fetchCountriesMore();
      }
    }
  }

//this will listen and manage search
  void searchItemListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
    setState(() {});
  }

//This will create delay so we don't face rapid api call
  void searchCallAfterDelay() {
    _searchDelay = Timer(const Duration(milliseconds: 500), itemSearch);
  }

  ///This will call api after some delay
  void itemSearch() {
    // if (searchController.text.isNotEmpty) {
    if (previousSearchQuery != searchController.text) {
      context.read<FetchCountriesCubit>().fetchCountries(
            search: searchController.text,
          );
      previousSearchQuery = searchController.text;
      setState(() {});
    }
    // } else {
    // context.read<SearchItemCubit>().clearSearch();
    // }
  }

  PreferredSizeWidget appBarWidget(List<CountriesModel> countriesModel) {
    return AppBar(
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarColor: context.color.backgroundColor),
      bottom: countriesModel.isNotEmpty
          ? PreferredSize(
              preferredSize: Size.fromHeight(58.rh(context)),
              child: Container(
                  width: double.maxFinite,
                  height: 48.rh(context),
                  margin: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width:
                              context.watch<AppThemeCubit>().state.appTheme ==
                                      AppTheme.dark
                                  ? 0
                                  : 1,
                          color: context.color.borderColor.darken(30)),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: context.color.secondaryColor),
                  child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        //OutlineInputBorder()
                        fillColor: Theme.of(context).colorScheme.secondaryColor,
                        hintText:
                            "${"search".translate(context)}\t${"country".translate(context)}",
                        prefixIcon: setSearchIcon(),
                        prefixIconConstraints:
                            const BoxConstraints(minHeight: 5, minWidth: 5),
                      ),
                      enableSuggestions: true,
                      onEditingComplete: () {
                        setState(
                          () {
                            isFocused = false;
                          },
                        );
                        FocusScope.of(context).unfocus();
                      },
                      onTap: () {
                        //change prefix icon color to primary
                        setState(() {
                          isFocused = true;
                        });
                      })))
          : null,
      automaticallyImplyLeading: false,
      title: Text(
        "locationLbl".translate(context),
      )
          .color(context.color.textDefaultColor)
          .bold(weight: FontWeight.w600)
          .size(18),
      leading: Material(
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        type: MaterialType.circle,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: 18.0,
            ),
            child: UiUtils.getSvg(AppIcons.arrowLeft,
                fit: BoxFit.none, color: context.color.textDefaultColor),
          ),
        ),
      ),
      /*BackButton(
        color: context.color.textDefaultColor,
      ),*/
      elevation: context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
          ? 0
          : 6,
      shadowColor:
          context.watch<AppThemeCubit>().state.appTheme == AppTheme.dark
              ? null
              : context.color.textDefaultColor.withOpacity(0.2),
      backgroundColor: context.color.backgroundColor,
    );
  }

  Widget shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      /*   padding: const EdgeInsets.symmetric(
        vertical: 10 + defaultPadding,
        //horizontal: defaultPadding,
      ),*/
      itemCount: 15,
      separatorBuilder: (context, index) {
        return Container();
      },
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
          highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
          child: Container(
            padding: EdgeInsets.all(5),
            width: double.maxFinite,
            height: 56,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border:
                    Border.all(color: context.color.borderColor.darken(30))),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchCountriesCubit, FetchCountriesState>(
        builder: (context, state) {
      List<CountriesModel> countriesModel = [];
      if (state is FetchCountriesSuccess) {
        countriesModel = state.countriesModel;
      }
      return Scaffold(
        appBar: appBarWidget(countriesModel),
        body: bodyData(),
        backgroundColor: context.color.backgroundColor,
      );
    });
  }

  Widget bodyData() {
    return searchItemsWidget();
  }

  defaultLocation() {
    _currentLocation = [
      HiveUtils.getCurrentAreaName(),
      HiveUtils.getCurrentCityName(),
      HiveUtils.getCurrentStateName(),
      HiveUtils.getCurrentCountryName()
    ].where((part) => part != null && part.isNotEmpty).join(', ');
    _locationStatus =
        _currentLocation.isNotEmpty ? 'locationFetched' : 'enableLocation';
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    if (_isFetchingLocation) return;

    setState(() {
      _isFetchingLocation = true;
      _locationStatus = 'fetchingLocation';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'locationServicesDisabled';
          _isFetchingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'locationPermissionsDenied';
            _isFetchingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'locationPermissionsPermanentlyDenied';
          _isFetchingLocation = false;
        });
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get placemarks from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        if (mounted) {
          setState(() {
            _currentLocation = [
              placemark.subLocality,
              placemark.locality,
              placemark.administrativeArea,
              placemark.country,
            ].where((part) => part != null && part.isNotEmpty).join(', ');
            _locationStatus = _currentLocation.isNotEmpty
                ? 'locationFetched'
                : 'enableLocation';
          });

          // Store current location in Hive
          HiveUtils.setCurrentLocation(
            area: placemark.subLocality,
            city: placemark.locality!,
            state: placemark.administrativeArea!,
            country: placemark.country!,
            latitude: position.latitude,
            longitude: position.longitude,
          );

          // Additional handling based on widget.from
          if (widget.from == "home") {
            HiveUtils.setLocation(
              area: placemark.subLocality,
              city: placemark.locality!,
              state: placemark.administrativeArea!,
              country: placemark.country!,
              latitude: position.latitude,
              longitude: position.longitude,
            );

            Future.delayed(Duration.zero, () {
              context.read<FetchHomeScreenCubit>().fetch(
                    city: placemark.locality!,
                  );
              context
                  .read<FetchHomeAllItemsCubit>()
                  .fetch(city: placemark.locality!);
            });
            Navigator.pop(context);
          } else if (widget.from == "location") {
            HiveUtils.setLocation(
              area: placemark.subLocality,
              city: placemark.locality!,
              state: placemark.administrativeArea!,
              country: placemark.country!,
              latitude: position.latitude,
              longitude: position.longitude,
            );
            HelperUtils.killPreviousPages(
                  context, Routes.main, {"from": "login"});
          } else {
            Map<String, dynamic> result = {
              'area_id': null,
              'area': placemark.subLocality,
              'city': placemark.locality!,
              'state': placemark.administrativeArea!,
              'country': placemark.country!,
              'latitude': position.latitude,
              'longitude': position.longitude,
            };

            Navigator.pop(context, result);
          }
        }
      } else {
        setState(() {
          _locationStatus = 'noPlacemarksFound';
        });
      }
    } catch (e) {
      setState(() {
        _locationStatus = 'locationFetchError';
      });
      print("Error fetching location: $e");
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  Widget currentLocation() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
        padding: EdgeInsets.only(top: 5),
        color: context.color.secondaryColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: InkWell(
                onTap: _isFetchingLocation ? null : _getCurrentLocation,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.my_location,
                      color: context.color.territoryColor,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("useCurrentLocation".translate(context))
                              .color(context.color.territoryColor)
                              .bold(weight: FontWeight.bold),
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Text(
                              _locationStatus == 'locationFetched'
                                  ? _currentLocation
                                  : _isFetchingLocation
                                      ? "fetchingLocation".translate(context)
                                      : "enableLocation".translate(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1.2,
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

/*  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationStatus = 'fetchingLocation';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'locationServicesDisabled';
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'locationPermissionsDenied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'locationPermissionsPermanentlyDenied';
        });
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get placemarks from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        if (mounted) {
          setState(() {
            _currentLocation = [
              placemark.subLocality,
              placemark.locality,
              placemark.administrativeArea,
              placemark.country,
            ].where((part) => part != null && part.isNotEmpty).join(', ');
            _locationStatus = _currentLocation.isNotEmpty
                ? 'locationFetched'
                : 'enableLocation';
          });

          // Store current location in Hive
          HiveUtils.setCurrentLocation(
            area: placemark.subLocality,
            city: placemark.locality!,
            state: placemark.administrativeArea!,
            country: placemark.country!,
            latitude: position.latitude,
            longitude: position.longitude,
          );

          // Additional handling based on widget.from
          if (widget.from == "home") {
            HiveUtils.setLocation(
              area: placemark.subLocality,
              city: placemark.locality!,
              state: placemark.administrativeArea!,
              country: placemark.country!,
              latitude: position.latitude,
              longitude: position.longitude,
            );

            Future.delayed(Duration.zero, () {
              context.read<FetchHomeScreenCubit>().fetch(
                    city: placemark.locality!,
                  );
              context
                  .read<FetchHomeAllItemsCubit>()
                  .fetch(city: placemark.locality!);
            });
            Navigator.pop(context);
            return;
          } else {
            Map<String, dynamic> result = {
              'area_id': null,
              'area': placemark.subLocality,
              'city': placemark.locality!,
              'state': placemark.administrativeArea!,
              'country': placemark.country!,
              'latitude': position.latitude,
              'longitude': position.longitude,
            };

            Navigator.pop(context, result);
            return;
          }
        }
      } else {
        setState(() {
          _locationStatus = 'noPlacemarksFound';
        });
      }
    } catch (e) {
      setState(() {
        _locationStatus = 'locationFetchError';
      });
      print("Error fetching location: $e");
    }
  }

  Widget currentLocation() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
        padding: EdgeInsets.only(top: 5),
        color: context.color.secondaryColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: InkWell(
                onTap: _getCurrentLocation,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.my_location,
                      color: context.color.territoryColor,
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("useCurrentLocation".translate(context))
                              .color(context.color.territoryColor)
                              .bold(weight: FontWeight.bold),
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Text(
                              _locationStatus == 'locationFetched'
                                  ? _currentLocation
                                  : "enableLocation".translate(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1.2,
              height: 10,
            ),
          ],
        ),
      ),
    );
  }*/

  Widget searchItemsWidget() {
    return Column(
      children: [
        currentLocation(),
        Expanded(
          child: BlocBuilder<FetchCountriesCubit, FetchCountriesState>(
            builder: (context, state) {
              if (state is FetchCountriesInProgress) {
                return shimmerEffect();
              }

              if (state is FetchCountriesFailure) {
                if (state.errorMessage is ApiException) {
                  if (state.errorMessage == "no-internet") {
                    return SingleChildScrollView(
                      child: NoInternet(
                        onRetry: () {
                          context
                              .read<FetchCountriesCubit>()
                              .fetchCountries(search: searchController.text);
                        },
                      ),
                    );
                  }
                }

                return Center(child: const SomethingWentWrong());
              }

              if (state is FetchCountriesSuccess) {
                if (state.countriesModel.isEmpty) {
                  return Container();
                }

                return Container(
                  width: double.infinity,
                  color: context.color.secondaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 18),
                        child: Text(
                          "${"chooseLbl".translate(context)}\t${"country".translate(context)}",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                            .color(context.color.textDefaultColor)
                            .size(context.font.normal)
                            .bold(weight: FontWeight.w600),
                      ),
                      const Divider(
                        thickness: 1.2,
                        height: 10,
                      ),
                      // Using Flexible instead of Expanded here
                      Flexible(
                        child: ListView.separated(
                          controller: controller,
                          itemCount: state.countriesModel.length,
                          padding: EdgeInsets.zero,
                          physics: AlwaysScrollableScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return const Divider(
                              thickness: 1.2,
                              height: 10,
                            );
                          },
                          itemBuilder: (context, index) {
                            CountriesModel country =
                                state.countriesModel[index];

                            return ListTile(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, Routes.statesScreen, arguments: {
                                  "countryId": country.id!,
                                  "countryName": country.name!,
                                  "from": widget.from
                                });
                              },
                              title: Text(
                                country.name!,
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                                  .color(context.color.textDefaultColor)
                                  .size(context.font.normal),
                              trailing: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color:
                                          context.color.borderColor.darken(10)),
                                  child: Icon(
                                    Icons.chevron_right_outlined,
                                    color: context.color.textDefaultColor,
                                  )),
                            );
                          },
                        ),
                      ),
                      if (state.isLoadingMore)
                        Center(
                          child: UiUtils.progress(
                            normalProgressColor: context.color.territoryColor,
                          ),
                        )
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  Widget setSearchIcon() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: UiUtils.getSvg(AppIcons.search,
            color: context.color.territoryColor));
  }

  Widget setSuffixIcon() {
    return GestureDetector(
      onTap: () {
        searchController.clear();
        isFocused = false; //set icon color to black back
        FocusScope.of(context).unfocus(); //dismiss keyboard
        setState(() {});
      },
      child: Icon(
        Icons.close_rounded,
        color: Theme.of(context).colorScheme.blackColor,
        size: 30,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    searchController.clear();
    super.dispose();
  }
}
