import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/Utils/Extensions/extensions.dart';
import 'package:eClassify/Utils/helper_utils.dart';
import 'package:eClassify/Utils/network_request_interseptor.dart';
import 'package:eClassify/data/cubits/chatCubits/get_buyer_chat_users_cubit.dart';

import '../data/cubits/Report/update_report_items_list_cubit.dart';
import '../data/cubits/chatCubits/blocked_users_list_cubit.dart';
import '../data/cubits/favorite/favoriteCubit.dart';
import '../exports/main_export.dart';

import 'errorFilter.dart';

class ApiException implements Exception {
  ApiException(this.errorMessage);

  dynamic errorMessage;

  @override
  String toString() {
    return ErrorFilter.check(errorMessage).error;
  }
}

class Api {
  static Map<String, dynamic> headers() {
    if (!HiveUtils.isUserAuthenticated()) {
      return {};
    } else {
      String? jwtToken = HiveUtils.getJWT();

      print("get jwt****$jwtToken");

      return {
        "Authorization": "Bearer $jwtToken",
        "Accept": "application/json",
        "Content-Language": HiveUtils.getLanguage()['code'] ?? ""
      };
    }
  }

  //Place API
  static const String _placeApiBaseUrl =
      "https://maps.googleapis.com/maps/api/place/";
  static String placeApiKey = "key";
  static const String input = "input";
  static const String types = "types";
  static const String placeid = "placeid";
  static String placeAPI = "${_placeApiBaseUrl}autocomplete/json";
  static String placeApiDetails = "${_placeApiBaseUrl}details/json";

//

  static String stripeIntentAPI = "https://api.stripe.com/v1/payment_intents";

  //api fun
  static String loginApi = "user-signup";
  static String updateProfileApi = "update-profile";
  static String getSliderApi = "get-slider";
  static String getCategoriesApi = "get-categories";
  static String getItemApi = "get-item";
  static String getMyItemApi = "my-items";
  static String getNotificationListApi = "get-notification-list";
  static String deleteUserApi = "delete-user";
  static String manageFavouriteApi = "manage-favourite";
  static String getPackageApi = "get-package";
  static String getLanguageApi = "get-languages";
  static String getPaymentSettingsApi = "get-payment-settings";
  static String getSystemSettingsApi = "get-system-settings";
  static String getFavoriteItemApi = "get-favourite-item";
  static String updateItemStatusApi = "update-item-status";
  static String getReportReasonsApi = "get-report-reasons";
  static String addReportsApi = "add-reports";
  static String getCustomFieldsApi = "get-customfields";
  static String getFeaturedSectionApi = "get-featured-section";
  static String updateItemApi = "update-item";
  static String addItemApi = "add-item";
  static String deleteItemApi = "delete-item";
  static String setItemTotalClickApi = "set-item-total-click";
  static String makeItemFeaturedApi = "make-item-featured";
  static String assignFreePackageApi = "assign-free-package";
  static String getLimitsOfPackageApi = "get-limits";
  static String getPaymentIntentApi = "payment-intent";
  static String inAppPurchaseApi = "in-app-purchase";
  static String getTipsApi = "tips";
  static String getCountriesApi = "countries";
  static String getStatesApi = "states";
  static String getCitiesApi = "cities";
  static String getAreasApi = "areas";
  static String getBlogApi = "blogs";

  //Chat module apis
  static String sendMessageApi = "send-message";
  static String getChatListApi = "chat-list";
  static String itemOfferApi = "item-offer";
  static String chatMessagesApi = "chat-messages";
  static String blockUserApi = "block-user";
  static String unBlockUserApi = "unblock-user";
  static String blockedUsersListApi = "blocked-users";

  //not used API List

  static String userPurchasePackageApi = "user-purchase-package";
  static String deleteInquiryApi = "delete-inquiry";
  static String setItemEnquiryApi = "set-item_-inquiry";
  static String getItemApiEnquiry = "get-item-inquiry";
  static String interestedUsersApi = "interested-users";
  static String storeAdvertisementApi = "store-advertisement";
  static String getPaymentDetailsApi = "payment-transactions";
  static String deleteAdvertisementApi = "delete-advertisement";
  static String deleteChatMessageApi = "delete-chat-message";

  //params
  static String id = "id";
  static String itemId = "item_id";
  static String mobile = "mobile";
  static String type = "type";
  static String firebaseId = "firebase_id";
  static String profile = "profile";
  static String fcmId = "fcm_id";
  static String address = "address";
  static String clientAddress = "client_address";
  static String email = "email";
  static String name = "name";
  static String amount = "amount";
  static String error = "error";
  static String message = "message";
  static String loginType = "logintype";
  static String isActive = "isActive";
  static String image = "image";
  static String category = "category";
  static String typeids = "typeids";
  static String userid = "userid";
  static String measurement = "measurement";
  static String categoryId = "category_id";
  static String title = "title";
  static String carpetArea = "carpet_area";
  static String builtUpArea = "built_up_area";
  static String plotArea = "plot_area";
  static String hectaArea = "hecta_area";
  static String acre = "acre";
  static String locationLatitude = "location_latitude";
  static String locationLongitude = "location_longitude";
  static String unitType = "unit_type";
  static String description = "description";
  static String furnished = "furnished";
  static String houseType = "house_type";
  static String taluka = "taluka";
  static String village = "village";
  static String properyType = "propery_type";
  static String price = "price";
  static String titleImage = "title_image";
  static String postCreated = "post_created";
  static String galleryImages = "gallery_images";
  static String typeId = "type_id";
  static String itemType = "item_type";
  static String imageUrl = "image_url";
  static String gallery = "gallery";
  static String parameterTypes = "parameter_types";
  static String status = "status";
  static String totalView = "total_view";
  static String addedBy = "added_by";
  static String district = "district";
  static String state = "state";
  static String houseNo = "house_no";
  static String surveyNo = "survey_no";
  static String plotNo = "plot_no";
  static String city = "city";
  static String languageCode = "language_code";
  static String country = "country";

  static String bathroom = "bathroom";
  static String aboutUs = "about_us";
  static String termsAndConditions = "terms_conditions";
  static String privacyPolicy = "privacy_policy";
  static String currencySymbol = "currency_symbol";
  static String company = "company";
  static String data = "data";
  static String actionType = "action_type";
  static String customerId = "customer_id";
  static String itemsId = "items_id";
  static String customersId = "customers_id";
  static String enqStatus = "status";
  static String search = "search";
  static String createdAt = "created_at";
  static String sendType = "send_type";
  static String created = "created";
  static String compName = "company_name";
  static String compWebsite = "company_website";
  static String compEmail = "company_email";
  static String compAdrs = "company_address";
  static String tele1 = "company_tel1";
  static String tele2 = "company_tel2";
  static String maintenanceMode = "maintenance_mode";
  static String maxPrice = "max_price";
  static String minPrice = "min_price";
  static String postedSince = "posted_since";
  static String item = "item";
  static String page = "page";
  static String topRated = "top_rated";
  static String promoted = "promoted";
  static String packageId = "package_id";
  static String notification = "notification";
  static String v360degImage = "threeD_image";
  static String videoLink = "video_link";
  static String categoryIds = "category_ids";
  static String sortBy = "sort_by";
  static String stateId = "state_id";
  static String countryId = "country_id";
  static String cityId = "city_id";
  static String countryCode = "country_code";

  static Future<Map<String, dynamic>> post({
    required String url,
    dynamic parameter,
    Options? options,
    bool? useBaseUrl,
  }) async {
    try {
      final Dio dio = Dio();
      dio.interceptors.add(NetworkRequestInterseptor());

      late FormData formData;

      if (parameter is Map<String, dynamic>) {
        Map<String, dynamic> formMap = {};

        parameter.forEach((key, value) {
          if (value is File) {
            // If the value is a File, convert it to MultipartFile
            formMap[key] = MultipartFile.fromFileSync(value.path,
                filename: value.path.split('/').last);
          } else if (value is List<File>) {
            // If the value is a List of Files, convert each to MultipartFile
            formMap[key] = value
                .map((file) => MultipartFile.fromFileSync(file.path,
                    filename: file.path.split('/').last))
                .toList();
          } else {
            // Otherwise, add the value as it is
            formMap[key] = value;
          }
        });

        // Create a new FormData object from the map
        formData = FormData.fromMap(
          formMap,
          ListFormat.multiCompatible,
        );
      } else {
        throw ArgumentError(
            'Invalid parameter type. Expected Map<String, dynamic>.');
      }

      final response = await dio.post(
        ((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
          headers: headers(),
        ),
      );

      var resp = response.data;

      if (resp['error'] ?? false) {
        throw ApiException(resp['message'].toString());
      }

      return Map.from(resp);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        userExpired();
      }

      if (e.response?.statusCode == 503) {
        throw "server-not-available";
      }

      throw ApiException(
        e.error is SocketException
            ? "no-internet"
            : "Something went wrong with error ${e.response?.statusCode}",
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

/*  static Future<Map<String, dynamic>> post({
    required String url,
    dynamic parameter, // Change parameter type to dynamic
    Options? options,
    bool? useBaseUrl,
  }) async {
    try {
      final Dio dio = Dio();
      dio.interceptors.add(NetworkRequestInterseptor());

      late FormData formData; // Declare FormData object

*/ /*      if (parameter is Map<String, dynamic>) {
        // If parameter is a map, treat it as form data
        formData = FormData.fromMap(
          parameter,
          ListFormat.multiCompatible,
        );
      } else if (parameter is FormData) {
        // If parameter is already a FormData object, use it directly
        formData = parameter;
      } else {
        throw ArgumentError(
            'Invalid parameter type. Expected Map<String, dynamic> or FormData.');
      }*/ /*

      if (parameter is Map<String, dynamic>) {
        // Always create a new FormData object from the map
        formData = FormData.fromMap(
          parameter,
          ListFormat.multiCompatible,
        );
      } else {
        throw ArgumentError(
            'Invalid parameter type. Expected Map<String, dynamic>.');
      }

      final response = await dio.post(
        ((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
          headers: headers(),
        ),
      );

      var resp = response.data;

      if (resp['error'] ?? false) {
        if (kDebugMode && resp?['message'] != null) {
          throw ApiException(resp['message'].toString());
        }

        throw ApiException(resp['message'].toString());
      }

      return Map.from(resp);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        userExpired();
        //throw "auth-expired";
      }

      if (e.response?.statusCode == 503) {
        throw "server-not-available";
      }

      throw ApiException(
        e.error is SocketException
            ? "no-internet"
            : "Something went wrong with error ${e.response?.statusCode}",
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      throw ApiException(st.toString());
    }
  }*/

  static void userExpired() {
    HelperUtils.showSnackBarMessage(Constant.navigatorKey.currentContext!,
        "userIsDeactivated".translate(Constant.navigatorKey.currentContext!),
        messageDuration: 3);
    Future.delayed(Duration(seconds: 2), () {
      HiveUtils.clear();
      Constant.favoriteItemList.clear();
      Constant.navigatorKey.currentContext!.read<UserDetailsCubit>().clear();
      Constant.navigatorKey.currentContext!.read<FavoriteCubit>().resetState();
      Constant.navigatorKey.currentContext!
          .read<UpdatedReportItemCubit>()
          .clearItem();
      Constant.navigatorKey.currentContext!
          .read<GetBuyerChatListCubit>()
          .resetState();
      Constant.navigatorKey.currentContext!
          .read<BlockedUsersListCubit>()
          .resetState();
      HiveUtils.logoutUser(
        Constant.navigatorKey.currentContext!,
        onLogout: () {},
      );
    });
  }

  static Future<Map<String, dynamic>> delete(
      {required String url,
      Map<String, dynamic>? queryParameters,
      bool? useBaseUrl}) async {
    try {
      //
      final Dio dio = Dio();
      dio.interceptors.add(NetworkRequestInterseptor());

      final response =
          await dio.delete(((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
              queryParameters: queryParameters,
              options: /*(useAuthToken ?? true) ?*/
                  Options(headers: headers()) /* : null*/);

      if (response.data['error'] == true) {
        throw ApiException(response.data['message'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        userExpired();
        // throw "auth-expired";
      }
      if (e.response?.statusCode == 503) {
        throw "server-not-available";
      }

      throw ApiException(e.error is SocketException
          ? "no-internet"
          : "Something went wrong with error ${e.response?.statusCode}");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      throw ApiException(st.toString());
    }
  }

  static Future<Map<String, dynamic>> get(
      {required String url,
      /* bool? useAuthToken,*/
      Map<String, dynamic>? queryParameters,
      bool? useBaseUrl}) async {
    try {
      //
      final Dio dio = Dio();
      dio.interceptors.add(NetworkRequestInterseptor());

      final response =
          await dio.get(((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
              queryParameters: queryParameters,
              options: /*(useAuthToken ?? true) ?*/
                  Options(headers: headers()) /* : null*/);

      if (response.data['error'] == true) {
        /* if(kDebugMode&&response.data?['details']!=null){


          throw ApiException(response.data['details'].toString());
        }*/

        throw ApiException(response.data['message'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        userExpired();
        // throw "auth-expired";
      }
      if (e.response?.statusCode == 503) {
        throw "server-not-available";
      }

      throw ApiException(e.error is SocketException
          ? "no-internet"
          : "Something went wrong with error ${e.response?.statusCode}");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      throw ApiException(st.toString());
    }
  }
}
