
import 'package:flutter/material.dart';
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
  Future<List<ActivityModel>> fetchLocalActivities({bool onlyUnsynced = false}) async {
    final result = await database.query(
      'activities',
      where: onlyUnsynced ? 'isSynced = ?' : null,
      whereArgs: onlyUnsynced ? [0] : null,
    );

    return result.map((e) => ActivityModel.fromSqlite(e)).toList();
  }

  @override
  Future<void> syncActivities() async {
    final unsyncedActivities = await fetchLocalActivities(onlyUnsynced: true);

    for (var activity in unsyncedActivities) {
      try {
        await _activityService.uploadActivity(activity);
        await database.update(
          'activities',
          {'isSynced': 1},
          where: 'activityID = ?',
          whereArgs: [activity.activityID],
        );
      } catch (e) {
        debugPrint('Failed to sync activity ${activity.activityID}: $e');
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

  @override
  Future<List<ActivityModel>?> fetchAllTypeOfActivity(String babyID, String activityType) async {
    final result = await database.rawQuery(
      'SELECT * FROM activities WHERE activityType = ? AND babyID = ?',
      [activityType, babyID],
    );

    return result.map((e) => ActivityModel.fromSqlite(e)).toList();
  }

  @override
  Future<List<ActivityModel>?> fetchActivity(DateTime day, String babyID) async{
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await database.query(
      'activities',
      where: 'updatedAt >= ? AND updatedAt <= ? AND babyID =?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String(), babyID],
    );
    return result.map((e)=> ActivityModel.fromSqlite(e)).toList();
    
  }
}
