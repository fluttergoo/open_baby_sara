part of 'vaccination_bloc.dart';

@immutable
sealed class VaccinationState {}

final class VaccinationInitial extends VaccinationState {}

class VaccinationLoading extends VaccinationState {}

class VaccinationLoaded extends VaccinationState {
  final List<String> vaccinationList;

  VaccinationLoaded([this.vaccinationList = const []]);
}

class VaccinationError extends VaccinationState {
  final String message;

  VaccinationError({required this.message});
}
