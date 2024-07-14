// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:eClassify/data/Repositories/chat_repository.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../Ui/screens/chat/chatAudio/widgets/chat_widget.dart';

class LoadChatMessagesState {}

class LoadChatMessagesInitial extends LoadChatMessagesState {}

class LoadChatMessagesInProgress extends LoadChatMessagesState {}

class LoadChatMessagesSuccess extends LoadChatMessagesState {
  List<ChatMessage> messages;
  int currentPage;
  int itemOfferId;
  int totalPage;
  bool isLoadingMore;

  LoadChatMessagesSuccess({
    required this.messages,
    required this.currentPage,
    required this.itemOfferId,
    required this.totalPage,
    required this.isLoadingMore,
  });

  LoadChatMessagesSuccess copyWith({
    List<ChatMessage>? messages,
    int? currentPage,
    int? userId,
    int? itemOfferId,
    int? totalPage,
    bool? isLoadingMore,
  }) {
    return LoadChatMessagesSuccess(
      messages: messages ?? this.messages,
      currentPage: currentPage ?? this.currentPage,
      itemOfferId: itemOfferId ?? this.itemOfferId,
      totalPage: totalPage ?? this.totalPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  String toString() {
    return 'LoadChatMessagesSuccess(messages: $messages, currentPage: $currentPage, itemOfferId: $itemOfferId,totalPage: $totalPage, isLoadingMore: $isLoadingMore)';
  }
}

class LoadChatMessagesFailed extends LoadChatMessagesState {
  final dynamic error;

  LoadChatMessagesFailed({
    required this.error,
  });
}

class LoadChatMessagesCubit extends Cubit<LoadChatMessagesState> with HydratedMixin{
  LoadChatMessagesCubit() : super(LoadChatMessagesInitial());
  final ChatRepostiory _chatRepostiory = ChatRepostiory();

  Future<void> load({required int itemOfferId}) async {
    try {
      emit(LoadChatMessagesInProgress());
      DataOutput<ChatMessage> result = await _chatRepostiory.getMessagesApi(
        itemOfferId: itemOfferId,
        page: 1,
      );

      emit(LoadChatMessagesSuccess(
        messages: result.modelList,
        currentPage: 1,
        itemOfferId: itemOfferId,
        isLoadingMore: false,
        totalPage: result.total,
      ));
    } catch (e) {
      emit(LoadChatMessagesFailed(error: e.toString()));
    }
  }

  Future<void> loadMore() async {
    try {
      if (state is LoadChatMessagesSuccess) {
        if ((state as LoadChatMessagesSuccess).isLoadingMore) {
          return;
        }
        emit((state as LoadChatMessagesSuccess).copyWith(isLoadingMore: true));

        DataOutput<ChatMessage> result = await _chatRepostiory.getMessagesApi(
            page: (state as LoadChatMessagesSuccess).currentPage + 1,
            itemOfferId: (state as LoadChatMessagesSuccess).itemOfferId);

        LoadChatMessagesSuccess messagesSuccessState =
            (state as LoadChatMessagesSuccess);

        messagesSuccessState.messages.addAll(result.modelList);

        emit(LoadChatMessagesSuccess(
          messages: messagesSuccessState.messages,
          currentPage: (state as LoadChatMessagesSuccess).currentPage + 1,
          itemOfferId: (state as LoadChatMessagesSuccess).itemOfferId,
          isLoadingMore: false,
          totalPage: result.total,
        ));
      }
    } catch (e) {
      emit((state as LoadChatMessagesSuccess).copyWith(isLoadingMore: false));
    }
  }

  bool hasMoreChat() {
    if (state is LoadChatMessagesSuccess) {
      return (state as LoadChatMessagesSuccess).messages.length <
          (state as LoadChatMessagesSuccess).totalPage;
    }
    return false;
  }

  @override
  LoadChatMessagesState? fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    return null;
  }

  @override
  Map<String, dynamic>? toJson(LoadChatMessagesState state) {
    return null;
  }
}
