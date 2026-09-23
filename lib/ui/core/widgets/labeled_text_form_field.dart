import 'package:flutter/material.dart';

class LabeledTextFormField extends StatelessWidget {
  final TextInputType inputType;
  final String? labelText;
  final String hintText;
  final bool? showPassword;
  final VoidCallback? toggleVisibility;
  final int? maxLength;
  final int maxLines;
  final String? initialValue;

  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final AutovalidateMode? autoValidateMode;

  const LabeledTextFormField({
    super.key,
    this.inputType = TextInputType.name,
    this.labelText,
    required this.hintText,
    this.showPassword,
    this.toggleVisibility,
    this.maxLength,
    this.maxLines = 1,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.autoValidateMode,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      initialValue: initialValue,
      obscureText: !(showPassword ?? true),
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      autovalidateMode: autoValidateMode,
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
