import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/view_toggle.dart';

// GETX: estado de la lista de autores (igual que el de libros)
class AuthorsListController extends GetxController {
  final search = ''.obs;
  final viewMode = ViewMode.list.obs;
  final searchCtrl = TextEditingController();

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }
}
