import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sara_baby_tracker_and_sound/core/constant/iso_tooth_descriptions_constants.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/activity_model.dart';

/// Calculates the total feed amount from a list of feed activities.
double calculateTotalFeedAmount(List<ActivityModel> feedActivities) {
  return feedActivities.fold(
    0.0,
        (sum, activity) => sum + ((activity.data['totalAmount'] ?? 0).toDouble()),
  );
}

String? getFeedUnit(List<ActivityModel> feedActivities) {
  return feedActivities.isNotEmpty
      ? feedActivities.first.data['totalUnit'] as String?
      : null;
}

double calculateTotalPumpAmount(List<ActivityModel> pumpActivities) {
  return pumpActivities.fold(
    0.0,
        (sum, activity) => sum + ((activity.data['totalAmount'] ?? 0).toDouble()),
  );
}

String? getPumpUnit(List<ActivityModel> pumpActivities) {
  return pumpActivities.isNotEmpty
      ? pumpActivities.first.data['totalUnit'] as String?
      : null;
}

String formatSleepDuration(List<ActivityModel> sleepActivities) {
  final totalMillis = sleepActivities.fold<int>(
    0,
        (sum, activity) => sum + ((activity.data['totalTime'] ?? 0) as int),
  );
  final duration = Duration(milliseconds: totalMillis);
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  return '${hours}h ${minutes}m';
}

String summarizeDiaperTypes(List<ActivityModel> diaperActivities) {
  int wetOnly = 0, dirtyOnly = 0, wetAndDirty = 0, dry = 0;

  for (final activity in diaperActivities) {
    final List selectedTypes = activity.data['mainSelection'] ?? [];
    final hasWet = selectedTypes.contains('Wet');
    final hasDirty = selectedTypes.contains('Dirty');
    final hasDry = selectedTypes.contains('Dry');

    if (hasWet && hasDirty) {
      wetAndDirty++;
    } else if (hasWet) {
      wetOnly++;
    } else if (hasDirty) {
      dirtyOnly++;
    } else if (hasDry) {
      dry++;
    }
  }

  final parts = <String>[];
  if (wetAndDirty > 0) parts.add('$wetAndDirty Mixed');
  if (wetOnly > 0) parts.add('$wetOnly Wet');
  if (dirtyOnly > 0) parts.add('$dirtyOnly Dirty');
  if (dry > 0) parts.add('$dry Dry');

  return parts.join(', ');
}


/// Calculates to Last Activities


ActivityModel? getLastActivity(List<ActivityModel> activities) {
  if (activities.isEmpty) return null;

  return activities.reduce((a, b) {
    final aDayStr = a.data['activityDay'] as String?;
    final bDayStr = b.data['activityDay'] as String?;

    if (aDayStr == null) return b;
    if (bDayStr == null) return a;

    final aDate = DateTime.tryParse(aDayStr);
    final bDate = DateTime.tryParse(bDayStr);

    if (aDate == null) return b;
    if (bDate == null) return a;

    return aDate.isAfter(bDate) ? a : b;
  });
}

String? getLastFeedSummary(List<ActivityModel> activities) {
  final last = getLastActivity(activities);
  if (last == null) return '➕ Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\n Tap to start';

  final amount = last.data['totalAmount'] ?? '';
  final unit = last.data['totalUnit'] ?? '';
  return '$amount $unit \nat $timeText';
}

String? getLastSleepSummary(List<ActivityModel> activities) {
  final last = getLastActivity(activities);
  if (last == null) return '➕ Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\n Tap to start';

  final durationMs = last.data['totalTime'] ?? 0;
  final duration = Duration(milliseconds: durationMs);
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  return '${hours}h ${minutes}m \nat $timeText';
}

String? getLastDiaperSummary(List<ActivityModel> activities) {
  final last = getLastActivity(activities);
  if (last == null) return '➕ Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\n Tap to start';

  final types = (last.data['mainSelection'] ?? []).join(' & ');
  return '$types \nat $timeText';
}

String? getLastPumpSummary(List<ActivityModel> activities) {
  final last = getLastActivity(activities);
  if (last == null) return '➕ Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\n Tap to start';

  final amount = last.data['totalAmount'] ?? '';
  final unit = last.data['totalUnit'] ?? '';
  return '$amount $unit \nat $timeText';
}

String? getLastWeight(List<ActivityModel> activities){

  final weightActivities = activities.where((a) =>
  a.data.containsKey('weight') &&
      a.data['weight'] != null &&
      a.data['weight'].toString().trim().isNotEmpty
  ).toList();
  final last = getLastActivity(weightActivities);
  if (last == null) return '➕\n Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\n Tap to start';

  final weight = last.data['weight'] ?? '';
  final weightUnit = last.data['weightUnit'] ?? '';
  return '$weight $weightUnit \nat $timeText';

}

String? getLastHeight(List<ActivityModel> activities){

  final heightActivities = activities.where((a) =>
  a.data.containsKey('height') &&
      a.data['height'] != null &&
      a.data['height'].toString().trim().isNotEmpty
  ).toList();
  final last = getLastActivity(heightActivities);
  if (last == null) return '➕\n Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\n Tap to start';

  final height = last.data['height'] ?? '';
  final heightUnit = last.data['heightUnit'] ?? '';
  return '$height $heightUnit \nat $timeText';

}

String? getLastHeadSize(List<ActivityModel> activities){

  final headSizeActivities = activities.where((a) =>
  a.data.containsKey('headSize') &&
      a.data['headSize'] != null &&
      a.data['headSize'].toString().trim().isNotEmpty
  ).toList();
  final last = getLastActivity(headSizeActivities);
  if (last == null) return '➕\n Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\n Tap to start';

  final headSize = last.data['headSize'] ?? '';
  final headSizeUnit = last.data['headSizeUnit'] ?? '';
  return '$headSize $headSizeUnit \nat $timeText';

}

String? getLastBabyFirstsSummary(List<ActivityModel> activities,BuildContext context,) {
  final last = getLastActivity(activities);
  if (last == null) return '➕ Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\n Tap to start';

  final milestoneTitle = (last.data['milestoneTitle'] ?? []).join(' & ');
  final milestoneDesc = (last.data['milestoneDesc'] ?? []).join(' & ');

  return '${context.tr(milestoneTitle)}\n${context.tr(milestoneDesc)}';

}


String? getLastTeethingSummary(
    List<ActivityModel> activities,
    BuildContext context,
    ) {
  final last = getLastActivity(activities);
  if (last == null) return '➕ Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\nTap to start';

  final rawTeethingData = last.data['teethingIsoNumber'];
  List<String> teethingNumbers;

  if (rawTeethingData is List) {
    teethingNumbers = rawTeethingData.map((e) => e.toString()).toList();
  } else if (rawTeethingData is String) {
    teethingNumbers = rawTeethingData.split(',').map((e) => e.trim()).toList();
  } else {
    teethingNumbers = [];
  }

  final isErupted = last.data['isErupted'] == true;
  final isShed = last.data['isShed'] == true;

  String status = '';
  if (isErupted) {
    status = context.tr('Tooth erupted');
  } else if (isShed) {
    status = context.tr('Tooth shed');
  } else {
    status = context.tr('Teething activity');
  }

  final List<String> descriptions = teethingNumbers.map((num) {
    return isoToothDescriptions[num] ?? 'Tooth $num';
  }).toList();

  final descriptionText = descriptions.join(', ');

  return '$status\n$descriptionText';
}



String? formatSmartDate(DateTime time) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(time.year, time.month, time.day);

  final diff = today.difference(dateOnly).inDays;

  if (diff > 7) {
    return null; // 7 günden eskiyse gösterme
  }

  if (diff == 0) {
    return DateFormat('h:mm a').format(time); // Örn: 2:30 PM
  } else if (diff == 1) {
    return 'Yesterday at ${DateFormat('h:mm a').format(time)}';
  } else {
    return DateFormat('MMM d, h:mm a').format(time); // Örn: May 10, 2:30 PM
  }
}

String? getActivitySummary(ActivityModel activity, BuildContext context) {
  switch (activity.activityType) {
    case 'feed':
    case 'breastFeed':
    case 'bottleFeed':
    case 'solids':
      return getLastFeedSummary([activity]);

    case 'pumpLeftRight':
    case 'pumpTotal':
      return getLastPumpSummary([activity]);

    case 'sleep':
      return getLastSleepSummary([activity]);

    case 'diaper':
      return getLastDiaperSummary([activity]);

    case 'medication':
      return getLastMedicationSummary([activity]);
    case 'growth':
      final weightSummary = getLastGrowthMetricSummary(
        activities: [activity],
        fieldKey: 'weight',
        unitKey: 'weightUnit',
      );

      final heightSummary = getLastGrowthMetricSummary(
        activities: [activity],
        fieldKey: 'height',
        unitKey: 'heightUnit',
      );

      final headSizeSummary = getLastGrowthMetricSummary(
        activities: [activity],
        fieldKey: 'headSize',
        unitKey: 'headSizeUnit',
      );

      final parts = [
        if (weightSummary != null && weightSummary.isNotEmpty) 'Weight: $weightSummary',
        if (heightSummary != null && heightSummary.isNotEmpty) 'Height: $heightSummary',
        if (headSizeSummary != null && headSizeSummary.isNotEmpty) 'Head Size: $headSizeSummary',
      ];
      return parts.join('\n');
    case 'babyFirsts':
      return getLastBabyFirstsSummary([activity], context);
    case 'teething':
      return getLastTeethingSummary([activity], context);
    case 'vaccination':
      return getLastVaccinationSummary([activity] );
    case 'doctorVisit':
      return getLastDoctorVisitSummary([activity]);
    case 'fever':
      return getLastFeverSummary([activity]);

    default:
      return 'Recorded';
  }
}

String? getLastFeverSummary(List<ActivityModel> activities) {
  final last = getLastActivity(activities);
  if (last == null) return '➕ Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕ Tap to start';

  final temperature = last.data['temperature']?.toString();
  final unit = last.data['temperatureUnit']?.toString();

  if (temperature == null || temperature.isEmpty) {
    return '➕ Tap to start';
  }

  return '$temperature $unit';
}

String? getLastVaccinationSummary(List<ActivityModel> activities) {
  final last = getLastActivity(activities);
  if (last == null) return '➕ Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕ Tap to start';

  final vaccinations = (last.data['medications'] as List<dynamic>?)
      ?.map((e) => e['name'] as String?)
      .where((name) => name != null && name.trim().isNotEmpty)
      .toList();

  if (vaccinations == null || vaccinations.isEmpty) {
    return '➕ Tap to start';
  }

  final vaccinationNames = vaccinations.join(', ');
  return vaccinationNames;
}

String? getLastDoctorVisitSummary(List<ActivityModel> activities) {
  final last = getLastActivity(activities);
  if (last == null) return '➕ Tap to start';

  final activityDayStr = last.data['activityDay'];
  final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
  final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
  if (timeText == null) return '➕\n Tap to start';

  final reason = last.data['reason'] ?? '';
  final reaction = last.data['reaction'] ?? '';
  final diagnosis = last.data['diagnosis'] ?? '';
  final notes = last.data['notes'] ?? '';

  final parts = <String>[];
  if (reason.toString().isNotEmpty) parts.add('Reason: $reason');
  if (reaction.toString().isNotEmpty) parts.add('Reaction: $reaction');
  if (diagnosis.toString().isNotEmpty) parts.add('Diagnosis: $diagnosis');
  if (notes.toString().isNotEmpty) parts.add('Notes: $notes');

  final joined = parts.join(' • ');

  return joined.isEmpty ? '➕ Tap to start' : joined;
}

String? getLastMedicationSummary(List<ActivityModel> list) {

    final last = getLastActivity(list);
    if (last == null) return '➕ Tap to start';

    final activityDayStr = last.data['activityDay'];
    final activityDay = activityDayStr != null ? DateTime.tryParse(activityDayStr) : null;
    final timeText = activityDay != null ? formatSmartDate(activityDay) : null;
    if (timeText == null) return '➕\n Tap to start';

    final List<dynamic>? meds = last.data['medications'];
    if (meds == null || meds.isEmpty) return 'No medication details';

    final medsSummary = meds.map((med) {
      final name = med['name'] ?? '';
      final amount = med['amount'] ?? '';
      final unit = med['unit'] ?? '';
      return '$name: $amount $unit';
    }).join(', ');

    return '$medsSummary ';
  }



getLastGrowthMetricSummary({required List<ActivityModel> activities, required String fieldKey, required String unitKey}) {
  final filtered = activities.where((a) =>
  a.data.containsKey(fieldKey) &&
      a.data[fieldKey] != null &&
      a.data[fieldKey].toString().trim().isNotEmpty
  ).toList();

  final last = getLastActivity(filtered);
  if (last == null) return null;

  final dateStr = last.data['activityDay'];
  final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
  final timeText = date != null ? formatSmartDate(date) : null;
  if (timeText == null) return null;

  final value = last.data[fieldKey]?.toString() ?? '';
  final unit = last.data[unitKey]?.toString() ?? '';

  return '$value $unit';
}
