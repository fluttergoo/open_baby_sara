import 'package:bloc/bloc.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/models/medication_model.dart';
import 'package:open_baby_sara/data/repositories/medication_repository.dart';
import 'package:meta/meta.dart';

part 'medication_event.dart';

part 'medication_state.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final MedicationRepository _medicationRepository =
      getIt<MedicationRepository>();

  MedicationBloc() : super(MedicationInitial()) {
    on<MedicationEvent>((event, emit) {});
    on<InsertMedication>((event, emit) async {
      try {
        await _medicationRepository.insertMedication(event.medicationModel);
        add(FetchMedications());
      } catch (e) {
        emit(MedicationError(message: 'Error, ${e.toString()}'));
      }
    });
    on<FetchMedications>((event, emit) async {
      emit(MedicationLoading());
      try {
        final List<MedicationModel>? medicationsList =
            await _medicationRepository.fetchMedicationList();
        emit(MedicationLoaded( medicationsList ?? []));
      } catch (e) {
        emit(MedicationError(message: 'Error, ${e.toString()}'));
      }
    });
    on<DeleteMedication>((event, emit) async {
      emit(MedicationLoading());
      try {
        await _medicationRepository.deleteMedication(event.id);
        add(FetchMedications());
      } catch (e) {
        emit(MedicationError(message: 'Error, ${e.toString()}'));
      }
    });
  }
}
