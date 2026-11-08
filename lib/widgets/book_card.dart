import 'package:flutter/material.dart';

import '../models/book.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'view_toggle.dart';

// Pinta un libro en fila compacta (lista) o en tarjeta con portada grande
// (antes BookCard.tsx). Incluye la editorial (publisher) del ejercicio.
class BookCard extends StatelessWidget {
  final Book book;
  final ViewMode viewMode;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.viewMode,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  // Nombres de los autores separados por coma
  String get _authorNames =>
      book.authors.isEmpty ? 'Sin autores' : book.authors.map((a) => a.name).join(', ');

  // Portada de prueba con el id del libro (igual que en React Native)
  String _coverUrl(int w, int h) => 'https://picsum.photos/seed/${book.id}/$w/$h';

  // Portada pequeña con las esquinas redondeadas
  Widget _cover(double w, double h, int pw, int ph) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(_coverUrl(pw, ph), width: w, height: h, fit: BoxFit.cover),
    );
  }

  // Etiqueta pequeña con el idioma
  Widget _languageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        languageName(book.language),
        style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _smallText(String text) =>
      Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textMuted));

  Widget _priceText() => Text(
        formatPrice(book.price),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
      );

  @override
  Widget build(BuildContext context) {
    return viewMode == ViewMode.list ? _buildList() : _buildCard();
  }

  // Modo lista: portada pequeña a la izquierda y botones a la derecha
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
              _cover(52, 72, 200, 300),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      _authorNames,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    // Si tiene editorial la mostramos
                    if (book.publisher != null && book.publisher!.isNotEmpty)
                      Text(
                        'Editorial: ${book.publisher}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.indigo),
                      ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _languageBadge(),
                        if (book.publishedYear != null) _smallText('${book.publishedYear}'),
                        if (book.price != null) _priceText(),
                      ],
                    ),
                  ],
                ),
              ),
              // Botones de editar y borrar
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

  // Modo tarjeta: portada grande arriba y detalles debajo
  Widget _buildCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  _coverUrl(400, 250),
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _authorNames,
                        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                      // Editorial en la tarjeta
                      if (book.publisher != null && book.publisher!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.business, size: 14, color: AppColors.indigo),
                              const SizedBox(width: 4),
                              Text(
                                'Editorial: ${book.publisher}',
                                style: const TextStyle(fontSize: 12, color: AppColors.indigo),
                              ),
                            ],
                          ),
                        ),
                      if (book.description != null && book.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            truncate(book.description, limit: 90),
                            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _languageBadge(),
                          if (book.publishedYear != null) _smallText('${book.publishedYear}'),
                          if (book.pages != null) _smallText('${book.pages} págs.'),
                          if (book.price != null) _priceText(),
                        ],
                      ),
                      if (book.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: book.tags
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.chipBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      tag,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Pie con los botones de editar y borrar
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
