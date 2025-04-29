import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';

abstract class ActivityRepository{
  Future<void> saveLocallyActivity(ActivityModel activityModel);
  Future<List<ActivityModel>?> fetchLocalActivities();
  Future<void> syncActivities();
}