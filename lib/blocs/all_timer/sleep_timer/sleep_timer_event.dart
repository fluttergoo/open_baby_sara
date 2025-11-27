part of 'sleep_timer_bloc.dart';

@immutable
sealed class SleepTimerEvent {}

class StartTimer extends SleepTimerEvent {
  final DateTime? timerStart;
  final String activityType;

  StartTimer({required this.activityType, this.timerStart});
}

class StopTimer extends SleepTimerEvent {
  final String activityType;

  StopTimer({required this.activityType});
}

class SetStartTimeTimer extends SleepTimerEvent {
  final DateTime? startTime;
  final String activityType;

  SetStartTimeTimer({required this.startTime, required this.activityType});
}

class SetEndTimeTimer extends SleepTimerEvent {
  final DateTime endTime;
  final DateTime? startTime; // Also send start time so bloc state is correct
  final String activityType;

  SetEndTimeTimer({
    required this.endTime, 
    this.startTime,
    required this.activityType,
  });
}

class SetDurationTimer extends SleepTimerEvent {
  Duration duration;
  final String activityType;

  SetDurationTimer({required this.duration, required this.activityType});
}

class ResetTimer extends SleepTimerEvent {
  final String activityType;

  ResetTimer({required this.activityType});
}

class LoadTimerFromLocalDatabase extends SleepTimerEvent {
  final String activityType;

  LoadTimerFromLocalDatabase({required this.activityType});
}

class Tick extends SleepTimerEvent {
  final String activityType;

  Tick({required this.activityType});
}
