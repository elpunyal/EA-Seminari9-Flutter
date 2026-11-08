import 'package:flutter/material.dart';

import '../models/author.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'role_badge.dart';
import 'view_toggle.dart';

// Pinta un autor en fila (lista) o en tarjeta (antes AuthorCard.tsx)
class AuthorCard extends StatelessWidget {
  final Author author;
  final ViewMode viewMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AuthorCard({
    super.key,
    required this.author,
    required this.viewMode,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  // Círculo con las iniciales del autor
  Widget _avatar(double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFFE0E7FF),
      child: Text(
        initials(author.name),
        style: TextStyle(
          fontSize: size / 2.6,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF4338CA),
        ),
      ),
    );
  }

  // Fila con icono + texto para los datos del autor
  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return viewMode == ViewMode.list ? _buildList() : _buildCard();
  }

  // Modo lista compacta
  Widget _buildList() {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _avatar(46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      author.email,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RoleBadge(role: author.role),
                        if (author.nationality != null && author.nationality!.isNotEmpty)
                          Text(
                            author.nationality!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modo tarjeta destacada
  Widget _buildCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _avatar(56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              author.email,
                              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      RoleBadge(role: author.role),
                      ActiveBadge(active: author.active ?? true),
                    ],
                  ),
                  if (author.nationality != null && author.nationality!.isNotEmpty)
                    _detailRow(Icons.flag_outlined, author.nationality!),
                  if (author.birthDate != null && author.birthDate!.isNotEmpty)
                    _detailRow(
                      Icons.calendar_today_outlined,
                      'Nacimiento: ${formatDate(author.birthDate)}',
                    ),
                  if (author.website != null && author.website!.isNotEmpty)
                    _detailRow(Icons.language, author.website!),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Borrar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
