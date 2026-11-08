import 'package:flutter_test/flutter_test.dart';
import 'package:ea_seminari8_flutter/utils/format.dart';

// Test sencillo de las funciones de formato
void main() {
  test('formato y removeEmpty', () {
    expect(initials('Miguel de Cervantes'), 'MC');
    expect(formatDate('2020-05-15T00:00:00.000Z'), '15/05/2020');
    expect(formatPrice(19.5), '19.50 €');
    expect(truncate('a' * 100, limit: 10), 'aaaaaaaaaa...');
    expect(removeEmpty({'a': '', 'b': ' ', 'c': null, 'd': 'x', 'e': []}), {'d': 'x', 'e': []});
  });
}
