import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnitInputFieldWithToggle extends StatefulWidget {
  final void Function(double value, String unit) onChanged;

  const UnitInputFieldWithToggle({super.key, required this.onChanged});

  @override
  State<UnitInputFieldWithToggle> createState() =>
      _UnitInputFieldWithToggleState();
}

class _UnitInputFieldWithToggleState extends State<UnitInputFieldWithToggle> {
  final TextEditingController _controller = TextEditingController();
  String selectedUnit = 'oz';
  double? convertedValue;

  double convert(double value, String fromUnit) {
    if (fromUnit == 'oz') {
      return value * 29.5735; // oz → ml
    } else {
      return value / 29.5735; // ml → oz
    }
  }

  void handleInputChange(String input) {
    final value = double.tryParse(input);
    if (value != null) {
      convertedValue = convert(value, selectedUnit);
      widget.onChanged(value, selectedUnit);
    } else {
      convertedValue = null;
    }
    setState(() {});
  }

  void handleToggleChange(int index) {
    if (selectedUnit == (index == 0 ? 'oz' : 'ml')) return;

    final currentValue = double.tryParse(_controller.text);
    if (currentValue != null) {
      final converted = convert(currentValue, selectedUnit);
      _controller.text = converted.toStringAsFixed(1);
    }

    setState(() {
      selectedUnit = index == 0 ? 'oz' : 'ml';
      convertedValue =
          currentValue != null ? convert(currentValue, selectedUnit) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOzSelected = selectedUnit == 'oz';

    return Column(
      children: [
        // Quantity Input
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black,
              fontSize: 16.sp,
            ),
            decoration: InputDecoration(
              labelText: 'Add Amount',
              labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontSize: 16.sp,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
            ),

            onChanged: handleInputChange,
          ),
        ),
        const SizedBox(width: 12),

        // Unit Toggle
        Align(
          alignment: Alignment.centerRight,
          child: ToggleButtons(
            isSelected: [isOzSelected, !isOzSelected],
            borderRadius: BorderRadius.circular(10),
            selectedColor: Colors.white,
            fillColor: Colors.deepPurple.shade300,
            color: Colors.deepPurple.shade300,
            onPressed: handleToggleChange,
            children: const [Text('oz'), Text('ml')],
          ),
        ),
      ],
    );
  }
}
