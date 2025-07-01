import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:open_baby_sara/data/models/activity_model.dart';
import 'package:open_baby_sara/data/models/milestones_model.dart';
import 'package:open_baby_sara/data/services/local_database/milestone_service.dart';
import 'package:sqflite/sqlite_api.dart';

class MilestoneServiceImpl implements MilestoneService {
  final Database database;

  MilestoneServiceImpl({required this.database});

  Future<List<MonthlyMilestonesModel>> loadMilestonesFromAssets() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/milestones.json',
    );
    final List<dynamic> jsonData = jsonDecode(jsonString);

    return jsonData
        .map(
          (element) =>
              MonthlyMilestonesModel.fromMap(element as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<String>> fetchMilestonesFromDB(String babyID) async {
    final result = await database.rawQuery(
      'SELECT * FROM activities WHERE activityType = ? AND babyID = ?',
      ['babyFirsts', babyID],
    );

    List<String> titleMilestone = [];

    if (result.isNotEmpty) {
      for (var row in result) {
        final activity = ActivityModel.fromSqlite(row);

        final titles = activity.data['milestoneTitle'];
        if (titles != null && titles is List) {
          titleMilestone.addAll(List<String>.from(titles));
        }
      }
    }
    debugPrint(titleMilestone.length.toString());
    return titleMilestone;
  }
}
