import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/environment.dart';

// Clase simple para guardar los errores de la API con su código HTTP
// (en React Native era la clase ApiError que extendía Error)
class ApiException implements Exception {
  final String message;
  final int status;

  ApiException(this.message, this.status);

  @override
  String toString() => message;
}

// Función común para hacer peticiones a la API (como request() de http.ts).
// method: GET, POST, PUT o DELETE. body: mapa que se convierte a JSON.
Future<dynamic> request(
  String path, {
  String method = 'GET',
  Map<String, dynamic>? body,
}) async {
  final url = Uri.parse('${Environment.apiUrl}$path');
  final headers = <String, String>{
    'Accept': 'application/json',
    // solo mandamos Content-Type si hay cuerpo
    if (body != null) 'Content-Type': 'application/json',
  };

  http.Response res;

  try {
    // Con http.get / http.post... según el método (en JS era fetch con method)
    switch (method) {
      case 'POST':
        res = await http.post(url, headers: headers, body: jsonEncode(body));
        break;
      case 'PUT':
        res = await http.put(url, headers: headers, body: jsonEncode(body));
        break;
      case 'DELETE':
        res = await http.delete(url, headers: headers);
        break;
      default:
        res = await http.get(url, headers: headers);
    }
  } catch (_) {
    // Si no conecta, avisamos de que miren si el backend está arrancado
    throw ApiException(
      'No se puede conectar con la API en $url. ¿Está arrancado el backend en el puerto 1337?',
      0,
    );
  }

  // Si la API responde con error (400, 404, 422...) leemos el mensaje
  if (res.statusCode < 200 || res.statusCode >= 300) {
    String message = 'Error HTTP ${res.statusCode}';
    try {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
    } catch (_) {
      // si no es JSON dejamos el mensaje por defecto
    }
    throw ApiException(message, res.statusCode);
  }

  // Un DELETE devuelve 204 (sin cuerpo), no hay JSON que leer
  if (res.statusCode == 204 || res.body.isEmpty) {
    return null;
  }

  return jsonDecode(utf8.decode(res.bodyBytes));
}
