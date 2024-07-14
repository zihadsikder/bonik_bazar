

import 'package:eClassify/data/model/Location/statesModel.dart';

import '../../../Utils/api.dart';
import '../../model/data_output.dart';

class StatesRepository {
  Future<DataOutput<StatesModel>> fetchStates(
      {required int page, required int countryId,String? search}) async {
    Map<String, dynamic> parameters = {
      Api.page: page,
      Api.countryId: countryId,
      if(search!=null) Api.search:search
    };

    Map<String, dynamic> response = await Api.get(
      url: Api.getStatesApi,
      queryParameters: parameters,
      useBaseUrl: true,
    );

    List<StatesModel> modelList = (response['data']['data'] as List)
        .map((e) => StatesModel.fromJson(e))
        .toList();

    return DataOutput<StatesModel>(
      total: response['data']['total'] ?? 0,
      modelList: modelList,
    );
  }
}
