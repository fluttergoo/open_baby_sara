import 'package:bloc/bloc.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/models/milestones_model.dart';
import 'package:open_baby_sara/data/services/local_database/milestone_service.dart';
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
    on<LoadMilestonesTitleFromDB>((event, emit) async {
      emit(MilestoneLoading());
      try {
        final milestonesTitle = await _milestoneService.fetchMilestonesFromDB(event.babyID);
        emit(MilestoneTitleLoadedFromDB(milestoneTitle: milestonesTitle));
      } catch (e) {
        emit(MilestoneError(e.toString()));
      }
    });
  }
}
