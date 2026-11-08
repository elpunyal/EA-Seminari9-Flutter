import 'package:flutter/foundation.dart';

// Igual que environment.ts de React Native:
// calcula la URL de la API según la plataforma.
class Environment {
  // Se puede cambiar al arrancar: flutter run --dart-define=API_URL=http://192.168.1.10:1337
  // (en React Native era la variable EXPO_PUBLIC_API_URL)
  static const String _envApiUrl = String.fromEnvironment('API_URL');

  static String get apiUrl {
    if (_envApiUrl.isNotEmpty) return _envApiUrl;

    // En el emulador de Android, localhost es el propio móvil,
    // por eso se usa 10.0.2.2 para llegar al ordenador.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:1337';
    }
    // iOS, web y escritorio
    return 'http://localhost:1337';
  }
}
