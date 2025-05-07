part of 'pump_total_timer_bloc.dart';

@immutable
sealed class PumpTotalTimerEvent {}
class StartTimer extends PumpTotalTimerEvent{
  final TimeOfDay? timerStart;
  final String activityType;

  StartTimer({required this.activityType, this.timerStart});

}
class StopTimer extends PumpTotalTimerEvent{
  final String activityType;

  StopTimer({required this.activityType});

}
class SetStartTimeTimer extends PumpTotalTimerEvent{
  final TimeOfDay? startTime;
  final String activityType;


  SetStartTimeTimer({required this.startTime,required this.activityType});
}
class SetEndTimeTimer extends PumpTotalTimerEvent{
  final TimeOfDay endTime;

  final String activityType;

  SetEndTimeTimer({required this.endTime,required this.activityType});
}
class SetDurationTimer extends PumpTotalTimerEvent{
  Duration duration;
  final String activityType;

  SetDurationTimer({required this.duration,required this.activityType});

}
class ResetTimer extends PumpTotalTimerEvent{
  final String activityType;

  ResetTimer({required this.activityType});

}
class LoadTimerFromLocalDatabase extends PumpTotalTimerEvent{
  final String activityType;

  LoadTimerFromLocalDatabase({required this.activityType});

}
class Tick extends PumpTotalTimerEvent{
  final String activityType;

  Tick({required this.activityType});

}
