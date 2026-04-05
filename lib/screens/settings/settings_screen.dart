import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('عام'),
          _buildSettingsCard([
            _SettingsItem(
              icon: Icons.language,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.dark_mode,
              title: 'الوضع المظلم',
              subtitle: 'مفعل',
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.cyanAccent,
              ),
            ),
            _SettingsItem(
              icon: Icons.notifications,
              title: 'الإشعارات',
              subtitle: 'مفعلة',
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.cyanAccent,
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('الصوت'),
          _buildSettingsCard([
            _SettingsItem(
              icon: Icons.mic,
              title: 'الميكروفون',
              subtitle: 'تمت الموافقة',
              trailing: const Icon(Icons.check_circle, color: AppTheme.successGreen),
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.volume_up,
              title: 'مستوى الصوت',
              subtitle: 'متوسط',
              trailing: Slider(
                value: 0.5,
                onChanged: (value) {},
                activeColor: AppTheme.cyanAccent,
                min: 0,
                max: 1,
                divisions: 10,
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('حول التطبيق'),
          _buildSettingsCard([
            _SettingsItem(
              icon: Icons.info,
              title: 'الإصدار',
              subtitle: '1.0.0',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.privacy_tip,
              title: 'سياسة الخصوصية',
              subtitle: 'اقرأ المزيد',
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingsItem> items) {
    return Card(
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  child: Icon(item.icon, color: AppTheme.cyanAccent, size: 20),
                ),
                title: Text(item.title, style: const TextStyle(color: Colors.white)),
                subtitle: Text(item.subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                trailing: item.trailing ?? (item.onTap != null ? const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16) : null),
                onTap: item.onTap,
              ),
              if (index < items.length - 1) Divider(color: Colors.white.withOpacity(0.1), indent: 72),
            ],
          );
        }).toList(),
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
