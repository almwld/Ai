import 'dart:async';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel(AppConstants.methodChannel);
  
  // Singleton pattern
  static final NativeBridge _instance = NativeBridge._internal();
  factory NativeBridge() => _instance;
  NativeBridge._internal();
  
  // Execute system command
  static Future<Map<String, dynamic>> executeCommand(
    String command, {
    Map<String, dynamic> params = const {},
  }) async {
    try {
      final result = await _channel.invokeMethod('executeCommand', {
        'command': command,
        'params': params,
      });
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.message ?? 'Unknown error',
        'code': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Check permissions
  static Future<Map<String, bool>> checkPermissions() async {
    try {
      final result = await _channel.invokeMethod('checkPermissions');
      return Map<String, bool>.from(result ?? {});
    } catch (e) {
      return {};
    }
  }
  
  // Request permission
  static Future<bool> requestPermission(String type) async {
    try {
      final result = await _channel.invokeMethod('requestPermission', {
        'type': type,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // Accessibility Service
  static Future<String> getScreenText() async {
    try {
      final result = await _channel.invokeMethod('getScreenText');
      return result ?? '';
    } catch (e) {
      return '';
    }
  }
  
  static Future<bool> performClick(String text) async {
    try {
      final result = await _channel.invokeMethod('performClick', {
        'text': text,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> isAccessibilityEnabled() async {
    try {
      final result = await _channel.invokeMethod('isAccessibilityEnabled');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // Open Settings
  static Future<bool> openAccessibilitySettings() async {
    try {
      final result = await _channel.invokeMethod('openAccessibilitySettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> openNotificationSettings() async {
    try {
      final result = await _channel.invokeMethod('openNotificationSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> openBatteryOptimizationSettings() async {
    try {
      final result = await _channel.invokeMethod('openBatteryOptimizationSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> ignoreBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod('ignoreBatteryOptimizations');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> openAppSettings() async {
    try {
      final result = await _channel.invokeMethod('openAppSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> openWifiSettings() async {
    try {
      final result = await _channel.invokeMethod('openWifiSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> openBluetoothSettings() async {
    try {
      final result = await _channel.invokeMethod('openBluetoothSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> openLocationSettings() async {
    try {
      final result = await _channel.invokeMethod('openLocationSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> openDisplaySettings() async {
    try {
      final result = await _channel.invokeMethod('openDisplaySettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> openSoundSettings() async {
    try {
      final result = await _channel.invokeMethod('openSoundSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // Device Info
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  static Future<Map<String, dynamic>> getBatteryStatus() async {
    try {
      final result = await _channel.invokeMethod('getBatteryStatus');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final result = await _channel.invokeMethod('getStorageInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  static Future<Map<String, dynamic>> getMemoryInfo() async {
    try {
      final result = await _channel.invokeMethod('getMemoryInfo');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Installed Apps
  static Future<Map<String, dynamic>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      return Map<String, dynamic>.from(result ?? {});
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Convenience methods for common commands
  static Future<Map<String, dynamic>> openApp(String packageName) async {
    return executeCommand('OPEN_APP', params: {'packageName': packageName});
  }
  
  static Future<Map<String, dynamic>> closeApp(String packageName) async {
    return executeCommand('CLOSE_APP', params: {'packageName': packageName});
  }
  
  static Future<Map<String, dynamic>> makeCall(String phoneNumber) async {
    return executeCommand('MAKE_CALL', params: {'phoneNumber': phoneNumber});
  }
  
  static Future<Map<String, dynamic>> sendSms(String phoneNumber, String message) async {
    return executeCommand('SEND_SMS', params: {
      'phoneNumber': phoneNumber,
      'message': message,
    });
  }
  
  static Future<Map<String, dynamic>> toggleWifi(bool enable) async {
    return executeCommand('TOGGLE_WIFI', params: {'enable': enable});
  }
  
  static Future<Map<String, dynamic>> toggleBluetooth(bool enable) async {
    return executeCommand('TOGGLE_BLUETOOTH', params: {'enable': enable});
  }
  
  static Future<Map<String, dynamic>> setBrightness(int level) async {
    return executeCommand('SET_BRIGHTNESS', params: {'level': level});
  }
  
  static Future<Map<String, dynamic>> setVolume(int level, {int stream = 3}) async {
    return executeCommand('SET_VOLUME', params: {
      'level': level,
      'stream': stream,
    });
  }
  
  static Future<Map<String, dynamic>> listFiles(String path) async {
    return executeCommand('LIST_FILES', params: {'path': path});
  }
  
  static Future<Map<String, dynamic>> createFolder(String path) async {
    return executeCommand('CREATE_FOLDER', params: {'path': path});
  }
  
  static Future<Map<String, dynamic>> deleteFile(String path) async {
    return executeCommand('DELETE_FILE', params: {'path': path});
  }
  
  static Future<Map<String, dynamic>> playMedia(String path) async {
    return executeCommand('PLAY_MEDIA', params: {'path': path});
  }
  
  static Future<Map<String, dynamic>> pauseMedia() async {
    return executeCommand('PAUSE_MEDIA');
  }
  
  static Future<Map<String, dynamic>> nextTrack() async {
    return executeCommand('NEXT_TRACK');
  }
  
  static Future<Map<String, dynamic>> previousTrack() async {
    return executeCommand('PREVIOUS_TRACK');
  }
  
  static Future<Map<String, dynamic>> takePhoto() async {
    return executeCommand('TAKE_PHOTO');
  }
  
  static Future<Map<String, dynamic>> getBatteryStatusCmd() async {
    return executeCommand('BATTERY_STATUS');
  }
  
  static Future<Map<String, dynamic>> getStorageInfoCmd() async {
    return executeCommand('STORAGE_INFO');
  }
  
  static Future<Map<String, dynamic>> getMemoryInfoCmd() async {
    return executeCommand('MEMORY_INFO');
  }
  
  static Future<Map<String, dynamic>> clearRam() async {
    return executeCommand('CLEAR_RAM');
  }
  
  static Future<Map<String, dynamic>> closeAllApps() async {
    return executeCommand('CLOSE_ALL_APPS');
  }
  
  static Future<Map<String, dynamic>> readScreen() async {
    return executeCommand('READ_SCREEN');
  }
  
  static Future<Map<String, dynamic>> increaseFontSize() async {
    return executeCommand('INCREASE_FONT');
  }
  
  static Future<Map<String, dynamic>> decreaseFontSize() async {
    return executeCommand('DECREASE_FONT');
  }
  
  static Future<Map<String, dynamic>> toggleSilentMode(bool enable) async {
    return executeCommand('TOGGLE_SILENT', params: {'enable': enable});
  }
  
  static Future<Map<String, dynamic>> toggleDndMode(bool enable) async {
    return executeCommand('TOGGLE_DND', params: {'enable': enable});
  }
}
