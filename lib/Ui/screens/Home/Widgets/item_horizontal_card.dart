// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eClassify/Ui/screens/widgets/promoted_widget.dart';

import 'package:eClassify/Utils/AppIcon.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/string_extenstion.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../Utils/ui_utils.dart';
import '../../../../app/app_theme.dart';
import '../../../../data/Repositories/favourites_repository.dart';
import '../../../../data/cubits/favorite/favoriteCubit.dart';
import '../../../../data/cubits/favorite/manageFavCubit.dart';
import '../../../../data/cubits/system/app_theme_cubit.dart';
import '../../../../utils/constant.dart';

class ItemHorizontalCard extends StatelessWidget {
  final ItemModel item;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final bool? useRow;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;

  const ItemHorizontalCard(
      {super.key,
      required this.item,
      this.useRow,
      this.addBottom,
      this.additionalHeight,
      this.statusButton,
      this.showDeleteButton,
      this.onDeleteTap,
      this.showLikeButton,
      this.additionalImageWidth});

  Widget favButton(BuildContext context) {
    bool isLike = context.read<FavoriteCubit>().isItemFavorite(item.id!);

    return BlocProvider(
        create: (context) => UpdateFavoriteCubit(FavoriteRepository()),
        child: BlocConsumer<FavoriteCubit, FavoriteState>(
            bloc: context.read<FavoriteCubit>(),
            listener: ((context, state) {
              if (state is FavoriteFetchSuccess) {
                isLike = context.read<FavoriteCubit>().isItemFavorite(item.id!);
              }
            }),
            builder: (context, likeAndDislikeState) {
              return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
                  bloc: context.read<UpdateFavoriteCubit>(),
                  listener: ((context, state) {
                    if (state is UpdateFavoriteSuccess) {
                      if (state.wasProcess) {
                        context
                            .read<FavoriteCubit>()
                            .addFavoriteitem(state.item);
                      } else {
                        context
                            .read<FavoriteCubit>()
                            .removeFavoriteItem(state.item);
                      }
                    }
                  }),
                  builder: (context, state) {
                    return InkWell(
                      onTap: () {
                        UiUtils.checkUser(
                            onNotGuest: () {
                              context
                                  .read<UpdateFavoriteCubit>()
                                  .setFavoriteItem(
                                    item: item,
                                    type: isLike ? 0 : 1,
                                  );
                            },
                            context: context);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow:
                              context.watch<AppThemeCubit>().state.appTheme ==
                                      AppTheme.dark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Color.fromARGB(12, 0, 0, 0),
                                        offset: Offset(0, 2),
                                        blurRadius: 10,
                                        spreadRadius: 4,
                                      )
                                    ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: state is UpdateFavoriteInProgress
                              ? Center(child: UiUtils.progress())
                              : UiUtils.getSvg(
                                  isLike ? AppIcons.like_fill : AppIcons.like,
                                  width: 22,
                                  height: 22,
                                  color: context.color.territoryColor,
                                ),
                        ),
                      ),
                    );
                  });
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Container(
        height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
        decoration: BoxDecoration(
            border: Border.all(color: context.color.borderColor.darken(50)),
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(15)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: UiUtils.getImage(
                                  item.image ?? "",
                                  height: addBottom == null
                                      ? 122
                                      : (122 +
                                          (additionalHeight ??
                                              0)) /*statusButton != null ? 90 : 120*/,
                                  width: 100 + (additionalImageWidth ?? 0),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Text(item.promoted.toString()),
                              if (item.isFeature ?? false)
                                const PositionedDirectional(
                                    start: 5,
                                    top: 5,
                                    child: PromotedCard(
                                        type: PromoteCardType.icon)),
                            ],
                          ),
                          if (statusButton != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: statusButton!.color,
                                    borderRadius: BorderRadius.circular(4)),
                                width: 80,
                                height: 120 - 90 - 8,
                                child: Center(
                                    child: Text(statusButton!.lable)
                                        .size(context.font.small)
                                        .bold()
                                        .color(statusButton?.textColor ??
                                            Colors.black)),
                              ),
                            )
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: 0,
                            start: 12,
                            bottom: 5,
                            end: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      Constant.currencySymbol +
                                          item.price!
                                              .toString()
                                              .priceFormate(
                                                  disabled: Constant
                                                          .isNumberWithSuffix ==
                                                      false)
                                              .toString()
                                              .formatAmount(
                                                prefix: true,
                                              ),
                                    )
                                        .size(context.font.large)
                                        .color(context.color.territoryColor)
                                        .bold(weight: FontWeight.w700),
                                  ),
                                  if (showLikeButton ?? true) favButton(context)
                                ],
                              ),
                              Text(
                                item.name!.firstUpperCase(),
                              )
                                  .setMaxLines(lines: 2)
                                  .size(context.font.normal)
                                  .color(context.color.textDefaultColor),
                              //SizedBox(height: 5),
                              if (item.address != "")
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 15,
                                      color: context.color.textDefaultColor
                                          .withOpacity(0.5),
                                    ),
                                    Expanded(
                                      child: Text(item.address?.trim() ?? "")
                                          .setMaxLines(lines: 1)
                                          .color(context.color.textDefaultColor
                                              .withOpacity(0.5))
                                          .size(context.font.smaller),
                                    )
                                  ],
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (useRow == false || useRow == null) ...addBottom ?? [],

                if (useRow == true) ...{Row(children: addBottom ?? [])}

                // ...addBottom ?? []
              ],
            ),
            if (showDeleteButton ?? false)
              PositionedDirectional(
                top: 32 * 2,
                end: 12,
                child: InkWell(
                  onTap: () {
                    onDeleteTap?.call();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.color.secondaryColor,
                      shape: BoxShape.circle,
                      boxShadow: context.watch<AppThemeCubit>().state.appTheme ==
                          AppTheme.dark
                          ? null
                          : [
                        BoxShadow(
                            color: Color.fromARGB(33, 0, 0, 0),
                            offset: Offset(0, 2),
                            blurRadius: 15,
                            spreadRadius: 0)
                      ],
                    ),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: FittedBox(
                        fit: BoxFit.none,
                        child: SvgPicture.asset(
                          AppIcons.bin,
                          colorFilter: ColorFilter.mode(
                              context.color.territoryColor, BlendMode.srcIn),
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StatusButton {
  final String lable;
  final Color color;
  final Color? textColor;

  StatusButton({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
