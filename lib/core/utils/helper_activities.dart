import 'package:easy_localization/easy_localization.dart';
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