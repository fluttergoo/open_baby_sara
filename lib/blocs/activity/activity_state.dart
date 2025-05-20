part of 'activity_bloc.dart';

@immutable
sealed class ActivityState {}

final class ActivityInitial extends ActivityState {}

final class ActivityLoading extends ActivityState {}

final class ActivityAdded extends ActivityState {
  final String message;

  ActivityAdded({this.message = 'Successfully'});
}

class ActivityError extends ActivityState {
  final String message;

  ActivityError(this.message);
}

class SleepActivityLoaded extends ActivityState {
  final ActivityModel? activityModel;

  SleepActivityLoaded({this.activityModel});
}

class PumpActivityLoaded extends ActivityState {
  final ActivityModel? activityModel;

  PumpActivityLoaded({required this.activityModel});
}

class FetchToothIsoNumberLoaded extends ActivityState {
  final List<String> toothIsoNumber;
  final List<ActivityModel> toothActivities;

  FetchToothIsoNumberLoaded({
    required this.toothIsoNumber,
    required this.toothActivities,
  });
}

class ActivitiesWithDateLoaded extends ActivityState {
  final List<ActivityModel> sleepActivities;
  final List<ActivityModel> diaperActivities;

  final List<ActivityModel> growthActivities;

  final List<ActivityModel> babyFirstsActivities;

  final List<ActivityModel> pumpActivities;

  final List<ActivityModel> teethingActivities;

  final List<ActivityModel> medicationActivities;

  final List<ActivityModel> feverActivities;

  final List<ActivityModel> vaccinationActivities;

  final List<ActivityModel> doctorVisitActivities;

  final List<ActivityModel> feedActivities;

  ActivitiesWithDateLoaded({
    required this.sleepActivities,
    required this.diaperActivities,
    required this.growthActivities,
    required this.babyFirstsActivities,
    required this.pumpActivities,
    required this.teethingActivities,
    required this.medicationActivities,
    required this.feverActivities,
    required this.vaccinationActivities,
    required this.doctorVisitActivities,
    required this.feedActivities,
  });
}

class ActivityByDateRangeLoaded extends ActivityState{
final List<ActivityModel> activities;
  ActivityByDateRangeLoaded({required this.activities});
}