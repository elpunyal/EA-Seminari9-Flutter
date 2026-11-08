import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Diálogo para confirmar antes de borrar (antes era ConfirmModal.tsx).
// Devuelve true si el usuario pulsa el botón de confirmar.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Borrar',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText, style: const TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
  // si cierran el diálogo tocando fuera, result es null -> false
  return result ?? false;
}
