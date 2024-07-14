import '../../utils/api.dart';
import '../model/blog_model.dart';
import '../model/data_output.dart';

class BlogsRepository {
  Future<DataOutput<BlogModel>> fetchBlogs({required int page}) async {
    Map<String, dynamic> parameters = {
      Api.page: page,
    };

    Map<String, dynamic> result =
        await Api.get(url: Api.getBlogApi, queryParameters: parameters);

    List<BlogModel> modelList = (result['data'] as List)
        .map((element) => BlogModel.fromJson(element))
        .toList();

    return DataOutput<BlogModel>(
        total: result['total'] ?? 0, modelList: modelList);
  }
}
