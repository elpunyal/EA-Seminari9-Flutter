import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Modo de vista: lista compacta o tarjetas (antes ViewToggle.tsx)
enum ViewMode { list, cards }

// Dos botones para cambiar entre lista y tarjetas
class ViewToggle extends StatelessWidget {
  final ViewMode mode;
  final ValueChanged<ViewMode> onChange;

  const ViewToggle({super.key, required this.mode, required this.onChange});

  Widget _button(IconData icon, String text, ViewMode value) {
    final selected = mode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _button(Icons.view_list, 'Lista', ViewMode.list),
          _button(Icons.grid_view, 'Tarjetas', ViewMode.cards),
        ],
      ),
    );
  }
}
