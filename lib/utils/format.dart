import '../services/http_client.dart';

// Funciones para dar formato a los datos (igual que format.ts)

const Map<String, String> _languageNames = {
  'es': 'Castellano',
  'ca': 'Catalán',
  'en': 'Inglés',
};

String languageName(String? code) {
  if (code == null || code.isEmpty) return '';
  return _languageNames[code] ?? code;
}

// Corta un texto largo y le añade "..."
String truncate(String? value, {int limit = 80}) {
  if (value == null || value.isEmpty) return '';
  // quitamos espacios y saltos de línea repetidos
  final clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return clean.length > limit ? '${clean.substring(0, limit).trim()}...' : clean;
}

// De "2020-05-15T00:00..." a "15/05/2020"
String formatDate(String? iso) {
  if (iso == null || iso.length < 10) return '';
  final parts = iso.substring(0, 10).split('-');
  if (parts.length != 3) return '';
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

String formatPrice(double? price) {
  if (price == null) return '';
  return '${price.toStringAsFixed(2)} €';
}

// Iniciales del nombre para el avatar (primera y última palabra)
String initials(String name) {
  final words = name.split(' ').where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '';
  final first = words.first[0];
  final last = words.length > 1 ? words.last[0] : '';
  return (first + last).toUpperCase();
}

// Mensaje de error para enseñar al usuario (como api-error.ts)
String errorMessage(Object error) {
  if (error is ApiException) return error.message;
  return 'Ha ocurrido un error inesperado';
}

// Quita los campos vacíos antes de mandar a la API (como remove-empty.ts)
// para que Joi no devuelva error 422 por campos en blanco.
Map<String, dynamic> removeEmpty(Map<String, dynamic> data) {
  final result = <String, dynamic>{};
  data.forEach((key, value) {
    final isEmpty = value == null || (value is String && value.trim().isEmpty);
    if (!isEmpty) result[key] = value;
  });
  return result;
}
