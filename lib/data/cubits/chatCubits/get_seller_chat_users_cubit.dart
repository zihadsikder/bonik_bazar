// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:eClassify/data/Repositories/chat_repository.dart';
import 'package:eClassify/data/model/chat/chated_user_model.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../model/data_output.dart';

abstract class GetSellerChatListState {}

class GetSellerChatListInitial extends GetSellerChatListState {}

class GetSellerChatListInProgress extends GetSellerChatListState {}

class GetSellerChatListInternalProcess extends GetSellerChatListState {}

class GetSellerChatListSuccess extends GetSellerChatListState {
  final int total;
  final bool isLoadingMore;
  final bool hasError;
  final int page;
  final List<ChatedUser> chatedUserList;

  GetSellerChatListSuccess({
    required this.total,
    required this.isLoadingMore,
    required this.hasError,
    required this.chatedUserList,
    required this.page,
  });

  GetSellerChatListSuccess copyWith({
    int? total,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasError,
    int? page,
    List<ChatedUser>? chatedUserList,
  }) {
    return GetSellerChatListSuccess(
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      chatedUserList: chatedUserList ?? this.chatedUserList,
      page: page ?? this.page,
    );
  }

/*  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      'isLoadingMore': isLoadingMore,
      'hasError': hasError,
      'chatedUserList': chatedUserList.map((x) => x.toJson()).toList(),
      'page':page
    };
  }

  factory GetSellerChatListSuccess.fromMap(Map<String, dynamic> map) {
    return GetSellerChatListSuccess(
      total: map['total'] as int,
      page: map['page'] as int,
      isLoadingMore: map['isLoadingMore'] as bool,
      hasError: map['hasError'] as bool,
      chatedUserList: List<ChatedUser>.from(
        (map['chatedUserList'] as List<int>).map<ChatedUser>(
          (x) => ChatedUser.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }*/
}

class GetSellerChatListFailed extends GetSellerChatListState {
  final dynamic error;

  GetSellerChatListFailed(this.error);
}

class GetSellerChatListCubit extends Cubit<GetSellerChatListState>
    with HydratedMixin {
  GetSellerChatListCubit() : super(GetSellerChatListInitial());
  final ChatRepostiory _chatRepostiory = ChatRepostiory();

  ///Setting build context for later use
  void setContext(BuildContext context) {
    _chatRepostiory.setContext(context);
  }

  void fetch() async {
    try {
      emit(GetSellerChatListInProgress());

      DataOutput<ChatedUser> result =
          await _chatRepostiory.fetchSellerChatList(1);

      emit(
        GetSellerChatListSuccess(
            isLoadingMore: false,
            hasError: false,
            chatedUserList: result.modelList,
            total: result.total,
            page: 1),
      );
    } catch (e) {
      emit(GetSellerChatListFailed(e));
    }
  }

  void addNewChat(ChatedUser user) {
    //this will create new chat in chat list if there is no already
    if (state is GetSellerChatListSuccess) {
      List<ChatedUser> chatedUserList =
          (state as GetSellerChatListSuccess).chatedUserList;
      bool contains = chatedUserList.any(
        (element) => element.sellerId == user.sellerId,
      );
      if (contains == false) {
        chatedUserList.insert(0, user);
        emit((state as GetSellerChatListSuccess)
            .copyWith(chatedUserList: chatedUserList));
      }
    }
  }

  Future<void> loadMore() async {
    try {
      if (state is GetSellerChatListSuccess) {
        if ((state as GetSellerChatListSuccess).isLoadingMore) {
          return;
        }
        emit((state as GetSellerChatListSuccess).copyWith(isLoadingMore: true));

        DataOutput<ChatedUser> result =
            await _chatRepostiory.fetchSellerChatList(
          (state as GetSellerChatListSuccess).page + 1,
        );

        GetSellerChatListSuccess messagesSuccessState =
            (state as GetSellerChatListSuccess);

        // messagesSuccessState.await.insertAll(0, result.modelList);
        messagesSuccessState.chatedUserList.addAll(result.modelList);
        emit(GetSellerChatListSuccess(
          chatedUserList: messagesSuccessState.chatedUserList,
          page: (state as GetSellerChatListSuccess).page + 1,
          hasError: false,
          isLoadingMore: false,
          total: result.total,
        ));
      }
    } catch (e) {
      emit((state as GetSellerChatListSuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }

  bool hasMoreData() {
    if (state is GetSellerChatListSuccess) {
      return (state as GetSellerChatListSuccess).chatedUserList.length <
          (state as GetSellerChatListSuccess).total;
    }

    return false;
  }

  @override
  GetSellerChatListState? fromJson(Map<String, dynamic> json) {
    return null;
  }

  @override
  Map<String, dynamic>? toJson(GetSellerChatListState state) {
    return null;
  }
}
