import 'dart:io';

import '../../utils/api.dart';
import '../model/data_output.dart';
import '../model/subscription_pacakage_model.dart';

class SubscriptionRepository {
  Future<DataOutput<SubscriptionPackageModel>> getSubscriptionPacakges(
      {required String type}) async {
    Map<String, dynamic> response = await Api.get(
        url: Api.getPackageApi,
        queryParameters: {if (Platform.isIOS) "platform": "ios", "type": type});

    List<SubscriptionPackageModel> modelList = (response['data'] as List)
        .map((element) => SubscriptionPackageModel.fromJson(element))
        .toList();
    List<SubscriptionPackageModel> combineList = [];
    List<SubscriptionPackageModel> activeModelList =
        modelList.where((item) => item.isActive == true).toList();
    combineList.addAll(activeModelList);
    List<SubscriptionPackageModel> inactiveModelList =
        modelList.where((item) => item.isActive == false).toList();
    combineList.addAll(inactiveModelList);

    return DataOutput(total: combineList.length, modelList: combineList);
  }

  Future<void> subscribeToPackage(
      int packageId, bool isPackageAvailable) async {
    try {
      Map<String, dynamic> parameters = {
        Api.packageId: packageId,
        if (isPackageAvailable) 'flag': 1,
      };
      // if (isPackageAvailable) {
      //   parameters['flag'] = 1;
      // }

      await Api.post(url: Api.userPurchasePackageApi, parameter: parameters);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
