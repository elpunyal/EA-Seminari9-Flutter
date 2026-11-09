import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../theme/app_colors.dart';
import 'authors_screen.dart';
import 'books_screen.dart';
import 'info_screen.dart';
import 'permissions_screen.dart';

// Pantalla principal con las 4 pestañas de abajo (antes app/(tabs)/_layout.tsx).
// Ahora es un StatelessWidget: la pestaña activa vive en el HomeController (GetX).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HomeController());

    // Obx se repinta solo cuando cambia c.currentIndex
    return Obx(
      () => Scaffold(
        // IndexedStack enseña solo una pantalla pero mantiene vivas las demás,
        // así no se pierde el buscador ni la lista al cambiar de pestaña.
        body: IndexedStack(
          index: c.currentIndex.value,
          children: const [
            BooksScreen(),
            AuthorsScreen(),
            PermissionsScreen(),
            InfoScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: c.currentIndex.value,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryLight,
          onDestinationSelected: c.changeTab,
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
      ),
    );
  }
}
