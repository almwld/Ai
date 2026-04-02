import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  Future<String> getModelPath() async {
    final directory = await getApplicationSupportDirectory();
    final modelsDir = Directory('${directory.path}/models');
    
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    
    return '${modelsDir.path}/${AppConstants.modelFileName}';
  }

  Future<bool> isModelDownloaded() async {
    final path = await getModelPath();
    final file = File(path);
    return await file.exists() && await file.length() > 100000000;
  }

  Future<void> downloadModel({
    Function(double progress)? onProgress,
    Function()? onComplete,
    Function(String error)? onError,
  }) async {
    if (_isDownloading) return;

    _isDownloading = true;

    try {
      final savePath = await getModelPath();
      
      // Simulate download for now
      for (double i = 0; i <= 1; i += 0.1) {
        await Future.delayed(const Duration(milliseconds: 100));
        onProgress?.call(i);
      }
      
      // Create an empty file to mark as downloaded
      final file = File(savePath);
      await file.writeAsString('Mock model file');
      
      onComplete?.call();
    } catch (e) {
      onError?.call('Download failed: $e');
    } finally {
      _isDownloading = false;
    }
  }

  void cancelDownload() {
    _isDownloading = false;
  }

  Future<void> deleteModel() async {
    try {
      final path = await getModelPath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting model: $e');
    }
  }

  Future<int> getModelSize() async {
    try {
      final path = await getModelPath();
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      print('Error getting model size: $e');
    }
    return 0;
  }

  String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (bytes.bitLength ~/ 10).clamp(0, suffixes.length - 1);
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  void dispose() {
    _isDownloading = false;
  }
}
