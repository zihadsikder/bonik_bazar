import '../../utils/api.dart';
import '../model/data_output.dart';
import '../model/transaction_model.dart';

class TransactionRepository {
  Future<DataOutput<TransactionModel>> fetchTransactions({required int page}) async {
    Map<String, dynamic> parameters = {
      //Api.page:page
    };

    Map<String, dynamic> response =
        await Api.get(url: Api.getPaymentDetailsApi, queryParameters: parameters);

    List<TransactionModel> transactionList = (response['data'] as List)
        .map((e) => TransactionModel.fromJson(e))
        .toList();

    return DataOutput<TransactionModel>(
        total: transactionList.length, modelList: transactionList);
  }
}
