import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

// Diálogo para confirmar antes de borrar (antes era ConfirmModal.tsx).
// Devuelve true si el usuario pulsa el botón de confirmar.
// Con Get.dialog no necesitamos el context.
Future<bool> confirmDialog({
  required String title,
  required String message,
  String confirmText = 'Borrar',
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text(confirmText, style: const TextStyle(color: AppColors.danger)),
        ),
      ],
    ),
  );
  // si cierran el diálogo tocando fuera, result es null -> false
  return result ?? false;
}
