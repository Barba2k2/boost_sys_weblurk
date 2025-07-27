import 'package:flutter/material.dart';
import '../app_colors.dart';

class BoostTextFormField extends StatefulWidget {
  const BoostTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;
  final bool obscureText;

  @override
  State<BoostTextFormField> createState() => _BoostTextFormFieldState();
}

class _BoostTextFormFieldState extends State<BoostTextFormField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      style: const TextStyle(
        fontFamily: 'Ibrand',
        color: AppColors.cardHeaderText,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(
          fontFamily: 'Ibrand',
          color: AppColors.cardHeaderText,
        ),
        fillColor: AppColors.translucentField,
        filled: true,
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: AppColors.cardHeaderText,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.cardHeaderText,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.cardHeaderText,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.cardHeaderText,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.cardHeaderText,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.cardHeaderText,
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Ibrand',
          color: AppColors.cardHeaderText,
        ),
      ),
    );
  }
}
