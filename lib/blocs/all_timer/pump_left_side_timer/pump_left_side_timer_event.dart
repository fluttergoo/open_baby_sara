part of 'pump_left_side_timer_bloc.dart';

@immutable
sealed class PumpLeftSideTimerEvent {}
class StartTimer extends PumpLeftSideTimerEvent{
  final TimeOfDay? timerStart;
  final String activityType;

  StartTimer({required this.activityType, this.timerStart});

}
class StopTimer extends PumpLeftSideTimerEvent{
  final String activityType;

  StopTimer({required this.activityType});

}
class SetStartTimeTimer extends PumpLeftSideTimerEvent{
  final TimeOfDay? startTime;
  final String activityType;


  SetStartTimeTimer({required this.startTime,required this.activityType});
}
class SetEndTimeTimer extends PumpLeftSideTimerEvent{
  final TimeOfDay endTime;

  final String activityType;

  SetEndTimeTimer({required this.endTime,required this.activityType});
}
class SetDurationTimer extends PumpLeftSideTimerEvent{
  Duration duration;
  final String activityType;

  SetDurationTimer({required this.duration,required this.activityType});

}
class ResetTimer extends PumpLeftSideTimerEvent{
  final String activityType;

  ResetTimer({required this.activityType});

}
class LoadTimerFromLocalDatabase extends PumpLeftSideTimerEvent{
  final String activityType;

  LoadTimerFromLocalDatabase({required this.activityType});

}
class Tick extends PumpLeftSideTimerEvent{
  final String activityType;

  Tick({required this.activityType});

}

