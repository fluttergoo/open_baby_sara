part of 'baby_bloc.dart';

@immutable
sealed class BabyEvent {}

class RegisterBaby extends BabyEvent{


  final String firstName;

  final String gender;
  final DateTime dateTime;

  RegisterBaby({required this.firstName, required this.gender, required this.dateTime});
}
