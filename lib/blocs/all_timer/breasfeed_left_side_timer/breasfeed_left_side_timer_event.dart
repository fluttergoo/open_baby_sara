part of 'breasfeed_left_side_timer_bloc.dart';

@immutable
sealed class BreasfeedLeftSideTimerEvent {}
class StartTimer extends BreasfeedLeftSideTimerEvent{
  final TimeOfDay? timerStart;
  final String activityType;

  StartTimer({required this.activityType, this.timerStart});

}
class StopTimer extends BreasfeedLeftSideTimerEvent{
  final String activityType;

  StopTimer({required this.activityType});

}
class SetStartTimeTimer extends BreasfeedLeftSideTimerEvent{
  final TimeOfDay? startTime;
  final String activityType;


  SetStartTimeTimer({required this.startTime,required this.activityType});
}
class SetEndTimeTimer extends BreasfeedLeftSideTimerEvent{
  final TimeOfDay endTime;

  final String activityType;

  SetEndTimeTimer({required this.endTime,required this.activityType});
}
class SetDurationTimer extends BreasfeedLeftSideTimerEvent{
  Duration duration;
  final String activityType;

  SetDurationTimer({required this.duration,required this.activityType});

}
class ResetTimer extends BreasfeedLeftSideTimerEvent{
  final String activityType;

  ResetTimer({required this.activityType});

}
class LoadTimerFromLocalDatabase extends BreasfeedLeftSideTimerEvent{
  final String activityType;

  LoadTimerFromLocalDatabase({required this.activityType});

}
class Tick extends BreasfeedLeftSideTimerEvent{
  final String activityType;

  Tick({required this.activityType});

}

