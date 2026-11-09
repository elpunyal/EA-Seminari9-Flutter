import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/book_detail_controller.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';

// Detalle de un libro (antes books/[id]/index.tsx).
// El id nos llega en la ruta (/books/:id) y lo leemos con Get.parameters
// (en Expo era useLocalSearchParams). El libro lo carga un controlador de GETX.
class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  // Cuadrito con título pequeño y valor (ISBN, idioma, año...)
  Widget _metaItem(String label, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id']!;
    final c = Get.put(BookDetailController(id));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalle del libro'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      // Obx se repinta solo cuando cambia loading, book o error
      body: Obx(() => _buildBody(c)),
    );
  }

  Widget _buildBody(BookDetailController c) {
    // 1. Cargando
    if (c.loading.value) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Cargando detalle...', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    // 2. Error o libro no encontrado
    final book = c.book.value;
    if (c.error.value.isNotEmpty || book == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
              const SizedBox(height: 8),
              const Text(
                'Error al cargar el libro',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              Text(
                c.error.value.isEmpty ? 'Libro no encontrado' : c.error.value,
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

    // 3. Libro cargado
    final authorNames = book.authors.isEmpty
        ? 'Sin autores asignados'
        : book.authors.map((a) => a.name).join(', ');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            'https://picsum.photos/seed/${book.id}/400/500',
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(authorNames, style: const TextStyle(fontSize: 15, color: AppColors.textMuted)),

                // Editorial (campo del ejercicio)
                if (book.publisher != null && book.publisher!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.business, size: 16, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 6),
                        Text(
                          'Editorial: ${book.publisher}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                // Wrap = fila que salta de línea si no cabe (era el metaGrid)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _metaItem('ISBN', book.isbn),
                    _metaItem('Idioma', languageName(book.language)),
                    if (book.publishedYear != null) _metaItem('Año', '${book.publishedYear}'),
                    if (book.pages != null) _metaItem('Páginas', '${book.pages}'),
                  ],
                ),

                if (book.price != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        const Text('Precio: ',
                            style: TextStyle(fontSize: 15, color: AppColors.textMuted)),
                        Text(
                          formatPrice(book.price),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (book.description != null && book.description!.isNotEmpty)
                  _section(
                    'Sinopsis',
                    Text(
                      book.description!,
                      style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF475569)),
                    ),
                  ),

                if (book.tags.isNotEmpty)
                  _section(
                    'Etiquetas',
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: book.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.chipBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('#$tag', style: const TextStyle(fontSize: 12)),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // vamos a editar y al volver recargamos el detalle
                      await Get.toNamed('/books/${book.id}/edit');
                      c.loadBook();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar Libro'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
