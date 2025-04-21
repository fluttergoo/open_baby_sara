part of 'caregiver_bloc.dart';

@immutable
sealed class CaregiverState {}

class CaregiverInitial extends CaregiverState {}

class CaregiverLoading extends CaregiverState {}

class CaregiverAdded extends CaregiverState {
  final String message;

  CaregiverAdded({this.message = 'Caregiver added!'});
}

class CaregiverDeleted extends CaregiverState {
  final String message;

  CaregiverDeleted({this.message='Caregiver deleted'});

}

class CaregiverError extends CaregiverState {
  final String message;

  CaregiverError(this.message);
}

class CaregiverListLoaded extends CaregiverState {
  final List<InviteModel> caregivers;

  CaregiverListLoaded(this.caregivers);
}
class CaregiverSignedUp extends CaregiverState{
  final String message;
  CaregiverSignedUp({this.message='Successfully'});
}
class GetCaregiverList extends CaregiverState{
  final List<InviteModel> caregiverList;
  GetCaregiverList({required this.caregiverList});
}


