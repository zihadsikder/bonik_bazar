import 'package:eClassify/data/Repositories/safety_tips_repository.dart';
import 'package:eClassify/data/model/data_output.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../model/safety_tips_model.dart';

abstract class FetchSafetyTipsListState {}

class FetchSafetyTipsInitial extends FetchSafetyTipsListState {}

class FetchSafetyTipsInProgress extends FetchSafetyTipsListState {}

class FetchSafetyTipsSuccess extends FetchSafetyTipsListState {
  final int total;
  final List<SafetyTipsModel> tips;

  FetchSafetyTipsSuccess({required this.total, required this.tips});

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'tips': tips.map((e) => e.toJson()).toList(),
    };
  }

  factory FetchSafetyTipsSuccess.fromMap(Map<String, dynamic> map) {
    return FetchSafetyTipsSuccess(
      total: map['total'] as int,
      tips: (map['tips'] as List)
          .map((e) => SafetyTipsModel.fromJson(e))
          .toList(),
    );
  }
}

class FetchSafetyTipsFailure extends FetchSafetyTipsListState {
  final dynamic error;

  FetchSafetyTipsFailure(this.error);
}

class FetchSafetyTipsListCubit extends Cubit<FetchSafetyTipsListState>
    with HydratedMixin {
  FetchSafetyTipsListCubit() : super(FetchSafetyTipsInitial());
  final SafetyTipsRepository _repository = SafetyTipsRepository();

  Future<void> fetchSafetyTips() async {
    try {
      emit(FetchSafetyTipsInProgress());

      DataOutput<SafetyTipsModel> result = await _repository.fetchTipsList();
      emit(FetchSafetyTipsSuccess(
        tips: result.modelList,
        total: result.total,
      ));
    } catch (e) {
      emit(
        FetchSafetyTipsFailure(
          e.toString(),
        ),
      );
    }
  }

  List<SafetyTipsModel>? getList() {
    if (state is FetchSafetyTipsSuccess) {
      return (state as FetchSafetyTipsSuccess).tips;
    }
    return null;
  }

  @override
  FetchSafetyTipsListState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['cubit_state'] == "FetchSafetyTipsSuccess") {
        FetchSafetyTipsSuccess fetchSafetyTipsSuccess =
            FetchSafetyTipsSuccess.fromMap(json);

        return fetchSafetyTipsSuccess;
      }
    } catch (e) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(FetchSafetyTipsListState state) {
    try {
      if (state is FetchSafetyTipsSuccess) {
        Map<String, dynamic> mapped = state.toMap();
        mapped['cubit_state'] = "FetchSafetyTipsSuccess";
        return mapped;
      }
    } catch (e) {}

    return null;
  }
}
