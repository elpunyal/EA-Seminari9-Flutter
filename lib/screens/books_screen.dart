import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controllers/books_list_controller.dart';
import '../models/book.dart';
import '../providers/books_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/book_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_banner.dart';
import '../widgets/search_field.dart';
import '../widgets/toast.dart';
import '../widgets/view_toggle.dart';

// Comprueba si un libro coincide con el texto del buscador.
// Como pedía el ejercicio, también se busca por editorial (publisher).
bool _matchesBook(Book book, String text) {
  final query = text.toLowerCase();
  return book.title.toLowerCase().contains(query) ||
      book.isbn.toLowerCase().contains(query) ||
      (book.publisher?.toLowerCase().contains(query) ?? false) ||
      (book.description?.toLowerCase().contains(query) ?? false);
}

// Pantalla con el catálogo de libros (antes books/index.tsx).
// Los libros vienen del PROVIDER y el buscador / la vista del controlador de GETX.
class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  // Borrar un libro tras confirmar
  Future<void> _deleteBook(Book book, BooksProvider provider) async {
    final confirmed = await confirmDialog(
      title: 'Confirmar Borrado',
      message: '¿Estás seguro de que deseas eliminar el libro "${book.title}"?',
    );
    if (!confirmed) return;

    final ok = await provider.deleteBook(book.id);
    showToast(ok ? 'Libro "${book.title}" borrado correctamente' : provider.error);
  }

  @override
  Widget build(BuildContext context) {
    // context.watch = "mira" el provider: si cambia, esta pantalla se repinta
    final provider = context.watch<BooksProvider>();
    final ui = Get.put(BooksListController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // Obx: se repinta cuando cambia el buscador o el modo de vista
          child: Obx(() {
            final search = ui.search.value.trim();
            // Lista filtrada según lo que escribe el usuario (era el useMemo)
            final filtered = search.isEmpty
                ? provider.books
                : provider.books.where((b) => _matchesBook(b, search)).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera con título y botón Nuevo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Catálogo de Libros',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            '${provider.books.length} ${provider.books.length == 1 ? 'libro' : 'libros'} en total',
                            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        // Get.toNamed = router.push con el nombre de la ruta
                        onPressed: () => Get.toNamed('/books/new'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Nuevo', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),

                // Buscador en tiempo real
                SearchField(
                  controller: ui.searchCtrl,
                  hint: 'Buscar por título, ISBN, editorial...',
                  onChanged: (value) => ui.search.value = value,
                ),

                // Botones lista / tarjetas
                ViewToggle(
                  mode: ui.viewMode.value,
                  onChange: (mode) => ui.viewMode.value = mode,
                ),

                if (provider.error.isNotEmpty) ErrorBanner(message: provider.error),

                // Spinner la primera vez, después la lista
                Expanded(
                  child: provider.loading
                      ? const Center(child: CircularProgressIndicator())
                      // RefreshIndicator = pull-to-refresh (RefreshControl en RN)
                      : RefreshIndicator(
                          onRefresh: provider.loadBooks,
                          // ListView.builder = FlatList: solo pinta lo que se ve en pantalla
                          child: filtered.isEmpty
                              ? ListView(
                                  // ListView siempre scrollable para que funcione el refresh
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    const SizedBox(height: 60),
                                    const Icon(Icons.menu_book_outlined,
                                        size: 48, color: AppColors.textSoft),
                                    const SizedBox(height: 8),
                                    Text(
                                      search.isNotEmpty
                                          ? 'Sin resultados para "$search"'
                                          : 'No hay libros registrados',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                    Text(
                                      search.isNotEmpty
                                          ? 'Prueba con otro término de búsqueda'
                                          : 'Pulsa "Nuevo" para crear uno',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSoft),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(bottom: 24),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final book = filtered[index];
                                    return BookCard(
                                      book: book,
                                      viewMode: ui.viewMode.value,
                                      onTap: () => Get.toNamed('/books/${book.id}'),
                                      onEdit: () => Get.toNamed('/books/${book.id}/edit'),
                                      onDelete: () => _deleteBook(book, provider),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
