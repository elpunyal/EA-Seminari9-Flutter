import 'package:flutter_test/flutter_test.dart';
import 'package:ea_seminari9_flutter/models/author.dart';
import 'package:ea_seminari9_flutter/models/book.dart';
import 'package:ea_seminari9_flutter/utils/format.dart';

// Tests sencillos de la serialización: fromJson (JSON -> objeto) y toJson (objeto -> JSON)
void main() {
  test('Book.fromJson lee la editorial y los autores', () {
    final book = Book.fromJson({
      '_id': 'b1',
      'title': 'Ficciones',
      'isbn': '123',
      'publisher': 'Editorial Test',
      'price': 12, // la API puede mandar un int
      'authors': [
        {'_id': 'a1', 'name': 'Borges', 'email': 'b@e.com'}
      ],
    });
    expect(book.publisher, 'Editorial Test');
    expect(book.price, 12.0);
    expect(book.authors.first.name, 'Borges');
  });

  test('Book.fromJson acepta autores como ids (respuesta al crear)', () {
    final book = Book.fromJson({
      '_id': 'b1',
      'title': 'Ficciones',
      'isbn': '123',
      'authors': ['a1', 'a2'], // la API devuelve solo los ids al crear
    });
    expect(book.authors, isEmpty); // no falla, simplemente no hay objetos Author
  });

  test('Book.toJson manda solo los ids de los autores', () {
    final book = Book(
      id: 'b1',
      title: 'Ficciones',
      isbn: '123',
      publisher: '',
      authors: [Author(id: 'a1', name: 'Borges', email: 'b@e.com')],
    );
    final json = removeEmpty(book.toJson()); // la editorial vacía se quita
    expect(json['authors'], ['a1']);
    expect(json.containsKey('publisher'), false);
    expect(json['title'], 'Ficciones');
  });

  test('Author.toJson no manda campos vacíos pero sí active=false', () {
    final json = removeEmpty(Author(
      id: '',
      name: 'Ana',
      email: 'a@e.com',
      password: '12345678',
      nationality: '',
      active: false,
    ).toJson());
    expect(json.containsKey('nationality'), false);
    expect(json['active'], false);
  });
}
