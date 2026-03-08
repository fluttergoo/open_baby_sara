import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DirtyDetailOptions extends StatefulWidget {
  final void Function({
    required List<String> selectedTextures,
    required List<String> selectedColors,
  })
  onChanged;
  final List<String>? initialTextures;
  final List<String>? initialColors;
  
  const DirtyDetailOptions({
    super.key, 
    required this.onChanged,
    this.initialTextures,
    this.initialColors,
  });

  @override
  State<DirtyDetailOptions> createState() => _DirtyDetailOptionsState();
}

class _DirtyDetailOptionsState extends State<DirtyDetailOptions> {
  final List<String> textures = [
    'Runny',
    'Mucous',
    'Mushy',
    'Solid',
    'Pebbles',
  ];
  final List<String> colors = ['Black', 'Green', 'Yellow', 'Brown', 'Red'];

  late List<String> selectedTextures;
  late List<String> selectedColors;
  
  @override
  void initState() {
    super.initState();
    selectedTextures = List<String>.from(widget.initialTextures ?? []);
    selectedColors = List<String>.from(widget.initialColors ?? []);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('Texture:'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        buildChips(textures, selectedTextures, true),
        const SizedBox(height: 15),
        Text(
          context.tr('Color:'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

  Widget buildChips(
    List<String> items,
    List<String> selectedList,
    bool isTexture,
  ) {
    final lightPurple = Color(0xFFE1BEE7); // Açık mor renk
    final darkPurple = Color(0xFFBA68C8); // Koyu mor renk
    
    return Wrap(
      spacing: 8,
      children:
          items.map((item) {
            final isSelected = selectedList.contains(item);
            return ChoiceChip(
              label: Text(
                context.tr(item),
                style: TextStyle(
                  color: isSelected ? darkPurple : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => toggleSelection(item, isTexture),
              selectedColor: lightPurple.withOpacity(0.3),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? darkPurple : lightPurple,
                width: 1,
              ),
            );
          }).toList(),
    );
  }
}
