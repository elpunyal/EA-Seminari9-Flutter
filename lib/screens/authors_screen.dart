import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controllers/authors_list_controller.dart';
import '../models/author.dart';
import '../providers/authors_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/author_card.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_banner.dart';
import '../widgets/search_field.dart';
import '../widgets/toast.dart';
import '../widgets/view_toggle.dart';

// Buscamos por nombre o email
bool _matchesAuthor(Author author, String text) {
  final query = text.toLowerCase();
  return author.name.toLowerCase().contains(query) ||
      author.email.toLowerCase().contains(query);
}

// Pantalla con el listado de autores (antes authors/index.tsx).
// Es casi igual que la de libros: Provider para los datos y GetX para el buscador.
class AuthorsScreen extends StatelessWidget {
  const AuthorsScreen({super.key});

  Future<void> _deleteAuthor(Author author, AuthorsProvider provider) async {
    final confirmed = await confirmDialog(
      title: 'Confirmar Borrado',
      message: '¿Estás seguro de que deseas eliminar al autor "${author.name}"?',
    );
    if (!confirmed) return;

    final ok = await provider.deleteAuthor(author.id);
    showToast(ok ? 'Autor "${author.name}" borrado correctamente' : provider.error);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthorsProvider>();
    final ui = Get.put(AuthorsListController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            final search = ui.search.value.trim();
            final filtered = search.isEmpty
                ? provider.authors
                : provider.authors.where((a) => _matchesAuthor(a, search)).toList();

            return Column(
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
                            '${provider.authors.length} ${provider.authors.length == 1 ? 'autor' : 'autores'} en total',
                            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/authors/new'),
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
                  controller: ui.searchCtrl,
                  hint: 'Buscar por nombre o email...',
                  onChanged: (value) => ui.search.value = value,
                ),
                ViewToggle(
                  mode: ui.viewMode.value,
                  onChange: (mode) => ui.viewMode.value = mode,
                ),
                if (provider.error.isNotEmpty) ErrorBanner(message: provider.error),
                Expanded(
                  child: provider.loading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: provider.loadAuthors,
                          child: filtered.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    const SizedBox(height: 60),
                                    const Icon(Icons.people_outline,
                                        size: 48, color: AppColors.textSoft),
                                    const SizedBox(height: 8),
                                    Text(
                                      search.isNotEmpty
                                          ? 'Sin resultados para "$search"'
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
                                      viewMode: ui.viewMode.value,
                                      onTap: () => Get.toNamed('/authors/${author.id}'),
                                      onEdit: () => Get.toNamed('/authors/${author.id}/edit'),
                                      onDelete: () => _deleteAuthor(author, provider),
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
