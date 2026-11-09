import 'package:get/get.dart';

import '../models/author.dart';
import '../services/author_service.dart';
import '../utils/format.dart';

// GETX: carga un autor para la pantalla de detalle.
class AuthorDetailController extends GetxController {
  final String id;
  AuthorDetailController(this.id);

  final author = Rxn<Author>();
  final loading = true.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAuthor();
  }

  Future<void> loadAuthor() async {
    loading.value = true;
    error.value = '';
    try {
      author.value = await AuthorService.getAuthor(id);
    } catch (e) {
      error.value = errorMessage(e);
    }
    loading.value = false;
  }
}
