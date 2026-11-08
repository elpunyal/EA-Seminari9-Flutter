import 'package:flutter/material.dart';

// Etiqueta con el rol del autor (antes RoleBadge.tsx)
class RoleBadge extends StatelessWidget {
  final String? role;

  const RoleBadge({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        // naranja claro para admin, azul claro para autor
        color: isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAdmin ? 'Administrador' : 'Autor',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isAdmin ? const Color(0xFFB45309) : const Color(0xFF4338CA),
        ),
      ),
    );
  }
}

// Etiqueta Activo / Inactivo del autor
class ActiveBadge extends StatelessWidget {
  final bool active;

  const ActiveBadge({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        active ? 'Activo' : 'Inactivo',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
        ),
      ),
    );
  }
}
