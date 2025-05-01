part of 'pump_right_side_timer_bloc.dart';

@immutable
sealed class PumpRightSideTimerEvent {}
class StartTimer extends PumpRightSideTimerEvent{
  final TimeOfDay? timerStart;
  final String activityType;

  StartTimer({required this.activityType, this.timerStart});

}
class StopTimer extends PumpRightSideTimerEvent{
  final String activityType;

  StopTimer({required this.activityType});

}
class SetStartTimeTimer extends PumpRightSideTimerEvent{
  final TimeOfDay? startTime;
  final String activityType;


  SetStartTimeTimer({required this.startTime,required this.activityType});
}
class SetEndTimeTimer extends PumpRightSideTimerEvent{
  final TimeOfDay endTime;

  final String activityType;

  SetEndTimeTimer({required this.endTime,required this.activityType});
}
class SetDurationTimer extends PumpRightSideTimerEvent{
  Duration duration;
  final String activityType;

  SetDurationTimer({required this.duration,required this.activityType});

}
class ResetTimer extends PumpRightSideTimerEvent{
  final String activityType;

  ResetTimer({required this.activityType});

}
class LoadTimerFromLocalDatabase extends PumpRightSideTimerEvent{
  final String activityType;

  LoadTimerFromLocalDatabase({required this.activityType});

}
class Tick extends PumpRightSideTimerEvent{
  final String activityType;

  Tick({required this.activityType});

}

