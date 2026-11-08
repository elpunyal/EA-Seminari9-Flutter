import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Esto es lo que antes era el hook usePermissions.ts.
// En Flutter no hay hooks, así que lo hago con una clase normal.
class PermissionsService {
  final ImagePicker _picker = ImagePicker();

  PermissionStatus? cameraStatus;
  PermissionStatus? mediaLibraryStatus;

  // Alerta cuando el usuario no da permiso (antes Alert.alert)
  Future<void> _showDeniedDialog(BuildContext context, String title, String message, bool blocked) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(blocked ? 'Cancelar' : 'Entendido'),
          ),
          // si está bloqueado, dejamos abrir los ajustes del móvil
          if (blocked)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              child: const Text('Abrir Ajustes'),
            ),
        ],
      ),
    );
  }

  // Pedir permiso para la cámara
  Future<bool> requestCameraPermission(BuildContext context) async {
    // en la web el navegador ya pide el permiso solo
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    cameraStatus = status;

    if (!status.isGranted) {
      final blocked = status.isPermanentlyDenied;
      await _showDeniedDialog(
        context,
        'Permiso de Cámara Denegado',
        blocked
            ? 'Los permisos están bloqueados en los ajustes de tu teléfono. Puedes activarlos en Ajustes.'
            : 'Necesitamos permiso de la cámara para hacer la foto del libro o autor.',
        blocked,
      );
      return false;
    }
    return true;
  }

  // Pedir permiso para la galería
  Future<bool> requestMediaLibraryPermission(BuildContext context) async {
    if (kIsWeb) return true;

    // En Android image_picker no necesita permiso para la galería
    if (defaultTargetPlatform == TargetPlatform.android) {
      mediaLibraryStatus = PermissionStatus.granted;
      return true;
    }

    final status = await Permission.photos.request();
    mediaLibraryStatus = status;

    // limited significa que solo deja ver algunas fotos, también vale
    if (!status.isGranted && !status.isLimited) {
      final blocked = status.isPermanentlyDenied;
      await _showDeniedDialog(
        context,
        'Permiso de Galería Denegado',
        blocked
            ? 'Permiso desactivado. Puedes activarlo en los ajustes del dispositivo.'
            : 'Necesitamos permiso para elegir una imagen de tu galería.',
        blocked,
      );
      return false;
    }
    return true;
  }

  // Abrir la cámara. Devuelve la ruta de la foto o null si cancela
  Future<String?> takePhoto(BuildContext context) async {
    if (!await requestCameraPermission(context)) return null;

    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    return file?.path;
  }

  // Abrir la galería para elegir una foto
  Future<String?> pickImage(BuildContext context) async {
    if (!await requestMediaLibraryPermission(context)) return null;

    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    return file?.path;
  }
}
