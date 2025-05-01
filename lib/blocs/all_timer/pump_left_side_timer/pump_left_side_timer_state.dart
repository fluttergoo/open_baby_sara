part of 'pump_left_side_timer_bloc.dart';

@immutable
sealed class PumpLeftSideTimerState {}

final class PumpLeftSideTimerInitial extends PumpLeftSideTimerState {}
final class TimerRunning extends PumpLeftSideTimerState {
  final TimeOfDay? startTime;
  final Duration duration;
  final String activityType;

  TimerRunning({
    required this.duration,
    required this.activityType,
    this.startTime,
  });
}

class TimerStopped extends PumpLeftSideTimerState {
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

final class TimerReset extends PumpLeftSideTimerState {}
