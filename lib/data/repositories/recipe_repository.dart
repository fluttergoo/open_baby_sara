import 'package:open_baby_sara/data/models/recipe_model.dart';

abstract class RecipeRepository{
  Future<List<RecipeModel>> loadRecipes();
}