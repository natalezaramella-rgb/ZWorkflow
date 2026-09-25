import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An adaptive text field that renders a Material [TextFormField] on Android
/// and a [CupertinoTextField] on iOS.
class AdaptiveTextField extends StatelessWidget {
  /// Creates an adaptive text field.
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.prefix,
    this.readOnly = false,
    this.onTap,
  });

  /// Optional text editing controller.
  final TextEditingController? controller;

  /// Label for the text field (Material) or placeholder (Cupertino).
  final String? label;

  /// Placeholder text displayed when the field is empty.
  final String? placeholder;

  /// Whether the text field obscures the text (for passwords).
  final bool obscureText;

  /// The keyboard type for the text field.
  final TextInputType? keyboardType;

  /// Validator function for form validation.
  final String? Function(String?)? validator;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Maximum number of lines.
  final int maxLines;

  /// An optional prefix widget.
  final Widget? prefix;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Called when the field is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 2),
              child: Text(
                label!,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          CupertinoTextField(
            controller: controller,
            placeholder: placeholder ?? label,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            maxLines: maxLines,
            prefix: prefix,
            readOnly: readOnly,
            onTap: onTap,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      );
    }

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: prefix,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
    );
  }
}
