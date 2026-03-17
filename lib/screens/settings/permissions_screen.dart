import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../services/native_bridge.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  Map<String, bool> _permissions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissions = await NativeBridge.checkPermissions();
    setState(() {
      _permissions = permissions;
      _isLoading = false;
    });
  }

  Future<void> _requestPermission(String type) async {
    final result = await NativeBridge.requestPermission(type);
    if (result) {
      await _checkPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('الصلاحيات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info card
                _buildInfoCard(),

                const SizedBox(height: 24),

                // Permissions list
                _buildSectionTitle('الصلاحيات الأساسية'),
                _buildPermissionsCard([
                  _PermissionItem(
                    icon: Icons.mic,
                    title: 'الميكروفون',
                    description: 'مطلوب للتعرف على الصوت',
                    isGranted: _permissions['recordAudio'] ?? false,
                    onRequest: () => _requestPermission('microphone'),
                  ),
                  _PermissionItem(
                    icon: Icons.phone,
                    title: 'المكالمات',
                    description: 'مطلوب لإجراء المكالمات',
                    isGranted: _permissions['makeCalls'] ?? false,
                    onRequest: () => _requestPermission('calls'),
                  ),
                  _PermissionItem(
                    icon: Icons.message,
                    title: 'الرسائل',
                    description: 'مطلوب لإرسال الرسائل',
                    isGranted: _permissions['sendSms'] ?? false,
                    onRequest: () => _requestPermission('sms'),
                  ),
                  _PermissionItem(
                    icon: Icons.contacts,
                    title: 'جهات الاتصال',
                    description: 'مطلوب للوصول لجهات الاتصال',
                    isGranted: _permissions['readContacts'] ?? false,
                    onRequest: () => _requestPermission('contacts'),
                  ),
                ]),

                const SizedBox(height: 24),

                _buildSectionTitle('الصلاحيات الإضافية'),
                _buildPermissionsCard([
                  _PermissionItem(
                    icon: Icons.location_on,
                    title: 'الموقع',
                    description: 'مطلوب للوصول للموقع',
                    isGranted: _permissions['accessLocation'] ?? false,
                    onRequest: () => _requestPermission('location'),
                  ),
                  _PermissionItem(
                    icon: Icons.storage,
                    title: 'التخزين',
                    description: 'مطلوب لقراءة وكتابة الملفات',
                    isGranted: _permissions['readStorage'] ?? false,
                    onRequest: () => _requestPermission('storage'),
                  ),
                  _PermissionItem(
                    icon: Icons.camera_alt,
                    title: 'الكاميرا',
                    description: 'مطلوب للتقاط الصور',
                    isGranted: _permissions['camera'] ?? false,
                    onRequest: () => _requestPermission('camera'),
                  ),
                  _PermissionItem(
                    icon: Icons.bluetooth,
                    title: 'البلوتوث',
                    description: 'مطلوب للتحكم بالبلوتوث',
                    isGranted: _permissions['bluetooth'] ?? false,
                    onRequest: () => _requestPermission('bluetooth'),
                  ),
                ]),

                const SizedBox(height: 24),

                // Accessibility service
                _buildSectionTitle('خدمة إمكانية الوصول'),
                _buildAccessibilityCard(),

                const SizedBox(height: 32),

                // Open settings button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => NativeBridge.openAppSettings(),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('فتح إعدادات التطبيق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cyanAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cyanAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cyanAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.cyanAccent,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'يحتاج Maestro AI إلى هذه الصلاحيات للعمل بكفاءة. يمكنك تفعيلها الآن أو لاحقاً من إعدادات الجهاز.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
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

  Widget _buildPermissionsCard(List<_PermissionItem> items) {
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
                    color: item.isGranted
                        ? AppTheme.successGreen.withOpacity(0.2)
                        : AppTheme.warningOrange.withOpacity(0.2),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isGranted ? AppTheme.successGreen : AppTheme.warningOrange,
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
                  item.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                trailing: item.isGranted
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: AppTheme.successGreen,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'مفعل',
                              style: TextStyle(
                                color: AppTheme.successGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: item.onRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cyanAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text('تفعيل'),
                      ),
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

  Widget _buildAccessibilityCard() {
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.purpleAccent.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.accessibility,
                    color: AppTheme.purpleAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'خدمة إمكانية الوصول',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مطلوبة لقراءة محتوى الشاشة وتنفيذ الإجراءات',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => NativeBridge.openAccessibilitySettings(),
                icon: const Icon(Icons.open_in_new),
                label: const Text('فتح إعدادات إمكانية الوصول'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionItem {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onRequest;

  _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onRequest,
  });
}
