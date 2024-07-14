import 'dart:async';

import 'package:flutter/material.dart';

import '../../../Utils/AppIcon.dart';
import '../../../Utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../../../data/model/item/item_model.dart';
import '../../../data/model/item_filter_model.dart';
import '../../../exports/main_export.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/api.dart';

import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../Home/Widgets/home_sections_adapter.dart';
import '../Widgets/Errors/no_data_found.dart';
import '../home/Widgets/item_horizontal_card.dart';
import '../main_activity.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/shimmerLoadingContainer.dart';

class ItemsList extends StatefulWidget {
  final String categoryId, categoryName;
  final List<String> categoryIds;

  const ItemsList(
      {super.key,
      required this.categoryId,
      required this.categoryName,
      required this.categoryIds});

  @override
  ItemsListState createState() => ItemsListState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => ItemsList(
        categoryId: arguments?['catID'] as String,
        categoryName: arguments?['catName'],
        categoryIds: arguments?['categoryIds'],
      ),
    );
  }
}

class ItemsListState extends State<ItemsList> {
  late ScrollController controller;
  static TextEditingController searchController = TextEditingController();
  bool isFocused = false;
  bool isList = true;
  String previousSearchQuery = "";
  Timer? _searchDelay;
  String? sortBy;
  ItemFilterModel? filter;

  @override
  void initState() {
    super.initState();
    searchbody = {};
    Constant.itemFilter = null;
    searchController = TextEditingController();
    searchController.addListener(searchItemListener);
    controller = ScrollController()..addListener(_loadMore);

    context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
        categoryId: int.parse(
          widget.categoryId,
        ),
        search: "");

    Future.delayed(Duration.zero, () {
      selectedcategoryId = widget.categoryId;
      selectedcategoryName = widget.categoryName;
      searchbody[Api.categoryId] = widget.categoryId;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.removeListener(_loadMore);
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  //this will listen and manage search
  void searchItemListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

//This will create delay so we don't face rapid api call
  void searchCallAfterDelay() {
    _searchDelay = Timer(const Duration(milliseconds: 500), itemSearch);
  }

  ///This will call api after some delay
  void itemSearch() {
    // if (searchController.text.isNotEmpty) {
    if (previousSearchQuery != searchController.text) {
      context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
          categoryId: int.parse(
            widget.categoryId,
          ),
          search: searchController.text);
      previousSearchQuery = searchController.text;
      sortBy = null;
      setState(() {});
    }
  }

  void _loadMore() async {
    if (controller.isEndReached()) {
      if (context.read<FetchItemFromCategoryCubit>().hasMoreData()) {
        context.read<FetchItemFromCategoryCubit>().fetchItemFromCategoryMore(
            catId: int.parse(
              widget.categoryId,
            ),
            search: searchController.text,
            sortBy: sortBy);
      }
    }
  }

  Widget searchBarWidget() {
    return Container(
      height: 56.rh(context),
      color: context.color.secondaryColor,
      child: LayoutBuilder(builder: (context, c) {
        return SizedBox(
            width: c.maxWidth,
            child: FittedBox(
              fit: BoxFit.none,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 18.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 243.rw(context),
                        height: 40.rh(context),
                        alignment: AlignmentDirectional.center,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: context.color.borderColor.darken(30)),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: context.color.primaryColor),
                        child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              //OutlineInputBorder()
                              fillColor:
                                  Theme.of(context).colorScheme.primaryColor,
                              hintText: "searchHintLbl".translate(context),
                              prefixIcon: setSearchIcon(),
                              prefixIconConstraints: const BoxConstraints(
                                  minHeight: 5, minWidth: 5),
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
                            })),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isList = false;
                        });
                      },
                      child: Container(
                        width: 40.rw(context),
                        height: 40.rh(context),
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: context.color.borderColor.darken(30)),
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: UiUtils.getSvg(AppIcons.gridViewIcon,
                              color: !isList
                                  ? context.color.textDefaultColor
                                  : context.color.textDefaultColor
                                      .withOpacity(0.2)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isList = true;
                        });
                      },
                      child: Container(
                        width: 40.rw(context),
                        height: 40.rh(context),
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: context.color.borderColor.darken(30)),
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: UiUtils.getSvg(AppIcons.listViewIcon,
                              color: isList
                                  ? context.color.textDefaultColor
                                  : context.color.textDefaultColor
                                      .withOpacity(0.2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      }),
    );
  }

  Widget setSearchIcon() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: UiUtils.getSvg(AppIcons.search,
            color: context.color.textDefaultColor));
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
  Widget build(BuildContext context) {
    return bodyWidget();
  }

  Widget bodyWidget() {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.secondaryColor,
      ),
      child: PopScope(
        canPop: true,
        onPopInvoked: (isPop) {
          Constant.itemFilter = null;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          appBar: UiUtils.buildAppBar(
            context,
            showBackButton: true,
            title: selectedcategoryName == ""
                ? widget.categoryName
                : selectedcategoryName,
          ),
          bottomNavigationBar: bottomWidget(),
          body: RefreshIndicator(
            onRefresh: () async {
              // Debug log to check if onRefresh is triggered

              searchbody = {};
              Constant.itemFilter = null;

              context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
                    categoryId: int.parse(widget.categoryId),
                    search: "",
                  );
            },
            color: context.color.territoryColor,
            child: Column(
              children: [
                searchBarWidget(),
                Expanded(child: fetchItems()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container bottomWidget() {
    return Container(
      color: context.color.secondaryColor,
      padding: EdgeInsets.only(top: 3, bottom: 3),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          filterByWidget(),
          VerticalDivider(
            color: context.color.borderColor.darken(50),
          ),
          // Add a vertical divider here
          sortByWidget(),
        ],
      ),
    );
  }

  Widget filterByWidget() {
    return InkWell(
      child: Row(
        children: [
          UiUtils.getSvg(AppIcons.filterByIcon,
              color: context.color.textDefaultColor),
          SizedBox(
            width: 7,
          ),
          Text("filterTitle".translate(context))
        ],
      ),
      onTap: () {
        Navigator.pushNamed(context, Routes.filterScreen, arguments: {
          "update": getFilterValue,
          "from": "itemsList",
          "categoryIds": widget.categoryIds
        }).then((value) {
          if (value == true) {
            ItemFilterModel updatedFilter =
                filter!.copyWith(categoryId: widget.categoryId);
            context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
                categoryId: int.parse(
                  widget.categoryId,
                ),
                search: searchController.text.toString(),
                filter: updatedFilter);
          }
          setState(() {});
        });
      },
    );
  }

  getFilterValue(ItemFilterModel model) {
    filter = model;
    setState(() {});
  }

  Widget sortByWidget() {
    return InkWell(
      child: Row(
        children: [
          UiUtils.getSvg(AppIcons.sortByIcon,
              color: context.color.textDefaultColor),
          SizedBox(
            width: 7,
          ),
          Text("sortBy".translate(context))
        ],
      ),
      onTap: () {
        showSortByBottomSheet();
      },
    );
  }

  showSortByBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: context.color.borderColor,
                    ),
                    height: 6,
                    width: 60,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 17, horizontal: 20),
                child: Text(
                  'sortBy'.translate(context),
                  textAlign: TextAlign.start,
                ).bold(weight: FontWeight.bold).size(context.font.large),
              ),

              Divider(height: 1), // Add some space between title and options
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: Text('default'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: null);

                  setState(() {
                    sortBy = null;
                  });

                  // Handle option 1 selection
                },
              ),
              Divider(height: 1), // Divider between option 1 and option 2
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: Text('newToOld'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: "new-to-old");
                  setState(() {
                    sortBy = "new-to-old";
                  });
                },
              ),
              Divider(height: 1), // Divider between option 2 and option 3
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: Text('oldToNew'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: "old-to-new");
                  setState(() {
                    sortBy = "old-to-new";
                  });
                },
              ),
              Divider(height: 1), // Divider between option 3 and option 4
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: Text('priceHighToLow'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: "price-high-to-low");
                  setState(() {
                    sortBy = "price-high-to-low";
                  });
                },
              ),
              Divider(height: 1), // Divider between option 4 and option 5
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: Text('priceLowToHigh'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: "price-low-to-high");
                  setState(() {
                    sortBy = "price-low-to-high";
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget fetchItems() {
    return BlocBuilder<FetchItemFromCategoryCubit, FetchItemFromCategoryState>(
        builder: (context, state) {
      if (state is FetchItemFromCategoryInProgress) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          itemCount: 10,
          itemBuilder: (context, index) {
            return buildItemsShimmer(context);
          },
        );
      }

      if (state is FetchItemFromCategoryFailure) {
        return Center(
          child: Text(state.errorMessage),
        );
      }
      if (state is FetchItemFromCategorySuccess) {
        if (state.itemModel.isEmpty) {
          return Center(
            child: NoDataFound(
              onTap: () {
                context
                    .read<FetchItemFromCategoryCubit>()
                    .fetchItemFromCategory(
                        categoryId: int.parse(
                          widget.categoryId,
                        ),
                        search: searchController.text.toString());
              },
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: isList
                  ? ListView.builder(
                      shrinkWrap: true,
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 3),
                      itemCount: state.itemModel.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        ItemModel item = state.itemModel[index];

                        return GestureDetector(
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
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                              crossAxisCount: 2,
                              height: MediaQuery.of(context).size.height /
                                  3.5.rh(context),
                              mainAxisSpacing: 7,
                              crossAxisSpacing: 10),
                      itemCount: state.itemModel.length,
                      itemBuilder: (context, index) {
                        ItemModel item = state.itemModel[index];

                        return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.adDetailsScreen,
                                arguments: {
                                  'model': item,
                                },
                              );
                            },
                            child: ItemCard(
                              item: item,
                            ));
                      },
                    ),
            ),
            if (state.isLoadingMore) UiUtils.progress()
          ],
        );
      }
      return Container();
    });
  }

  Widget buildItemsShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 120.rh(context),
        decoration: BoxDecoration(
            border: Border.all(width: 1.5, color: context.color.borderColor),
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            CustomShimmer(
              height: 120.rh(context),
              width: 100.rw(context),
            ),
            SizedBox(
              width: 10.rw(context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomShimmer(
                  width: 100.rw(context),
                  height: 10,
                  borderRadius: 7,
                ),
                CustomShimmer(
                  width: 150.rw(context),
                  height: 10,
                  borderRadius: 7,
                ),
                CustomShimmer(
                  width: 120.rw(context),
                  height: 10,
                  borderRadius: 7,
                ),
                CustomShimmer(
                  width: 80.rw(context),
                  height: 10,
                  borderRadius: 7,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
