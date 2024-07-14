/*
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/hive_keys.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../data/cubits/Home/fetch_home_all_items_cubit.dart';
import '../../../../data/cubits/Home/fetch_home_screen_cubit.dart';
import '../../../../data/model/google_place_model.dart';
import '../../../../utils/AppIcon.dart';

import '../../../../utils/ui_utils.dart';
import '../../widgets/BottomSheets/choose_location_bottomsheet.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.none,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16.rw(context),
          ),
          GestureDetector(
            onTap: () async {
              var result = await showModalBottomSheet(
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                context: context,
                builder: (context) {
                  return const ChooseLocatonBottomSheet();
                },
              );
              if (result != null) {
                GooglePlaceModel place = (result as GooglePlaceModel);

                HiveUtils.setLocation(
                    city: place.city,
                    state: place.state,
                    country: place.country,
                    placeId: place.placeId,
                    latitude: place.latitude,
                    longitude: place.longitude);

                Future.delayed(
                  Duration.zero,
                  () {
                    context.read<FetchHomeScreenCubit>().fetch(
                          city: HiveUtils.getCityName(),
                        );
                    context.read<FetchHomeAllItemsCubit>().fetch(
                          city: HiveUtils.getCityName(),
                        );
                  },
                );
              }
            },
            child: Container(
              width: 40.rw(context),
              height: 40.rh(context),
              decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: UiUtils.getSvg(
                AppIcons.location,
                fit: BoxFit.none,
                color: context.color.territoryColor,
              ),
            ),
          ),
          SizedBox(
            width: 10.rw(context),
          ),
          ValueListenableBuilder(
              valueListenable: Hive.box(HiveKeys.userDetailsBox).listenable(),
              builder: (context, value, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("locationLbl".translate(context))
                        .color(context.color.textColorDark)
                        .size(
                          context.font.small,
                        ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        HiveUtils.getCityName() == null
                            ? "---"
                            : ((HiveUtils.getCityName() ?? "") +
                                    (HiveUtils.getStateName() == null ||
                                            HiveUtils.getStateName() == ""
                                        ? ""
                                        : ",") +
                                    (HiveUtils.getStateName() ?? "") +
                                    (HiveUtils.getCountryName() == null ||
                                            HiveUtils.getCountryName() == ""
                                        ? ""
                                        : ",") +
                                    (HiveUtils.getCountryName() ?? "")) +
                                "",
                        maxLines: 1,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      )
                          .color(context.color.textColorDark)
                          .size(context.font.small)
                          .bold(weight: FontWeight.w600),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
*/

import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/hive_keys.dart';
import 'package:eClassify/Utils/responsiveSize.dart';
import 'package:eClassify/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/ui_utils.dart';


class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.none,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.pushNamed(context, Routes.countriesScreen,
                  arguments: {"from": "home"});
              /* var result = await showModalBottomSheet(
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                context: context,
                builder: (context) {
                  return SelectLocationScreen();
                },
              );
              if (result != null) {}*/
            },
            child: Container(
              width: 40.rw(context),
              height: 40.rh(context),
              decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: UiUtils.getSvg(
                AppIcons.location,
                fit: BoxFit.none,
                color: context.color.territoryColor,
              ),
            ),
          ),
          SizedBox(
            width: 10.rw(context),
          ),
          ValueListenableBuilder(
              valueListenable: Hive.box(HiveKeys.userDetailsBox).listenable(),
              builder: (context, value, child) {
                print("area name****${HiveUtils.getAreaName()}");
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("locationLbl".translate(context))
                        .color(context.color.textColorDark)
                        .size(
                          context.font.small,
                        ),
                    Text(
                      HiveUtils.getCityName() == null
                          ? "---"
                          : (HiveUtils.getAreaName() ?? "") +
                              ((HiveUtils.getAreaName() == null ||
                                          HiveUtils.getAreaName() == ""
                                      ? ""
                                      : ",") +
                                  (HiveUtils.getCityName() ?? "") +
                                  (HiveUtils.getStateName() == null ||
                                          HiveUtils.getStateName() == ""
                                      ? ""
                                      : ",") +
                                  (HiveUtils.getStateName() ?? "") +
                                  (HiveUtils.getCountryName() == null ||
                                          HiveUtils.getCountryName() == ""
                                      ? ""
                                      : ",") +
                                  (HiveUtils.getCountryName() ?? "")) +
                              "",
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    )
                        .color(context.color.textColorDark)
                        .size(context.font.small)
                        .bold(weight: FontWeight.w600),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
