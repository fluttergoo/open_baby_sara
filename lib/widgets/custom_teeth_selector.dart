import 'package:flutter/material.dart';
import 'package:teeth_selector/teeth_selector.dart';

class CustomTeethSelector extends StatefulWidget {
  final Function(List<String>)? onSave;
  final bool isShowDetailTooth;
  final List<String>? initilizeTeeth;
  final double size;
  final bool isColor;
  final bool isMultiSelect;

  const CustomTeethSelector({
    super.key,
    this.onSave,
    required this.isShowDetailTooth,
    this.initilizeTeeth,
    this.size = 400,
    required this.isColor,
    required this.isMultiSelect,
  });

  @override
  State<CustomTeethSelector> createState() => _CustomTeethSelectorState();
}

class _CustomTeethSelectorState extends State<CustomTeethSelector> {
  List<String> selectedTeeth = [];
  Color selectedColor = Colors.green;

  final Map<String, String> toothTypes = {
    "51": "Central Incisor",
    "52": "Lateral Incisor",
    "53": "Canine",
    "54": "First Molar",
    "55": "Second Molar",
    "61": "Central Incisor",
    "62": "Lateral Incisor",
    "63": "Canine",
    "64": "First Molar",
    "65": "Second Molar",
    "71": "Central Incisor",
    "72": "Lateral Incisor",
    "73": "Canine",
    "74": "First Molar",
    "75": "Second Molar",
    "81": "Central Incisor",
    "82": "Lateral Incisor",
    "83": "Canine",
    "84": "First Molar",
    "85": "Second Molar",
  };

  final Map<String, Color> typeColors = {
    "Central Incisor": Colors.blue,
    "Lateral Incisor": Colors.orange,
    "Canine": Colors.purple,
    "First Molar": Colors.green,
    "Second Molar": Colors.red,
  };

  Map<String, Color> colorMap = {};

  @override
  void initState() {
    selectedTeeth = widget.initilizeTeeth ?? [];
    for (var entry in toothTypes.entries) {
      colorMap[entry.key] = typeColors[entry.value] ?? Colors.grey;
    }

    if (selectedTeeth.isNotEmpty) {
      final type = toothTypes[selectedTeeth.first];
      selectedColor = typeColors[type] ?? Colors.grey;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.size,
          width: widget.size,
          child: FittedBox(
            fit: BoxFit.contain,
            child: TeethSelector(
              onChange: (selected) {
                debugPrint('burasi');
                setState(() {
                  if (!widget.isMultiSelect) {
                    selectedTeeth = selected;
                  } else {
                    selectedTeeth = [...selected];
                  }

                  if (selected.isNotEmpty) {
                    final selectedTooth = selected.last;
                    final type = toothTypes[selectedTooth];
                    selectedColor = typeColors[type] ?? Colors.grey;
                  } else {
                    selectedColor = Colors.white;
                  }

                  widget.onSave!(selectedTeeth);
                });
              },
              showPrimary: true,
              showPermanent: false,
              multiSelect: widget.isMultiSelect,
              selectedColor: selectedColor,
              unselectedColor: Colors.white,
              defaultStrokeColor: Colors.grey,
              defaultStrokeWidth: 1.5,
              initiallySelected: selectedTeeth,
              // colorized: widget.isColor ? colorMap : {},
              StrokedColorized: widget.isColor ? colorMap : {},
              notation: (iso) => toothTypes[iso] ?? "Tooth $iso",
            ),
          ),
        ),
        if (widget.isShowDetailTooth)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children:
                  typeColors.entries.map((entry) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(entry.key),
                      ],
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }
}
