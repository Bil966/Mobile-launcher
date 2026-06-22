import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> hasStorageAccess() =>
      Permission.manageExternalStorage.isGranted;

  Future<bool> requestStorageAccess() async {
    if (await hasStorageAccess()) return true;

    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    await openAppSettings();
    return hasStorageAccess();
  }
}
