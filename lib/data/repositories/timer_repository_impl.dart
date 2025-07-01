import 'package:open_baby_sara/data/repositories/timer_repository.dart';
import 'package:sqflite/sqflite.dart';

class TimerRepositoryImpl extends TimerRepository {
  final Database database;

  TimerRepositoryImpl({required this.database});

  @override
  Future<void> saveTimerStart(DateTime startTime,String activityType) async {
    await database.insert(activityType, {
      'id': 1,
      'startTime': startTime.toIso8601String(),
      'isRunning': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> stopTimer(String activityType) async {
    await database.update(
      activityType,
      {'isRunning': 0},
      where: 'id=?',
      whereArgs: [1],
    );
  }

  @override
  Future<Map<String, dynamic>?> loadTimer(String activityType) async{
    final result=await database.query(activityType,where: 'id=?',whereArgs: [1]);
    if (result.isEmpty) {
      return null;
    }
    return result.first;
  }
  Future<void> clearTimer(String activityType) async {
    await database.delete(activityType, where: 'id = ?', whereArgs: [1]);
  }
}
