import 'package:flutter/foundation.dart';

import '../models/author.dart';
import '../services/author_service.dart';
import '../utils/format.dart';

// PROVIDER: estado de los autores (igual que BooksProvider pero para autores)
class AuthorsProvider extends ChangeNotifier {
  List<Author> authors = [];
  bool loading = true;
  String error = '';

  Future<void> loadAuthors() async {
    try {
      authors = await AuthorService.getAuthors();
      error = '';
    } catch (e) {
      error = errorMessage(e);
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> deleteAuthor(String id) async {
    try {
      await AuthorService.deleteAuthor(id);
      authors.removeWhere((a) => a.id == id);
      error = '';
      notifyListeners();
      return true;
    } catch (e) {
      error = errorMessage(e);
      notifyListeners();
      return false;
    }
  }
}
