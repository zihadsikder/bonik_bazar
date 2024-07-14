import 'package:eClassify/Ui/screens/Subscription/widget/subscriptionPlansItem.dart';
import 'package:eClassify/Ui/screens/Widgets/intertitial_ads_screen.dart';
import 'package:eClassify/data/cubits/subscription/assign_free_package_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_featured_subscription_packages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Utils/api.dart';
import '../../../data/cubits/subscription/fetch_ads_listing_subscription_packages_cubit.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/ui_utils.dart';
import '../Widgets/Errors/no_data_found.dart';
import '../Widgets/Errors/no_internet.dart';
import '../Widgets/Errors/something_went_wrong.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';

class SubscriptionPackageListScreen extends StatefulWidget {
  const SubscriptionPackageListScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(builder: (context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AssignFreePackageCubit(),
          ),
        ],
        child: const SubscriptionPackageListScreen(),
      );
    });
  }

  @override
  State<SubscriptionPackageListScreen> createState() =>
      _SubscriptionPackageListScreenState();
}

class _SubscriptionPackageListScreenState
    extends State<SubscriptionPackageListScreen> {
  //List mySubscriptions = [];
  bool isLifeTimeSubscription = false;
  bool hasAlreadyPackage = false;
  bool isInterstitialAdShown = false;

  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);

  int currentIndex = 0;

  //bool isCurrentPlan = false;

  @override
  void initState() {
    AdHelper.loadInterstitialAd();
    context.read<FetchAdsListingSubscriptionPackagesCubit>().fetchPackages();
    context.read<FetchFeaturedSubscriptionPackagesCubit>().fetchPackages();
    super.initState();
  }

  int selectedPage = 0;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index; //update current index for Next button
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: "subsctiptionPlane".translate(context),
          // bottomHeight: 49,
          bottomHeight: 49,

          bottom: [
            Container(
              decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  // Set background color here
                  boxShadow: [
                    BoxShadow(
                      color: context.color.borderColor.withOpacity(0.8),
                      // Shadow color
                      spreadRadius: 3,
                      // Spread radius
                      blurRadius: 2,
                      // Blur radius
                      offset: Offset(0, 1), // Shadow offset
                    ),
                  ]),
              child: TabBar(
                tabs: [
                  Tab(text: "Ads Listing"),
                  Tab(text: "Featured Ads"),
                ],

                indicatorColor: context.color.territoryColor,
                // Line color
                indicatorWeight: 3,

                // Line thickness
                labelColor: context.color.territoryColor,
                // Selected tab text color
                unselectedLabelColor:
                    context.color.textDefaultColor.withOpacity(0.5),
                // Unselected tab text color
                labelStyle: TextStyle(
                  fontSize: 16,
                ),
                // Selected tab text style
                labelPadding: EdgeInsets.symmetric(horizontal: 16),
                // Padding around the tab text
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            adsListing(),
            featuredAds(),
          ],
        ),
      ),
    );
  }

  Builder adsListing() {
    return Builder(builder: (context) {
      if (!isInterstitialAdShown) {
        AdHelper.showInterstitialAd();
        isInterstitialAdShown = true; // Update the flag
      }
      return BlocConsumer<FetchAdsListingSubscriptionPackagesCubit,
              FetchAdsListingSubscriptionPackagesState>(
          listener:
              (context, FetchAdsListingSubscriptionPackagesState state) {},
          builder: (context, state) {
            if (state is FetchAdsListingSubscriptionPackagesInProgress) {
              return Center(
                child: UiUtils.progress(),
              );
            }
            if (state is FetchAdsListingSubscriptionPackagesFailure) {
              if (state.errorMessage is ApiException) {
                if (state.errorMessage == "no-internet") {
                  return NoInternet(
                    onRetry: () {
                      context
                          .read<FetchAdsListingSubscriptionPackagesCubit>()
                          .fetchPackages();
                    },
                  );
                }
              }

              return const SomethingWentWrong();
            }
            if (state is FetchAdsListingSubscriptionPackagesSuccess) {
              if (state.subscriptionPackages.isEmpty) {
                return NoDataFound(
                  onTap: () {
                    context
                        .read<FetchAdsListingSubscriptionPackagesCubit>()
                        .fetchPackages();
                  },
                );
              }

              return PageView.builder(
                  onPageChanged: onPageChanged,
                  //update index and fetch nex index details
                  controller: pageController,
                  itemBuilder: (context, index) {
                    return SubscriptionPlansItem(
                        itemIndex: currentIndex,
                        index: index,
                        model: state.subscriptionPackages[index]);
                  },
                  itemCount: state.subscriptionPackages.length);
            }

            return Container();
          });
    });
  }

  Builder featuredAds() {
    return Builder(builder: (context) {
      if (!isInterstitialAdShown) {
        AdHelper.showInterstitialAd();
        isInterstitialAdShown = true; // Update the flag
      }
      return BlocConsumer<FetchFeaturedSubscriptionPackagesCubit,
              FetchFeaturedSubscriptionPackagesState>(
          listener: (context, FetchFeaturedSubscriptionPackagesState state) {},
          builder: (context, state) {
            if (state is FetchFeaturedSubscriptionPackagesInProgress) {
              return Center(
                child: UiUtils.progress(),
              );
            }
            if (state is FetchFeaturedSubscriptionPackagesFailure) {
              if (state.errorMessage is ApiException) {
                if (state.errorMessage == "no-internet") {
                  return NoInternet(
                    onRetry: () {
                      context
                          .read<FetchFeaturedSubscriptionPackagesCubit>()
                          .fetchPackages();
                    },
                  );
                }
              }

              return const SomethingWentWrong();
            }
            if (state is FetchFeaturedSubscriptionPackagesSuccess) {
              if (state.subscriptionPackages.isEmpty) {
                return NoDataFound(
                  onTap: () {
                    context
                        .read<FetchFeaturedSubscriptionPackagesCubit>()
                        .fetchPackages();
                  },
                );
              }

              return PageView.builder(
                  onPageChanged: onPageChanged,
                  //update index and fetch nex index details
                  controller: pageController,
                  itemBuilder: (context, index) {
                    return SubscriptionPlansItem(
                        itemIndex: currentIndex,
                        index: index,
                        model: state.subscriptionPackages[index]);
                  },
                  itemCount: state.subscriptionPackages.length);
            }

            return Container();
          });
    });
  }

  oldUi() {
    /* Scaffold(
          backgroundColor: context.color.primaryColor,
          appBar: UiUtils.buildAppBar(
            context,
            showBackButton: true,
            title: "subsctiptionPlane".translate(context),
          ),
          body: SafeArea(child: Builder(builder: (context) {
            if (!isInterstitialAdShown) {
              AdHelper.showInterstitialAd();
              isInterstitialAdShown = true; // Update the flag
            }
            return BlocConsumer<FetchAdsListingSubscriptionPackagesCubit,
                    FetchAdsListingSubscriptionPackagesState>(
                listener: (context, FetchAdsListingSubscriptionPackagesState state) {},
                builder: (context, state) {
                  if (state is FetchAdsListingSubscriptionPackagesInProgress) {
                    return Center(
                      child: UiUtils.progress(),
                    );
                  }
                  if (state is FetchAdsListingSubscriptionPackagesFailure) {
                    if (state.errorMessage is ApiException) {
                      if (state.errorMessage == "no-internet") {
                        return NoInternet(
                          onRetry: () {
                            context
                                .read<FetchAdsListingSubscriptionPackagesCubit>()
                                .fetchPackages();
                          },
                        );
                      }
                    }

                    return const SomethingWentWrong();
                  }
                  if (state is FetchAdsListingSubscriptionPackagesSuccess) {
                    if (state.subscriptionPacakges.isEmpty) {
                      return NoDataFound(
                        onTap: () {
                          context
                              .read<FetchAdsListingSubscriptionPackagesCubit>()
                              .fetchPackages();
                        },
                      );
                    }

                    return PageView.builder(
                        onPageChanged: onPageChanged,
                        //update index and fetch nex index details
                        controller: pageController,
                        itemBuilder: (context, index) {
                          return SubscriptionPlansItem(
                              itemIndex: currentIndex,
                              index: index,
                              model: state.subscriptionPacakges[index]);
                        },
                        itemCount: state.subscriptionPacakges.length);
                  }

                  return Container();
                });
          }))),*/
  }

/*  Row Indicator(FetchAdsListingSubscriptionPackagesSuccess state, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate((state.subscriptionPackages.length), (index) {
          bool isSelected = selectedPage == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: isSelected ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                border: isSelected
                    ? const Border()
                    : Border.all(color: context.color.textColorDark),
                color: isSelected
                    ? context.color.territoryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        })
      ],
    );
  }*/

  Widget PlanFacilityRow(
      {required String icon,
      required String facilityTitle,
      required String count}) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
          colorFilter:
              ColorFilter.mode(context.color.territoryColor, BlendMode.srcIn),
        ),
        const SizedBox(
          width: 11,
        ),
        Text("$facilityTitle $count")
            .size(context.font.large)
            .color(context.color.textColorDark.withOpacity(0.8))
      ],
    );
  }
}
