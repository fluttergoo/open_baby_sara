part of 'pump_total_timer_bloc.dart';

@immutable
sealed class PumpTotalTimerState {}

final class PumpTotalTimerInitial extends PumpTotalTimerState {}

final class TimerRunning extends PumpTotalTimerState {
  final TimeOfDay? startTime;
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

final class TimerReset extends PumpTotalTimerState {}


