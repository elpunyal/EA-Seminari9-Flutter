import 'package:flutter/material.dart';

// Aviso corto abajo de la pantalla (antes era ToastContext.tsx).
// En Flutter ya existe el SnackBar, así que no hace falta un Provider propio.
void showToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar(); // quitamos el anterior si había
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: const Color(0xFF1E293B),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 2500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
    ),
  );
}
