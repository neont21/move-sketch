import 'package:flutter/material.dart';

class LabeledTextFormField extends StatelessWidget {
  final TextInputType inputType;
  final String labelText;
  final String hintText;
  final bool? showPassword;
  final VoidCallback? toggleVisibility;
  final int? maxLength;
  final int maxLines;
  final String? initialValue;
  const LabeledTextFormField({
    super.key,
    this.inputType = TextInputType.name,
    required this.labelText,
    required this.hintText,
    this.showPassword,
    this.toggleVisibility,
    this.maxLength,
    this.maxLines = 1,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      keyboardType: inputType,
      initialValue: initialValue,
      obscureText: !(showPassword ?? true),
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: (showPassword == null)
            ? null
            : IconButton(
                onPressed: toggleVisibility,
                icon: Icon(
                  showPassword! ? Icons.visibility : Icons.visibility_off,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
      ),
    );
  }
}
