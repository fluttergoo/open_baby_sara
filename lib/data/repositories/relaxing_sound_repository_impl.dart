import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/relaxing_sound_repository.dart';
import 'package:sqflite/sqflite.dart';

class RelaxingSoundRepositoryImpl extends RelaxingSoundRepository {
  final Database database;

  RelaxingSoundRepositoryImpl({required this.database});

  @override
  Future<Map<String, dynamic>?> loadSound() async {
    final result = await database.query(
      'relaxing_sound',
      where: 'id=?',
      whereArgs: [1],
    );
    if (result.isEmpty) {
      return null;
    }
    return result.first;
  }

  @override
  Future<void> saveSoundPlay(int index) async {
    await database.insert('relaxing_sound', {
      'id': 1,
      'sound_index': index,
      'isRunning': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> stopSound(int index) async {
    await database.update(
      'relaxing_sound',
      {'isRunning': 0},
      where: 'id=?',
      whereArgs: [1],
    );
  }
}
