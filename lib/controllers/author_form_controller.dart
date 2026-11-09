import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../providers/authors_provider.dart';
import '../services/author_service.dart';
import '../services/permissions_service.dart';
import '../utils/format.dart';
import '../widgets/toast.dart';

// GETX: lógica del formulario de autor (crear y editar).
class AuthorFormController extends GetxController {
  final String? authorId; // si es null estamos creando
  AuthorFormController(this.authorId);

  bool get isEditing => authorId != null;

  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final birthDateCtrl = TextEditingController();
  final nationalityCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();

  final active = true.obs;
  final role = 'author'.obs;
  final avatarPath = RxnString();

  final loading = false.obs;
  final saving = false.obs;
  final error = ''.obs;

  final _permissions = PermissionsService();

  @override
  void onInit() {
    super.onInit();
    if (isEditing) {
      loading.value = true;
      loadAuthor();
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    birthDateCtrl.dispose();
    nationalityCtrl.dispose();
    websiteCtrl.dispose();
    super.onClose();
  }

  // Al editar, pedimos el autor y rellenamos el formulario
  // (la contraseña no se precarga, igual que en React Native)
  Future<void> loadAuthor() async {
    try {
      final author = await AuthorService.getAuthor(authorId!);
      nameCtrl.text = author.name;
      emailCtrl.text = author.email;
      // nos quedamos con AAAA-MM-DD (los 10 primeros caracteres)
      final birth = author.birthDate ?? '';
      birthDateCtrl.text = birth.length >= 10 ? birth.substring(0, 10) : birth;
      nationalityCtrl.text = author.nationality ?? '';
      websiteCtrl.text = author.website ?? '';
      active.value = author.active ?? true;
      role.value = author.role ?? 'author';
    } catch (e) {
      error.value = errorMessage(e);
    }
    loading.value = false;
  }

  Future<void> takePhoto() async {
    final path = await _permissions.takePhoto();
    if (path != null) avatarPath.value = path;
  }

  Future<void> pickImage() async {
    final path = await _permissions.pickImage();
    if (path != null) avatarPath.value = path;
  }

  // ---- Validaciones (mismas que en React Native) ----
  String? validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null;

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'El email es obligatorio';
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim())) return 'Email no válido';
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) {
      return isEditing ? 'La contraseña es obligatoria para actualizar' : 'La contraseña es obligatoria';
    }
    if (v.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  String? validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Repite la contraseña';
    if (v != passwordCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  String? validateWebsite(String? v) {
    if (v == null || v.trim().isEmpty) return null; // opcional
    if (!RegExp(r'^https?://\S+$').hasMatch(v.trim())) return 'Debe empezar por http:// o https://';
    return null;
  }

  // Enviar el formulario
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      showToast('Por favor, revisa los errores');
      return;
    }

    // No mandamos confirmPassword a la API (el modelo Author ni lo tiene)
    final author = Author(
      id: authorId ?? '',
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text,
      birthDate: birthDateCtrl.text.trim(),
      nationality: nationalityCtrl.text.trim(),
      website: websiteCtrl.text.trim(),
      active: active.value,
      role: role.value,
    );

    saving.value = true;
    error.value = '';

    try {
      if (isEditing) {
        await AuthorService.updateAuthor(authorId!, author);
      } else {
        await AuthorService.createAuthor(author);
      }
      // recargamos los autores del provider para que la lista se actualice
      Provider.of<AuthorsProvider>(Get.context!, listen: false).loadAuthors();
      Get.back();
      showToast(isEditing ? 'Autor actualizado correctamente' : '¡Autor creado con éxito!');
    } catch (e) {
      error.value = errorMessage(e);
      saving.value = false;
    }
  }
}
