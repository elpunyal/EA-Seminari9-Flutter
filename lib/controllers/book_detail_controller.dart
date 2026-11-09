import 'package:get/get.dart';

import '../models/book.dart';
import '../services/book_service.dart';
import '../utils/format.dart';

// GETX: carga un libro para la pantalla de detalle.
class BookDetailController extends GetxController {
  final String id;
  BookDetailController(this.id);

  final book = Rxn<Book>(); // Rxn = observable que puede ser null
  final loading = true.obs;
  final error = ''.obs;

  // onInit se ejecuta al crear el controlador (como initState / useEffect)
  @override
  void onInit() {
    super.onInit();
    loadBook();
  }

  Future<void> loadBook() async {
    loading.value = true;
    error.value = '';
    try {
      book.value = await BookService.getBook(id);
    } catch (e) {
      error.value = errorMessage(e);
    }
    loading.value = false;
  }
}
