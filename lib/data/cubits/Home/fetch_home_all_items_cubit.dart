import 'package:eClassify/data/Repositories/Home/home_repository.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';


abstract class FetchHomeAllItemsState {}

class FetchHomeAllItemsInitial extends FetchHomeAllItemsState {}

class FetchHomeAllItemsInProgress extends FetchHomeAllItemsState {}

class FetchHomeAllItemsSuccess extends FetchHomeAllItemsState {
  final List<ItemModel> items;
  final bool isLoadingMore;
  final bool loadingMoreError;
  final int page;
  final int total;

  FetchHomeAllItemsSuccess(
      {required this.items,
      required this.isLoadingMore,
      required this.loadingMoreError,
      required this.page,
      required this.total});

  FetchHomeAllItemsSuccess copyWith({
    List<ItemModel>? items,
    bool? isLoadingMore,
    bool? loadingMoreError,
    int? page,
    int? total,
  }) {
    return FetchHomeAllItemsSuccess(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class FetchHomeAllItemsFail extends FetchHomeAllItemsState {
  final dynamic error;

  FetchHomeAllItemsFail(this.error);
}

class FetchHomeAllItemsCubit extends Cubit<FetchHomeAllItemsState>
    with HydratedMixin {
  FetchHomeAllItemsCubit() : super(FetchHomeAllItemsInitial());

  final HomeRepository _homeRepository = HomeRepository();

  void fetch({String? city,int? areaId}) async {
    try {
      emit(FetchHomeAllItemsInProgress());
      DataOutput<ItemModel> result =
          await _homeRepository.fetchHomeAllItems(page: 1, city: city,areaId: areaId);

      emit(
        FetchHomeAllItemsSuccess(
          page: 1,
          isLoadingMore: false,
          loadingMoreError: false,
          items: result.modelList,
          total: result.total,
        ),
      );
    } catch (e) {
      print("fetch all failed****${e.toString()}");
      emit(FetchHomeAllItemsFail(e.toString()));
    }
  }

  Future<void> fetchMore({String? city}) async {
    try {
      if (state is FetchHomeAllItemsSuccess) {
        if ((state as FetchHomeAllItemsSuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchHomeAllItemsSuccess).copyWith(isLoadingMore: true));
        DataOutput<ItemModel> result = await _homeRepository.fetchHomeAllItems(
            page: (state as FetchHomeAllItemsSuccess).page + 1, city: city);

        FetchHomeAllItemsSuccess itemModelState =
            (state as FetchHomeAllItemsSuccess);
        itemModelState.items.addAll(result.modelList);
        emit(FetchHomeAllItemsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            items: itemModelState.items,
            page: (state as FetchHomeAllItemsSuccess).page + 1,
            total: result.total));
      }
    } catch (e) {
      emit((state as FetchHomeAllItemsSuccess)
          .copyWith(isLoadingMore: false, loadingMoreError: true));
    }
  }

  bool hasMoreData() {
    if (state is FetchHomeAllItemsSuccess) {
      return (state as FetchHomeAllItemsSuccess).items.length <
          (state as FetchHomeAllItemsSuccess).total;
    }
    return false;
  }

  @override
  FetchHomeAllItemsState? fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchHomeAllItemsState state) {
    return null;
  }
}
