import 'package:flutter/material.dart';

import '../models/author.dart';
import '../services/author_service.dart';
import '../services/permissions_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/error_banner.dart';
import '../widgets/field_wrapper.dart';
import '../widgets/photo_picker_section.dart';
import '../widgets/toast.dart';

// Formulario de autor. Igual que con los libros, juntamos crear y editar en un fichero:
// si hay authorId estamos editando.
class AuthorFormScreen extends StatefulWidget {
  final String? authorId;

  const AuthorFormScreen({super.key, this.authorId});

  @override
  State<AuthorFormScreen> createState() => _AuthorFormScreenState();
}

class _AuthorFormScreenState extends State<AuthorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  bool _active = true;
  String _role = 'author';

  String? _avatarPath;
  final _permissions = PermissionsService();

  bool _loading = false;
  bool _saving = false;
  String _error = '';

  bool get _isEditing => widget.authorId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loading = true;
      _loadAuthor();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _birthDateCtrl.dispose();
    _nationalityCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  // Al editar, pedimos el autor y rellenamos el formulario
  // (la contraseña no se precarga, igual que en React Native)
  Future<void> _loadAuthor() async {
    try {
      final author = await AuthorService.getAuthor(widget.authorId!);
      setState(() {
        _nameCtrl.text = author.name;
        _emailCtrl.text = author.email;
        // nos quedamos con AAAA-MM-DD (los 10 primeros caracteres)
        final birth = author.birthDate ?? '';
        _birthDateCtrl.text = birth.length >= 10 ? birth.substring(0, 10) : birth;
        _nationalityCtrl.text = author.nationality ?? '';
        _websiteCtrl.text = author.website ?? '';
        _active = author.active ?? true;
        _role = author.role ?? 'author';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    final path = await _permissions.takePhoto(context);
    if (path != null) setState(() => _avatarPath = path);
  }

  Future<void> _pickImage() async {
    final path = await _permissions.pickImage(context);
    if (path != null) setState(() => _avatarPath = path);
  }

  // ---- Validaciones (mismas que en React Native) ----
  String? _validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'El email es obligatorio';
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v.trim())) return 'Email no válido';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) {
      return _isEditing ? 'La contraseña es obligatoria para actualizar' : 'La contraseña es obligatoria';
    }
    if (v.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Repite la contraseña';
    if (v != _passwordCtrl.text) return 'Las contraseñas no coinciden';
    return null;
  }

  String? _validateWebsite(String? v) {
    if (v == null || v.trim().isEmpty) return null; // opcional
    if (!RegExp(r'^https?://\S+$').hasMatch(v.trim())) return 'Debe empezar por http:// o https://';
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      showToast(context, 'Por favor, revisa los errores');
      return;
    }

    // No mandamos confirmPassword a la API. removeEmpty quita los campos en blanco.
    final payload = removeEmpty({
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'birthDate': _birthDateCtrl.text.trim(),
      'nationality': _nationalityCtrl.text.trim(),
      'website': _websiteCtrl.text.trim(),
      'active': _active,
      'role': _role,
    });

    setState(() {
      _saving = true;
      _error = '';
    });

    try {
      if (_isEditing) {
        await AuthorService.updateAuthor(widget.authorId!, payload);
      } else {
        await AuthorService.createAuthor(payload);
      }
      if (!mounted) return;
      showToast(context, _isEditing ? 'Autor actualizado correctamente' : '¡Autor creado con éxito!');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(e);
        _saving = false;
      });
    }
  }

  Widget _roleChip(String role) {
    final selected = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Autor' : 'Nuevo Autor'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing
                          ? 'Modifica los datos del autor'
                          : 'Registra los datos del autor en la plataforma',
                      style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    if (_error.isNotEmpty) ErrorBanner(message: _error),

                    PhotoPickerSection(
                      title: 'Foto de Perfil (Permisos Nativos)',
                      imagePath: _avatarPath,
                      isAvatar: true,
                      cameraText: 'Tomar con Cámara',
                      galleryText: 'Galería de Fotos',
                      onTakePhoto: _takePhoto,
                      onPickImage: _pickImage,
                      onRemove: () => setState(() => _avatarPath = null),
                    ),

                    FieldWrapper(
                      label: 'Nombre *',
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: inputDecoration('Nombre y apellidos'),
                        validator: _validateName,
                      ),
                    ),

                    FieldWrapper(
                      label: 'Correo Electrónico *',
                      child: TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: inputDecoration('autor@ejemplo.com'),
                        validator: _validateEmail,
                      ),
                    ),

                    FieldWrapper(
                      label: 'Contraseña *',
                      child: TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true, // equivale a secureTextEntry
                        decoration: inputDecoration('Mínimo 8 caracteres'),
                        validator: _validatePassword,
                      ),
                    ),

                    FieldWrapper(
                      label: 'Confirmar Contraseña *',
                      child: TextFormField(
                        controller: _confirmCtrl,
                        obscureText: true,
                        decoration: inputDecoration('Repite la contraseña'),
                        validator: _validateConfirm,
                      ),
                    ),

                    FieldWrapper(
                      label: 'Nacionalidad',
                      child: TextFormField(
                        controller: _nationalityCtrl,
                        decoration: inputDecoration('Ej. Española, Colombiana...'),
                      ),
                    ),

                    FieldWrapper(
                      label: 'Fecha de Nacimiento (AAAA-MM-DD)',
                      child: TextFormField(
                        controller: _birthDateCtrl,
                        keyboardType: TextInputType.datetime,
                        decoration: inputDecoration('1970-05-15'),
                      ),
                    ),

                    FieldWrapper(
                      label: 'Sitio Web',
                      child: TextFormField(
                        controller: _websiteCtrl,
                        keyboardType: TextInputType.url,
                        decoration: inputDecoration('https://...'),
                        validator: _validateWebsite,
                      ),
                    ),

                    FieldWrapper(
                      label: 'Rol en el sistema',
                      child: Wrap(
                        spacing: 8,
                        children: authorRoles.map(_roleChip).toList(),
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
                        Switch(
                          value: _active,
                          activeThumbColor: AppColors.primary,
                          onChanged: (value) => setState(() => _active = value),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _isEditing ? 'Guardar Cambios' : 'Guardar Autor',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
