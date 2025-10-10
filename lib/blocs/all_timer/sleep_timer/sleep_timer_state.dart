part of 'sleep_timer_bloc.dart';

@immutable
sealed class SleepTimerState {}

final class SleepTimerInitial extends SleepTimerState {}

final class TimerRunning extends SleepTimerState {
  final DateTime? startTime;
  final Duration duration;
  final String activityType;

  TimerRunning({
    required this.duration,
    required this.activityType,
    this.startTime,
  });
}

class TimerStopped extends SleepTimerState {
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

final class TimerReset extends SleepTimerState {}
