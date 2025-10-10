import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:open_baby_sara/data/models/recipe_model.dart';
import 'package:open_baby_sara/data/repositories/recipe_repository.dart';

class RecipeRepositoryImpl extends RecipeRepository {
  @override
  Future<List<RecipeModel>> loadRecipes() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/recipes.json',
    );
    final List<dynamic> jsonData = jsonDecode(jsonString);
    debugPrint('✅ Loaded recipes: ${jsonData.length}');

    return jsonData
        .map((e) => RecipeModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
