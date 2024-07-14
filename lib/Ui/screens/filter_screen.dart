// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:eClassify/Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/data/model/item_filter_model.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Utils/AppIcon.dart';

import '../../data/cubits/CustomField/fetch_custom_fields_cubit.dart';

import '../../exports/main_export.dart';
import '../../utils/api.dart';

import '../../utils/ui_utils.dart';
import 'Item/add_item_screen/CustomFiledStructure/custom_field.dart';
import 'Widgets/DynamicField/dynamic_field.dart';
import 'main_activity.dart';

class FilterScreen extends StatefulWidget {
  final Function update;
  final String from;
  final List<String>? categoryIds;

  const FilterScreen({
    super.key,
    required this.update,
    required this.from,
    this.categoryIds,
  });

  @override
  FilterScreenState createState() => FilterScreenState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => BlocProvider(
        create: (context) => FetchCustomFieldsCubit(),
        child: FilterScreen(
          update: arguments?['update'],
          from: arguments?['from'],
          categoryIds: arguments?['categoryIds'] ?? [],
        ),
      ),
    );
  }
}

class FilterScreenState extends State<FilterScreen> {
  TextEditingController minController =
      TextEditingController(text: Constant.itemFilter?.minPrice);
  TextEditingController maxController =
      TextEditingController(text: Constant.itemFilter?.maxPrice);

  // = 2; // 0: last_week   1: yesterday
  dynamic defaultCategoryID = currentVisitingCategoryId;
  dynamic defaultCategory = currentVisitingCategory;
  dynamic city = Constant.itemFilter?.city ?? "";
  dynamic area = Constant.itemFilter?.area ?? "";
  dynamic areaId = Constant.itemFilter?.areaId ?? null;
  dynamic _state = Constant.itemFilter?.state ?? "";
  dynamic country = Constant.itemFilter?.country ?? "";
  dynamic latitude = "";
  dynamic longitude = "";
  List<CustomFieldBuilder> moreDetailDynamicFields = [];

  // String _selectedOption = "All Time";
  /*List<String> postedSince = [
    "All Time",
    "Today",
    "Within 1 week",
    "Within 2 weeks",
    "Within 1 month",
    "Within 3 months"
  ];*/

  String postedOn =
      Constant.itemFilter?.postedSince ?? Constant.postedSince[0].value;

  List<CategoryModel> categoryList = [];

  @override
  void dispose() {
    minController.dispose();
    maxController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("Constant.itemFilter****${Constant.itemFilter?.customFields}");
    setDefaultVal(isRefresh: false);
    //clearFieldData();
    getCustomFieldsData();
  }

  getCustomFieldsData() {
    if (Constant.itemFilter == null) {
      AbstractField.fieldsData.clear();
    }
    print("widget categories Id****${widget.categoryIds!}");
    if (widget.categoryIds != null && widget.categoryIds!.isNotEmpty) {
      context.read<FetchCustomFieldsCubit>().fetchCustomFields(
            categoryIds: widget.categoryIds!.join(','),
          );
    }
  }

  void setDefaultVal({bool isRefresh = true}) {
    if (isRefresh) {
      postedOn = Constant.postedSince[0].value;
      Constant.itemFilter = null;
      searchbody[Api.postedSince] = Constant.postedSince[0].value;

      selectedcategoryId = "0";
      city = "";
      areaId = null;
      area = "";
      _state = "";
      country = "";
      latitude = "";
      longitude = "";
      selectedcategoryName = "";
      selectedCategory = defaultCategory;

      minController.clear();
      maxController.clear();
      moreDetailDynamicFields.clear();
      AbstractField.fieldsData.clear();
      checkFilterValSet();
      getCustomFieldsData();
    }
  }

  bool checkFilterValSet() {
    if (postedOn != Constant.postedSince[0].value ||
        minController.text.trim().isNotEmpty ||
        maxController.text.trim().isNotEmpty ||
        selectedCategory != defaultCategory) {
      return true;
    }

    return false;
  }

  void _onTapChooseLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pushNamed(context, Routes.countriesScreen,
        arguments: {"from": "addItem"}).then((value) {
      if (value != null) {
        Map<String, dynamic> location = value as Map<String, dynamic>;
        //getCloudData('add_item_location_detail');
        print("value location****$value");

        setState(() {
          area = location["area"] ?? "";
          city = location["city"] ?? "";
          areaId = location["area_id"] ?? null;
          country = location["country"] ?? "";
          _state = location["state"] ?? "";
          latitude = location["latitude"] ?? '';
          longitude = location["longitude"] ?? '';
        });
      }
    });
/*    FocusManager.instance.primaryFocus?.unfocus();
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
      latitude = place.latitude;
      longitude = place.longitude;
    }*/
  }

  Map<String, dynamic> convertToCustomFields(Map<dynamic, dynamic> fieldsData) {
    return fieldsData.map((key, value) {
      return MapEntry('custom_fields[$key]', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        checkFilterValSet();
        return;
      },
      /*  onWillPop: () async {
        checkFilterValSet();
        return true;
      },*/
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryColor,
        appBar: UiUtils.buildAppBar(
          context,
          onBackPress: () {
            checkFilterValSet();
            Navigator.pop(context);
          },
          showBackButton: true,
          title: "filterTitle".translate(context),
          actions: [
            // if ((checkFilterValSet() == true)) ...[
            FittedBox(
              fit: BoxFit.none,
              child: UiUtils.buildButton(
                context,
                onPressed: () {
                  setDefaultVal(isRefresh: true);
                  setState(() {});
                },
                width: 100,
                height: 50,
                fontSize: context.font.normal,
                buttonColor: context.color.secondaryColor,
                showElevation: false,
                textColor: context.color.textColorDark,
                buttonTitle: "reset".translate(context),
              ),
            )
            // ]
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: context.color.secondaryColor,
          elevation: 3,
          //padding: EdgeInsets.all(12),
          child: UiUtils.buildButton(context,
              outerPadding: const EdgeInsets.all(12),
              height: 50.rh(context), onPressed: () {
            print("field data******${AbstractField.fieldsData.length}");

            Map<String, dynamic> customFields =
                convertToCustomFields(AbstractField.fieldsData);
            print("customFields***$customFields");
            Constant.itemFilter = ItemFilterModel(
                maxPrice: maxController.text,
                minPrice: minController.text,
                categoryId: "",
                /* categoryId: ((selectedCategory is String)
          ? selectedCategory
          : selectedCategory?.id) ??
      "",*/
                postedSince: postedOn,
                city: city,
                areaId: areaId,
                state: _state,
                country: country,
                customFields: customFields);

            widget.update(ItemFilterModel(
                maxPrice: maxController.text,
                minPrice: minController.text,
                categoryId: widget.from == "search"
                    ? ((selectedCategory is String)
                            ? selectedCategory
                            : selectedCategory?.id) ??
                        ""
                    : '',
                postedSince: postedOn,
                city: city,
                areaId: areaId,
                state: _state,
                country: country,
                customFields: customFields));

            Navigator.pop(context, true);

            //this will set name of previous screen app bar

            /*if (selectedCategory == null) {
              selectedcategoryName = "";
            } else {
              selectedcategoryName =
                  (selectedCategory as CategoryModel).name ?? "";
            }*/
          }, buttonTitle: "applyFilter".translate(context), radius: 8),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(
              20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('locationLbl'.translate(context))
                    .bold(weight: FontWeight.w600)
                    .color(context.color.textDefaultColor),
                const SizedBox(height: 5),
                locationWidget(context),

                //categoryModule(),
                const SizedBox(
                  height: 15,
                ),
                Text('budgetLbl'.translate(context))
                    .bold(weight: FontWeight.w600)
                    .color(context.color.textDefaultColor),
                const SizedBox(height: 15),
                budgetOption(),
                const SizedBox(height: 15),
                Text('postedSinceLbl'.translate(context))
                    .bold(weight: FontWeight.w600)
                    .color(context.color.textDefaultColor),
                const SizedBox(height: 5),
                postedSinceOption(context),
                const SizedBox(height: 15),
                customFields()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customFields() {
    return BlocConsumer<FetchCustomFieldsCubit, FetchCustomFieldState>(
      listener: (context, state) {
        if (state is FetchCustomFieldSuccess) {
          moreDetailDynamicFields = context
              .read<FetchCustomFieldsCubit>()
              .getFields()
              .where((field) => field.type != "fileinput")
              .map((field) {
            print("field****${field.value}");
            Map<String, dynamic> fieldData = field.toMap();

            // Prefill value from Constant.itemFilter!.customFields
            if (Constant.itemFilter != null &&
                Constant.itemFilter!.customFields != null) {
              String customFieldKey = 'custom_fields[${fieldData['id']}]';
              print("customFieldKey****$customFieldKey");
              if (Constant.itemFilter!.customFields!
                  .containsKey(customFieldKey)) {
                fieldData['value'] =
                    Constant.itemFilter!.customFields![customFieldKey];
                print("fieldData['value']****${fieldData['value']}");
                fieldData['isEdit'] = true;
              }
            }

            CustomFieldBuilder customFieldBuilder =
                CustomFieldBuilder(fieldData);
            customFieldBuilder.stateUpdater(setState);
            customFieldBuilder.init();
            return customFieldBuilder;
          }).toList();
          print("more detail field***${moreDetailDynamicFields.length}");
          //print("custom field***${Constant.itemFilter!.customFields}");
          setState(() {});
        }
      },
      builder: (context, state) {
        if (moreDetailDynamicFields.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: moreDetailDynamicFields.map((field) {
              field.stateUpdater(setState);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                child: field.build(context),
              );
            }).toList(),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  /* Widget customFields() {
    return BlocConsumer<FetchCustomFieldsCubit, FetchCustomFieldState>(
        listener: (context, state) {
      if (state is FetchCustomFieldSuccess) {
        moreDetailDynamicFields =
            context.read<FetchCustomFieldsCubit>().getFields().where((field) {
          return field.type != "fileinput";
        }).map((field) {
          print("field****${field.value}");
          Map<String, dynamic> fieldData = field.toMap();
          CustomFieldBuilder customFieldBuilder = CustomFieldBuilder(fieldData);
          customFieldBuilder.stateUpdater(setState);
          customFieldBuilder.init();
          return customFieldBuilder;
        }).toList();
        print("more detail field***${moreDetailDynamicFields.length}");
        print("custom field***${Constant.itemFilter!.customFields}");
        setState(() {});
      }
    }, builder: (context, state) {
      if (moreDetailDynamicFields.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...moreDetailDynamicFields.map(
              (field) {
                field.stateUpdater(setState);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9.0),
                  child: field.build(context),
                );
              },
            )
          ],
        );
      } else {
        return SizedBox();
      }
    });
  }*/

  Widget categoryModule() {
    if (widget.from == "search") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          Text("category".translate(context))
              .bold(weight: FontWeight.w600)
              .color(context.color.textDefaultColor),
          const SizedBox(height: 5),
          categoryWidget(context),
          catListShow(),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget locationWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        _onTapChooseLocation();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.color.borderColor.darken(30),
                width: 1,
              )),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 14.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UiUtils.getSvg(AppIcons.locationIcon,
                    color: context.color.textDefaultColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10.0),
                    child: (city != "" && city != null)
                        ? Text(
                            "${area != null && area != "" ? '$area,' : ''}$city, $_state, $country",
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          )
                        : Text("allCities".translate(context)).color(
                            context.color.textDefaultColor.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget catListShow() {
    if (categoryList.isNotEmpty) {
      return Wrap(
          children: List.generate(categoryList.length, (index) {
        return categoryList.last.children!.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text("category".translate(context))
                      .bold(weight: FontWeight.w600)
                      .color(context.color.textDefaultColor),
                  const SizedBox(height: 5),
                  subCategoryWidget(
                      context,
                      categoryList[index],
                      "All in ${categoryList[index].name}",
                      context.color.textDefaultColor.withOpacity(0.5)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text("category".translate(context))
                      .bold(weight: FontWeight.w600)
                      .color(context.color.textDefaultColor),
                  const SizedBox(height: 5),
                  subCategoryWidget(
                      context,
                      categoryList[index],
                      categoryList[index].name!,
                      context.color.textDefaultColor),
                ],
              );
      }));
    } else {
      return SizedBox.shrink();
    }
  }

  Widget subCategoryWidget(
      BuildContext context, CategoryModel model, String name, Color color) {
    return InkWell(
      onTap: () {
        if (model.children!.isNotEmpty) {
          Navigator.pushNamed(context, Routes.subCategoryFilterScreen,
              arguments: {
                "addModel": getCategoryModel,
                "model": model.children
              });
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.color.borderColor.darken(30),
                width: 1,
              )),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 14.0),
            child: Row(
              children: [
                UiUtils.getImage(model.url!,
                    height: 20, width: 20, fit: BoxFit.contain),
                Padding(
                    padding: const EdgeInsetsDirectional.only(start: 15.0),
                    child: Text(name).color(color)),
                Spacer(),
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 14.0),
                  child: UiUtils.getSvg(
                    AppIcons.downArrow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getCategoryModel(CategoryModel model) {
    setState(() {
      bool containsModel = categoryList.any((cat) => cat.id == model.id);

      if (!containsModel) {
        categoryList.add(model);
      }
    });
  }

  Widget categoryWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.categoryFilterScreen,
            arguments: {"addModel": getCategoryModel}).then((value) {
          if (value != null) {
            CategoryModel model = value as CategoryModel;
            setState(() {
              bool containsModel =
                  categoryList.any((cat) => cat.id == model.id);

              if (!containsModel) {
                categoryList.add(model);
              } else {
                categoryList.clear();
              }
            });
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.color.borderColor.darken(30),
                width: 1,
              )),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 14.0),
            child: Row(
              children: [
                categoryList.isNotEmpty
                    ? UiUtils.getImage(categoryList[0].url!,
                        height: 20, width: 20, fit: BoxFit.contain)
                    : UiUtils.getSvg(
                        AppIcons.categoryIcon,
                      ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 15.0),
                  child: categoryList.isNotEmpty
                      ? Text("${categoryList[0].name}")
                      : Text("allCategories".translate(context)).color(
                          context.color.textDefaultColor.withOpacity(0.5)),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 14.0),
                  child: UiUtils.getSvg(
                    AppIcons.downArrow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget saveFilter() {
    //save prefs & validate fields & call API
    return IconButton(
        onPressed: () {
          Constant.itemFilter = ItemFilterModel(
            maxPrice: maxController.text,
            city: city,
            areaId: areaId,
            state: _state,
            country: country,
            minPrice: minController.text,
            categoryId: selectedCategory?.id ?? "",
            postedSince: postedOn,
          );

          Navigator.pop(context, true);
        },
        icon: const Icon(Icons.check));
  }

  Widget budgetOption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              minMaxTFF(
                "minLbl".translate(context),
              )
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              minMaxTFF("maxLbl".translate(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget minMaxTFF(String minMax) {
    return Container(
        /*  padding: EdgeInsetsDirectional.only(
            end: minMax == "minLbl".translate(context) ? 5 :),*/
        alignment: AlignmentDirectional.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Theme.of(context).colorScheme.secondaryColor),
        child: TextFormField(
            controller: (minMax == "minLbl".translate(context))
                ? minController
                : maxController,
            onChanged: ((value) {
              bool isEmpty = value.trim().isEmpty;
              if (minMax == "minLbl".translate(context)) {
                if (isEmpty && searchbody.containsKey(Api.minPrice)) {
                  searchbody.remove(Api.minPrice);
                } else {
                  searchbody[Api.minPrice] = value;
                }
              } else {
                if (isEmpty && searchbody.containsKey(Api.maxPrice)) {
                  searchbody.remove(Api.maxPrice);
                } else {
                  searchbody[Api.maxPrice] = value;
                }
              }
            }),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                isDense: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: context.color.territoryColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: context.color.borderColor.darken(30))),
                labelStyle: TextStyle(
                    color: context.color.textDefaultColor.withOpacity(0.5)),
                hintText: "00",
                label: Text(
                  minMax,
                ),
                prefixText: '${Constant.currencySymbol} ',
                prefixStyle: TextStyle(
                    color: Theme.of(context).colorScheme.territoryColor),
                fillColor: Theme.of(context).colorScheme.secondaryColor,
                border: const OutlineInputBorder()),
            keyboardType: TextInputType.number,
            style:
                TextStyle(color: Theme.of(context).colorScheme.territoryColor),
            /* onSubmitted: () */
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]));
  }

  postedSinceUpdate(String value) {
    setState(() {
      postedOn = value;
    });
  }

  Widget postedSinceOption(BuildContext context) {
    int index =
        Constant.postedSince.indexWhere((item) => item.value == postedOn);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.postedSinceFilterScreen,
            arguments: {
              "list": Constant.postedSince,
              "postedSince": postedOn,
              "update": postedSinceUpdate
            }).then((value) {});
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.color.borderColor.darken(30),
                width: 1,
              )),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 14.0),
            child: Row(
              children: [
                UiUtils.getSvg(AppIcons.sinceIcon,
                    color: context.color.textDefaultColor),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 15.0),
                  child: Text(Constant.postedSince[index].status)
                      .color(context.color.textDefaultColor.withOpacity(0.5)),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 14.0),
                  child: UiUtils.getSvg(AppIcons.downArrow,
                      color: context.color.textDefaultColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*Widget postedSinceOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("postedSinceLbl".translate(context))
            .bold(weight: FontWeight.w600)
            .color(context.color.textDefaultColor),
        SizedBox(
          height: 10.rh(context),
        ),
        Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: context.color.borderColor.darken(30),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 14.0),
            child: Row(
              children: [
                UiUtils.getSvg(
                  AppIcons.sinceIcon,
                ),
                SizedBox(width: 10),
                // Add space between icon and selected value
                Expanded(
                  child: DropdownButton<String>(
                    itemHeight: 55,
                    icon: Container(),
                    // Set the icon to null to only show the arrow icon at the end
                    underline: Container(),
                    borderRadius: BorderRadius.circular(10),
                    value: _selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue!;
                      });
                      // Perform action based on selected option
                      onClickPosted(newValue!);
                    },
                    padding: EdgeInsets.all(7),
                    items: postedSince
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 14),
                  child: UiUtils.getSvg(
                    // Icon shown at the end
                    AppIcons.downArrow,
                  ),
                ),
              ],
            ),
          ),
        )

        */ /* SizedBox(
          height: 45,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              UiUtils.buildButton(
                context,
                fontSize: context.font.small,
                showElevation: false,
                autoWidth: true,
                border:
                    BorderSide(color: context.color.borderColor, width: 1.5),
                buttonColor: searchbody[Api.postedSince] == Constant.filterAll
                    ? context.color.territoryColor
                    : context.color.territoryColor.withOpacity(0.05),
                textColor: searchbody[Api.postedSince] == Constant.filterAll
                    ? context.color.secondaryColor
                    : context.color.textColorDark,
                buttonTitle: "anytimeLbl".translate(context),
                onPressed: () {
                  onClickPosted(
                    Constant.filterAll,
                  );
                  setState(() {});
                },
              ),
              SizedBox(
                width: 5.rw(context),
              ),
              UiUtils.buildButton(
                fontSize: context.font.small,
                context,
                autoWidth: true,
                border:
                    BorderSide(color: context.color.borderColor, width: 1.5),
                textColor:
                    searchbody[Api.postedSince] == Constant.filterLastWeek
                        ? context.color.secondaryColor
                        : context.color.textColorDark,
                showElevation: false,
                buttonColor:
                    searchbody[Api.postedSince] == Constant.filterLastWeek
                        ? context.color.territoryColor
                        : context.color.territoryColor.withOpacity(0.05),
                buttonTitle: "lastWeekLbl".translate(context),
                onPressed: () {
                  onClickPosted(
                    Constant.filterLastWeek,
                  );
                },
              ),
              SizedBox(
                width: 5.rw(context),
              ),
              UiUtils.buildButton(
                fontSize: context.font.small,
                context,
                autoWidth: true,
                border:
                    BorderSide(color: context.color.borderColor, width: 1.5),
                showElevation: false,
                textColor:
                    searchbody[Api.postedSince] == Constant.filterYesterday
                        ? context.color.secondaryColor
                        : context.color.textColorDark,
                buttonColor:
                    searchbody[Api.postedSince] == Constant.filterYesterday
                        ? context.color.territoryColor
                        : context.color.territoryColor.withOpacity(0.05),
                buttonTitle: "yesterdayLbl".translate(context),
                onPressed: () {
                  onClickPosted(
                    Constant.filterYesterday,
                  );
                },
              ),
            ],
          ),
        )*/ /*
      ],
    );
  }*/

  void onClickPosted(String val) {
    if (val == Constant.postedSince[0].value &&
        searchbody.containsKey(Api.postedSince)) {
      searchbody[Api.postedSince] = "";
    } else {
      searchbody[Api.postedSince] = val;
    }

    postedOn = val;
    setState(() {});
  }
}

class PostedSinceItem {
  final String status;
  final String value;

  PostedSinceItem({
    required this.status,
    required this.value,
  });
}
