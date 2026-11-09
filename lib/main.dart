import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'providers/authors_provider.dart';
import 'providers/books_provider.dart';
import 'screens/author_detail_screen.dart';
import 'screens/author_form_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/book_form_screen.dart';
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
    // MultiProvider: deja los providers disponibles para toda la app (el estado de libros y autores).
    // Los ".." llaman a loadBooks / loadAuthors nada más crearlos, para pedir los datos a la API.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BooksProvider()..loadBooks()),
        ChangeNotifierProvider(create: (_) => AuthorsProvider()..loadAuthors()),
      ],
      // GetMaterialApp = MaterialApp de GetX. Añade las rutas con nombre (routing)
      child: GetMaterialApp(
        title: 'Backoffice Autores y Libros',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
        ),
        initialRoute: '/',
        // Las mismas rutas que teníamos en Expo Router.
        // OJO con el orden: '/books/new' tiene que ir antes que '/books/:id'
        getPages: [
          GetPage(name: '/', page: () => const HomeScreen()),
          GetPage(name: '/books/new', page: () => const BookFormScreen()),
          GetPage(name: '/books/:id/edit', page: () => const BookFormScreen()),
          GetPage(name: '/books/:id', page: () => const BookDetailScreen()),
          GetPage(name: '/authors/new', page: () => const AuthorFormScreen()),
          GetPage(name: '/authors/:id/edit', page: () => const AuthorFormScreen()),
          GetPage(name: '/authors/:id', page: () => const AuthorDetailScreen()),
        ],
      ),
    );
  }
}
