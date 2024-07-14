import 'package:eClassify/data/Repositories/Home/home_repository.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';


abstract class FetchSectionItemsState {}

class FetchSectionItemsInitial extends FetchSectionItemsState {}

class FetchSectionItemsInProgress extends FetchSectionItemsState {}

class FetchSectionItemsSuccess extends FetchSectionItemsState {
  final List<ItemModel> items;
  final bool isLoadingMore;
  final bool loadingMoreError;
  final int page;
  final int total;

  FetchSectionItemsSuccess(
      {required this.items,
      required this.isLoadingMore,
      required this.loadingMoreError,
      required this.page,
      required this.total});

  FetchSectionItemsSuccess copyWith({
    List<ItemModel>? items,
    bool? isLoadingMore,
    bool? loadingMoreError,
    int? page,
    int? total,
  }) {
    return FetchSectionItemsSuccess(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class FetchSectionItemsFail extends FetchSectionItemsState {
  final dynamic error;

  FetchSectionItemsFail(this.error);
}

class FetchSectionItemsCubit extends Cubit<FetchSectionItemsState> with HydratedMixin {
  FetchSectionItemsCubit() : super(FetchSectionItemsInitial());

  final HomeRepository _homeRepository = HomeRepository();

  void fetchSectionItem(int sectionId) async {
    try {
      emit(FetchSectionItemsInProgress());
      DataOutput<ItemModel> result = await _homeRepository.fetchSectionItems(
          page: 1, sectionId: sectionId);

      emit(
        FetchSectionItemsSuccess(
          page: 1,
          isLoadingMore: false,
          loadingMoreError: false,
          items: result.modelList,
          total: result.total,
        ),
      );
    } catch (e) {
      emit(FetchSectionItemsFail(e));
    }
  }

  Future<void> fetchSectionItemMore(int sectionId) async {
    try {
      if (state is FetchSectionItemsSuccess) {
        if ((state as FetchSectionItemsSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchSectionItemsSuccess).copyWith(isLoadingMore: true));
        DataOutput<ItemModel> result = await _homeRepository.fetchSectionItems(
            page: (state as FetchSectionItemsSuccess).page + 1,
            sectionId: sectionId);

        FetchSectionItemsSuccess itemModelState =
            (state as FetchSectionItemsSuccess);
        itemModelState.items.addAll(result.modelList);
        emit(FetchSectionItemsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            items: itemModelState.items,
            page: (state as FetchSectionItemsSuccess).page + 1,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchSectionItemsSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {

    if (state is FetchSectionItemsSuccess) {

      return (state as FetchSectionItemsSuccess).items.length <
          (state as FetchSectionItemsSuccess).total;
    }
    return false;
  }

  @override
  FetchSectionItemsState? fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchSectionItemsState state) {
    // TODO: implement toJson
    return null;
  }
}
