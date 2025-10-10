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
}
