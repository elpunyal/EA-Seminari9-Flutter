import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../providers/books_provider.dart';
import '../services/author_service.dart';
import '../services/book_service.dart';
import '../services/permissions_service.dart';
import '../utils/format.dart';
import '../widgets/toast.dart';

// GETX: toda la lógica del formulario de libro (crear y editar).
// Antes esto era el hook useForm + los useState de new.tsx / edit.tsx.
class BookFormController extends GetxController {
  final String? bookId; // si es null estamos creando; si no, editando
  BookFormController(this.bookId);

  bool get isEditing => bookId != null;

  // La key del Form sirve para validar todos los campos de golpe
  final formKey = GlobalKey<FormState>();

  // Un controller por cada campo de texto
  final titleCtrl = TextEditingController();
  final isbnCtrl = TextEditingController();
  final publisherCtrl = TextEditingController(); // Editorial (ejercicio)
  final descriptionCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final pagesCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  // Campos observables (al cambiar, se repintan los Obx que los lean)
  final selectedAuthors = <String>[].obs;
  final selectedTags = <String>[].obs;
  final language = 'es'.obs;
  final authors = <Author>[].obs; // autores disponibles para elegir
  final coverPath = RxnString(); // foto elegida (solo se muestra, como en React Native)

  final loading = true.obs;
  final saving = false.obs;
  final submitted = false.obs; // para enseñar el error de los autores solo tras pulsar Guardar
  final error = ''.obs;

  final _permissions = PermissionsService();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    isbnCtrl.dispose();
    publisherCtrl.dispose();
    descriptionCtrl.dispose();
    yearCtrl.dispose();
    pagesCtrl.dispose();
    priceCtrl.dispose();
    super.onClose();
  }

  // Carga los autores y, si estamos editando, el libro para precargar el formulario
  Future<void> loadData() async {
    try {
      authors.value = await AuthorService.getAuthors();
      if (isEditing) {
        final book = await BookService.getBook(bookId!);
        // Rellenamos el formulario (era el fill() del useForm), incluida la editorial
        titleCtrl.text = book.title;
        isbnCtrl.text = book.isbn;
        publisherCtrl.text = book.publisher ?? '';
        descriptionCtrl.text = book.description ?? '';
        yearCtrl.text = book.publishedYear?.toString() ?? '';
        pagesCtrl.text = book.pages?.toString() ?? '';
        priceCtrl.text = book.price?.toString() ?? '';
        selectedAuthors.value = book.authors.map((a) => a.id).toList();
        selectedTags.value = List<String>.from(book.tags);
        language.value = book.language ?? 'es';
      }
    } catch (e) {
      error.value = errorMessage(e);
    }
    loading.value = false;
  }

  // Marcar / desmarcar un autor o una etiqueta
  void toggleAuthor(String id) {
    selectedAuthors.contains(id) ? selectedAuthors.remove(id) : selectedAuthors.add(id);
  }

  void toggleTag(String tag) {
    selectedTags.contains(tag) ? selectedTags.remove(tag) : selectedTags.add(tag);
  }

  Future<void> takePhoto() async {
    final path = await _permissions.takePhoto();
    if (path != null) coverPath.value = path;
  }

  Future<void> pickImage() async {
    final path = await _permissions.pickImage();
    if (path != null) coverPath.value = path;
  }

  // ---- Validaciones (mismas reglas que validate() de React Native) ----
  String? validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) return null; // es opcional
    final year = int.tryParse(value.trim());
    if (year == null || year < 1450 || year > 2100) return 'Año entre 1450 y 2100';
    return null;
  }

  String? validatePages(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final pages = int.tryParse(value.trim());
    if (pages == null || pages < 1) return 'Mínimo 1 página';
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final price = double.tryParse(value.trim().replaceAll(',', '.'));
    if (price == null || price < 0) return 'El precio no puede ser negativo';
    return null;
  }

  // Enviar el formulario a la API
  Future<void> submit() async {
    submitted.value = true;

    final formOk = formKey.currentState!.validate();
    if (!formOk || selectedAuthors.isEmpty) {
      showToast('Por favor, revisa los errores del formulario');
      return;
    }

    // Montamos el libro con los datos del formulario.
    // En authors solo hacen falta los ids (toJson los convierte).
    final book = Book(
      id: bookId ?? '',
      title: titleCtrl.text.trim(),
      isbn: isbnCtrl.text.trim(),
      publisher: publisherCtrl.text.trim(), // editorial: si está vacía el servicio la quita
      authors: authors.where((a) => selectedAuthors.contains(a.id)).toList(),
      description: descriptionCtrl.text.trim(),
      publishedYear: int.tryParse(yearCtrl.text.trim()),
      pages: int.tryParse(pagesCtrl.text.trim()),
      language: language.value,
      tags: selectedTags.toList(),
      price: double.tryParse(priceCtrl.text.trim().replaceAll(',', '.')),
    );

    saving.value = true;
    error.value = '';

    try {
      if (isEditing) {
        await BookService.updateBook(bookId!, book);
      } else {
        await BookService.createBook(book);
      }
      // le pedimos al provider que vuelva a cargar los libros para que la lista se actualice
      Provider.of<BooksProvider>(Get.context!, listen: false).loadBooks();
      Get.back(); // volvemos atrás (router.back())
      showToast(isEditing ? 'Libro actualizado correctamente' : '¡Libro creado con éxito!');
    } catch (e) {
      error.value = errorMessage(e);
      saving.value = false;
    }
  }
}
