import 'author.dart';

// Los mismos idiomas y etiquetas que acepta la API del backend
const List<String> bookLanguages = ['es', 'ca', 'en'];
const List<String> bookTags = [
  'ciencia-ficcion',
  'fantasia',
  'novela',
  'ensayo',
  'poesia',
  'historia',
];

// Libro tal como lo devuelve la API (con los autores ya cargados).
// Incluye publisher (editorial), el campo del ejercicio.
class Book {
  final String id;
  final String title;
  final String isbn;
  final List<Author> authors;
  final int? edition;
  final String? publisher; // editorial
  final int? publishedYear;
  final int? pages;
  final String? language;
  final List<String> tags;
  final double? price;
  final String? description;

  Book({
    required this.id,
    required this.title,
    required this.isbn,
    required this.authors,
    this.edition,
    this.publisher,
    this.publishedYear,
    this.pages,
    this.language,
    this.tags = const [],
    this.price,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // authors viene como lista de objetos, los pasamos a Author
    final authors = (json['authors'] as List<dynamic>? ?? [])
        .map((a) => Author.fromJson(a))
        .toList();

    return Book(
      id: json['_id'] as String,
      title: json['title'] as String? ?? '',
      isbn: json['isbn'] as String? ?? '',
      authors: authors,
      edition: (json['edition'] as num?)?.toInt(),
      publisher: json['publisher'] as String?,
      publishedYear: (json['publishedYear'] as num?)?.toInt(),
      pages: (json['pages'] as num?)?.toInt(),
      language: json['language'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? []).map((t) => t.toString()).toList(),
      // el precio puede venir como int o double, lo pasamos siempre a double
      price: (json['price'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );
  }
}
