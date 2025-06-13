import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';

abstract class ActivityRepository {
  Future<void> saveLocallyActivity(ActivityModel activityModel);

  Future<List<ActivityModel>?> fetchLocalActivities();

  Future<void> syncActivities();

  Future<ActivityModel?> fetchLastSleepActivity(String babyID);

  Future<ActivityModel?> fetchLastPumpActivity(String babyID);

  Future<List<ActivityModel>?> fetchAllTypeOfActivity(
    String babyID,
    String activityType,
  );

  Future<List<ActivityModel>?> fetchActivity(DateTime datetime, String babyID);

  Future<List<ActivityModel>?> fetchActivityByDateRange({required DateTime start, required DateTime end, required String babyID, List<String>? activityTypes,});
  Future<void> deleteActivity(String babyID, String activityID);
  Future<void> updateActivity(ActivityModel activityModel);


}
