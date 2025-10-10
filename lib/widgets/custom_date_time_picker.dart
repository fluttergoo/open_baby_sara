import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker extends StatefulWidget {
  final String initialText;
  final Function(DateTime) onDateTimeSelected;

  const CustomDateTimePicker({
    super.key,
    required this.initialText,
    required this.onDateTimeSelected,
  });

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  DateTime? selectedDateTime;
  late String displayText;

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now();
    displayText = formatDateTime(selectedDateTime!);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onConfirm: (date) {
            setState(() {
              selectedDateTime = date;
              displayText = formatDateTime(date);
            });

            widget.onDateTimeSelected(date);
          },
          currentTime: selectedDateTime,
        );
      },
      child: Text(
        displayText,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String formatDateTime(DateTime datetime) {
    final now = DateTime.now();
    final isToday =
        datetime.day == now.day &&
        datetime.month == now.month &&
        datetime.year == now.year;

    final formattedHour = datetime.hour.toString().padLeft(2, '0');
    final formattedMinute = datetime.minute.toString().padLeft(2, '0');

    if (isToday) {
      return 'Today $formattedHour:$formattedMinute';
    } else {
      final formattedDate = DateFormat('MMMM d').format(datetime);
      return '$formattedDate $formattedHour:$formattedMinute';
    }
  }
}
