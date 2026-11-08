import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'authors_screen.dart';
import 'books_screen.dart';
import 'info_screen.dart';
import 'permissions_screen.dart';

// Pantalla principal con las 4 pestañas de abajo (antes app/(tabs)/_layout.tsx).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // pestaña seleccionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack enseña solo una pantalla pero mantiene vivas las demás,
      // así no se pierde el buscador ni la lista al cambiar de pestaña.
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          BooksScreen(),
          AuthorsScreen(),
          PermissionsScreen(),
          InfoScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryLight,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
            label: 'Libros',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppColors.primary),
            label: 'Autores',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user, color: AppColors.primary),
            label: 'Permisos',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info, color: AppColors.primary),
            label: 'Teoría',
          ),
        ],
      ),
    );
  }
}
