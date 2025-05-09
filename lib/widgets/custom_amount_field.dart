import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';

class CustomAmountField extends StatefulWidget {
  final String initialUnit;
  final String? initialValue;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onUnitChanged;
  final FocusNode focusNode;

  const CustomAmountField({
    super.key,
    this.initialUnit = 'oz',
    this.initialValue,
    required this.onAmountChanged,
    required this.onUnitChanged,
    required this.focusNode,
  });

  @override
  State<CustomAmountField> createState() => _CustomAmountFieldState();
}

class _CustomAmountFieldState extends State<CustomAmountField> {
  late TextEditingController _controller;
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.initialUnit;
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 56, maxHeight: 120),
      child: KeyboardActions(
        config: _buildKeyboardConfig(context),
        child: TextFormField(
          focusNode: widget.focusNode,
          controller: _controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount',
            suffixText: _selectedUnit,
            border: OutlineInputBorder(),
          ),
          onChanged: widget.onAmountChanged,
        ),
      ),
    );
  }
  KeyboardActionsConfig _buildKeyboardConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardBarColor: Colors.grey.shade200,
      actions: [
        KeyboardActionsItem(
          focusNode: widget.focusNode,
          toolbarButtons: [
                (node) {
              return Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedUnit = 'oz';
                      });
                      widget.onUnitChanged('oz');
                    },
                    child: Text('oz'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedUnit = 'lb';
                      });
                      widget.onUnitChanged('lb');
                    },
                    child: Text('lb'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => node.unfocus(),
                    child: Text('Done'),
                  ),
                ],
              );
            },
          ],
        ),
      ],
    );
  }
}
