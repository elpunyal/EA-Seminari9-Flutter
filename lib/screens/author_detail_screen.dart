import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/author_detail_controller.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/role_badge.dart';

// Detalle de un autor (antes authors/[id]/index.tsx).
// Igual que el del libro: el id viene en la ruta y el controlador de GETX carga el autor.
class AuthorDetailScreen extends StatelessWidget {
  const AuthorDetailScreen({super.key});

  // Fila con icono, etiqueta y valor
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('$label ', style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id']!;
    final c = Get.put(AuthorDetailController(id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle del autor'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Obx(() => _buildBody(c)),
    );
  }

  Widget _buildBody(AuthorDetailController c) {
    if (c.loading.value) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Cargando autor...', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    final author = c.author.value;
    if (c.error.value.isNotEmpty || author == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 8),
              const Text(
                'Error al cargar autor',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              Text(
                c.error.value.isEmpty ? 'Autor no encontrado' : c.error.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => Get.back(), child: const Text('Volver')),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de arriba con avatar, nombre y etiquetas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFE0E7FF),
                  child: Text(
                    initials(author.name),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4338CA),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  author.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                Text(author.email, style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    RoleBadge(role: author.role),
                    ActiveBadge(active: author.active ?? true),
                  ],
                ),
              ],
            ),
          ),

          // Datos personales
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos Personales',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                _infoRow(
                  Icons.flag_outlined,
                  'Nacionalidad:',
                  (author.nationality ?? '').isEmpty ? 'No especificada' : author.nationality!,
                ),
                _infoRow(
                  Icons.calendar_today_outlined,
                  'Nacimiento:',
                  formatDate(author.birthDate).isEmpty
                      ? 'No especificado'
                      : formatDate(author.birthDate),
                ),
                if (author.website != null && author.website!.isNotEmpty)
                  _infoRow(Icons.language, 'Web:', author.website!),
              ],
            ),
          ),

          // Biografía (solo si tiene)
          if (author.biography != null && author.biography!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Biografía',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    author.biography!,
                    style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Get.toNamed('/authors/${author.id}/edit');
                c.loadAuthor();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar Autor'),
            ),
          ),
        ],
      ),
    );
  }
}
