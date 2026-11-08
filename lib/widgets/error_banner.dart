import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Cuadro rojo con el mensaje de error (se repetía en todas las pantallas)
class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        border: Border.all(color: AppColors.dangerBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13, color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
