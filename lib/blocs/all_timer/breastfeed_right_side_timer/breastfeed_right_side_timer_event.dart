part of 'breastfeed_right_side_timer_bloc.dart';

@immutable
sealed class BreastfeedRightSideTimerEvent {}

class StartTimer extends BreastfeedRightSideTimerEvent {
  final DateTime? timerStart;
  final String activityType;

  StartTimer({required this.activityType, this.timerStart});
}

class StopTimer extends BreastfeedRightSideTimerEvent {
  final String activityType;

  StopTimer({required this.activityType});
}

class SetStartTimeTimer extends BreastfeedRightSideTimerEvent {
  final DateTime? startTime;
  final String activityType;

  SetStartTimeTimer({required this.startTime, required this.activityType});
}

class SetEndTimeTimer extends BreastfeedRightSideTimerEvent {
  final DateTime endTime;

  final String activityType;

  SetEndTimeTimer({required this.endTime, required this.activityType});
}

class SetDurationTimer extends BreastfeedRightSideTimerEvent {
  Duration duration;
  final String activityType;

  SetDurationTimer({required this.duration, required this.activityType});
}

class ResetTimer extends BreastfeedRightSideTimerEvent {
  final String activityType;

  ResetTimer({required this.activityType});
}

class LoadTimerFromLocalDatabase extends BreastfeedRightSideTimerEvent {
  final String activityType;

  LoadTimerFromLocalDatabase({required this.activityType});
}

class Tick extends BreastfeedRightSideTimerEvent {
  final String activityType;

  Tick({required this.activityType});
}
