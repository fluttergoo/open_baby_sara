part of 'medication_bloc.dart';

@immutable
sealed class MedicationState {}

final class MedicationInitial extends MedicationState {}
class MedicationLoading extends MedicationState{}
class MedicationLoaded extends MedicationState{
  final List<MedicationModel> medications;

  MedicationLoaded([this.medications = const []]);
}
class MedicationError extends MedicationState{
  final String message;

  MedicationError({required this.message});
}
