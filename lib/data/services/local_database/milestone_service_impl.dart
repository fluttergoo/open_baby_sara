import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/milestones_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/services/local_database/milestone_service.dart';

class MilestoneServiceImpl implements MilestoneService {

  Future<List<MonthlyMilestonesModel>> loadMilestonesFromAssets() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/milestones.json',
    );
    final List<dynamic> jsonData = jsonDecode(jsonString);

    return jsonData
        .map(
          (element) => MonthlyMilestonesModel.fromMap(element as Map<String, dynamic>),
    )
        .toList();
  }
}
