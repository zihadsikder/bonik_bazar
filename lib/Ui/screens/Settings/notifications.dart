
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/routes.dart';
import '../../../data/cubits/fetch_notifications_cubit.dart';
import '../../../data/helper/custom_exception.dart';
import '../../../data/model/item/item_model.dart';
import '../../../data/model/notification_data.dart';

import '../../../utils/Extensions/extensions.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../Widgets/intertitial_ads_screen.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';
import '../widgets/Errors/no_data_found.dart';
import '../widgets/Errors/no_internet.dart';
import '../widgets/Errors/something_went_wrong.dart';
import '../widgets/shimmerLoadingContainer.dart';

late NotificationData selectedNotification;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  NotificationsState createState() => NotificationsState();

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const Notifications(),
    );
  }
}

class NotificationsState extends State<Notifications> {
  late final ScrollController _pageScrollController = ScrollController();

  /* ..addListener(() {
      if (_pageScrollController.isEndReached()) {
        if (context.read<FetchNotificationsCubit>().hasMoreData()) {
          context.read<FetchNotificationsCubit>().fetchNotificationsMore();
        }
      }
    });*/
  List<ItemModel> itemData = [];

  @override
  void initState() {
    super.initState();
    AdHelper.loadInterstitialAd();
    context.read<FetchNotificationsCubit>().fetchNotifications();
    _pageScrollController.addListener(_pageScroll);
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchNotificationsCubit>().hasMoreData()) {
        context.read<FetchNotificationsCubit>().fetchNotificationsMore();
      }
    }
  }

  @override
  void dispose() {
    //Routes.currentRoute = Routes.previousCustomerRoute;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AdHelper.showInterstitialAd();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: "notifications".translate(context),
        showBackButton: true,
      ),
      body: BlocBuilder<FetchNotificationsCubit, FetchNotificationsState>(
          builder: (context, state) {
        if (state is FetchNotificationsInProgress) {
          return buildNotificationShimmer();
        }
        if (state is FetchNotificationsFailure) {

          if (state.errorMessage is ApiException) {
            if (state.errorMessage.error == "no-internet") {
              return NoInternet(
                onRetry: () {
                  context.read<FetchNotificationsCubit>().fetchNotifications();
                },
              );
            }
          }

          return const SomethingWentWrong();
        }

        if (state is FetchNotificationsSuccess) {
          if (state.notificationdata.isEmpty) {
            return NoDataFound(
              onTap: () {
                context.read<FetchNotificationsCubit>().fetchNotifications();
              },
            );
          }

          return buildNotificationListWidget(state);
        }

        return const SizedBox.square();
      }),
    );
  }

  Widget buildNotificationShimmer() {
    return ListView.separated(
        padding: const EdgeInsets.all(10),
        separatorBuilder: (context, index) => const SizedBox(
              height: 10,
            ),
        itemCount: 20,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return SizedBox(
            height: 55,
            child: Row(
              children: <Widget>[
                const CustomShimmer(
                  width: 50,
                  height: 50,
                  borderRadius: 11,
                ),
                const SizedBox(
                  width: 5,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomShimmer(
                      height: 7,
                      width: 200.rw(context),
                    ),
                    const SizedBox(height: 5),
                    CustomShimmer(
                      height: 7,
                      width: 100.rw(context),
                    ),
                    const SizedBox(height: 5),
                    CustomShimmer(
                      height: 7,
                      width: 150.rw(context),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }

  Column buildNotificationListWidget(FetchNotificationsSuccess state) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
              controller: _pageScrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(10),
              separatorBuilder: (context, index) => const SizedBox(
                    height: 12,
                  ),
              itemCount: state.notificationdata.length,
              itemBuilder: (context, index) {
                NotificationData notificationData =
                    state.notificationdata[index];
                return GestureDetector(
                  onTap: () {
                    selectedNotification = notificationData;

                      HelperUtils.goToNextPage(
                          Routes.notificationDetailPage, context, false);

                  },
                  child: Container(
                    height: 101,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: context.color.borderColor.darken(50),
                          width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ClipRRect(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(15),
                            ),
                            child: UiUtils.getImage(notificationData.image!,
                                height: 53.rh(context),
                                width: 53.rw(context),
                                fit: BoxFit.fill),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                Text(
                                  notificationData.title!.firstUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .merge(const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  child: Text(
                                    notificationData.message!.firstUpperCase(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
                                  ).color(context.color.textLightColor),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(notificationData.createdAt!
                                          .formatDate()
                                          .toString())
                                      .size(context.font.smaller)
                                      .color(context.color.textLightColor),
                                )
                              ])),
                        ]),
                  ),
                );
              }),
        ),
        if (state.isLoadingMore) UiUtils.progress()
      ],
    );
  }

  Future<List<ItemModel>> getItemById() async {
    Map<String, dynamic> body = {
      // ApiParams.id: itemsId,//String itemsId
    };

    var response = await Api.get(url: Api.getItemApi, queryParameters: body);

    if (!response[Api.error]) {
      List list = response['data'];
      itemData = list.map((model) => ItemModel.fromJson(model)).toList();
    } else {
      throw CustomException(response[Api.message]);
    }
    return itemData;
  }
}
