import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/model_provider.dart';

class DownloadProgressScreen extends ConsumerStatefulWidget {
  const DownloadProgressScreen({super.key});

  @override
  ConsumerState<DownloadProgressScreen> createState() => _DownloadProgressScreenState();
}

class _DownloadProgressScreenState extends ConsumerState<DownloadProgressScreen> {
  bool _hasStartedDownload = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkModelStatus();
    });
  }

  void _checkModelStatus() {
    final modelState = ref.read(modelProvider);
    
    if (modelState.isDownloaded) {
      // Model already downloaded, go to home
      Navigator.pushReplacementNamed(context, '/home');
    } else if (!_hasStartedDownload) {
      // Start download
      _startDownload();
    }
  }

  void _startDownload() {
    setState(() {
      _hasStartedDownload = true;
    });
    ref.read(modelProvider.notifier).downloadModel();
  }

  void _cancelDownload() {
    ref.read(modelProvider.notifier).cancelDownload();
    setState(() {
      _hasStartedDownload = false;
    });
  }

  void _retryDownload() {
    ref.read(modelProvider.notifier).clearError();
    _startDownload();
  }

  void _skipDownload() {
    // Allow user to skip and use fallback parsing
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final modelState = ref.watch(modelProvider);

    // Listen for download completion
    if (modelState.isDownloaded && modelState.downloadProgress >= 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.cyanAccent,
                      AppTheme.cyanAccent.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cyanAccent.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  modelState.isDownloading ? Icons.downloading : Icons.cloud_download,
                  size: 60,
                  color: Colors.white,
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                  .shimmer(duration: 2.seconds),

              const SizedBox(height: 48),

              // Title
              Text(
                modelState.isDownloading
                    ? 'جاري تحميل نموذج الذكاء الاصطناعي'
                    : modelState.downloadError != null
                        ? 'فشل التحميل'
                        : 'تحميل النموذج',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                modelState.isDownloading
                    ? 'يرجى الانتظار أثناء تحميل نموذج Llama 3.2...'
                    : modelState.downloadError != null
                        ? 'حدث خطأ أثناء التحميل. يمكنك إعادة المحاولة أو تخطي هذا الخطوة.'
                        : 'للاستفادة من ميزات الذكاء الاصطناعي، نحتاج لتحميل النموذج (~780 ميجابايت)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Progress section
              if (modelState.isDownloading) ...[
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: modelState.downloadProgress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cyanAccent),
                    minHeight: 12,
                  ),
                ),

                const SizedBox(height: 16),

                // Progress text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(modelState.downloadProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppTheme.cyanAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      modelState.status,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Cancel button
                OutlinedButton.icon(
                  onPressed: _cancelDownload,
                  icon: const Icon(Icons.cancel),
                  label: const Text('إلغاء'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ] else if (modelState.downloadError != null) ...[
                // Error icon
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorRed,
                ),

                const SizedBox(height: 16),

                // Error message
                Text(
                  modelState.downloadError!,
                  style: TextStyle(
                    color: AppTheme.errorRed.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _retryDownload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cyanAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _skipDownload,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('تخطي'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Start download button
                ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('بدء التحميل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyanAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Skip button
                TextButton(
                  onPressed: _skipDownload,
                  child: const Text(
                    'تخطي التحميل',
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.5),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'يمكنك استخدام التطبيق بدون النموذج، لكن الدقة ستكون أقل. يمكنك تحميله لاحقاً من الإعدادات.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
