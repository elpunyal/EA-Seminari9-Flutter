import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Aviso corto abajo de la pantalla (antes era ToastContext.tsx).
// Con GetX no hace falta pasar el context: Get.rawSnackbar lo hace solo.
void showToast(String message) {
  Get.rawSnackbar(
    messageText: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    backgroundColor: const Color(0xFF1E293B),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
    borderRadius: 24,
    duration: const Duration(milliseconds: 2500),
  );
}
