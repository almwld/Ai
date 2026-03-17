import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  
  // Stream controllers for progress
  final _progressController = StreamController<DownloadProgress>.broadcast();
  final _statusController = StreamController<DownloadStatus>.broadcast();
  
  Stream<DownloadProgress> get progressStream => _progressController.stream;
  Stream<DownloadStatus> get statusStream => _statusController.stream;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  CancelToken? _cancelToken;

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
    return await file.exists() && await file.length() > 100000000; // At least 100MB
  }

  Future<void> downloadModel({
    String? url,
    Function(double progress)? onProgress,
    Function()? onComplete,
    Function(String error)? onError,
  }) async {
    if (_isDownloading) return;

    _isDownloading = true;
    _statusController.add(DownloadStatus.downloading);
    _cancelToken = CancelToken();

    try {
      final modelUrl = url ?? AppConstants.modelUrl;
      final savePath = await getModelPath();

      await _dio.download(
        modelUrl,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            final downloadProgress = DownloadProgress(
              receivedBytes: received,
              totalBytes: total,
              progress: progress,
              speed: 0, // Could calculate actual speed
            );
            _progressController.add(downloadProgress);
            onProgress?.call(progress);
          }
        },
      );

      _statusController.add(DownloadStatus.completed);
      onComplete?.call();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _statusController.add(DownloadStatus.cancelled);
      } else {
        final errorMsg = 'Download failed: ${e.message}';
        _statusController.add(DownloadStatus.error);
        onError?.call(errorMsg);
      }
    } catch (e) {
      final errorMsg = 'Download failed: $e';
      _statusController.add(DownloadStatus.error);
      onError?.call(errorMsg);
    } finally {
      _isDownloading = false;
      _cancelToken = null;
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel('Download cancelled by user');
    _isDownloading = false;
  }

  Future<void> deleteModel() async {
    try {
      final path = await getModelPath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      _statusController.add(DownloadStatus.notStarted);
    } catch (e) {
      debugPrint('Error deleting model: $e');
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
      debugPrint('Error getting model size: $e');
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
    cancelDownload();
    _progressController.close();
    _statusController.close();
  }
}

class DownloadProgress {
  final int receivedBytes;
  final int totalBytes;
  final double progress;
  final double speed;

  DownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
    required this.progress,
    required this.speed,
  });

  String get formattedReceived => DownloadService().formatBytes(receivedBytes);
  String get formattedTotal => DownloadService().formatBytes(totalBytes);
  String get percentage => '${(progress * 100).toStringAsFixed(1)}%';

  @override
  String toString() => 
      'DownloadProgress(received: $formattedReceived, total: $formattedTotal, progress: $percentage)';
}

enum DownloadStatus {
  notStarted,
  downloading,
  paused,
  completed,
  cancelled,
  error,
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
