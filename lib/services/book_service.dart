import '../models/book.dart';
import '../utils/format.dart';
import 'http_client.dart';

// Llamadas a la API de libros (igual que book.service.ts)
class BookService {
  /// GET /books
  static Future<List<Book>> getBooks() async {
    final res = await request('/books');
    return (res['books'] as List<dynamic>)
        .map((b) => Book.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  /// GET /books/:id
  static Future<Book> getBook(String id) async {
    final res = await request('/books/$id');
    return Book.fromJson(res['book'] as Map<String, dynamic>);
  }

  /// POST /books
  static Future<Book> createBook(Book book) async {
    // toJson convierte el libro en mapa y removeEmpty quita los campos vacíos (para que Joi no dé 422)
    final res = await request('/books', method: 'POST', body: removeEmpty(book.toJson()));
    return Book.fromJson(res['book'] as Map<String, dynamic>);
  }

  /// PUT /books/:id
  static Future<Book> updateBook(String id, Book book) async {
    final res = await request('/books/$id', method: 'PUT', body: removeEmpty(book.toJson()));
    return Book.fromJson(res['book'] as Map<String, dynamic>);
  }

  /// DELETE /books/:id
  static Future<void> deleteBook(String id) async {
    await request('/books/$id', method: 'DELETE');
  }
}
