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
}
