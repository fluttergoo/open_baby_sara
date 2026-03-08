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

  static Future<void> saveDoctorVisitNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_visit_notes_$babyID', notes);
  }

  static Future<String?> getDoctorVisitNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('doctor_visit_notes_$babyID');
  }

  static Future<void> clearDoctorVisitNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('doctor_visit_notes_$babyID');
  }

  static Future<void> saveDoctorVisitDiagnosis(String babyID, String diagnosis) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctor_visit_diagnosis_$babyID', diagnosis);
  }

  static Future<String?> getDoctorVisitDiagnosis(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('doctor_visit_diagnosis_$babyID');
  }

  static Future<void> clearDoctorVisitDiagnosis(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('doctor_visit_diagnosis_$babyID');
  }

  static Future<void> saveFeverTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fever_tracker_notes_$babyID', notes);
  }

  static Future<String?> getFeverTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fever_tracker_notes_$babyID');
  }

  static Future<void> clearFeverTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fever_tracker_notes_$babyID');
  }

  static Future<void> saveMedicalTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medical_tracker_notes_$babyID', notes);
  }

  static Future<String?> getMedicalTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('medical_tracker_notes_$babyID');
  }

  static Future<void> clearMedicalTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('medical_tracker_notes_$babyID');
  }

  static Future<void> saveTeethingTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teething_tracker_notes_$babyID', notes);
  }

  static Future<String?> getTeethingTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('teething_tracker_notes_$babyID');
  }

  static Future<void> clearTeethingTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('teething_tracker_notes_$babyID');
  }

  static Future<void> saveVaccinationTrackerNotes(String babyID, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vaccination_tracker_notes_$babyID', notes);
  }

  static Future<String?> getVaccinationTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('vaccination_tracker_notes_$babyID');
  }

  static Future<void> clearVaccinationTrackerNotes(String babyID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vaccination_tracker_notes_$babyID');
  }
}
