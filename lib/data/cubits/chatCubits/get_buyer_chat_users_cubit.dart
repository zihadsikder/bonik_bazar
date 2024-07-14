// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:eClassify/data/Repositories/chat_repository.dart';
import 'package:eClassify/data/model/chat/chated_user_model.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../model/data_output.dart';

abstract class GetBuyerChatListState {}

class GetBuyerChatListInitial extends GetBuyerChatListState {}

class GetBuyerChatListInProgress extends GetBuyerChatListState {}

class GetBuyerChatListInternalProcess extends GetBuyerChatListState {}

class GetBuyerChatListSuccess extends GetBuyerChatListState {
  final int total;
  final bool isLoadingMore;
  final bool hasError;
  final int page;
  final List<ChatedUser> chatedUserList;

  GetBuyerChatListSuccess({
    required this.total,
    required this.isLoadingMore,
    required this.hasError,
    required this.chatedUserList,
    required this.page,
  });

  GetBuyerChatListSuccess copyWith({
    int? total,
    int? currentPage,
    bool? isLoadingMore,
    bool? hasError,
    int? page,
    List<ChatedUser>? chatedUserList,
  }) {
    return GetBuyerChatListSuccess(
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

  factory GetBuyerChatListSuccess.fromMap(Map<String, dynamic> map) {
    return GetBuyerChatListSuccess(
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

class GetBuyerChatListFailed extends GetBuyerChatListState {
  final dynamic error;

  GetBuyerChatListFailed(this.error);
}

class GetBuyerChatListCubit extends Cubit<GetBuyerChatListState>
    with HydratedMixin {
  GetBuyerChatListCubit() : super(GetBuyerChatListInitial());
  final ChatRepostiory _chatRepostiory = ChatRepostiory();

  ///Setting build context for later use
  void setContext(BuildContext context) {
    _chatRepostiory.setContext(context);
  }

  void fetch() async {
    try {
      emit(GetBuyerChatListInProgress());

      DataOutput<ChatedUser> result =
          await _chatRepostiory.fetchBuyerChatList(1);

      emit(
        GetBuyerChatListSuccess(
            isLoadingMore: false,
            hasError: false,
            chatedUserList: result.modelList,
            total: result.total,
            page: 1),
      );
    } catch (e) {
      emit(GetBuyerChatListFailed(e));
    }
  }

  void addNewChat(ChatedUser user) {
    //this will create new chat in chat list if there is no already
    if (state is GetBuyerChatListSuccess) {
      List<ChatedUser> chatedUserList =
          (state as GetBuyerChatListSuccess).chatedUserList;
      bool contains = chatedUserList.any(
        (element) => element.itemId == user.itemId,
      );
      if (contains == false) {
        chatedUserList.insert(0, user);
        emit((state as GetBuyerChatListSuccess)
            .copyWith(chatedUserList: chatedUserList));
      }
    }
  }

  Future<void> loadMore() async {
    try {
      if (state is GetBuyerChatListSuccess) {
        if ((state as GetBuyerChatListSuccess).isLoadingMore) {
          return;
        }
        emit((state as GetBuyerChatListSuccess).copyWith(isLoadingMore: true));

        DataOutput<ChatedUser> result =
            await _chatRepostiory.fetchBuyerChatList(
          (state as GetBuyerChatListSuccess).page + 1,
        );

        GetBuyerChatListSuccess messagesSuccessState =
            (state as GetBuyerChatListSuccess);

        // messagesSuccessState.await.insertAll(0, result.modelList);
        messagesSuccessState.chatedUserList.addAll(result.modelList);
        emit(GetBuyerChatListSuccess(
          chatedUserList: messagesSuccessState.chatedUserList,
          page: (state as GetBuyerChatListSuccess).page + 1,
          hasError: false,
          isLoadingMore: false,
          total: result.total,
        ));
      }
    } catch (e) {
      emit((state as GetBuyerChatListSuccess)
          .copyWith(isLoadingMore: false, hasError: true));
    }
  }

  bool hasMoreData() {
    if (state is GetBuyerChatListSuccess) {
      return (state as GetBuyerChatListSuccess).chatedUserList.length <
          (state as GetBuyerChatListSuccess).total;
    }

    return false;
  }

  /*void updateMakeAnOfferItem(String itemId) {
    if (state is GetBuyerChatListSuccess) {
      final offer = (state as GetBuyerChatListSuccess).chatedUserList;

      // Find the index of the item to be removed
      int index = offer.indexWhere((element) => element.itemId == itemId);
      if (index != -1) {
        // Decrement totalLikes of the item being removed
        ChatedUser chatedUserModel = offer[index];
        chatedUserModel. = (chatedUserModel.totalLikes ?? 0) - 1;
        favorite.removeAt(indexToRemove);


        emit(GetBuyerChatListSuccess(
          chatedUserList: messagesSuccessState.chatedUserList,
          page: (state as GetBuyerChatListSuccess).page + 1,
          hasError: false,
          isLoadingMore: false,
          total: result.total,
        ));

        emit(FavoriteFetchSuccess(
          isLoadingMore: false,
          favorite: List.from(favorite),
          hasMoreFetchError: true,
          page: (state as FavoriteFetchSuccess).page,
          totalFavoriteCount: (state as FavoriteFetchSuccess).totalFavoriteCount,
          hasMore: (state as FavoriteFetchSuccess).hasMore,
        ));

      }
    }
  }*/

  @override
  GetBuyerChatListState? fromJson(Map<String, dynamic> json) {
    return null;
  }

  @override
  Map<String, dynamic>? toJson(GetBuyerChatListState state) {
    return null;
  }

/*  bool isItemOffer(int itemId) {
    print("item id***$itemId");
    if (state is GetBuyerChatListSuccess) {
      List<ChatedUser> offer =
          (state as GetBuyerChatListSuccess).chatedUserList;
      print("offer****${offer.length}");
      return (offer.isNotEmpty)
          ? (offer.indexWhere((element) => (element.itemId == itemId)) != -1)
          : false;
    }
    return false;
  }*/

  ChatedUser? getOfferForItem(int itemId) {
    if (state is GetBuyerChatListSuccess) {
      List<ChatedUser> offerList =
          (state as GetBuyerChatListSuccess).chatedUserList;

      int matchingOffer = offerList.indexWhere(
        (offer) => offer.itemId == itemId,
      );
      if (matchingOffer != -1) {
        return (state as GetBuyerChatListSuccess).chatedUserList[matchingOffer];
      } else {
        return null;
      }
    }
    return null; // Return null if state is not GetBuyerChatListSuccess
  }

  void resetState() {
    emit(GetBuyerChatListInProgress());
  }
}
