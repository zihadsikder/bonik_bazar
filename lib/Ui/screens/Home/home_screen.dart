// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

//import 'package:app_links/app_links.dart';
import 'package:eClassify/Ui/screens/Home/Widgets/grid_list_adapter.dart';
import 'package:eClassify/data/cubits/Home/fetch_home_all_items_cubit.dart';
import 'package:eClassify/data/cubits/Home/fetch_home_screen_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favoriteCubit.dart';

import 'package:eClassify/data/model/Home/home_screen_section.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:uni_links/uni_links.dart';

import '../../../Utils/api.dart';

import '../../../data/cubits/chatCubits/blocked_users_list_cubit.dart';
import '../../../data/cubits/chatCubits/get_buyer_chat_users_cubit.dart';
import '../../../data/helper/designs.dart';
import '../../../data/model/item/item_model.dart';
import '../../../data/model/system_settings_model.dart';
import '../../../exports/main_export.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../AdBannderScreen.dart';
import '../Widgets/Errors/no_internet.dart';
import '../Widgets/Errors/something_went_wrong.dart';
import '../Widgets/shimmerLoadingContainer.dart';
import '../home/Widgets/item_horizontal_card.dart';
import 'Widgets/category_widget_home.dart';
import 'Widgets/home_search.dart';
import 'Widgets/home_sections_adapter.dart';
import 'Widgets/home_shimmers.dart';
import 'Widgets/location_widget.dart';
import 'slider_widget.dart';

const double sidePadding = 18;

class HomeScreen extends StatefulWidget {
  final String? from;

  const HomeScreen({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  //
  @override
  bool get wantKeepAlive => true;

  //
  List<ItemModel> itemLocalList = [];

  //
  bool isCategoryEmpty = false;

  //
  late final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    initializeSettings();
    addPageScrollListener();
    notificationPermissionChecker();

    context.read<SliderCubit>().fetchSlider(
          context,
        );
    context.read<FetchCategoryCubit>().fetchCategories();
    context
        .read<FetchHomeScreenCubit>()
        .fetch(city: HiveUtils.getCityName(), areaId: HiveUtils.getAreaId());
    context
        .read<FetchHomeAllItemsCubit>()
        .fetch(city: HiveUtils.getCityName(), areaId: HiveUtils.getAreaId());

    if (HiveUtils.isUserAuthenticated()) {
      context.read<FavoriteCubit>().getFavorite();
      //fetchApiKeys();
      context.read<GetBuyerChatListCubit>().fetch();
      context.read<BlockedUsersListCubit>().blockedUsersList();
    }

    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchHomeAllItemsCubit>().hasMoreData()) {
          context.read<FetchHomeAllItemsCubit>().fetchMore(
                city: HiveUtils.getCityName(),
              );
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  void addPageScrollListener() {
    //homeScreenController.addListener(pageScrollListener);
  }

  void fetchApiKeys() {
    context.read<GetApiKeysCubit>().fetch();
  }

/*  void pageScrollListener() {
    ///This will load data on page end
    if (homeScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<FetchHomeItemsCubit>().hasMoreData()) {
          if (context.read<FetchHomeItemsCubit>().hasMoreData()) {
            context.read<FetchHomeItemsCubit>().fetchMoreItem();
          }
        }
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leadingWidth: double.maxFinite,
          leading: Padding(
              padding: EdgeInsetsDirectional.only(
                  start: sidePadding.rw(context), end: sidePadding.rw(context)),
              child: const LocationWidget()),
          /* HiveUtils.getCityName() != null
                    ? const LocationWidget()
                    : const SizedBox.shrink()),*/
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        ),
        backgroundColor: context.color.primaryColor,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,

          color: context.color.territoryColor,
          //triggerMode: RefreshIndicatorTriggerMode.onEdge,
          onRefresh: () async {
            context.read<SliderCubit>().fetchSlider(
                  context,
                );
            context.read<FetchCategoryCubit>().fetchCategories();
            context.read<FetchHomeScreenCubit>().fetch(
                city: HiveUtils.getCityName(), areaId: HiveUtils.getAreaId());
            context.read<FetchHomeAllItemsCubit>().fetch(
                city: HiveUtils.getCityName(), areaId: HiveUtils.getAreaId());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            child: Column(
              children: [
                BlocBuilder<FetchHomeScreenCubit, FetchHomeScreenState>(
                  builder: (context, state) {
                    /* if (state is FetchHomeScreenFail) {
                      return Center(child: Text("${state.error}"));
                    }*/
                    if (state is FetchHomeScreenInProgress) {
                      return shimmerEffect();
                    }
                    if (state is FetchHomeScreenSuccess) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HomeSearchField(),
                          const SliderWidget(),
                          const CategoryWidgetHome(),
                          ...List.generate(state.sections.length, (index) {
                            HomeScreenSection section = state.sections[index];
                            if (state.sections.isNotEmpty) {
                              return HomeSectionsAdapter(
                                section: section,
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          }),
                          if (state.sections.isNotEmpty &&
                              Constant.isGoogleBannerAdsEnabled == "1") ...[
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: context.color.secondaryColor),
                              height: 85,
                              margin: EdgeInsets.symmetric(
                                  horizontal: sidePadding, vertical: 10),

                              // Height of the banner ad container
                              alignment: AlignmentDirectional.center,
                              child:
                                  AdBannerWidget(), // Custom widget for banner ad
                            )
                          ] else ...[
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ],
                      );
                    }

                    return SizedBox.shrink();
                  },
                ),
                const AllItemsWidget(),
                const SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget shimmerEffect() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: defaultPadding,
        ),
        child: Column(
          children: [
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CustomShimmer(height: 52, width: double.maxFinite),
            ),
            SizedBox(
              height: 12,
            ),
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CustomShimmer(height: 170, width: double.maxFinite),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              height: 100,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 10,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8.0),
                    child: const Column(
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CustomShimmer(
                            height: 70,
                            width: 66,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomShimmer(
                          height: 10,
                          width: 48,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        const CustomShimmer(
                          height: 10,
                          width: 60,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomShimmer(
                  height: 20,
                  width: 150,
                ),
                /* CustomShimmer(
                  height: 20,
                  width: 50,
                ),*/
              ],
            ),
            Container(
              height: 214,
              margin: EdgeInsets.only(top: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 10.0),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CustomShimmer(
                            height: 147,
                            width: 250,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        CustomShimmer(
                          height: 15,
                          width: 90,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const CustomShimmer(
                          height: 14,
                          width: 230,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const CustomShimmer(
                          height: 14,
                          width: 200,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 16,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: CustomShimmer(
                          height: 147,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomShimmer(
                        height: 15,
                        width: 70,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const CustomShimmer(
                        height: 14,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const CustomShimmer(
                        height: 14,
                        width: 130,
                      ),
                    ],
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 215,
                  crossAxisCount: 2, // Single column grid
                  mainAxisSpacing: 15.0,
                  crossAxisSpacing: 15.0,
                  // You may adjust this aspect ratio as needed
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sliderWidget() {
    return BlocConsumer<SliderCubit, SliderState>(
      listener: (context, state) {
        if (state is SliderFetchSuccess) {
          setState(() {});
        }
      },
      builder: (context, state) {
        if (state is SliderFetchInProgress) {
          return const SliderShimmer();
        }
        if (state is SliderFetchFailure) {
          return Container();
        }
        if (state is SliderFetchSuccess) {
          if (state.sliderlist.isNotEmpty) {
            return const SliderWidget();
          }
        }
        return Container();
      },
    );
  }
}

class AllItemsWidget extends StatelessWidget {
  const AllItemsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchHomeAllItemsCubit, FetchHomeAllItemsState>(
      builder: (context, state) {
        print("all item state****$state");
        if (state is FetchHomeAllItemsSuccess) {
          if (state.items.isNotEmpty) {
            return Column(
              children: [
                /*GridListAdapter(
                  type: ListUiType.Grid,
                  crossAxisCount: 2,
                  height: MediaQuery.of(context).size.height / 3.5.rh(context),
                  builder: (context, int index) {
                    ItemModel? item = state.items[index];
                    return ItemCard(
                      item: item,
                      width: 192,
                    );
                  },
                  total: state.items.length,
                ),*/
                GridListAdapter(
                  type: ListUiType.Mixed,
                  mixMode: true,
                  crossAxisCount: 2,
                  height: MediaQuery.of(context).size.height / 3.5.rh(context),
                  builder: (context, int index, bool isGrid) {
                    ItemModel? item = state.items[index];

                    if (isGrid) {
                      // Show ItemCard for grid items
                      return ItemCard(
                        item: item,
                        width: 192,
                      );
                    } else {
                      // Show ItemHorizontalCard for list items
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.adDetailsScreen,
                            arguments: {
                              'model': item,
                            },
                          );
                        },
                        child: ItemHorizontalCard(
                          item: item,
                          showLikeButton: true,
                          additionalImageWidth: 8,
                        ),
                      );
                    }
                  },
                  total: state.items.length,
                ),
                if (state.isLoadingMore) UiUtils.progress(),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        }
        if (state is FetchHomeAllItemsFail) {
          if (state.error is ApiException) {
            if (state.error.error == "no-internet") {
              return Center(child: NoInternet());
            }
          }

          return const SomethingWentWrong();
        }
        return SizedBox.shrink();
      },
    );
  }
}

Widget _builderWrapper(FetchHomeAllItemsSuccess state, BuildContext context,
    int index, bool isGrid) {
  ItemModel? item = state.items[index];

  if (isGrid) {
    // Show ItemCard for grid items
    return ItemCard(
      item: item,
      width: 192,
    );
  } else {
    // Show ItemHorizontalCard for list items
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {
            'model': item,
          },
        );
      },
      child: ItemHorizontalCard(
        item: item,
        showLikeButton: true,
        additionalImageWidth: 8,
      ),
    );
  }
}

Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}
