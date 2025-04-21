import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gender_picker/gender_picker.dart';
import 'package:gender_picker/source/enums.dart';

class GenderSelector extends StatelessWidget {
  final Gender? selectedGender;
  final ValueChanged<Gender?> onGenderSelected;

  const GenderSelector({
    Key? key,
    required this.selectedGender,
    required this.onGenderSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenderPickerWithImage(
      showOtherGender: true,
      verticalAlignedText: true,
      selectedGender: selectedGender,
      onChanged: onGenderSelected,
      equallyAligned: true,
      animationDuration: const Duration(milliseconds: 300),
      isCircular: true,
      size: 80.0,
      maleText: context.tr("boy"),
      femaleText: context.tr("girl"),
      otherGenderText: context.tr("other"),
      selectedGenderTextStyle: const TextStyle(
        color: Colors.pinkAccent,
        fontWeight: FontWeight.bold,
      ),
      unSelectedGenderTextStyle: const TextStyle(
        color: Colors.grey,
      ),
    );
  }
}
