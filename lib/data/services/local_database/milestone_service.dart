import 'package:open_baby_sara/data/models/milestones_model.dart';

abstract class MilestoneService{
  Future<List<MonthlyMilestonesModel>> loadMilestonesFromAssets();
  Future<List<String>> fetchMilestonesFromDB(String babyID);

}