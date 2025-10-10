import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WetDirtyDrySelector extends StatefulWidget {
  final void Function(List<String> selectedValues) onChanged;

  const WetDirtyDrySelector({super.key, required this.onChanged});

  @override
  State<WetDirtyDrySelector> createState() => _WetDirtyDrySelectorState();
}

class _WetDirtyDrySelectorState extends State<WetDirtyDrySelector> {
  List<String> selected = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildToggleButton("Wet"),
        buildToggleButton("Dirty"),
        buildToggleButton("Dry"),
      ],
    );
  }

  void toggleSelection(String value) {
    setState(() {
      if (selected.contains(value)) {
        selected.remove(value);
      } else if (value == 'Dry') {
        selected.clear();
        selected.add(value);
      } else {
        selected.remove('Dry');
        selected.add(value);
      }
      widget.onChanged(selected);
    });
  }

  Widget buildToggleButton(String label) {
    final isSelected = selected.contains(label);

    return GestureDetector(
      onTap: () => toggleSelection(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        child: Center(
          child: Text(
            context.tr(label),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}
