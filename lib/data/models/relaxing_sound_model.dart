class RelaxingSoundModel {
  final String title;
  final String assetPath;
  final String iconAssetPath;
  int isPlaying;

  RelaxingSoundModel({
    required this.title,
    required this.iconAssetPath,
    required this.assetPath,
    this.isPlaying = 0,
  });
}
