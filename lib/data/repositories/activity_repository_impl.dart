import 'package:flutter/material.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/data/repositories/activity_reposityory.dart';
import 'package:open_baby_sara/data/services/firebase/activity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class ActivityRepositoryImpl extends ActivityRepository {
  final Database database;
  final ActivityService _activityService = getIt<ActivityService>();

  ActivityRepositoryImpl({required this.database});

  // ─── SharedPreferences helpers ────────────────────────────────────────────

  Future<DateTime> _getLastSyncTimestamp(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('lastSync_$babyID');
    if (stored == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.parse(stored);
  }

  Future<void> _saveLastSyncTimestamp(String babyID, DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSync_$babyID', timestamp.toIso8601String());
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  @override
  Future<void> saveLocallyActivity(ActivityModel activityModel) async {
    await database.insert(
      'activities',
      // always isSynced=0 so it gets pushed on next sync
      activityModel.copyWith(isSynced: false).toSqlite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  @override
  Future<List<ActivityModel>> fetchLocalActivities({
    bool onlyUnsynced = false,
  }) async {
    String? where;
    List<dynamic>? whereArgs;

    if (onlyUnsynced) {
      where = 'isSynced = ? AND isPendingDelete = ?';
      whereArgs = [0, 0];
    } else {
      where = 'isPendingDelete = ?';
      whereArgs = [0];
    }

    final result = await database.query(
      'activities',
      where: where,
      whereArgs: whereArgs,
    );

    return result.map((e) => ActivityModel.fromSqlite(e)).toList();
  }

  @override
  Future<ActivityModel?> fetchLastSleepActivity(String babyID) async {
    final result = await database.rawQuery(
      'SELECT * FROM activities WHERE activityType = ? AND babyID = ? AND isPendingDelete = 0 ORDER BY activityDateTime DESC LIMIT 1',
      ['sleep', babyID],
    );

    if (result.isNotEmpty) {
      return ActivityModel.fromSqlite(result.first);
    } else {
      return null;
    }
  }

  @override
  Future<ActivityModel?> fetchLastPumpActivity(String babyID) async {
    final result = await database.rawQuery(
      'SELECT * FROM activities WHERE activityType IN(?,?) AND babyID = ? AND isPendingDelete = 0 ORDER BY activityDateTime DESC LIMIT 1',
      ['pumpTotal', 'pumpLeftRight', babyID],
    );

    if (result.isNotEmpty) {
      return ActivityModel.fromSqlite(result.first);
    } else {
      return null;
    }
  }

  @override
  Future<List<ActivityModel>?> fetchAllTypeOfActivity(
    String babyID,
    String activityType,
  ) async {
    final result = await database.rawQuery(
      'SELECT * FROM activities WHERE activityType = ? AND babyID = ? AND isPendingDelete = 0',
      [activityType, babyID],
    );

    return result.map((e) => ActivityModel.fromSqlite(e)).toList();
  }

  @override
  Future<List<ActivityModel>?> fetchActivity(
    DateTime day,
    String babyID,
  ) async {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await database.query(
      'activities',
      where:
          'activityDateTime >= ? AND activityDateTime <= ? AND babyID = ? AND isPendingDelete = ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
        babyID,
        0,
      ],
    );
    return result.map((e) => ActivityModel.fromSqlite(e)).toList();
  }

  @override
  Future<List<ActivityModel>?> fetchActivityByDateRange({
    required DateTime start,
    required DateTime end,
    required String babyID,
    List<String>? activityTypes,
  }) async {
    final startOfRange = DateTime(start.year, start.month, start.day);
    final endOfRange = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final whereClauses = <String>[
      'activityDateTime >= ?',
      'activityDateTime <= ?',
      'babyID = ?',
      'isPendingDelete = ?',
    ];
    final whereArgs = <dynamic>[
      startOfRange.toIso8601String(),
      endOfRange.toIso8601String(),
      babyID,
      0,
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

  // ─── Delete (soft) ────────────────────────────────────────────────────────

  @override
  Future<void> deleteActivity(String babyID, String activityID) async {
    try {
      // Soft-delete: mark locally, sync to Firestore will hard-delete remotely
      await database.update(
        'activities',
        {
          'isPendingDelete': 1,
          'isSynced': 0,
          'deletedAt': DateTime.now().toIso8601String(),
        },
        where: 'activityID = ? AND babyID = ?',
        whereArgs: [activityID, babyID],
      );

      // Attempt immediate remote delete if possible; failure is safe to retry
      await _activityService.deleteActivityFromFirebase(babyID, activityID);

      // Remote delete succeeded — remove local record too
      await database.delete(
        'activities',
        where: 'activityID = ? AND babyID = ?',
        whereArgs: [activityID, babyID],
      );
    } catch (e) {
      // Stays as isPendingDelete=1 — syncActivities will retry on next cycle
      debugPrint('Delete queued for later sync: $e');
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────

  @override
  Future<void> updateActivity(ActivityModel activityModel) async {
    // Always mark isSynced=0 first so offline updates are never lost
    await database.update(
      'activities',
      {...activityModel.toSqlite(), 'isSynced': 0},
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
      // isSynced=0 remains — will be retried by syncActivities
      debugPrint('Update queued for later sync: $e');
    }
  }

  // ─── Sync ─────────────────────────────────────────────────────────────────

  @override
  Future<void> syncActivities() async {
    // 1. Push pending deletes to Firestore, then hard-delete locally
    final pendingDeletes = await database.query(
      'activities',
      where: 'isPendingDelete = ?',
      whereArgs: [1],
    );

    for (final row in pendingDeletes) {
      final activityID = row['activityID'] as String;
      final babyID = row['babyID'] as String;
      try {
        await _activityService.deleteActivityFromFirebase(babyID, activityID);
        await database.delete(
          'activities',
          where: 'activityID = ?',
          whereArgs: [activityID],
        );
      } catch (e) {
        debugPrint('Pending delete retry failed for $activityID: $e');
      }
    }

    // 2. Push unsynced new/updated activities
    final unsyncedActivities = await fetchLocalActivities(onlyUnsynced: true);

    for (final activity in unsyncedActivities) {
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

  // ─── Pull from Firestore ──────────────────────────────────────────────────

  @override
  Future<void> pullFromFirestore(String babyID) async {
    try {
      final lastSync = await _getLastSyncTimestamp(babyID);
      final remoteActivities = await _activityService.fetchActivitiesSince(
        babyID,
        lastSync,
      );

      for (final remote in remoteActivities) {
        final localRows = await database.query(
          'activities',
          where: 'activityID = ?',
          whereArgs: [remote.activityID],
        );

        if (localRows.isEmpty) {
          // New record from another device — insert it
          await database.insert(
            'activities',
            remote.copyWith(isSynced: true).toSqlite(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        } else {
          final local = ActivityModel.fromSqlite(localRows.first);

          // Skip if local has pending changes (local wins) or pending delete
          if (!local.isSynced || local.isPendingDelete) continue;

          // Remote is newer — update local cache
          if (remote.updatedAt.isAfter(local.updatedAt)) {
            await database.update(
              'activities',
              remote.copyWith(isSynced: true).toSqlite(),
              where: 'activityID = ?',
              whereArgs: [remote.activityID],
            );
          }
        }
      }

      await _saveLastSyncTimestamp(babyID, DateTime.now());
    } catch (e) {
      debugPrint('pullFromFirestore error for $babyID: $e');
    }
  }

  // ─── Full two-way sync ────────────────────────────────────────────────────

  @override
  Future<void> fullSync(String babyID) async {
    await pullFromFirestore(babyID);
    await syncActivities();
  }
}
