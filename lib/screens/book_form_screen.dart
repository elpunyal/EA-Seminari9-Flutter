import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/book_form_controller.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/error_banner.dart';
import '../widgets/field_wrapper.dart';
import '../widgets/photo_picker_section.dart';

// Formulario de libro. En React Native había dos ficheros (new.tsx y [id]/edit.tsx);
// aquí uso uno solo: si la ruta tiene :id (/books/:id/edit) es EDITAR, si no es CREAR.
// Toda la lógica está en BookFormController (GETX); esta pantalla solo dibuja.
class BookFormScreen extends StatelessWidget {
  const BookFormScreen({super.key});

  // Un "chip" que se puede marcar (autores, idioma y etiquetas)
  Widget _chip(String text, bool selected, VoidCallback onTap, {IconData? icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.chipBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textMuted),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // El id viene de la ruta. Si es null estamos creando un libro nuevo.
    final id = Get.parameters['id'];
    final c = Get.put(BookFormController(id));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(c.isEditing ? 'Editar Libro' : 'Nuevo Libro'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      // Obx se repinta cuando cambia loading
      body: Obx(
        () => c.loading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: c.formKey,
                  // los errores se van enseñando mientras el usuario escribe
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.isEditing
                            ? 'Modifica los datos del libro'
                            : 'Rellena los campos para añadir un libro al catálogo',
                        style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),

                      Obx(() => c.error.value.isEmpty ? const SizedBox() : ErrorBanner(message: c.error.value)),

                      // Foto de portada con permisos de cámara / galería
                      Obx(
                        () => PhotoPickerSection(
                          title: 'Foto de Portada (Permisos de Cámara/Galería)',
                          imagePath: c.coverPath.value,
                          onTakePhoto: c.takePhoto,
                          onPickImage: c.pickImage,
                          onRemove: () => c.coverPath.value = null,
                        ),
                      ),

                      FieldWrapper(
                        label: 'Título *',
                        child: TextFormField(
                          controller: c.titleCtrl,
                          decoration: inputDecoration('Ej. Don Quijote de la Mancha'),
                          validator: (v) => c.validateRequired(v, 'El título es obligatorio'),
                        ),
                      ),

                      FieldWrapper(
                        label: 'ISBN *',
                        child: TextFormField(
                          controller: c.isbnCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: inputDecoration('Ej. 978-84-376-0494-7'),
                          validator: (v) => c.validateRequired(v, 'El ISBN es obligatorio'),
                        ),
                      ),

                      // Campo Editorial añadido por el ejercicio
                      FieldWrapper(
                        label: 'Editorial (Publisher)',
                        hint: 'Nombre de la casa editorial',
                        child: TextFormField(
                          controller: c.publisherCtrl,
                          decoration: inputDecoration('Ej. Editorial Cátedra / Planeta'),
                        ),
                      ),

                      Obx(
                        () => FieldWrapper(
                          label: 'Autores *',
                          hint: 'Toca los autores para seleccionarlos',
                          error: c.submitted.value && c.selectedAuthors.isEmpty
                              ? 'Elige al menos un autor'
                              : null,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: c.authors
                                .map(
                                  (a) => _chip(
                                    a.name,
                                    c.selectedAuthors.contains(a.id),
                                    () => c.toggleAuthor(a.id),
                                    icon: c.selectedAuthors.contains(a.id)
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),

                      FieldWrapper(
                        label: 'Descripción',
                        child: TextFormField(
                          controller: c.descriptionCtrl,
                          maxLines: 3,
                          decoration: inputDecoration('Breve sinopsis o descripción del libro...'),
                        ),
                      ),

                      // Año y páginas en la misma fila
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FieldWrapper(
                              label: 'Año de publicación',
                              child: TextFormField(
                                controller: c.yearCtrl,
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration('1605'),
                                validator: c.validateYear,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FieldWrapper(
                              label: 'Páginas',
                              child: TextFormField(
                                controller: c.pagesCtrl,
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration('450'),
                                validator: c.validatePages,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Obx(
                        () => FieldWrapper(
                          label: 'Idioma',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: bookLanguages
                                .map(
                                  (lang) => _chip(
                                    languageName(lang),
                                    c.language.value == lang,
                                    () => c.language.value = lang,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),

                      Obx(
                        () => FieldWrapper(
                          label: 'Etiquetas (Tags)',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: bookTags
                                .map((tag) => _chip(
                                      '#$tag',
                                      c.selectedTags.contains(tag),
                                      () => c.toggleTag(tag),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),

                      FieldWrapper(
                        label: 'Precio (€)',
                        child: TextFormField(
                          controller: c.priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: inputDecoration('19.99'),
                          validator: c.validatePrice,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            // si está guardando, onPressed null desactiva el botón
                            onPressed: c.saving.value ? null : c.submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: c.saving.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    c.isEditing ? 'Guardar Cambios' : 'Guardar Libro',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
