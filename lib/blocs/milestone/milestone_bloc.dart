import 'package:bloc/bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/milestones_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/services/local_database/milestone_service.dart';
import 'package:meta/meta.dart';

part 'milestone_event.dart';

part 'milestone_state.dart';

class MilestoneBloc extends Bloc<MilestoneEvent, MilestoneState> {
  final MilestoneService _milestoneService = getIt<MilestoneService>();

  MilestoneBloc() : super(MilestoneInitial()) {
    on<MilestoneEvent>((event, emit) {});
    on<LoadMilestones>((event, emit) async {
      emit(MilestoneLoading());
      try {
        final milestones = await _milestoneService.loadMilestonesFromAssets();
        emit(MilestoneLoaded(milestones));
      } catch (e) {
        emit(MilestoneError(e.toString()));
      }
    });
  }
}
