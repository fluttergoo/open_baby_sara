part of 'pump_right_side_timer_bloc.dart';

@immutable
sealed class PumpRightSideTimerEvent {}

class StartTimer extends PumpRightSideTimerEvent {
  final DateTime? timerStart;
  final String activityType;

  StartTimer({required this.activityType, this.timerStart});
}

class StopTimer extends PumpRightSideTimerEvent {
  final String activityType;

  StopTimer({required this.activityType});
}

class SetStartTimeTimer extends PumpRightSideTimerEvent {
  final DateTime? startTime;
  final String activityType;

  SetStartTimeTimer({required this.startTime, required this.activityType});
}

class SetEndTimeTimer extends PumpRightSideTimerEvent {
  final DateTime endTime;
  final DateTime? startTime; // Also send start time so bloc state is correct
  final String activityType;

  SetEndTimeTimer({
    required this.endTime,
    this.startTime,
    required this.activityType,
  });
}

class SetDurationTimer extends PumpRightSideTimerEvent {
  Duration duration;
  final String activityType;

  SetDurationTimer({required this.duration, required this.activityType});
}

class ResetTimer extends PumpRightSideTimerEvent {
  final String activityType;

  ResetTimer({required this.activityType});
}

class LoadTimerFromLocalDatabase extends PumpRightSideTimerEvent {
  final String activityType;

  LoadTimerFromLocalDatabase({required this.activityType});
}

class Tick extends PumpRightSideTimerEvent {
  final String activityType;

  Tick({required this.activityType});
}
