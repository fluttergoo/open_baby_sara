import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/timer_repository.dart';
import 'package:sqflite/sqflite.dart';

class TimerRepositoryImpl extends TimerRepository {
  final Database database;

  TimerRepositoryImpl({required this.database});

  @override
  Future<void> saveTimerStart(DateTime startTime) async {
    await database.insert('timer', {
      'id': 1,
      'startTime': startTime.toIso8601String(),
      'isRunning': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> stopTimer() async {
    await database.update(
      'timer',
      {'isRunning': 0},
      where: 'id=?',
      whereArgs: [1],
    );
  }

  @override
  Future<Map<String, dynamic>?> loadTimer() async{
    final result=await database.query('timer',where: 'id=?',whereArgs: [1]);
    if (result.isEmpty) {
      return null;
    }
    return result.first;
  }
  Future<void> clearTimer() async {
    await database.delete('timer', where: 'id = ?', whereArgs: [1]);
  }
}
