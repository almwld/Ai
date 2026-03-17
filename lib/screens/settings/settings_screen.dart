import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/model_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelState = ref.watch(modelProvider);

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Model Status Section
          _buildSectionTitle('نموذج الذكاء الاصطناعي'),
          _buildModelCard(context, ref, modelState),

          const SizedBox(height: 24),

          // Permissions Section
          _buildSectionTitle('الصلاحيات'),
          _buildSettingsCard([
            _SettingsItem(
              icon: Icons.security,
              title: 'إدارة الصلاحيات',
              subtitle: 'التحكم في صلاحيات التطبيق',
              onTap: () => Navigator.pushNamed(context, '/permissions'),
            ),
            _SettingsItem(
              icon: Icons.accessibility,
              title: 'خدمة إمكانية الوصول',
              subtitle: 'تفعيل خدمة إمكانية الوصول',
              onTap: () => Navigator.pushNamed(context, '/permissions'),
            ),
          ]),

          const SizedBox(height: 24),

          // Apps Section
          _buildSectionTitle('التطبيقات'),
          _buildSettingsCard([
            _SettingsItem(
              icon: Icons.apps,
              title: 'إدارة التطبيقات',
              subtitle: 'عرض وإدارة التطبيقات المثبتة',
              onTap: () => Navigator.pushNamed(context, '/apps_management'),
            ),
          ]),

          const SizedBox(height: 24),

          // General Settings
          _buildSectionTitle('عام'),
          _buildSettingsCard([
            _SettingsItem(
              icon: Icons.language,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () {
                // TODO: Language selection
              },
            ),
            _SettingsItem(
              icon: Icons.notifications,
              title: 'الإشعارات',
              subtitle: 'تفعيل الإشعارات',
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.cyanAccent,
              ),
            ),
            _SettingsItem(
              icon: Icons.volume_up,
              title: 'الصوت',
              subtitle: 'تفعيل التعليق الصوتي',
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.cyanAccent,
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // About Section
          _buildSectionTitle('حول'),
          _buildSettingsCard([
            _SettingsItem(
              icon: Icons.info,
              title: 'عن التطبيق',
              subtitle: 'Maestro AI v1.0.0',
              onTap: () {
                _showAboutDialog(context);
              },
            ),
            _SettingsItem(
              icon: Icons.privacy_tip,
              title: 'سياسة الخصوصية',
              subtitle: 'قراءة سياسة الخصوصية',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.help,
              title: 'المساعدة',
              subtitle: 'كيفية استخدام التطبيق',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 32),

          // Reset button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showResetConfirmation(context),
              icon: const Icon(Icons.restore),
              label: const Text('إعادة ضبط التطبيق'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorRed,
                side: const BorderSide(color: AppTheme.errorRed),
                padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildModelCard(BuildContext context, WidgetRef ref, dynamic modelState) {
    final isDownloaded = modelState.isDownloaded;
    final isDownloading = modelState.isDownloading;

    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDownloaded
                        ? AppTheme.successGreen.withOpacity(0.2)
                        : AppTheme.warningOrange.withOpacity(0.2),
                  ),
                  child: Icon(
                    isDownloaded ? Icons.check_circle : Icons.cloud_download,
                    color: isDownloaded ? AppTheme.successGreen : AppTheme.warningOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDownloaded ? 'النموذج محمل' : 'النموذج غير محمل',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDownloaded
                            ? 'Llama 3.2 - ${ref.read(modelProvider.notifier).getFormattedModelSize()}'
                            : 'مطلوب للحصول على أفضل أداء',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isDownloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: modelState.downloadProgress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cyanAccent),
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 8),
              Text(
                '${(modelState.downloadProgress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isDownloading
                        ? () => ref.read(modelProvider.notifier).cancelDownload()
                        : isDownloaded
                            ? () => _showDeleteModelConfirmation(context, ref)
                            : () => ref.read(modelProvider.notifier).downloadModel(),
                    icon: Icon(isDownloading
                        ? Icons.cancel
                        : isDownloaded
                            ? Icons.delete
                            : Icons.download),
                    label: Text(isDownloading
                        ? 'إلغاء'
                        : isDownloaded
                            ? 'حذف'
                            : 'تحميل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDownloaded ? AppTheme.errorRed : AppTheme.cyanAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (isDownloaded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/model_management'),
                      icon: const Icon(Icons.settings),
                      label: const Text('إدارة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.cyanAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingsItem> items) {
    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cyanAccent.withOpacity(0.2),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppTheme.cyanAccent,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                trailing: item.trailing ??
                    (item.onTap != null
                        ? const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white54,
                            size: 16,
                          )
                        : null),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                Divider(
                  color: Colors.white.withOpacity(0.1),
                  indent: 72,
                  height: 1,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Center(
          child: Text(
            'Maestro AI',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.cyanAccent, AppTheme.purpleAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyanAccent.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'مساعد ذكي يتحكم في هاتفك عبر الأوامر الصوتية',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 Maestro AI',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showDeleteModelConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'حذف النموذج',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل أنت متأكد من حذف نموذج الذكاء الاصطناعي؟ ستحتاج لإعادة تحميله لاحقاً.',
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

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'إعادة ضبط التطبيق',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل أنت متأكد من إعادة ضبط التطبيق؟ سيتم حذف جميع البيانات والإعدادات.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Reset app
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('إعادة ضبط'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });
}
