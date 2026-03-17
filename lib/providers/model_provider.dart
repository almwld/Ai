import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../services/download_service.dart';
import '../services/ai_service.dart';

final modelProvider = StateNotifierProvider<ModelNotifier, ModelState>((ref) {
  return ModelNotifier();
});

class ModelState {
  final bool isDownloaded;
  final bool isDownloading;
  final double downloadProgress;
  final String? downloadError;
  final bool isLoaded;
  final bool isLoading;
  final String? modelPath;
  final int modelSize;
  final String status;

  ModelState({
    this.isDownloaded = false,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.downloadError,
    this.isLoaded = false,
    this.isLoading = false,
    this.modelPath,
    this.modelSize = 0,
    this.status = 'Not initialized',
  });

  ModelState copyWith({
    bool? isDownloaded,
    bool? isDownloading,
    double? downloadProgress,
    String? downloadError,
    bool? isLoaded,
    bool? isLoading,
    String? modelPath,
    int? modelSize,
    String? status,
  }) {
    return ModelState(
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadError: downloadError,
      isLoaded: isLoaded ?? this.isLoaded,
      isLoading: isLoading ?? this.isLoading,
      modelPath: modelPath ?? this.modelPath,
      modelSize: modelSize ?? this.modelSize,
      status: status ?? this.status,
    );
  }
}

class ModelNotifier extends StateNotifier<ModelState> {
  final DownloadService _downloadService = DownloadService();
  final AIService _aiService = AIService();
  late Box _settingsBox;

  ModelNotifier() : super(ModelState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    _settingsBox = Hive.box(AppConstants.settingsBox);
    
    // Check if model is already downloaded
    final downloaded = await _downloadService.isModelDownloaded();
    final savedPath = _settingsBox.get(AppConstants.keyModelPath) as String?;
    final size = await _downloadService.getModelSize();

    state = state.copyWith(
      isDownloaded: downloaded,
      modelPath: savedPath,
      modelSize: size,
      status: downloaded ? 'Model downloaded' : 'Model not downloaded',
    );

    // Listen to download progress
    _downloadService.progressStream.listen((progress) {
      state = state.copyWith(
        downloadProgress: progress.progress,
        status: 'Downloading: ${progress.percentage}',
      );
    });

    // Listen to download status
    _downloadService.statusStream.listen((status) {
      switch (status) {
        case DownloadStatus.downloading:
          state = state.copyWith(isDownloading: true);
          break;
        case DownloadStatus.completed:
          _onDownloadComplete();
          break;
        case DownloadStatus.cancelled:
          state = state.copyWith(
            isDownloading: false,
            downloadProgress: 0.0,
            status: 'Download cancelled',
          );
          break;
        case DownloadStatus.error:
          state = state.copyWith(
            isDownloading: false,
            downloadError: 'Download failed',
            status: 'Download failed',
          );
          break;
        default:
          break;
      }
    });
  }

  Future<void> _onDownloadComplete() async {
    final path = await _downloadService.getModelPath();
    final size = await _downloadService.getModelSize();
    
    await _settingsBox.put(AppConstants.keyModelDownloaded, true);
    await _settingsBox.put(AppConstants.keyModelPath, path);

    state = state.copyWith(
      isDownloaded: true,
      isDownloading: false,
      downloadProgress: 1.0,
      modelPath: path,
      modelSize: size,
      status: 'Download complete',
    );
  }

  Future<void> downloadModel() async {
    if (state.isDownloading) return;

    state = state.copyWith(
      downloadError: null,
      status: 'Starting download...',
    );

    await _downloadService.downloadModel(
      onProgress: (progress) {
        // Progress is handled by stream listener
      },
      onComplete: () {
        // Completion is handled by stream listener
      },
      onError: (error) {
        state = state.copyWith(
          downloadError: error,
          status: 'Download error: $error',
        );
      },
    );
  }

  Future<void> cancelDownload() async {
    _downloadService.cancelDownload();
  }

  Future<void> deleteModel() async {
    await _downloadService.deleteModel();
    await _settingsBox.put(AppConstants.keyModelDownloaded, false);
    await _settingsBox.delete(AppConstants.keyModelPath);

    state = state.copyWith(
      isDownloaded: false,
      isLoaded: false,
      modelPath: null,
      modelSize: 0,
      downloadProgress: 0.0,
      status: 'Model deleted',
    );
  }

  Future<void> loadModel() async {
    if (state.isLoaded || state.isLoading) return;
    if (!state.isDownloaded || state.modelPath == null) {
      state = state.copyWith(
        downloadError: 'Model not downloaded',
        status: 'Model not downloaded',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      status: 'Loading model...',
    );

    try {
      await _aiService.initialize(state.modelPath!);
      
      state = state.copyWith(
        isLoaded: true,
        isLoading: false,
        status: 'Model loaded successfully',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        downloadError: 'Failed to load model: $e',
        status: 'Failed to load model',
      );
    }
  }

  Future<void> unloadModel() async {
    _aiService.dispose();
    
    state = state.copyWith(
      isLoaded: false,
      status: 'Model unloaded',
    );
  }

  String getFormattedModelSize() {
    return _downloadService.formatBytes(state.modelSize);
  }

  String getFormattedTotalSize() {
    return _downloadService.formatBytes(AppConstants.modelSizeMB * 1024 * 1024);
  }

  void clearError() {
    state = state.copyWith(downloadError: null);
  }

  @override
  void dispose() {
    _downloadService.dispose();
    _aiService.dispose();
    super.dispose();
  }
}
