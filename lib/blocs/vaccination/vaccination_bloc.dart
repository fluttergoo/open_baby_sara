import 'package:bloc/bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/vaccination_repository.dart';
import 'package:meta/meta.dart';

part 'vaccination_event.dart';
part 'vaccination_state.dart';

class VaccinationBloc extends Bloc<VaccinationEvent, VaccinationState> {
  final VaccinationRepository _vaccinationRepository =
  getIt<VaccinationRepository>();

  VaccinationBloc() : super(VaccinationInitial()) {
    on<VaccinationEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<InsertVaccination>((event, emit) async {
      try {
        await _vaccinationRepository.insertVaccination(event.vaccinationName);
        add(FetchVaccination());
      } catch (e) {
        emit(VaccinationError(message: 'Error, ${e.toString()}'));
      }
    });
    on<FetchVaccination>((event, emit) async {
      emit(VaccinationLoading());
      try {
        final List<String>? vaccinationList = await _vaccinationRepository.fetchVaccinationList();
        emit(VaccinationLoaded( vaccinationList ?? []));
      } catch (e) {
        emit(VaccinationError(message: 'Error, ${e.toString()}'));
      }
    });
    on<DeleteVaccination>((event, emit) async {
      emit(VaccinationLoading());
      try {
        await _vaccinationRepository.deleteVaccination(event.vaccination);
        add(FetchVaccination());
      } catch (e) {
        emit(VaccinationError(message: 'Error, ${e.toString()}'));
      }
    });
  }
}
