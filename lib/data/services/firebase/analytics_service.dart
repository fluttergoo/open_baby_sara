abstract class AnalyticsService {
  Future<void> logScreenView(String screenName);
  Future<void> logActivitySaved(String babyID, String activityName);
  Future<void> logSoundsView(String soundsName);
}
