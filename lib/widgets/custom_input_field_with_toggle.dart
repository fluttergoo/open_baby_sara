import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum MeasurementOfUnitNames { drink, weight, height, temperature }

class CustomInputFieldWithToggle extends StatefulWidget {
  MeasurementOfUnitNames selectedMeasurementOfUnit;
  final void Function(double value, String unit)? onChanged;
  bool vertical;
  final String title;

  CustomInputFieldWithToggle({
    super.key,
    this.selectedMeasurementOfUnit = MeasurementOfUnitNames.drink,
    this.vertical = false,
    required this.onChanged,
    required this.title,
  });

  @override
  State<CustomInputFieldWithToggle> createState() =>
      _CustomInputFieldWithToggleState();
}

class _CustomInputFieldWithToggleState
    extends State<CustomInputFieldWithToggle> {
  List<Text> measurementOfDrink = [Text('oz'), Text('mL')];
  List<Text> measurementOfWeight = [Text('lb'), Text('kg')];
  List<Text> measurementOfHeight = [Text('inch'), Text('cm')];
  final List<Text> measurementOfTemperature = [Text('°F'), Text('°C')];

  final TextEditingController _controller = TextEditingController();

  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return widget.vertical
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [buildTextField(), buildToggleButtons()],
        )
        : Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Expanded(child: buildTextField()), buildToggleButtons()],
        );
  }

  void handleToggleChange(int index) {
    if (isSelected[index]) return;

    final currentValue = double.tryParse(_controller.text);
    final oldUnit = getSelectedUnitLabel();

    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = i == index;
      }
    });

    final newUnit = getSelectedUnitLabel();
    if (currentValue != null) {
      final converted = convertValue(currentValue, from: oldUnit, to: newUnit);
      final rounded = double.parse(converted.toStringAsFixed(1));
      _controller.text = rounded.toStringAsFixed(1);
      widget.onChanged?.call(rounded, newUnit);
    }
  }

  List<Text> handleToggleUnit() {
    switch (widget.selectedMeasurementOfUnit) {
      case MeasurementOfUnitNames.weight:
        return measurementOfWeight;
      case MeasurementOfUnitNames.height:
        return measurementOfHeight;
      case MeasurementOfUnitNames.temperature:
        return measurementOfTemperature;
      case MeasurementOfUnitNames.drink:
      default:
        return measurementOfDrink;
    }
  }

  void handleInputChange(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && widget.onChanged != null) {
      widget.onChanged!(parsed, getSelectedUnitLabel());
    }
  }

  String getSelectedUnitLabel() {
    final units = handleToggleUnit();
    return units[isSelected.indexOf(true)].data ?? '';
  }

  double convertValue(
    double value, {
    required String from,
    required String to,
  }) {
    if (from == to) return value;

    // DRINK: oz <-> ml
    if ((from == 'oz' && to == 'ml') || (from == 'ml' && to == 'oz')) {
      return from == 'oz' ? value * 29.5735 : value / 29.5735;
    }

    // WEIGHT: lb <-> kg
    if ((from == 'lb' && to == 'kg') || (from == 'kg' && to == 'lb')) {
      return from == 'lb' ? value * 0.453592 : value / 0.453592;
    }

    // HEIGHT: inch <-> cm
    if ((from == 'inch' && to == 'cm') || (from == 'cm' && to == 'inch')) {
      return from == 'inch' ? value * 2.54 : value / 2.54;
    }

    // TEMPERATURE: °C <-> °F
    if ((from == '°C' && to == '°F')) {
      return value * 9 / 5 + 32;
    } else if (from == '°F' && to == '°C') {
      return (value - 32) * 5 / 9;
    }

    return value;
  }

  buildTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.black, fontSize: 16.sp),
        decoration: InputDecoration(
          labelText: widget.title,
          labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.black,
            fontSize: 16.sp,
          ),
          floatingLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
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
    );
  }

  buildToggleButtons() {
    return ToggleButtons(
      isSelected: isSelected,
      onPressed: handleToggleChange,
      borderRadius: BorderRadius.circular(10),
      selectedColor: Colors.white,
      fillColor: Colors.deepPurpleAccent.shade100,
      color: Colors.deepPurpleAccent.shade100,
      children: handleToggleUnit(),
    );
  }
}
