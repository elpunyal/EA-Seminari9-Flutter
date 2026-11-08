import 'package:flutter/material.dart';

import '../models/author.dart';
import '../services/author_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/author_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_banner.dart';
import '../widgets/search_field.dart';
import '../widgets/toast.dart';
import '../widgets/view_toggle.dart';
import 'author_detail_screen.dart';
import 'author_form_screen.dart';

// Pantalla con el listado de autores (antes authors/index.tsx).
// Es casi igual que la de libros.
class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  List<Author> _authors = [];
  bool _loading = true;
  String _error = '';
  String _search = '';
  ViewMode _viewMode = ViewMode.list;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Pedir los autores a la API
  Future<void> _loadAuthors() async {
    try {
      final authors = await AuthorService.getAuthors();
      setState(() {
        _authors = authors;
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

  // Buscamos por nombre o email
  bool _matchesAuthor(Author author, String text) {
    final query = text.toLowerCase();
    return author.name.toLowerCase().contains(query) ||
        author.email.toLowerCase().contains(query);
  }

  List<Author> get _filteredAuthors {
    if (_search.trim().isEmpty) return _authors;
    return _authors.where((a) => _matchesAuthor(a, _search.trim())).toList();
  }

  Future<void> _deleteAuthor(Author author) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Confirmar Borrado',
      message: '¿Estás seguro de que deseas eliminar al autor "${author.name}"?',
    );
    if (!confirmed) return;

    try {
      await AuthorService.deleteAuthor(author.id);
      if (!mounted) return;
      setState(() => _authors.removeWhere((a) => a.id == author.id));
      showToast(context, 'Autor "${author.name}" borrado correctamente');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = errorMessage(e));
      showToast(context, errorMessage(e));
    }
  }

  // Ir a otra pantalla y recargar la lista al volver
  Future<void> _goTo(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadAuthors();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAuthors;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Autores',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          '${_authors.length} ${_authors.length == 1 ? 'autor' : 'autores'} en total',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _goTo(const AuthorFormScreen()),
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
              SearchField(
                controller: _searchController,
                hint: 'Buscar por nombre o email...',
                onChanged: (value) => setState(() => _search = value),
              ),
              ViewToggle(
                mode: _viewMode,
                onChange: (mode) => setState(() => _viewMode = mode),
              ),
              if (_error.isNotEmpty) ErrorBanner(message: _error),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadAuthors,
                        child: filtered.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 60),
                                  const Icon(Icons.people_outline,
                                      size: 48, color: AppColors.textSoft),
                                  const SizedBox(height: 8),
                                  Text(
                                    _search.isNotEmpty
                                        ? 'Sin resultados para "$_search"'
                                        : 'No hay autores registrados',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final author = filtered[index];
                                  return AuthorCard(
                                    author: author,
                                    viewMode: _viewMode,
                                    onTap: () => _goTo(AuthorDetailScreen(authorId: author.id)),
                                    onEdit: () => _goTo(AuthorFormScreen(authorId: author.id)),
                                    onDelete: () => _deleteAuthor(author),
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
