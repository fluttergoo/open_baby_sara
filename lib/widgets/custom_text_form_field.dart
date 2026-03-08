import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isNotes;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.isNotes = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscure = true;
  final FocusNode _focusNode = FocusNode();

  void _toggleObscure() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    final borderColor = isFocused 
        ? Color(0xFFBA68C8) // Daha belirgin mor (focus)
        : Color(0xFFE1BEE7); // Açık mor (normal)

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {});
      },
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword ? _obscure : false,
        validator: widget.validator,
        maxLines: widget.isNotes ? null : 1,
        minLines: widget.isNotes ? 4 : 1, // Notes için minimum 4 satır
        onChanged: widget.onChanged,
        keyboardType:
            widget.isNotes ? TextInputType.multiline : widget.keyboardType,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.black, fontSize: 16.sp),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.5,
            ),
          ),
          errorStyle: TextStyle(
            fontSize: 12.sp,
            color: Colors.redAccent,
            fontWeight: FontWeight.w500,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.5, // Kalınlık her zaman aynı, sadece renk değişiyor
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
            vertical: widget.isNotes ? 16.h : 12.h, // Notes için daha fazla padding
          ),

          floatingLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Color(0xFFBA68C8),
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),

          hintText: widget.isNotes && widget.hintText.isEmpty 
              ? 'Add any notes here...' 
              : widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16.sp,
          ),
          suffixIcon:
              widget.isPassword
                  ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: _toggleObscure,
                  )
                  : null,
        ),
      ),
    );
  }
}
