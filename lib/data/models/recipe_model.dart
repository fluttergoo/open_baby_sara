class RecipeModel {
  final int id;
  final String titleKey;
  final String ageGroupKey;
  final String image;
  final List<String> ingredientsKeys;
  final List<String> instructionsKeys;
  final String prepTimeKey;
  final String cookTimeKey;
  final String servingSizeKey;
  final String notesKey;

  RecipeModel({
    required this.id,
    required this.titleKey,
    required this.ageGroupKey,
    required this.image,
    required this.ingredientsKeys,
    required this.instructionsKeys,
    required this.prepTimeKey,
    required this.cookTimeKey,
    required this.servingSizeKey,
    required this.notesKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleKey': titleKey,
      'ageGroupKey': ageGroupKey,
      'image': image,
      'ingredientsKeys': ingredientsKeys,
      'instructionsKeys': instructionsKeys,
      'prepTimeKey': prepTimeKey,
      'cookTimeKey': cookTimeKey,
      'servingSizeKey': servingSizeKey,
      'notesKey': notesKey,
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'] as int,
      titleKey: map['titleKey'] as String,
      ageGroupKey: map['age_groupKey'] as String,
      image: map['image'] as String,
      ingredientsKeys: List<String>.from(map['ingredientsKeys']),
      instructionsKeys: List<String>.from(map['instructionsKeys']),
      prepTimeKey: map['prep_timeKey'] as String,
      cookTimeKey: map['cook_timeKey'] as String,
      servingSizeKey: map['serving_sizeKey'] as String,
      notesKey: map['notesKey'] as String,
    );
  }
}
