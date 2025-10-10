part of 'pump_total_timer_bloc.dart';

@immutable
sealed class PumpTotalTimerState {}

final class PumpTotalTimerInitial extends PumpTotalTimerState {}

final class TimerRunning extends PumpTotalTimerState {
  final DateTime? startTime;
  final Duration duration;
  final String activityType;

  TimerRunning({
    required this.duration,
    required this.activityType,
    this.startTime,
  });
}

class TimerStopped extends PumpTotalTimerState {
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

final class TimerReset extends PumpTotalTimerState {}
