import 'package:flutter/material.dart';

class DirtyDetailOptions extends StatefulWidget {
  final void Function({
  required List<String> selectedTextures,
  required List<String> selectedColors,
  }) onChanged;
  const DirtyDetailOptions({super.key, required this.onChanged});

  @override
  State<DirtyDetailOptions> createState() => _DirtyDetailOptionsState();
}

class _DirtyDetailOptionsState extends State<DirtyDetailOptions> {
  final List<String> textures = ['Runny', 'Mucous', 'Mushy', 'Solid', 'Pebbles'];
  final List<String> colors = ['Black', 'Green', 'Yellow', 'Brown', 'Red'];

  List<String> selectedTextures = [];
  List<String> selectedColors = [];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Texture:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        buildChips(textures, selectedTextures, true),
        const SizedBox(height: 15),
        const Text("Color:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        buildChips(colors, selectedColors, false),
      ],
    );
  }

  void toggleSelection(String item, bool isTexture) {
    setState(() {
      final list = isTexture ? selectedTextures : selectedColors;
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
      widget.onChanged(
        selectedTextures: selectedTextures,
        selectedColors: selectedColors,
      );
    });
  }

  Widget buildChips(List<String> items, List<String> selectedList, bool isTexture) {
    return Wrap(
      spacing: 8,
      children: items.map((item) {
        final isSelected = selectedList.contains(item);
        return ChoiceChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (_) => toggleSelection(item, isTexture),
          selectedColor: Colors.orange,
        );
      }).toList(),
    );
  }

}
