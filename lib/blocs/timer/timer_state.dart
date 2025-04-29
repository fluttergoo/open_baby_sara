part of 'timer_bloc.dart';

@immutable
sealed class TimerState {}

final class TimerInitial extends TimerState {}
final class TimerRunning extends TimerState{
  final TimeOfDay? startTime;
  final Duration duration;

  TimerRunning( {required this.duration, this.startTime});
}
class TimerStopped extends TimerState {
  final Duration duration;
  final TimeOfDay? endTime;
  TimerStopped({required this.duration, this.endTime});
}
final class TimerReset extends TimerState {}

