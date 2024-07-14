
import 'package:eClassify/Ui/screens/Auth/forgot_password.dart';
import 'package:eClassify/Ui/screens/Auth/signup_screen.dart';
import 'package:eClassify/Ui/screens/Chat/blocked_user_list_screen.dart';

import 'package:eClassify/Ui/screens/FavoriteScreen.dart';
import 'package:eClassify/Ui/screens/Home/Widgets/categoryFilterScreen.dart';
import 'package:eClassify/Ui/screens/Home/Widgets/postedSinceFilter.dart';
import 'package:eClassify/Ui/screens/Item/add_item_screen/Widgets/PdfViewer.dart';
import 'package:eClassify/Ui/screens/Item/add_item_screen/add_item_details.dart';
import 'package:eClassify/Ui/screens/Item/add_item_screen/confirm_location_screen.dart';
import 'package:eClassify/Ui/screens/Item/add_item_screen/more_details.dart';
import 'package:eClassify/Ui/screens/Item/items_list.dart';
import 'package:eClassify/Ui/screens/Location/cities_screen.dart';
import 'package:eClassify/Ui/screens/Location/countries_screen.dart';
import 'package:eClassify/Ui/screens/Location/states_screen.dart';
import 'package:eClassify/Ui/screens/SubCategory/SubCategoryScreen.dart';
import 'package:eClassify/Ui/screens/ad_details_screen.dart';
import 'package:eClassify/Ui/screens/location_permission_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Ui/screens/Advertisement/my_advertisment_screen.dart';
import '../Ui/screens/Auth/login_screen.dart';
import '../Ui/screens/Blogs/blog_details.dart';
import '../Ui/screens/Blogs/blogs_screen.dart';
import '../Ui/screens/Home/Widgets/subCategoryFilterScreen.dart';
import '../Ui/screens/Home/category_list.dart';
import '../Ui/screens/Home/change_language_screen.dart';
import '../Ui/screens/Home/search_screen.dart';
import '../Ui/screens/Item/add_item_screen/Widgets/success_item_screen.dart';
import '../Ui/screens/Item/add_item_screen/select_category.dart';
import '../Ui/screens/Item/my_items_screen.dart';
import '../Ui/screens/Item/viewAll.dart';
import '../Ui/screens/Location/areas_screen.dart';
import '../Ui/screens/Onboarding/onboarding_screen.dart';

import '../Ui/screens/Settings/contact_us.dart';
import '../Ui/screens/Settings/notification_detail.dart';
import '../Ui/screens/Settings/notifications.dart';
import '../Ui/screens/Settings/profile_setting.dart';
import '../Ui/screens/Subscription/packages_list.dart';

import '../Ui/screens/Subscription/transaction_history_screen.dart';
import '../Ui/screens/Userprofile/edit_profile.dart';
import '../Ui/screens/filter_screen.dart';
import '../Ui/screens/main_activity.dart';
import '../Ui/screens/splash_screen.dart';
import '../Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart';
import '../Ui/screens/widgets/maintenance_mode.dart';
import '../data/Repositories/Item/item_repository.dart';
import '../data/model/data_output.dart';
import '../data/model/item/item_model.dart';

class Routes {
  //private constructor
  //Routes._();

  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const forgotPassword = 'forgotPassword';
  static const signup = 'signup';
  static const completeProfile = 'complete_profile';
  static const main = 'main';
  static const home = 'Home';
  static const addItem = 'addItem';
  static const waitingScreen = 'waitingScreen';
  static const categories = 'Categories';
  static const addresses = 'address';
  static const chooseAdrs = 'chooseAddress';
  static const itemsList = 'itemsList';
  static const contactUs = 'ContactUs';
  static const profileSettings = 'profileSettings';
  static const filterScreen = 'filterScreen';
  static const notificationPage = 'notificationpage';
  static const notificationDetailPage = 'notificationdetailpage';
  static const addItemScreenRoute = 'addItemScreenRoute';
  static const blogsScreenRoute = 'blogsScreenRoute';
  static const subscriptionPackageListRoute = 'subscriptionPackageListRoute';
  static const subscriptionScreen = 'subscriptionScreen';
  static const maintenanceMode = '/maintenanceMode';
  static const favoritesScreen = '/favoritescreen';
  static const promotedItemsScreen = '/promotedItemsScreen';
  static const mostLikedItemsScreen = '/mostLikedItemsScreen';
  static const mostViewedItemsScreen = '/mostViewedItemsScreen';
  static const blogDetailsScreenRoute = '/blogDetailsScreenRoute';

  static const languageListScreenRoute = '/languageListScreenRoute';
  static const searchScreenRoute = '/searchScreenRoute';
  static const itemMapScreen = '/ItemMap';
  static const dashboard = '/dashboard';
  static const subCategoryScreen = '/subCategoryScreen';
  static const categoryFilterScreen = '/categoryFilterScreen';
  static const subCategoryFilterScreen = '/subCategoryFilterScreen';
  static const postedSinceFilterScreen = '/postedSinceFilterScreen';
  static const locationPermissionScreen = '/locationPermissionScreen';

  static const myAdvertisment = '/myAdvertisment';
  static const transactionHistory = '/transactionHistory';
  static const personalizedItemScreen = '/personalizedItemScreen';
  static const myItemScreen = '/myItemScreen';
  static const pdfViewerScreen = '/pdfViewerScreen';
  static const countriesScreen = '/countriesScreen';
  static const statesScreen = '/statesScreen';
  static const citiesScreen = '/citiesScreen';
  static const areasScreen = '/areasScreen';

  ///Add Item screens
  static const selectItemTypeScreen = '/selectItemType';
  static const addItemDetailsScreen = '/addItemDetailsScreen';
  static const setItemParametersScreen = '/setItemParametersScreen';
  static const selectOutdoorFacility = '/selectOutdoorFacility';
  static const adDetailsScreen = '/adDetailsScreen';
  static const successItemScreen = '/successItemScreen';

  ///Add item screens
  static const selectCategoryScreen = '/selectCategoryScreen';
  static const selectNestedCategoryScreen = '/selectNestedCategoryScreen';
  static const addItemDetails = '/addItemDetails';
  static const addMoreDetailsScreen = '/addMoreDetailsScreen';
  static const confirmLocationScreen = '/confirmLocationScreen';
  static const sectionWiseItemsScreen = '/sectionWiseItemsScreen';
  static const blockedUserListScreen = '/blockedUserListScreen';

  // static const myItemsScreen = '/myItemsScreen';

  //Sandbox[test]
  static const playground = 'playground';

  static String currentRoute = splash;

  //static String previousCustomerRoute = splash;

  static Route onGenerateRouted(RouteSettings routeSettings) {
    //previousCustomerRoute = currentRoute;
    currentRoute = routeSettings.name ?? "";
    /*   print("Current Route is:::::::::"
        " ${routeSettings.name} ");*/

    print("currentRoue****$currentRoute");

    if (routeSettings.name!.contains('/items-details/')) {
      int itemId = int.parse(routeSettings.name!.split('/').last);
      // Fetch item details based on the itemId
      return MaterialPageRoute(builder: (context) {
        return FutureBuilder<DataOutput<ItemModel>>(
          future: ItemRepository().fetchItemFromItemId(itemId),
          builder: (context, snapshot) {
            print("snapshot connectionstate***${snapshot.connectionState}");
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Return a loading indicator while fetching data
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasError) {
              // Handle error case
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            } else {
              // Navigate to adDetailsScreen with the fetched item details
              return AdDetailsScreen(model: snapshot.data!.modelList.first);
            }
          },
        );
      });
    }

    switch (routeSettings.name) {
      case splash:
        return BlurredRouter(builder: ((context) => const SplashScreen()));
      case onboarding:
        return CupertinoPageRoute(
            builder: ((context) => const OnboardingScreen()));
      case main:
        return MainActivity.route(routeSettings);
      case login:
        return LoginScreen.route(routeSettings);
      case forgotPassword:
        return ForgotPasswordScreen.route(routeSettings);
      case signup:
        return SignupScreen.route(routeSettings);

      case completeProfile:
        return UserProfileScreen.route(routeSettings);

      case categories:
        return CategoryList.route(routeSettings);
      case subCategoryScreen:
        return SubCategoryScreen.route(routeSettings);
      case categoryFilterScreen:
        return CategoryFilterScreen.route(routeSettings);
      case subCategoryFilterScreen:
        return SubCategoryFilterScreen.route(routeSettings);
      case postedSinceFilterScreen:
        return PostedSinceFilterScreen.route(routeSettings);
      case maintenanceMode:
        return MaintenanceMode.route(routeSettings);
      case languageListScreenRoute:
        return LanguagesListScreen.route(routeSettings);

      case contactUs:
        return ContactUs.route(routeSettings);
      case locationPermissionScreen:
        return LocationPermissionScreen.route(routeSettings);
      case profileSettings:
        return ProfileSettings.route(routeSettings);
      case filterScreen:
        return FilterScreen.route(routeSettings);
      case notificationPage:
        return Notifications.route(routeSettings);
      case notificationDetailPage:
        return NotificationDetail.route(routeSettings);
      case blogsScreenRoute:
        return BlogsScreen.route(routeSettings);
      case successItemScreen:
        return SuccessItemScreen.route(routeSettings);

      case blogDetailsScreenRoute:
        return BlogDetails.route(routeSettings);
      case subscriptionPackageListRoute:
        return SubscriptionPackageListScreen.route(routeSettings);

      case favoritesScreen:
        return FavoriteScreen.route(routeSettings);

      case transactionHistory:
        return TransactionHistory.route(routeSettings);
      case blockedUserListScreen:
        return BlockedUserListScreen.route(routeSettings);
      case countriesScreen:
        return CountriesScreen.route(routeSettings);

      case statesScreen:
        return StatesScreen.route(routeSettings);
      case citiesScreen:
        return CitiesScreen.route(routeSettings);
      case areasScreen:
        return AreasScreen.route(routeSettings);

      case myAdvertisment:
        return MyAdvertisementScreen.route(routeSettings);
      case myItemScreen:
        return ItemsScreen.route(routeSettings);
      case searchScreenRoute:
        return SearchScreen.route(routeSettings);

      case itemsList:
        return ItemsList.route(routeSettings);

      //Add item screen
      case selectCategoryScreen:
        return SelectCategoryScreen.route(routeSettings);
      case selectNestedCategoryScreen:
        return SelectNestedCategory.route(routeSettings);
      case addItemDetails:
        return AddItemDetails.route(routeSettings);
      case addMoreDetailsScreen:
        return AddMoreDetailsScreen.route(routeSettings);

      case confirmLocationScreen:
        return ConfirmLocationScreen.route(routeSettings);
      case sectionWiseItemsScreen:
        return SectionItemsScreen.route(routeSettings);

      case adDetailsScreen:
        return AdDetailsScreen.route(routeSettings);

      case pdfViewerScreen:
        return PdfViewer.route(routeSettings);

      /*  case myItemsScreen:
        return ItemsScreen.route(routeSettings);*/

      default:
        return CupertinoPageRoute(builder: (context) => const Scaffold());
      /*
        if (routeSettings.name!.contains(AppSettings.shareNavigationWebUrl)) {

          return NativeLinkWidget.render(routeSettings);
        }

        return BlurredRouter(
          builder: ((context) => Scaffold(
                body: Text(
                  "pageNotFoundErrorMsg".translate(context),
                ),
              )),
        );*/
    }
  }
}
