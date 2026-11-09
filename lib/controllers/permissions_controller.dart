import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/permissions_service.dart';

// GETX: estado de la pantalla de permisos (antes los useState de permissions.tsx)
class PermissionsController extends GetxController {
  final _service = PermissionsService();

  final cameraStatus = Rxn<PermissionStatus>();
  final mediaLibraryStatus = Rxn<PermissionStatus>();
  final capturedImage = RxnString(); // ruta de la última foto

  Future<void> askCamera() async {
    await _service.requestCameraPermission();
    cameraStatus.value = _service.cameraStatus;
  }

  Future<void> askGallery() async {
    await _service.requestMediaLibraryPermission();
    mediaLibraryStatus.value = _service.mediaLibraryStatus;
  }

  Future<void> openCamera() async {
    final path = await _service.takePhoto();
    cameraStatus.value = _service.cameraStatus;
    if (path != null) capturedImage.value = path;
  }

  Future<void> openGallery() async {
    final path = await _service.pickImage();
    mediaLibraryStatus.value = _service.mediaLibraryStatus;
    if (path != null) capturedImage.value = path;
  }
}
