import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormulaBreastmilkSelector extends StatefulWidget {
  final void Function(String selectedValue) onChanged;

  const FormulaBreastmilkSelector({super.key, required this.onChanged});

  @override
  State<FormulaBreastmilkSelector> createState() => _FormulaBreastmilkSelectorState();
}

class _FormulaBreastmilkSelectorState extends State<FormulaBreastmilkSelector> {
  String selected = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildToggleButton("breast milk"),
        buildToggleButton("formula"),
      ],
    );
  }
  void toggleSelection(String value) {
    setState(() {
      selected = (selected == value) ? '' : value;
      widget.onChanged(selected);
    });
  }
  Widget buildToggleButton(String label) {
    final isSelected = selected == label;

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
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

}


