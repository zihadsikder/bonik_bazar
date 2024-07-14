import 'dart:async';
import 'package:eClassify/data/cubits/Location/fetch_areas_cubit.dart';
import 'package:eClassify/data/cubits/Location/fetch_cities_cubit.dart';
import 'package:eClassify/data/model/Location/cityModel.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../../../Utils/api.dart';
import '../../../Utils/cloudState/cloud_state.dart';
import '../../../data/cubits/Home/fetch_home_all_items_cubit.dart';
import '../../../data/cubits/Home/fetch_home_screen_cubit.dart';
import '../../../exports/main_export.dart';
import '../Widgets/Errors/no_data_found.dart';
import '../Widgets/Errors/no_internet.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Errors/something_went_wrong.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import '../../../utils/ui_utils.dart';
import '../../../Utils/helper_utils.dart';

class CitiesScreen extends StatefulWidget {
  final int stateId;
  final String stateName;
  final String countryName;
  final String from;

  const CitiesScreen({
    super.key,
    required this.stateId,
    required this.stateName,
    required this.from,
    required this.countryName,
  });

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;

    return BlurredRouter(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FetchCitiesCubit(),
          ),

          /* BlocProvider(
            create: (context) => FetchHomeAllItemsCubit(),
          ),
          BlocProvider(
            create: (context) => FetchHomeScreenCubit(),
          ),*/
        ],
        child: CitiesScreen(
          stateId: arguments?['stateId'],
          stateName: arguments?['stateName'],
          from: arguments?['from'],
          countryName: arguments?['countryName'],
        ),
      ),
    );
  }

  @override
  CitiesScreenState createState() => CitiesScreenState();
}

class CitiesScreenState extends CloudState<CitiesScreen> {
  bool isFocused = false;
  String previousSearchQuery = "";
  TextEditingController searchController =
      TextEditingController(text: null);
  final ScrollController controller = ScrollController();
  Timer? _searchDelay;

  @override
  void initState() {
    super.initState();
    context
        .read<FetchCitiesCubit>()
        .fetchCities(search: searchController.text, stateId: widget.stateId);
    searchController = TextEditingController();

    searchController.addListener(searchItemListener);
    controller.addListener(pageScrollListen);
  }

  void pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<FetchCitiesCubit>().hasMoreData()) {
        context
            .read<FetchCitiesCubit>()
            .fetchCitiesMore(stateId: widget.stateId);
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
      context
          .read<FetchCitiesCubit>()
          .fetchCities(search: searchController.text, stateId: widget.stateId);
      previousSearchQuery = searchController.text;
      setState(() {});
    }
    // } else {
    // context.read<SearchItemCubit>().clearSearch();
    // }
  }

  PreferredSizeWidget appBarWidget() {
    return AppBar(
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarColor: context.color.backgroundColor),
      bottom: PreferredSize(
          preferredSize: Size.fromHeight(58.rh(context)),
          child: Container(
              width: double.maxFinite,
              height: 48.rh(context),
              margin: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: context.watch<AppThemeCubit>().state.appTheme ==
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
                        "${"search".translate(context)}\t${"city".translate(context)}",
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
                  }))),
      automaticallyImplyLeading: false,
      title: Text(
        widget.stateName,
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
    return Scaffold(
      appBar: appBarWidget(),
      body: bodyData(),
      backgroundColor: context.color.backgroundColor,
    );
  }

  Widget bodyData() {
    return searchItemsWidget();
  }

  Widget searchItemsWidget() {
    return BlocBuilder<FetchCitiesCubit, FetchCitiesState>(
      builder: (context, state) {
        if (state is FetchCitiesInProgress) {
          return shimmerEffect();
        }

        if (state is FetchCitiesFailure) {
          if (state.errorMessage is ApiException) {
            if (state.errorMessage == "no-internet") {
              return SingleChildScrollView(
                child: NoInternet(
                  onRetry: () {
                    context.read<FetchCitiesCubit>().fetchCities(
                        search: searchController.text, stateId: widget.stateId);
                  },
                ),
              );
            }
          }

          return Center(child: const SomethingWentWrong());
        }

        if (state is FetchCitiesSuccess) {
          if (state.citiesModel.isEmpty) {
            return SingleChildScrollView(
              child: NoDataFound(
                onTap: () {
                  context.read<FetchCitiesCubit>().fetchCities(
                      search: searchController.text, stateId: widget.stateId);
                },
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 17),
            child: Container(
              color: context.color.secondaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    child: Text(
                      "${"chooseLbl".translate(context)}\t${"city".translate(context)}",
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
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.citiesModel.length,
                      padding: EdgeInsets.zero,
                      controller: controller,
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      separatorBuilder: (context, index) {
                        return const Divider(
                          thickness: 1.2,
                          height: 10,
                        );
                      },
                      itemBuilder: (context, index) {
                        CityModel city = state.citiesModel[index];

                        return BlocProvider(
                          create: (context) => FetchAreasCubit(),
                          child: Builder(builder: (context) {
                            return BlocListener<FetchAreasCubit,
                                FetchAreasState>(
                              listener: (context, area) {
                                print("area state****$state");
                                print("city name****${city.name!}");
                                if (area is FetchAreasSuccess) {
                                  print(
                                      "area.areasModel.isNotEmpty${area.areasModel.isNotEmpty}");
                                  if (area.areasModel.isNotEmpty) {
                                    Navigator.pushNamed(
                                        context, Routes.areasScreen,
                                        arguments: {
                                          "cityId": city.id!,
                                          "cityName": city.name!,
                                          "from": widget.from,
                                          "stateName": widget.stateName,
                                          "countryName": widget.countryName,
                                          "latitude":
                                              double.parse(city.latitude!),
                                          "longitude":
                                              double.parse(city.longitude!)
                                        });
                                  } else {
                                    if (widget.from == "home") {
                                      HiveUtils.setLocation(
                                          city: city.name!,
                                          state: widget.stateName,
                                          country: widget.countryName,
                                          latitude:
                                              double.parse(city.latitude!),
                                          longitude:
                                              double.parse(city.longitude!));

                                      Future.delayed(
                                        Duration.zero,
                                        () {
                                          context
                                              .read<FetchHomeScreenCubit>()
                                              .fetch(
                                                city: city.name!,
                                              );
                                          context
                                              .read<FetchHomeAllItemsCubit>()
                                              .fetch(
                                                city: city.name!,
                                              );
                                        },
                                      );

                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);
                                    } else if (widget.from == "location") {
                                      HiveUtils.setLocation(
                                        area: null,
                                        city: city.name!,
                                        state: widget.stateName,
                                        country: widget.countryName,
                                        latitude: double.parse(city.latitude!),
                                        longitude:
                                            double.parse(city.longitude!),
                                      );
                                      HelperUtils.killPreviousPages(
                  context, Routes.main, {"from": "login"});
                                    } else {
                                      Map<String, dynamic> result = {
                                        'area_id': null,
                                        'area': null,
                                        'city': city.name!,
                                        'state': widget.stateName,
                                        'country': widget.countryName,
                                        'latitude':
                                            double.parse(city.latitude!),
                                        'longitude':
                                            double.parse(city.longitude!)
                                      };

                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Navigator.pop(context, result);
                                    }
                                  }
                                }
                                // TODO: implement listener
                              },
                              child: ListTile(
                                onTap: () {
                                  /*widget.addModel(widget.model[index]);
                                Navigator.pop(context);*/

                                  context
                                      .read<FetchAreasCubit>()
                                      .fetchAreas(cityId: city.id!);
                                },
                                title: Text(
                                  city.name!,
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
                                        color: context.color.borderColor
                                            .darken(10)),
                                    child: Icon(
                                      Icons.chevron_right_outlined,
                                      color: context.color.textDefaultColor,
                                    )),
                              ),
                            );
                          }),
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
            ),
          );
        }
        return Container();
      },
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
