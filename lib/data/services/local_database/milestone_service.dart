import 'package:flutter_sara_baby_tracker_and_sound/data/models/milestones_model.dart';

abstract class MilestoneService{
  Future<List<MonthlyMilestonesModel>> loadMilestonesFromAssets();
  Future<List<String>> fetchMilestonesFromDB(String babyID);

}