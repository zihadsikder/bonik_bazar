import 'dart:async';
import 'package:eClassify/data/model/Location/statesModel.dart';

import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../../Utils/api.dart';

import '../../../data/cubits/Location/fetch_cities_cubit.dart';
import '../../../data/cubits/Location/fetch_states_cubit.dart';
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

class StatesScreen extends StatefulWidget {
  final int countryId;
  final String countryName;
  final String from;

  const StatesScreen({
    super.key,
    required this.countryId,
    required this.countryName,
    required this.from,
  });

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;

    return BlurredRouter(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FetchStatesCubit(),
          ),
          /* BlocProvider(
            create: (context) => FetchCitiesCubit(),
          ),*/
        ],
        child: StatesScreen(
          countryId: arguments?['countryId'],
          countryName: arguments?['countryName'],
          from: arguments?['from'],
        ),
      ),
    );
  }

  @override
  StatesScreenState createState() => StatesScreenState();
}

class StatesScreenState extends State<StatesScreen> {
  bool isFocused = false;
  String previousSearchQuery = "";
  TextEditingController searchController =
      TextEditingController(text: null);
  final ScrollController controller = ScrollController();
  Timer? _searchDelay;

  @override
  void initState() {
    super.initState();
    context.read<FetchStatesCubit>().fetchStates(
        search: searchController.text, countryId: widget.countryId);
    searchController = TextEditingController();

    searchController.addListener(searchItemListener);
    controller.addListener(pageScrollListen);
  }

  void pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<FetchStatesCubit>().hasMoreData()) {
        context
            .read<FetchStatesCubit>()
            .fetchStatesMore(countryId: widget.countryId);
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
      context.read<FetchStatesCubit>().fetchStates(
          search: searchController.text, countryId: widget.countryId);
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
                        "${"search".translate(context)}\t${"state".translate(context)}",
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
        widget.countryName,
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
    return BlocBuilder<FetchStatesCubit, FetchStatesState>(
      builder: (context, state) {
        print("state states****$state");
        if (state is FetchStatesInProgress) {
          return shimmerEffect();
        }

        if (state is FetchStatesFailure) {
          if (state.errorMessage is ApiException) {
            if (state.errorMessage == "no-internet") {
              return SingleChildScrollView(
                child: NoInternet(
                  onRetry: () {
                    context.read<FetchStatesCubit>().fetchStates(
                        search: searchController.text,
                        countryId: widget.countryId);
                  },
                ),
              );
            }
          }

          return Center(child: const SomethingWentWrong());
        }

        if (state is FetchStatesSuccess) {
          if (state.statesModel.isEmpty) {
            return SingleChildScrollView(
              child: NoDataFound(
                onTap: () {
                  context.read<FetchStatesCubit>().fetchStates(
                      search: searchController.text,
                      countryId: widget.countryId);
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    child: Text(
                      "${"chooseLbl".translate(context)}\t${"state".translate(context)}",
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
                  // Remove Expanded here
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: state.statesModel.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, index) {
                        return const Divider(
                          thickness: 1.2,
                          height: 10,
                        );
                      },
                      itemBuilder: (context, index) {
                        StatesModel states = state.statesModel[index];

                        return BlocProvider(
                          create: (context) => FetchCitiesCubit(),
                          child: Builder(builder: (context) {
                            return BlocListener<FetchCitiesCubit,
                                FetchCitiesState>(
                              listener: (context, city) {
                                print("city state****$city");
                                print("state name****${states.name!}");
                                if (city is FetchCitiesSuccess) {
                                  if (city.citiesModel.isNotEmpty) {
                                    print(
                                        "city.citiesModel.isNotEmpty${city.citiesModel}");
                                    Navigator.pushNamed(
                                        context, Routes.citiesScreen,
                                        arguments: {
                                          "stateId": states.id!,
                                          "stateName": states.name!,
                                          "from": widget.from,
                                          "countryName": widget.countryName
                                        });
                                  }
                                }
                              },
                              child: ListTile(
                                onTap: () {
                                  context
                                      .read<FetchCitiesCubit>()
                                      .fetchCities(stateId: states.id!);
                                },
                                title: Text(
                                  states.name!,
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

/*  Widget searchItemsWidget() {
    return BlocBuilder<FetchStatesCubit, FetchStatesState>(
      builder: (context, state) {
        print("state states****$state");
        if (state is FetchStatesInProgress) {
          return shimmerEffect();
        }

        if (state is FetchStatesFailure) {
          if (state.errorMessage is ApiException) {
            if (state.errorMessage == "no-internet") {
              return SingleChildScrollView(
                child: NoInternet(
                  onRetry: () {
                    context.read<FetchStatesCubit>().fetchStates(
                        search: searchController.text,
                        countryId: widget.countryId);
                  },
                ),
              );
            }
          }

          return Center(child: const SomethingWentWrong());
        }

        if (state is FetchStatesSuccess) {
          if (state.statesModel.isEmpty) {
            return SingleChildScrollView(
              child: NoDataFound(
                onTap: () {
                  context.read<FetchStatesCubit>().fetchStates(
                      search: searchController.text,
                      countryId: widget.countryId);
                },
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
                width: context.screenWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Container(
                    color: context.color.secondaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                          child: Text(
                            "${"chooseLbl".translate(context)}\t${"state".translate(context)}",
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
                            controller: controller,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: state.statesModel.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, index) {
                              return const Divider(
                                thickness: 1.2,
                                height: 10,
                              );
                            },
                            itemBuilder: (context, index) {
                              StatesModel states = state.statesModel[index];

                              return BlocProvider(
                                create: (context) => FetchCitiesCubit(),
                                child: Builder(builder: (context) {
                                  return BlocListener<FetchCitiesCubit,
                                      FetchCitiesState>(
                                    listener: (context, city) {
                                      print("city state****$city");
                                      print("state name****${states.name!}");
                                      if (city is FetchCitiesSuccess) {
                                        if (city.citiesModel.isNotEmpty) {
                                          print(
                                              "city.citiesModel.isNotEmpty${city.citiesModel}");
                                          Navigator.pushNamed(
                                              context, Routes.citiesScreen,
                                              arguments: {
                                                "stateId": states.id!,
                                                "stateName": states.name!,
                                                "from": widget.from,
                                                "countryName":
                                                    widget.countryName
                                              });
                                        } */ /*else {
                                              Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName(
                                                      Routes.confirmLocationScreen));
                                            }*/ /*
                                      }
                                    },
                                    child: ListTile(
                                      onTap: () {
                                        */ /*widget.addModel(widget.model[index]);
                                          Navigator.pop(context);*/ /*

                                        context
                                            .read<FetchCitiesCubit>()
                                            .fetchCities(stateId: states.id!);
                                      },
                                      title: Text(
                                        states.name!,
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: context.color.borderColor
                                                  .darken(10)),
                                          child: Icon(
                                            Icons.chevron_right_outlined,
                                            color:
                                                context.color.textDefaultColor,
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
                )),
          );
        }
        return Container();
      },
    );
  }*/

  /*Widget searchItemsWidget() {
    return BlocBuilder<FetchStatesCubit, FetchStatesState>(
      builder: (context, state) {
        print("state states****$state");
        if (state is FetchStatesInProgress) {
          return shimmerEffect();
        }

        if (state is FetchStatesFailure) {
          if (state.errorMessage is ApiException) {
            if (state.errorMessage == "no-internet") {
              return SingleChildScrollView(
                child: NoInternet(
                  onRetry: () {
                    context.read<FetchStatesCubit>().fetchStates(
                        search: searchController.text,
                        countryId: widget.countryId);
                  },
                ),
              );
            }
          }

          return Center(child: const SomethingWentWrong());
        }

        if (state is FetchStatesSuccess) {
          if (state.statesModel.isEmpty) {
            return SingleChildScrollView(
              child: NoDataFound(
                onTap: () {
                  context.read<FetchStatesCubit>().fetchStates(
                      search: searchController.text,
                      countryId: widget.countryId);
                },
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
                width: context.screenWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Container(
                    color: context.color.secondaryColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                          child: Text(
                            "${"chooseLbl".translate(context)}\t${"state".translate(context)}",
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
                            controller: controller,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: state.statesModel.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, index) {
                              return const Divider(
                                thickness: 1.2,
                                height: 10,
                              );
                            },
                            itemBuilder: (context, index) {
                              StatesModel states = state.statesModel[index];

                              return BlocListener<FetchCitiesCubit,
                                  FetchCitiesState>(
                                listener: (context, city) {
                                  if (city is FetchCitiesSuccess) {
                                    if (city.citiesModel.isNotEmpty) {
                                      Navigator.pushNamed(
                                          context, Routes.citiesScreen,
                                          arguments: {
                                            "stateId": states.id!,
                                            "stateName": states.name!,
                                            "from": widget.from,
                                            "countryName": widget.countryName
                                          });
                                    } */ /*else {
                                      Navigator.popUntil(
                                          context,
                                          ModalRoute.withName(
                                              Routes.confirmLocationScreen));
                                    }*/ /*
                                  }
                                },
                                child: ListTile(
                                  onTap: () {
                                    */ /*widget.addModel(widget.model[index]);
                                  Navigator.pop(context);*/ /*

                                    context
                                        .read<FetchCitiesCubit>()
                                        .fetchCities(
                                            search: "", stateId: states.id!);
                                  },
                                  title: Text(
                                    states.name!,
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: context.color.borderColor
                                              .darken(10)),
                                      child: Icon(
                                        Icons.chevron_right_outlined,
                                        color: context.color.textDefaultColor,
                                      )),
                                ),
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
                )),
          );
        }
        return Container();
      },
    );
  }*/

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
