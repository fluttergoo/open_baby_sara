part of 'vaccination_bloc.dart';

@immutable
sealed class VaccinationEvent {}
class InsertVaccination extends VaccinationEvent{
  final String vaccinationName;

  InsertVaccination({required this.vaccinationName});
}

class FetchVaccination extends VaccinationEvent{}
class DeleteVaccination extends VaccinationEvent{
  final String vaccination;
  DeleteVaccination({required this.vaccination});
}