import 'package:flutter/material.dart';

class LabeledTextFormField extends StatelessWidget {
  final TextInputType _inputType;
  final String _labelText;
  final String _hintText;
  final bool? _showPassword;
  final Function()? _toggleVisibility;
  final int? _maxLength;
  final int _maxLines;
  final String? _initialValue;
  const LabeledTextFormField({
    super.key,
    this._inputType = TextInputType.name,
    required this._labelText,
    required this._hintText,
    this._showPassword,
    this._toggleVisibility,
    this._maxLength,
    this._maxLines = 1,
    this._initialValue,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      keyboardType: _inputType,
      initialValue: _initialValue,
      obscureText: !(_showPassword ?? true),
      maxLines: _maxLines,
      maxLength: _maxLength,
      decoration: InputDecoration(
        labelText: _labelText,
        labelStyle: textTheme.labelLarge,
        hintText: _hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.tertiaryContainer,
        ),
        suffixIcon: (_showPassword == null)
            ? null
            : IconButton(
                onPressed: _toggleVisibility,
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: colorScheme.tertiaryContainer,
                ),
              ),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(40),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(40),
        ),
        counterStyle: textTheme.labelSmall,
      ),
    );
  }
}
