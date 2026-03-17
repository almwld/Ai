import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'microphone': await Permission.microphone.isGranted,
      'phone': await Permission.phone.isGranted,
      'sms': await Permission.sms.isGranted,
      'contacts': await Permission.contacts.isGranted,
      'location': await Permission.location.isGranted,
      'storage': await Permission.storage.isGranted,
      'camera': await Permission.camera.isGranted,
      'bluetooth': await Permission.bluetooth.isGranted,
    };
  }

  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophone() async {
    return await requestPermission(Permission.microphone);
  }

  static Future<bool> requestPhone() async {
    return await requestPermission(Permission.phone);
  }

  static Future<bool> requestSms() async {
    return await requestPermission(Permission.sms);
  }

  static Future<bool> requestContacts() async {
    return await requestPermission(Permission.contacts);
  }

  static Future<bool> requestLocation() async {
    return await requestPermission(Permission.location);
  }

  static Future<bool> requestStorage() async {
    return await requestPermission(Permission.storage);
  }

  static Future<bool> requestCamera() async {
    return await requestPermission(Permission.camera);
  }

  static Future<bool> requestBluetooth() async {
    return await requestPermission(Permission.bluetooth);
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
