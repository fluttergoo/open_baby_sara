part of 'breasfeed_left_side_timer_bloc.dart';

@immutable
sealed class BreasfeedLeftSideTimerEvent {}

class StartTimer extends BreasfeedLeftSideTimerEvent {
  final DateTime? timerStart;
  final String activityType;

  StartTimer({required this.activityType, this.timerStart});
}

class StopTimer extends BreasfeedLeftSideTimerEvent {
  final String activityType;

  StopTimer({required this.activityType});
}

class SetStartTimeTimer extends BreasfeedLeftSideTimerEvent {
  final DateTime? startTime;
  final String activityType;

  SetStartTimeTimer({required this.startTime, required this.activityType});
}

class SetEndTimeTimer extends BreasfeedLeftSideTimerEvent {
  final DateTime endTime;
  final DateTime? startTime; // Also send start time so bloc state is correct
  final String activityType;

  SetEndTimeTimer({
    required this.endTime,
    this.startTime,
    required this.activityType,
  });
}

class SetDurationTimer extends BreasfeedLeftSideTimerEvent {
  Duration duration;
  final String activityType;

  SetDurationTimer({required this.duration, required this.activityType});
}

class ResetTimer extends BreasfeedLeftSideTimerEvent {
  final String activityType;

  ResetTimer({required this.activityType});
}

class LoadTimerFromLocalDatabase extends BreasfeedLeftSideTimerEvent {
  final String activityType;

  LoadTimerFromLocalDatabase({required this.activityType});
}

class Tick extends BreasfeedLeftSideTimerEvent {
  final String activityType;

  Tick({required this.activityType});
}
