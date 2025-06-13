part of 'pump_right_side_timer_bloc.dart';

@immutable
sealed class PumpRightSideTimerState {}

final class PumpRightSideTimerInitial extends PumpRightSideTimerState {}
final class TimerRunning extends PumpRightSideTimerState {
  final DateTime? startTime;
  final Duration duration;
  final String activityType;

  TimerRunning({
    required this.duration,
    required this.activityType,
    this.startTime,
  });
}

class TimerStopped extends PumpRightSideTimerState {
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

final class TimerReset extends PumpRightSideTimerState {}
