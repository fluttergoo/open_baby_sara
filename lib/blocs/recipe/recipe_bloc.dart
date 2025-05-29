import 'package:bloc/bloc.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/models/recipe_model.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/locator.dart';
import 'package:flutter_sara_baby_tracker_and_sound/data/repositories/recipe_repository.dart';
import 'package:meta/meta.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {

  final RecipeRepository _recipeRepository=getIt<RecipeRepository>();

  RecipeBloc() : super(RecipeInitial()) {
    on<RecipeEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<LoadRecipe>((event, emit)async{
      print("🟠 LoadRecipe triggered");

      emit(RecipeLoading());
      try{
        final  recipes = await _recipeRepository.loadRecipes();
        print("✅ Recipes loaded: ${recipes.length}");
        emit(RecipeLoaded(recipes: recipes));
      }catch (e){
        print("❌ Error loading recipes: $e");
        emit(RecipeError(message: 'Error ${e.toString()}'));
      }
    });

  }
}
