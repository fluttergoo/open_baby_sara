class RelaxingSoundModel {
  final String title;
  final String assetPath;
  final String iconAssetPath;
  bool isPlaying;

  RelaxingSoundModel({required this.title,required this.iconAssetPath, required this.assetPath, this.isPlaying = false});
}