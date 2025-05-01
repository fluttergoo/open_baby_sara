part of 'activity_bloc.dart';

@immutable
sealed class ActivityEvent {}

class AddActivity extends ActivityEvent {
  final ActivityModel activityModel;

  AddActivity({required this.activityModel});
}

class StartAutoSync extends ActivityEvent {}

class StopAutoSync extends ActivityEvent {}

class FetchActivitySleepLoad extends ActivityEvent {
  final String babyID;

  FetchActivitySleepLoad({required this.babyID});
}
