import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/book_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/book_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_banner.dart';
import '../widgets/search_field.dart';
import '../widgets/toast.dart';
import '../widgets/view_toggle.dart';
import 'book_detail_screen.dart';
import 'book_form_screen.dart';

// Pantalla con el catálogo de libros (antes books/index.tsx)
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  // Estado de la pantalla (en React eran los useState)
  List<Book> _books = [];
  bool _loading = true;
  String _error = '';
  String _search = '';
  ViewMode _viewMode = ViewMode.list;
  final _searchController = TextEditingController();

  // initState es como useEffect(() => {...}, []): se ejecuta una vez al crear la pantalla
  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  // Liberamos el controller cuando se cierra la pantalla
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Pedir los libros a la API
  Future<void> _loadBooks() async {
    try {
      final books = await BookService.getBooks();
      setState(() {
        _books = books;
        _error = '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  // Comprueba si un libro coincide con el texto del buscador.
  // Como pedía el ejercicio, también se busca por editorial (publisher).
  bool _matchesBook(Book book, String text) {
    final query = text.toLowerCase();
    return book.title.toLowerCase().contains(query) ||
        book.isbn.toLowerCase().contains(query) ||
        (book.publisher?.toLowerCase().contains(query) ?? false) ||
        (book.description?.toLowerCase().contains(query) ?? false);
  }

  // Lista filtrada según lo que escribe el usuario (era el useMemo)
  List<Book> get _filteredBooks {
    if (_search.trim().isEmpty) return _books;
    return _books.where((b) => _matchesBook(b, _search.trim())).toList();
  }

  // Borrar un libro tras confirmar
  Future<void> _deleteBook(Book book) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Confirmar Borrado',
      message: '¿Estás seguro de que deseas eliminar el libro "${book.title}"?',
    );
    if (!confirmed) return;

    try {
      await BookService.deleteBook(book.id);
      if (!mounted) return;
      // quitamos el libro de la lista local sin volver a pedir todo
      setState(() => _books.removeWhere((b) => b.id == book.id));
      showToast(context, 'Libro "${book.title}" borrado correctamente');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorMessage(e));
      showToast(context, errorMessage(e));
    }
  }

  // Navegar a otra pantalla. En Flutter usamos Navigator.push (en Expo era router.push).
  // Con await esperamos a que vuelva y recargamos la lista por si hubo cambios.
  Future<void> _goTo(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBooks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
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
                          '${_books.length} ${_books.length == 1 ? 'libro' : 'libros'} en total',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _goTo(const BookFormScreen()),
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
                controller: _searchController,
                hint: 'Buscar por título, ISBN, editorial...',
                onChanged: (value) => setState(() => _search = value),
              ),

              // Botones lista / tarjetas
              ViewToggle(
                mode: _viewMode,
                onChange: (mode) => setState(() => _viewMode = mode),
              ),

              if (_error.isNotEmpty) ErrorBanner(message: _error),

              // Spinner la primera vez, después la lista
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    // RefreshIndicator = pull-to-refresh (RefreshControl en RN)
                    : RefreshIndicator(
                        onRefresh: _loadBooks,
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
                                    _search.isNotEmpty
                                        ? 'Sin resultados para "$_search"'
                                        : 'No hay libros registrados',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                  Text(
                                    _search.isNotEmpty
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
                                    viewMode: _viewMode,
                                    onTap: () => _goTo(BookDetailScreen(bookId: book.id)),
                                    onEdit: () => _goTo(BookFormScreen(bookId: book.id)),
                                    onDelete: () => _deleteBook(book),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
