part of 'recipe_bloc.dart';

@immutable
sealed class RecipeState {}

final class RecipeInitial extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<RecipeModel> recipes;

  RecipeLoaded({required this.recipes});
}

class RecipeLoading extends RecipeState {}

class RecipeError extends RecipeState {
  final String message;

  RecipeError({required this.message});
}
