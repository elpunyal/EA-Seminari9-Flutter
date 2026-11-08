import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/permissions_service.dart';
import '../theme/app_colors.dart';
import '../widgets/photo_picker_section.dart';

// Pantalla para probar los permisos nativos (antes permissions.tsx)
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final _permissions = PermissionsService();
  String? _capturedImage;

  // Después de pedir un permiso hacemos setState para que se actualice el estado en pantalla
  Future<void> _askCamera() async {
    await _permissions.requestCameraPermission(context);
    setState(() {});
  }

  Future<void> _askGallery() async {
    await _permissions.requestMediaLibraryPermission(context);
    setState(() {});
  }

  Future<void> _openCamera() async {
    final path = await _permissions.takePhoto(context);
    setState(() {
      if (path != null) _capturedImage = path;
    });
  }

  Future<void> _openGallery() async {
    final path = await _permissions.pickImage(context);
    setState(() {
      if (path != null) _capturedImage = path;
    });
  }

  // Etiqueta de color según el estado del permiso
  Widget _statusBadge(PermissionStatus? status) {
    final granted = status != null && (status.isGranted || status.isLimited);
    final denied = status != null && !granted;

    final text = granted ? 'Concedido' : (denied ? 'Denegado' : 'Sin pedir');
    final bg = granted
        ? const Color(0xFFDCFCE7)
        : (denied ? const Color(0xFFFEE2E2) : AppColors.chipBg);
    final fg = granted
        ? const Color(0xFF15803D)
        : (denied ? const Color(0xFFB91C1C) : AppColors.textMuted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _statusRow(IconData icon, String name, String desc, PermissionStatus? status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.chipBg,
            child: Icon(icon, size: 20, color: const Color(0xFF334155)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  // Botón de prueba (primary = azul relleno, si no = azul claro)
  Widget _actionButton(String text, IconData icon, VoidCallback onTap, {bool primary = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary ? AppColors.primary : AppColors.primaryLight,
            foregroundColor: primary ? Colors.white : AppColors.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: Icon(icon, size: 18),
          label: Text(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Permisos Nativos'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permisos Nativos y los Platform Channels',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
            ),
            const SizedBox(height: 4),
            const Text(
              'Explicación sencilla de cómo Flutter habla con el móvil para pedir permisos.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            // Tarjeta explicativa (en React Native hablaba del Bridge)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.memory, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '¿Qué son los Platform Channels y por qué pedimos permisos?',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'En Flutter el código Dart dibuja la interfaz con su propio motor gráfico, '
                    'pero la cámara y las fotos son cosas del sistema (Android o iOS).',
                    style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Los Platform Channels son el canal por el que Dart envía mensajes al código '
                    'nativo (es lo parecido al Bridge de React Native). Los paquetes '
                    'permission_handler e image_picker ya usan estos canales por nosotros: '
                    'le piden permiso al usuario y nos devuelven la respuesta.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Estado de los Permisos en tu Teléfono',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            _statusRow(Icons.camera_alt, 'Cámara', 'Para hacer fotos de portadas o autores',
                _permissions.cameraStatus),
            _statusRow(Icons.photo_library, 'Galería de Fotos',
                'Para seleccionar imágenes guardadas', _permissions.mediaLibraryStatus),

            const SizedBox(height: 16),
            const Text(
              'Botones de Prueba',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _actionButton('1. Pedir Permiso de Cámara', Icons.verified_user_outlined, _askCamera),
            _actionButton('2. Pedir Permiso de Galería', Icons.verified_user_outlined, _askGallery),
            _actionButton('3. Abrir Cámara y Hacer Foto', Icons.camera_alt_outlined, _openCamera,
                primary: true),
            _actionButton(
                '4. Abrir Galería y Elegir Foto', Icons.photo_library_outlined, _openGallery,
                primary: true),

            if (_capturedImage != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Última imagen elegida',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Center(child: LocalImage(path: _capturedImage!, width: 200, height: 260)),
            ],
          ],
        ),
      ),
    );
  }
}
