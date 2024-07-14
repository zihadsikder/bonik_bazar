// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Repositories/chat_repository.dart';

class BlockUserState {}

class BlockUserInitial extends BlockUserState {}

class BlockUserInProgress extends BlockUserState {}

class BlockUserSuccess extends BlockUserState {
  final dynamic message;

  BlockUserSuccess({
    required this.message,
  });
}

class BlockUserFail extends BlockUserState {
  dynamic error;

  BlockUserFail({
    required this.error,
  });
}

class BlockUserCubit extends Cubit<BlockUserState> {
  BlockUserCubit() : super(BlockUserInitial());

  final ChatRepostiory _chatRepository = ChatRepostiory();

  void blockUser({required int blockUserId}) async {
    try {
      emit(BlockUserInProgress());

      var result = await _chatRepository.blockUserApi(blockUserId: blockUserId);

      emit(BlockUserSuccess(message: result['message']));
    } catch (e) {
      emit(BlockUserFail(error: e.toString()));
    }
  }
}
