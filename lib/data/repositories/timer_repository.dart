abstract class TimerRepository{
  Future<void> saveTimerStart(DateTime startTime);
  Future<void> stopTimer();
  Future<Map<String,dynamic>?> loadTimer();
  Future<void> clearTimer();



}