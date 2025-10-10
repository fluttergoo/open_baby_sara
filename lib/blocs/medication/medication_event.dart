part of 'medication_bloc.dart';

@immutable
sealed class MedicationEvent {}

class InsertMedication extends MedicationEvent {
  final MedicationModel medicationModel;

  InsertMedication({required this.medicationModel});
}

class FetchMedications extends MedicationEvent {}

class DeleteMedication extends MedicationEvent {
  final int id;
  DeleteMedication({required this.id});
}
