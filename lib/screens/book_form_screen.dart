import 'package:flutter/material.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../services/author_service.dart';
import '../services/book_service.dart';
import '../services/permissions_service.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/error_banner.dart';
import '../widgets/field_wrapper.dart';
import '../widgets/photo_picker_section.dart';
import '../widgets/toast.dart';

// Formulario de libro. En React Native había dos ficheros (new.tsx y [id]/edit.tsx);
// aquí uso uno solo: si me pasan bookId es EDITAR, si no es CREAR.
class BookFormScreen extends StatefulWidget {
  final String? bookId;

  const BookFormScreen({super.key, this.bookId});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  // La key del Form sirve para validar todos los campos de golpe
  final _formKey = GlobalKey<FormState>();

  // Un controller por cada campo de texto (en RN era form.values + handleChangeText)
  final _titleCtrl = TextEditingController();
  final _isbnCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController(); // Editorial (ejercicio)
  final _descriptionCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _pagesCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  // Campos que no son de texto
  List<String> _selectedAuthors = [];
  List<String> _selectedTags = [];
  String _language = 'es';

  List<Author> _authors = []; // autores disponibles para elegir
  String? _coverPath; // foto elegida (solo se muestra, como en React Native)
  final _permissions = PermissionsService();

  bool _loading = true; // cargando autores / libro
  bool _saving = false;
  bool _submitted = false; // para enseñar el error de los autores solo tras pulsar Guardar
  String _error = '';

  bool get _isEditing => widget.bookId != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _isbnCtrl.dispose();
    _publisherCtrl.dispose();
    _descriptionCtrl.dispose();
    _yearCtrl.dispose();
    _pagesCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // Carga los autores y, si estamos editando, el libro para precargar el formulario
  Future<void> _loadData() async {
    try {
      final authors = await AuthorService.getAuthors();
      Book? book;
      if (_isEditing) {
        book = await BookService.getBook(widget.bookId!);
      }
      setState(() {
        _authors = authors;
        if (book != null) {
          // Rellenamos el formulario (era el fill() del useForm), incluida la editorial
          _titleCtrl.text = book.title;
          _isbnCtrl.text = book.isbn;
          _publisherCtrl.text = book.publisher ?? '';
          _descriptionCtrl.text = book.description ?? '';
          _yearCtrl.text = book.publishedYear?.toString() ?? '';
          _pagesCtrl.text = book.pages?.toString() ?? '';
          _priceCtrl.text = book.price?.toString() ?? '';
          _selectedAuthors = book.authors.map((a) => a.id).toList();
          _selectedTags = List<String>.from(book.tags);
          _language = book.language ?? 'es';
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  // Marcar / desmarcar un autor o una etiqueta
  void _toggleAuthor(String id) {
    setState(() {
      _selectedAuthors.contains(id) ? _selectedAuthors.remove(id) : _selectedAuthors.add(id);
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      _selectedTags.contains(tag) ? _selectedTags.remove(tag) : _selectedTags.add(tag);
    });
  }

  Future<void> _takePhoto() async {
    final path = await _permissions.takePhoto(context);
    if (path != null) setState(() => _coverPath = path);
  }

  Future<void> _pickImage() async {
    final path = await _permissions.pickImage(context);
    if (path != null) setState(() => _coverPath = path);
  }

  // ---- Validaciones (mismas reglas que validate() de React Native) ----
  String? _validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.trim().isEmpty) return null; // es opcional
    final year = int.tryParse(value.trim());
    if (year == null || year < 1450 || year > 2100) return 'Año entre 1450 y 2100';
    return null;
  }

  String? _validatePages(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final pages = int.tryParse(value.trim());
    if (pages == null || pages < 1) return 'Mínimo 1 página';
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final price = double.tryParse(value.trim().replaceAll(',', '.'));
    if (price == null || price < 0) return 'El precio no puede ser negativo';
    return null;
  }

  // Enviar el formulario a la API
  Future<void> _handleSubmit() async {
    setState(() => _submitted = true);

    final formOk = _formKey.currentState!.validate();
    if (!formOk || _selectedAuthors.isEmpty) {
      showToast(context, 'Por favor, revisa los errores del formulario');
      return;
    }

    // Montamos el mapa que mandamos a la API. removeEmpty quita los campos vacíos
    // para que la API (Joi) no dé error 422.
    final payload = removeEmpty({
      'title': _titleCtrl.text.trim(),
      'isbn': _isbnCtrl.text.trim(),
      'publisher': _publisherCtrl.text.trim(), // editorial: si está vacía se quita
      'authors': _selectedAuthors,
      'description': _descriptionCtrl.text.trim(),
      'publishedYear': int.tryParse(_yearCtrl.text.trim()),
      'pages': int.tryParse(_pagesCtrl.text.trim()),
      'language': _language,
      'tags': _selectedTags,
      'price': double.tryParse(_priceCtrl.text.trim().replaceAll(',', '.')),
    });

    setState(() {
      _saving = true;
      _error = '';
    });

    try {
      if (_isEditing) {
        await BookService.updateBook(widget.bookId!, payload);
      } else {
        await BookService.createBook(payload);
      }
      if (!mounted) return;
      showToast(context, _isEditing ? 'Libro actualizado correctamente' : '¡Libro creado con éxito!');
      Navigator.pop(context); // volvemos atrás (router.back())
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(e);
        _saving = false;
      });
    }
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Libro' : 'Nuevo Libro'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                // los errores se van enseñando mientras el usuario escribe
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEditing
                          ? 'Modifica los datos del libro'
                          : 'Rellena los campos para añadir un libro al catálogo',
                      style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),

                    if (_error.isNotEmpty) ErrorBanner(message: _error),

                    // Foto de portada con permisos de cámara / galería
                    PhotoPickerSection(
                      title: 'Foto de Portada (Permisos de Cámara/Galería)',
                      imagePath: _coverPath,
                      onTakePhoto: _takePhoto,
                      onPickImage: _pickImage,
                      onRemove: () => setState(() => _coverPath = null),
                    ),

                    FieldWrapper(
                      label: 'Título *',
                      child: TextFormField(
                        controller: _titleCtrl,
                        decoration: inputDecoration('Ej. Don Quijote de la Mancha'),
                        validator: (v) => _validateRequired(v, 'El título es obligatorio'),
                      ),
                    ),

                    FieldWrapper(
                      label: 'ISBN *',
                      child: TextFormField(
                        controller: _isbnCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: inputDecoration('Ej. 978-84-376-0494-7'),
                        validator: (v) => _validateRequired(v, 'El ISBN es obligatorio'),
                      ),
                    ),

                    // Campo Editorial añadido por el ejercicio
                    FieldWrapper(
                      label: 'Editorial (Publisher)',
                      hint: 'Nombre de la casa editorial',
                      child: TextFormField(
                        controller: _publisherCtrl,
                        decoration: inputDecoration('Ej. Editorial Cátedra / Planeta'),
                      ),
                    ),

                    FieldWrapper(
                      label: 'Autores *',
                      hint: 'Toca los autores para seleccionarlos',
                      error: _submitted && _selectedAuthors.isEmpty ? 'Elige al menos un autor' : null,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _authors
                            .map(
                              (a) => _chip(
                                a.name,
                                _selectedAuthors.contains(a.id),
                                () => _toggleAuthor(a.id),
                                icon: _selectedAuthors.contains(a.id)
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    FieldWrapper(
                      label: 'Descripción',
                      child: TextFormField(
                        controller: _descriptionCtrl,
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
                              controller: _yearCtrl,
                              keyboardType: TextInputType.number,
                              decoration: inputDecoration('1605'),
                              validator: _validateYear,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FieldWrapper(
                            label: 'Páginas',
                            child: TextFormField(
                              controller: _pagesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: inputDecoration('450'),
                              validator: _validatePages,
                            ),
                          ),
                        ),
                      ],
                    ),

                    FieldWrapper(
                      label: 'Idioma',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: bookLanguages
                            .map(
                              (lang) => _chip(
                                languageName(lang),
                                _language == lang,
                                () => setState(() => _language = lang),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    FieldWrapper(
                      label: 'Etiquetas (Tags)',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: bookTags
                            .map((tag) => _chip('#$tag', _selectedTags.contains(tag), () => _toggleTag(tag)))
                            .toList(),
                      ),
                    ),

                    FieldWrapper(
                      label: 'Precio (€)',
                      child: TextFormField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: inputDecoration('19.99'),
                        validator: _validatePrice,
                      ),
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // si está guardando, onPressed null desactiva el botón
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
                                _isEditing ? 'Guardar Cambios' : 'Guardar Libro',
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
