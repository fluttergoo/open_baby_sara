part of 'breasfeed_left_side_timer_bloc.dart';

@immutable
sealed class BreasfeedLeftSideTimerState {}

final class BreasfeedLeftSideTimerInitial extends BreasfeedLeftSideTimerState {}

final class TimerRunning extends BreasfeedLeftSideTimerState {
  final DateTime? startTime;
  final Duration duration;
  final String activityType;

  TimerRunning({
    required this.duration,
    required this.activityType,
    this.startTime,
  });
}

class TimerStopped extends BreasfeedLeftSideTimerState {
  final Duration duration;
  final DateTime? endTime;
  final DateTime? startTime;

  final String activityType;

  TimerStopped({
    required this.duration,
    this.endTime,
    required this.activityType,
    this.startTime,
  });
}

final class TimerReset extends BreasfeedLeftSideTimerState {}
