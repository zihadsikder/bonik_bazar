import 'package:eClassify/data/Repositories/Home/home_repository.dart';
import 'package:eClassify/data/model/Home/home_screen_section.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class FetchHomeScreenState {}

class FetchHomeScreenInitial extends FetchHomeScreenState {}

class FetchHomeScreenInProgress extends FetchHomeScreenState {}

class FetchHomeScreenSuccess extends FetchHomeScreenState {
  final List<HomeScreenSection> sections;

  FetchHomeScreenSuccess(this.sections);
}

class FetchHomeScreenFail extends FetchHomeScreenState {
  final dynamic error;

  FetchHomeScreenFail(this.error);
}

class FetchHomeScreenCubit extends Cubit<FetchHomeScreenState>
    with HydratedMixin {
  FetchHomeScreenCubit() : super(FetchHomeScreenInitial());

  final HomeRepository _homeRepository = HomeRepository();

  fetch({String? city, int? areaId}) async {
    try {
      emit(FetchHomeScreenInProgress());
      List<HomeScreenSection> homeScreenDataList =
          await _homeRepository.fetchHome(city: city, areaId: areaId);

      emit(FetchHomeScreenSuccess(homeScreenDataList));
    } catch (e) {
      emit(FetchHomeScreenFail(e));
    }
  }

  @override
  FetchHomeScreenState? fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchHomeScreenState state) {
    // TODO: implement toJson
    return null;
  }
}
