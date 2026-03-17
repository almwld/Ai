import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> getAppSupportDirectory() async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  static Future<String> getTempDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  static Future<String> getExternalDirectory() async {
    final directory = await getExternalStorageDirectory();
    return directory?.path ?? await getAppDirectory();
  }

  static Future<bool> fileExists(String path) async {
    final file = File(path);
    return await file.exists();
  }

  static Future<bool> directoryExists(String path) async {
    final directory = Directory(path);
    return await directory.exists();
  }

  static Future<void> createDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> deleteDirectory(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  static Future<DateTime?> getFileModifiedDate(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final stat = await file.stat();
      return stat.modified;
    }
    return null;
  }

  static String formatFileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (bytes.bitLength ~/ 10).clamp(0, suffixes.length - 1);
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static Future<List<FileSystemEntity>> listDirectory(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      return await directory.list().toList();
    }
    return [];
  }

  static Future<void> copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(destinationPath);
    }
  }

  static Future<void> moveFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    if (await sourceFile.exists()) {
      await sourceFile.rename(destinationPath);
    }
  }

  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  static String getFileName(String path) {
    return path.split('/').last;
  }

  static String getFileNameWithoutExtension(String path) {
    final fileName = getFileName(path);
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) return fileName;
    return fileName.substring(0, lastDotIndex);
  }
}
