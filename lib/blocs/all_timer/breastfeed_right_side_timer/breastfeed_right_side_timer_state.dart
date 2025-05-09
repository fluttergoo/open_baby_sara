part of 'breastfeed_right_side_timer_bloc.dart';

@immutable
sealed class BreastfeedRightSideTimerState {}

final class BreastfeedRightSideTimerInitial extends BreastfeedRightSideTimerState {}

final class BreasfeedLeftSideTimerInitial extends BreastfeedRightSideTimerState {}
final class TimerRunning extends BreastfeedRightSideTimerState {
  final TimeOfDay? startTime;
  final Duration duration;
  final String activityType;

  TimerRunning({
    required this.duration,
    required this.activityType,
    this.startTime,
  });
}

class TimerStopped extends BreastfeedRightSideTimerState {
  final Duration duration;
  final TimeOfDay? endTime;
  final TimeOfDay? startTime;

  final String activityType;


  TimerStopped({
    required this.duration,
    this.endTime,
    required this.activityType,
    this.startTime,
  });
}

final class TimerReset extends BreastfeedRightSideTimerState {}


