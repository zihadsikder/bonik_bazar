
import 'package:eClassify/Utils/api.dart';

import '../model/CustomField/custom_field_model.dart';

class CustomFieldRepository {
  Future<List<CustomFieldModel>> getCustomFields(String categoryIds) async {
    try {
      Map<String, dynamic> parameters = {
        Api.categoryIds: categoryIds,
      };

      Map<String, dynamic> response = await Api.get(
          url: Api.getCustomFieldsApi, queryParameters: parameters);


      List<CustomFieldModel> modelList = (response['data'] as List)
          .map((e) => CustomFieldModel.fromMap(e))
          .toList();

      return modelList;
    } catch (e) {
      throw "$e";
    }
  }
}
