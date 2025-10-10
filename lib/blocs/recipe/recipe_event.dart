part of 'recipe_bloc.dart';

@immutable
sealed class RecipeEvent {}

class LoadRecipe extends RecipeEvent {}
