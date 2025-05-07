
import 'package:flutter_sara_baby_tracker_and_sound/core/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/activity_reposityory.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/services/firebase/activity_service.dart';
import 'package:sqflite/sqflite.dart';

class ActivityRepositoryImpl extends ActivityRepository {
  final Database database;
  final ActivityService _activityService = getIt<ActivityService>();

  ActivityRepositoryImpl({required this.database});

  @override
  Future<void> saveLocallyActivity(ActivityModel activityModel) async {
    await database.insert(
      'activities',
      activityModel.toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ActivityModel>?> fetchLocalActivities() async {
    final result = await database.query('activities');
    return result.map((e) {
      return ActivityModel.fromSqlite(e);
    }).toList();
  }

  @override
  Future<void> syncActivities() async {
    final activities = await fetchLocalActivities();

    for (var activity in activities!) {
      final remote = await _activityService.getActivity(
        activity.babyID,
        activity.activityID,
      );
      if (remote == null || activity.updatedAt.isAfter(remote.updatedAt)) {
        await _activityService.uploadActivity(activity);
        await database.update(
          'activities',
          {'isSynced': 1},
          where: 'activityID=?',
          whereArgs: [activity.activityID],
        );
      }
    }
  }

  Future<ActivityModel?> fetchLastSleepActivity(String babyID) async {
    final result = await database.rawQuery(
      'SELECT * FROM activities WHERE activityType = ? AND babyID = ? ORDER BY createdAt DESC LIMIT 1',
      ['sleep', babyID],
    );

    if (result.isNotEmpty) {
      return ActivityModel.fromSqlite(result.first);
    } else {
      return null;
    }
  }

  @override
  Future<ActivityModel?> fetchLastPumpActivity(String babyID) async{
    final result = await database.rawQuery(
      'SELECT * FROM activities WHERE activityType IN(?,?) AND babyID = ? ORDER BY createdAt DESC LIMIT 1',
      ['pumpTotal','pumpLeftRight', babyID],
    );

    if (result.isNotEmpty) {
      return ActivityModel.fromSqlite(result.first);
    } else {
      return null;
    }
  }
}
