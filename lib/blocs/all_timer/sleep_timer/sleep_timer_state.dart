part of 'sleep_timer_bloc.dart';

@immutable
sealed class SleepTimerState {}

final class SleepTimerInitial extends SleepTimerState {}
final class TimerRunning extends SleepTimerState {
  final TimeOfDay? startTime;
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

final class TimerReset extends SleepTimerState {}
