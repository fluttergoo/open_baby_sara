part of 'sleep_timer_bloc.dart';

@immutable
sealed class SleepTimerEvent {}

class StartTimer extends SleepTimerEvent{
  final TimeOfDay? timerStart;
  final String activityType;

  StartTimer({required this.activityType,this.timerStart});

}
class StopTimer extends SleepTimerEvent{
  final String activityType;

  StopTimer({required this.activityType});

}
class SetStartTimeTimer extends SleepTimerEvent{
  final TimeOfDay? startTime;
  final String activityType;


  SetStartTimeTimer({required this.startTime,required this.activityType});
}
class SetEndTimeTimer extends SleepTimerEvent{
  final TimeOfDay endTime;

  final String activityType;

  SetEndTimeTimer({required this.endTime,required this.activityType});
}
class SetDurationTimer extends SleepTimerEvent{
  Duration duration;
  final String activityType;

  SetDurationTimer({required this.duration,required this.activityType});

}
class ResetTimer extends SleepTimerEvent{
  final String activityType;

  ResetTimer({required this.activityType});

}
class LoadTimerFromLocalDatabase extends SleepTimerEvent{
  final String activityType;

  LoadTimerFromLocalDatabase({required this.activityType});

}
class Tick extends SleepTimerEvent{
  final String activityType;

  Tick({required this.activityType});

}

