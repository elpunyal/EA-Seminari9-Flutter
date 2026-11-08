import '../models/author.dart';
import 'http_client.dart';

// Llamadas a la API de autores (igual que author.service.ts)
class AuthorService {
  /// GET /authors
  static Future<List<Author>> getAuthors() async {
    final res = await request('/authors');
    return (res['authors'] as List<dynamic>)
        .map((a) => Author.fromJson(a as Map<String, dynamic>))
        .toList();
  }

  /// GET /authors/:id
  static Future<Author> getAuthor(String id) async {
    final res = await request('/authors/$id');
    return Author.fromJson(res['author'] as Map<String, dynamic>);
  }

  /// POST /authors
  static Future<Author> createAuthor(Map<String, dynamic> payload) async {
    final res = await request('/authors', method: 'POST', body: payload);
    return Author.fromJson(res['author'] as Map<String, dynamic>);
  }

  /// PUT /authors/:id
  static Future<Author> updateAuthor(String id, Map<String, dynamic> payload) async {
    final res = await request('/authors/$id', method: 'PUT', body: payload);
    return Author.fromJson(res['author'] as Map<String, dynamic>);
  }

  /// DELETE /authors/:id
  static Future<void> deleteAuthor(String id) async {
    await request('/authors/$id', method: 'DELETE');
  }
}
