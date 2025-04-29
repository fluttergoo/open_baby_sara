part of 'timer_bloc.dart';

@immutable
sealed class TimerEvent {}

class StartSleepTimer extends TimerEvent{
  final TimeOfDay? timerStart;
  StartSleepTimer({this.timerStart});
}
class SetTimer extends TimerEvent{
  final TimeOfDay? setTimer;
  SetTimer({this.setTimer});
}
class Tick extends TimerEvent{}
class StopSleepTimer extends TimerEvent {}
class SetEndTimer extends TimerEvent{
  final TimeOfDay? setTimer;
  SetEndTimer({this.setTimer});
}
class CancelTimer extends TimerEvent {}
class LoadTimerFromLocalDatabase extends TimerEvent{}




