import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';

abstract class ActivityService{
  Future<void> uploadActivity(ActivityModel activityModel);
  Future<ActivityModel?> getActivity(String babyID,String activityID);
}