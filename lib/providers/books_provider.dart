import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../services/book_service.dart';
import '../utils/format.dart';

// PROVIDER: estado de los libros que comparten varias pantallas
// (la lista, el detalle y los formularios). Es lo que antes era el hook useApiList.
// ChangeNotifier avisa con notifyListeners() y las pantallas que lo "miran" se repintan.
class BooksProvider extends ChangeNotifier {
  List<Book> books = [];
  bool loading = true; // true solo la primera vez (el spinner)
  String error = '';

  // Pedir los libros a la API
  Future<void> loadBooks() async {
    try {
      books = await BookService.getBooks();
      error = '';
    } catch (e) {
      error = errorMessage(e);
    }
    loading = false;
    notifyListeners();
  }

  // Borrar un libro. Devuelve true si ha ido bien.
  Future<bool> deleteBook(String id) async {
    try {
      await BookService.deleteBook(id);
      // quitamos el libro de la lista local sin volver a pedir todo
      books.removeWhere((b) => b.id == id);
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
