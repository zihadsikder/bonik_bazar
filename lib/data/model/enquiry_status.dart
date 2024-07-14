import '../../utils/api.dart';
import 'item/item_model.dart';


class EnquiryStatus {
  String? id;
  String? itemId;
  String? customerId;
  String? status;
  String? createdAt;
  ItemModel? item;

  EnquiryStatus(
      {this.item,
      this.id,
      this.itemId,
      this.customerId,
      this.status,
      this.createdAt});

  EnquiryStatus.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    itemId = json[Api.itemsId].toString();
    customerId = json[Api.customersId].toString();
    status = json[Api.enqStatus].toString();
    createdAt = json[Api.createdAt];
    item = ItemModel.fromJson(json[Api.item]);
  }
}
