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
  final FocusNode _focusNode = FocusNode();
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

  void _incrementValue() {
    final currentValue = double.tryParse(_controller.text) ?? 0.0;
    final newValue = currentValue + 0.5;
    _controller.text = newValue.toStringAsFixed(1);
    handleInputChange(_controller.text);
  }

  void _decrementValue() {
    final currentValue = double.tryParse(_controller.text) ?? 0.0;
    if (currentValue > 0) {
      final newValue = (currentValue - 0.5).clamp(0.0, double.infinity);
      _controller.text = newValue.toStringAsFixed(1);
      handleInputChange(_controller.text);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOzSelected = selectedUnit == 'oz';
    final isFocused = _focusNode.hasFocus;
    final borderColor = isFocused 
        ? Color(0xFFBA68C8) // Daha belirgin mor (focus)
        : Color(0xFFE1BEE7); // Açık mor (normal)
    final lightPurple = Color(0xFFE1BEE7); // Açık mor rengi

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
          child: Text(
            'Amount',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Input Container with Stepper and Toggle
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: borderColor,
              width: 1.5, // Kalınlık her zaman aynı, sadece renk değişiyor
            ),
          ),
          child: Row(
            children: [
              // Input Field
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontSize: 16.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16.sp,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  onChanged: handleInputChange,
                ),
              ),
              
              // Stepper Control
              Container(
                margin: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Up Arrow
                    InkWell(
                      onTap: _incrementValue,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(6.r)),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    // Down Arrow
                    InkWell(
                      onTap: _decrementValue,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(6.r)),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(width: 8.w),
              
              // Unit Toggle
              Container(
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: lightPurple.withOpacity(0.3), // Açık mor arka plan
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // oz Button
                    GestureDetector(
                      onTap: () => handleToggleChange(0),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isOzSelected 
                              ? Colors.white.withOpacity(1.0)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: isOzSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 1.5,
                                    offset: Offset(0, 0.5),
                                  ),
                                ]
                              : [],
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            color: isOzSelected
                                ? Color(0xFFBA68C8)
                                : Colors.grey[600],
                            fontSize: 13.sp,
                            fontWeight: isOzSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          child: Text('oz'),
                        ),
                      ),
                    ),
                    
                    // ml Button
                    GestureDetector(
                      onTap: () => handleToggleChange(1),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: !isOzSelected 
                              ? Colors.white.withOpacity(1.0)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: !isOzSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 1.5,
                                    offset: Offset(0, 0.5),
                                  ),
                                ]
                              : [],
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            color: !isOzSelected
                                ? Color(0xFFBA68C8)
                                : Colors.grey[600],
                            fontSize: 13.sp,
                            fontWeight: !isOzSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          child: Text('ml'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
