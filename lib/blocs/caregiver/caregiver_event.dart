part of 'caregiver_bloc.dart';

@immutable
sealed class CaregiverEvent {}

class CreateCaregiver extends CaregiverEvent {
  final String firstName;
  final String email;

  CreateCaregiver({required this.firstName, required this.email});
}

class LoadCaregivers extends CaregiverEvent {
  final String userID;

  LoadCaregivers({required this.userID});
}

class DeleteCaregiver extends CaregiverEvent {
  final String caregiverID;

  DeleteCaregiver({required this.caregiverID});
}

class CaregiverSignUp extends CaregiverEvent {
  final String firstName;
  final String email;
  final String password;

  CaregiverSignUp({
    required this.firstName,
    required this.email,
    required this.password,
  });
}

class CaregiverSignUpWithGoogle extends CaregiverEvent {
  // These fields are optional as they will be extracted from Google account
  final String? firstName;
  final String? email;

  CaregiverSignUpWithGoogle({
    this.firstName,
    this.email,
  });
}

class GetCaregivers extends CaregiverEvent {}
