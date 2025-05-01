abstract class TimerRepository{
  Future<void> saveTimerStart(DateTime startTime,String activityType);
  Future<void> stopTimer(String activityType);
  Future<Map<String,dynamic>?> loadTimer(String activityType);
  Future<void> clearTimer(String activityType);



}