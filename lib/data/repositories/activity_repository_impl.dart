
import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/locator.dart';
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
      'SELECT * FROM activities WHERE activityType = ? AND babyID = ? ORDER BY activityDateTime DESC LIMIT 1',
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
      'SELECT * FROM activities WHERE activityType IN(?,?) AND babyID = ? ORDER BY activityDateTime DESC LIMIT 1',
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
      where: 'activityDateTime >= ? AND activityDateTime <= ? AND babyID =?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String(), babyID],
    );
    return result.map((e)=> ActivityModel.fromSqlite(e)).toList();
    
  }

  @override
  Future<List<ActivityModel>?> fetchActivityByDateRange({
    required DateTime start,
    required DateTime end,
    required String babyID,
    List<String>? activityTypes
  }) async {
    final startOfRange = DateTime(start.year, start.month, start.day);
    final endOfRange = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final whereClauses = <String>[
      'activityDateTime >= ?',
      'activityDateTime <= ?',
      'babyID = ?',
    ];
    final whereArgs = <dynamic>[
      startOfRange.toIso8601String(),
      endOfRange.toIso8601String(),
      babyID,
    ];

    if (activityTypes != null && activityTypes.isNotEmpty) {
      final placeholders = List.filled(activityTypes.length, '?').join(', ');
      whereClauses.add('activityType IN ($placeholders)');
      whereArgs.addAll(activityTypes);
    }

    final result = await database.query(
      'activities',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'activityDateTime DESC',
    );

    return result.map((e) => ActivityModel.fromSqlite(e)).toList();
  }

  @override
  Future<void> deleteActivity(String babyID, String activityID) async{
    try {
      await database.delete(
        'activities',
        where: 'activityID = ? AND babyID = ?',
        whereArgs: [activityID, babyID],
      );

      await _activityService.deleteActivityFromFirebase(babyID, activityID);
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  @override
  Future<void> updateActivity(ActivityModel activityModel) async
  {
    await database.update(
      'activities',
      activityModel.toSqlite(),
      where: 'activityID = ?',
      whereArgs: [activityModel.activityID],
    );


    try {
      await _activityService.uploadActivity(activityModel);
      await database.update(
        'activities',
        {'isSynced': 1},
        where: 'activityID = ?',
        whereArgs: [activityModel.activityID],
      );
    } catch (e) {
      debugPrint('Firebase update failed: $e');
    }
  }





}
