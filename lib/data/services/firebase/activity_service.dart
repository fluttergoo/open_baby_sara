import 'package:open_baby_sara/data/models/activity_model.dart';

abstract class ActivityService {
  Future<void> uploadActivity(ActivityModel activityModel);

  Future<ActivityModel?> getActivity(String babyID, String activityID);
  Future<void> deleteActivityFromFirebase(String babyID, String activityID);
  Future<void> updateActivity(ActivityModel activityModel);
}
