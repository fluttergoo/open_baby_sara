import 'package:flutter_sara_baby_tracker_and_sound/data/models/recipe_model.dart';

abstract class RecipeRepository{
  Future<List<RecipeModel>> loadRecipes();
}