import 'package:get/get.dart';

// GETX: controlador de la pantalla principal.
// .obs convierte el valor en "observable": los Obx() que lo lean se repintan solos
// cuando cambia (así no hace falta setState).
class HomeController extends GetxController {
  final currentIndex = 0.obs; // pestaña seleccionada

  void changeTab(int index) => currentIndex.value = index;
}
