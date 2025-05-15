import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/vaccination_repository.dart';
import 'package:sqflite/sqflite.dart';

class VaccinationRepositoryImpl implements VaccinationRepository {
  final Database database;

  VaccinationRepositoryImpl({required this.database});

  @override
  Future<void> deleteVaccination(String name) async {
    final result = await database.delete(
      'vaccinations',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  @override
  Future<List<String>?> fetchVaccinationList() async{
    final result = await database.rawQuery('SELECT * FROM vaccinations');

    if (result.isNotEmpty) {
      return result.map((e) => e['name'] as String).toList();
    } else {
      return null;
    }
  }

  @override
  Future<void> insertVaccination(String vaccinationNames) async {
    await database.insert('vaccinations', {
      'name': vaccinationNames,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
