import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/author_form_controller.dart';
import '../models/author.dart';
import '../theme/app_colors.dart';
import '../widgets/error_banner.dart';
import '../widgets/field_wrapper.dart';
import '../widgets/photo_picker_section.dart';

// Formulario de autor. Igual que con los libros, juntamos crear y editar en un fichero:
// si la ruta tiene :id (/authors/:id/edit) estamos editando.
// La lógica está en AuthorFormController (GETX).
class AuthorFormScreen extends StatelessWidget {
  const AuthorFormScreen({super.key});

  Widget _roleChip(AuthorFormController c, String role) {
    final selected = c.role.value == role;
    return GestureDetector(
      onTap: () => c.role.value = role,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.chipBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          role == 'admin' ? 'Administrador' : 'Autor',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'];
    final c = Get.put(AuthorFormController(id));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(c.isEditing ? 'Editar Autor' : 'Nuevo Autor'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Obx(
        () => c.loading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: c.formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.isEditing
                            ? 'Modifica los datos del autor'
                            : 'Registra los datos del autor en la plataforma',
                        style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => c.error.value.isEmpty ? const SizedBox() : ErrorBanner(message: c.error.value)),

                      Obx(
                        () => PhotoPickerSection(
                          title: 'Foto de Perfil (Permisos Nativos)',
                          imagePath: c.avatarPath.value,
                          isAvatar: true,
                          cameraText: 'Tomar con Cámara',
                          galleryText: 'Galería de Fotos',
                          onTakePhoto: c.takePhoto,
                          onPickImage: c.pickImage,
                          onRemove: () => c.avatarPath.value = null,
                        ),
                      ),

                      FieldWrapper(
                        label: 'Nombre *',
                        child: TextFormField(
                          controller: c.nameCtrl,
                          decoration: inputDecoration('Nombre y apellidos'),
                          validator: c.validateName,
                        ),
                      ),

                      FieldWrapper(
                        label: 'Correo Electrónico *',
                        child: TextFormField(
                          controller: c.emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: inputDecoration('autor@ejemplo.com'),
                          validator: c.validateEmail,
                        ),
                      ),

                      FieldWrapper(
                        label: 'Contraseña *',
                        child: TextFormField(
                          controller: c.passwordCtrl,
                          obscureText: true, // equivale a secureTextEntry
                          decoration: inputDecoration('Mínimo 8 caracteres'),
                          validator: c.validatePassword,
                        ),
                      ),

                      FieldWrapper(
                        label: 'Confirmar Contraseña *',
                        child: TextFormField(
                          controller: c.confirmCtrl,
                          obscureText: true,
                          decoration: inputDecoration('Repite la contraseña'),
                          validator: c.validateConfirm,
                        ),
                      ),

                      FieldWrapper(
                        label: 'Nacionalidad',
                        child: TextFormField(
                          controller: c.nationalityCtrl,
                          decoration: inputDecoration('Ej. Española, Colombiana...'),
                        ),
                      ),

                      FieldWrapper(
                        label: 'Fecha de Nacimiento (AAAA-MM-DD)',
                        child: TextFormField(
                          controller: c.birthDateCtrl,
                          keyboardType: TextInputType.datetime,
                          decoration: inputDecoration('1970-05-15'),
                        ),
                      ),

                      FieldWrapper(
                        label: 'Sitio Web',
                        child: TextFormField(
                          controller: c.websiteCtrl,
                          keyboardType: TextInputType.url,
                          decoration: inputDecoration('https://...'),
                          validator: c.validateWebsite,
                        ),
                      ),

                      Obx(
                        () => FieldWrapper(
                          label: 'Rol en el sistema',
                          child: Wrap(
                            spacing: 8,
                            children: authorRoles.map((role) => _roleChip(c, role)).toList(),
                          ),
                        ),
                      ),

                      // Interruptor de autor activo (Switch como en React Native)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Autor activo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF334155),
                            ),
                          ),
                          Obx(
                            () => Switch(
                              value: c.active.value,
                              activeThumbColor: AppColors.primary,
                              onChanged: (value) => c.active.value = value,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
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
                                    c.isEditing ? 'Guardar Cambios' : 'Guardar Autor',
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
