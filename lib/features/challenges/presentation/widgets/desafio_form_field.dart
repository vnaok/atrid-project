
import 'package:flutter/material.dart';

class DesafioFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  final String? hint;
  final String? helperText;
  final String? Function(String?)? validator;

  final IconData? prefixIcon;
  final TextInputType keyboardType;

  final int maxLines;
  final int? minLines;
  final int? maxLength;

  final bool enabled;
  final bool obscureText;
  final bool required;

  const DesafioFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helperText,
    this.validator,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.obscureText = false,
    this.required = false,
  });

  static const Color texto = Color(0xFF292621);
  static const Color acento = Color(0xFF8B6F47);
  static const Color borde = Color(0xFFD6CEC2);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: texto,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: Color(0xFFB65346),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          enabled: enabled,
          obscureText: obscureText,
          style: const TextStyle(
            color: texto,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            prefixIcon: prefixIcon != null
                ? Icon(
              prefixIcon,
              color: acento,
              size: 20,
            )
                : null,
            filled: true,
            fillColor: enabled
                ? Colors.white
                : const Color(0xFFF0ECE5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            hintStyle: const TextStyle(
              color: Color(0xFFAAA399),
              fontSize: 13,
            ),
            helperStyle: const TextStyle(
              color: Color(0xFF777168),
              fontSize: 11,
            ),
            counterStyle: const TextStyle(
              fontSize: 11,
              color: Color(0xFF777168),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borde),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borde),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: acento,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFB65346),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFB65346),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
