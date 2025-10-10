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
        color: value ? Colors.deepPurpleAccent.shade100 : Colors.white,
        border: Border.all(
          color:
              value ? Colors.deepPurpleAccent.shade100 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.radio_button_unchecked,
            color: value ? Colors.white : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style:
                value
                    ? TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )
                    : TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
