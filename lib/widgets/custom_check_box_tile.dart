import 'package:flutter/material.dart';

Widget customCheckboxTile({
  required String label,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return GestureDetector(
    onTap: () => onChanged(!value),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: value ? Colors.lightBlue.shade50 : Colors.white,
        border: Border.all(color: value ? Colors.blue : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.radio_button_unchecked,
            color: value ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
