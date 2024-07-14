import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repositories/Item/item_repository.dart';

abstract class ChangeMyItemStatusState {}

class ChangeMyItemStatusInitial extends ChangeMyItemStatusState {}

class ChangeMyItemStatusInProgress extends ChangeMyItemStatusState {}

class ChangeMyItemStatusSuccess extends ChangeMyItemStatusState {
  final String message;

  ChangeMyItemStatusSuccess(this.message);
}

class ChangeMyItemStatusFailure extends ChangeMyItemStatusState {
  final String errorMessage;

  ChangeMyItemStatusFailure(this.errorMessage);
}

class ChangeMyItemStatusCubit extends Cubit<ChangeMyItemStatusState> {
  final ItemRepository _itemRepository = ItemRepository();

  ChangeMyItemStatusCubit() : super(ChangeMyItemStatusInitial());

  Future<void> changeMyItemStatus({required int id, required String status}) async {
    try {
      emit(ChangeMyItemStatusInProgress());

      await _itemRepository
          .changeMyItemStatus(itemId: id, status: status)
          .then((value) {
        emit(ChangeMyItemStatusSuccess(value["message"]));
      });
    } catch (e) {
      emit(ChangeMyItemStatusFailure(e.toString()));
    }
  }
}
