import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repositories/Item/item_repository.dart';

abstract class MakeAnOfferItemState {}

class MakeAnOfferItemInitial extends MakeAnOfferItemState {}

class MakeAnOfferItemInProgress extends MakeAnOfferItemState {}

class MakeAnOfferItemSuccess extends MakeAnOfferItemState {
  final String message;
  final dynamic data;

  //final int itemOfferId;
  //final String itemOfferAmount;

  MakeAnOfferItemSuccess(
    this.message,
    this.data,
    /*this.itemOfferId, this.itemOfferAmount*/
  );
}

class MakeAnOfferItemFailure extends MakeAnOfferItemState {
  final String errorMessage;

  MakeAnOfferItemFailure(this.errorMessage);
}

class MakeAnOfferItemCubit extends Cubit<MakeAnOfferItemState> {
  final ItemRepository _itemRepository = ItemRepository();

  MakeAnOfferItemCubit() : super(MakeAnOfferItemInitial());

  Future<void> makeAnOfferItem(int id, int amount) async {
    emit(MakeAnOfferItemInProgress());

    await _itemRepository.makeAnOfferItem(id, amount).then((value) {
      emit(MakeAnOfferItemSuccess(value['message'],
          value['data'] /* value['data']['id'],value['data']['amount']*/));
    }).catchError((e) {
      emit(MakeAnOfferItemFailure(e.toString()));
    });
  }
}
