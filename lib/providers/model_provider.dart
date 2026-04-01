import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../services/download_service.dart';

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

final modelProvider = StateNotifierProvider<ModelNotifier, ModelState>((ref) {
  return ModelNotifier();
});

class ModelNotifier extends StateNotifier<ModelState> {
  final DownloadService _downloadService = DownloadService();
  late Box _settingsBox;

  ModelNotifier() : super(ModelState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    _settingsBox = Hive.box(AppConstants.settingsBox);
    final downloaded = await _downloadService.isModelDownloaded();
    final savedPath = _settingsBox.get(AppConstants.keyModelPath) as String?;
    final size = await _downloadService.getModelSize();

    state = state.copyWith(
      isDownloaded: downloaded,
      modelPath: savedPath,
      modelSize: size,
      status: downloaded ? 'Model downloaded' : 'Model not downloaded',
    );
  }

  Future<void> downloadModel() async {
    if (state.isDownloading) return;

    state = state.copyWith(
      isDownloading: true,
      downloadProgress: 0.0,
      status: 'Downloading...',
    );

    await _downloadService.downloadModel(
      onProgress: (progress) {
        state = state.copyWith(
          downloadProgress: progress,
          status: 'Downloading: ${(progress * 100).toStringAsFixed(1)}%',
        );
      },
      onComplete: () async {
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
      },
      onError: (error) {
        state = state.copyWith(
          isDownloading: false,
          downloadError: error,
          status: 'Download failed',
        );
      },
    );
  }

  void cancelDownload() {
    _downloadService.cancelDownload();
    state = state.copyWith(
      isDownloading: false,
      status: 'Download cancelled',
    );
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
      status: 'Model deleted',
    );
  }

  String getFormattedModelSize() {
    return _downloadService.formatBytes(state.modelSize);
  }

  void clearError() {
    state = state.copyWith(downloadError: null);
  }

  @override
  void dispose() {
    _downloadService.dispose();
    super.dispose();
  }
}
