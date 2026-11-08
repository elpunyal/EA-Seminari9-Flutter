import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Muestra una imagen elegida del móvil.
// En web la ruta es una URL, en móvil es un archivo.
class LocalImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;

  const LocalImage({super.key, required this.path, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final image = kIsWeb
        ? Image.network(path, width: width, height: height, fit: BoxFit.cover)
        : Image.file(File(path), width: width, height: height, fit: BoxFit.cover);
    return ClipRRect(borderRadius: BorderRadius.circular(6), child: image);
  }
}

// Bloque con la foto y los botones de cámara / galería.
// Se repite en el formulario de libros y de autores, por eso es un widget aparte.
class PhotoPickerSection extends StatelessWidget {
  final String title;
  final String? imagePath;
  final bool isAvatar; // true = icono de persona, false = icono de imagen
  final String cameraText;
  final String galleryText;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickImage;
  final VoidCallback onRemove;

  const PhotoPickerSection({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTakePhoto,
    required this.onPickImage,
    required this.onRemove,
    this.isAvatar = false,
    this.cameraText = 'Tomar Foto (Cámara)',
    this.galleryText = 'Elegir de Galería',
  });

  Widget _smallButton(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Si hay imagen la enseñamos, si no un hueco gris con icono
              if (imagePath != null)
                LocalImage(path: imagePath!, width: 60, height: 80)
              else
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isAvatar ? Icons.person_outline : Icons.image_outlined,
                    size: 30,
                    color: AppColors.textSoft,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _smallButton(Icons.camera_alt_outlined, cameraText, onTakePhoto),
                    const SizedBox(height: 6),
                    _smallButton(Icons.photo_library_outlined, galleryText, onPickImage),
                    if (imagePath != null)
                      TextButton(
                        onPressed: onRemove,
                        child: const Text(
                          'Quitar imagen',
                          style: TextStyle(fontSize: 11, color: AppColors.danger),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
