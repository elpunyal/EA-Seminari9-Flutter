import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

// Punto de entrada de la app (como app/_layout.tsx + index.tsx en Expo).
// main() es lo primero que se ejecuta y runApp() pinta el widget raíz.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp configura el tema y la navegación de toda la app
    return MaterialApp(
      title: 'Backoffice Autores y Libros',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const HomeScreen(),
    );
  }
}
