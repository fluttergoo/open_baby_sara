import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static Future<void> saveSelectedBabyID(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_baby_id', babyID);
  }

  static Future<String?> getSelectedBabyID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_baby_id');
  }

  static Future<void> saveSleepTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sleep_tracker_notes_$babyID', notes);
  }

  static Future<String?> getSleepTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sleep_tracker_notes_$babyID');
  }

  static Future<void> clearSleepTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sleep_tracker_notes_$babyID');
  }

  static Future<void> saveFeedTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('feed_tracker_notes_$babyID', notes);
  }

  static Future<String?> getFeedTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('feed_tracker_notes_$babyID');
  }

  static Future<void> clearFeedTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('feed_tracker_notes_$babyID');
  }

  static Future<void> saveDiaperTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('diaper_tracker_notes_$babyID', notes);
  }

  static Future<String?> getDiaperTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('diaper_tracker_notes_$babyID');
  }

  static Future<void> clearDiaperTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('diaper_tracker_notes_$babyID');
  }

  static Future<void> savePumpTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pump_tracker_notes_$babyID', notes);
  }

  static Future<String?> getPumpTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pump_tracker_notes_$babyID');
  }

  static Future<void> clearPumpTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pump_tracker_notes_$babyID');
  }

  static Future<void> saveGrowthTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('growth_tracker_notes_$babyID', notes);
  }

  static Future<String?> getGrowthTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('growth_tracker_notes_$babyID');
  }

  static Future<void> clearGrowthTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('growth_tracker_notes_$babyID');
  }

  static Future<void> saveBabyFirstsTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baby_firsts_tracker_notes_$babyID', notes);
  }

  static Future<String?> getBabyFirstsTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('baby_firsts_tracker_notes_$babyID');
  }

  static Future<void> clearBabyFirstsTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('baby_firsts_tracker_notes_$babyID');
  }
}
