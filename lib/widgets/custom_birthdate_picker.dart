import 'package:bottom_picker/resources/arrays.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BirthdayField extends StatefulWidget {
  final TextEditingController controller;

  const BirthdayField({Key? key, required this.controller}) : super(key: key);

  @override
  State<BirthdayField> createState() => _BirthdayFieldState();
}

class _BirthdayFieldState extends State<BirthdayField> {
  void _showBottomDatePicker(BuildContext context) {
    BottomPicker.date(
      pickerTitle: Text(
        context.tr("set_your_birthday_or_due_date"),
        style: TextStyle(fontSize: 14.sp, color: Colors.blue),
      ),
      dateOrder: DatePickerDateOrder.dmy,
      initialDateTime: DateTime.now(),
      maxDateTime: DateTime(2050),
      minDateTime: DateTime(1980),
      pickerTextStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        // fontWeight: FontWeight.bold,
        fontSize: 16.sp,
      ),
      onSubmit: (date) {
        widget.controller.text = DateFormat('M/d/yyyy').format(date);
      },
      onChange: (date) {},
      bottomPickerTheme: BottomPickerTheme.plumPlate,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      onTap: () => _showBottomDatePicker(context),
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: Colors.black, fontSize: 16.sp),
      decoration: InputDecoration(
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
        labelText: context.tr("birthdate_or_due_date"),
        hintText: context.tr("select_your_birthdate"),
        labelStyle: TextStyle(fontSize: 14.sp),
        hintStyle: TextStyle(fontSize: 14.sp),
        suffixIcon: const Icon(Icons.calendar_month),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
