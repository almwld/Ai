import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/model_provider.dart';

class ModelManagementScreen extends ConsumerWidget {
  const ModelManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelState = ref.watch(modelProvider);

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('إدارة النموذج'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Model info card
          _buildModelInfoCard(context, ref, modelState),

          const SizedBox(height: 24),

          // Model actions
          _buildSectionTitle('الإجراءات'),
          _buildActionsCard(context, ref, modelState),

          const SizedBox(height: 24),

          // Model info
          _buildSectionTitle('معلومات النموذج'),
          _buildModelDetailsCard(),

          const SizedBox(height: 24),

          // Performance settings
          _buildSectionTitle('إعدادات الأداء'),
          _buildPerformanceCard(),
        ],
      ),
    );
  }

  Widget _buildModelInfoCard(BuildContext context, WidgetRef ref, dynamic modelState) {
    final isDownloaded = modelState.isDownloaded;
    final isLoaded = modelState.isLoaded;

    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Model icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDownloaded
                      ? [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.7)]
                      : [AppTheme.warningOrange, AppTheme.warningOrange.withOpacity(0.7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDownloaded
                        ? AppTheme.successGreen.withOpacity(0.4)
                        : AppTheme.warningOrange.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                isDownloaded ? Icons.check_circle : Icons.cloud_off,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Model name
            const Text(
              'Llama 3.2 1B Instruct',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Model status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isLoaded
                    ? AppTheme.successGreen.withOpacity(0.2)
                    : isDownloaded
                        ? AppTheme.cyanAccent.withOpacity(0.2)
                        : AppTheme.warningOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isLoaded
                    ? 'محمل ويعمل'
                    : isDownloaded
                        ? 'محمل في الذاكرة'
                        : 'غير محمل',
                style: TextStyle(
                  color: isLoaded
                      ? AppTheme.successGreen
                      : isDownloaded
                          ? AppTheme.cyanAccent
                          : AppTheme.warningOrange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Model size
            if (isDownloaded) ...[
              Text(
                'الحجم: ${ref.read(modelProvider.notifier).getFormattedModelSize()}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, WidgetRef ref, dynamic modelState) {
    final isDownloaded = modelState.isDownloaded;
    final isLoaded = modelState.isLoaded;
    final isLoading = modelState.isLoading;

    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (!isDownloaded) ...[
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cyanAccent.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.download,
                  color: AppTheme.cyanAccent,
                ),
              ),
              title: const Text(
                'تحميل النموذج',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'تحميل من Hugging Face (~780 MB)',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () => ref.read(modelProvider.notifier).downloadModel(),
            ),
          ] else ...[
            if (!isLoaded && !isLoading)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.successGreen.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppTheme.successGreen,
                  ),
                ),
                title: const Text(
                  'تحميل في الذاكرة',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'تحميل النموذج للاستخدام',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                onTap: () => ref.read(modelProvider.notifier).loadModel(),
              ),
            if (isLoading)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.warningOrange.withOpacity(0.2),
                  ),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warningOrange),
                    ),
                  ),
                ),
                title: const Text(
                  'جاري التحميل...',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel, color: AppTheme.errorRed),
                  onPressed: () => ref.read(modelProvider.notifier).unloadModel(),
                ),
              ),
            if (isLoaded)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.errorRed.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.stop,
                    color: AppTheme.errorRed,
                  ),
                ),
                title: const Text(
                  'إيقاف النموذج',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'تفريغ النموذج من الذاكرة',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                onTap: () => ref.read(modelProvider.notifier).unloadModel(),
              ),
            const Divider(color: Colors.white10, indent: 72),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.errorRed.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.delete,
                  color: AppTheme.errorRed,
                ),
              ),
              title: const Text(
                'حذف النموذج',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'حذف ملف النموذج من الجهاز',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () => _showDeleteConfirmation(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModelDetailsCard() {
    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          _InfoTile(
            label: 'الاسم',
            value: 'Llama 3.2 1B Instruct',
          ),
          Divider(color: Colors.white10, indent: 16, endIndent: 16),
          _InfoTile(
            label: 'الإصدار',
            value: 'Q4_K_M GGUF',
          ),
          Divider(color: Colors.white10, indent: 16, endIndent: 16),
          _InfoTile(
            label: 'الحجم المتوقع',
            value: '~780 MB',
          ),
          Divider(color: Colors.white10, indent: 16, endIndent: 16),
          _InfoTile(
            label: 'المصدر',
            value: 'Hugging Face',
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'حجم السياق',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'عدد الرموز التي يمكن معالجتها',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cyanAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '1024',
                style: TextStyle(
                  color: AppTheme.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white10, indent: 16, endIndent: 16),
          ListTile(
            title: const Text(
              'عدد المسارات',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'عدد المسارات المستخدمة للمعالجة',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cyanAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '4',
                style: TextStyle(
                  color: AppTheme.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'حذف النموذج',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل أنت متأكد من حذف نموذج Llama 3.2؟ ستحتاج لإعادة تحميله لاحقاً.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(modelProvider.notifier).deleteModel();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
