import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Etiqueta + campo + pista + error (antes era Field.tsx)
class FieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  final String? hint;
  final String? error;

  const FieldWrapper({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          child,
          if (hint != null && error == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(hint!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(error!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
            ),
        ],
      ),
    );
  }
}

// Estilo común de los campos de texto (era styles.input en React Native)
InputDecoration inputDecoration(String hint) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textSoft),
    filled: true,
    fillColor: AppColors.background,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: border(AppColors.inputBorder),
    focusedBorder: border(AppColors.primary),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger),
  );
}
