import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../services/stats_service.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late StatsService _statsService;

  @override
  void initState() {
    super.initState();
    _statsService = StatsService();
    _statsService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final total = _statsService.totalCommands;
    final success = _statsService.successCommands;
    final failed = _statsService.failedCommands;
    final successRate = _statsService.successRate;

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white70),
            onPressed: () => _showResetDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'إجمالي الأوامر',
                    value: total.toString(),
                    icon: Icons.touch_app,
                    color: AppTheme.cyanAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'نسبة النجاح',
                    value: '${(successRate * 100).toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'الأوامر الناجحة',
                    value: success.toString(),
                    icon: Icons.check_circle,
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'الأوامر الفاشلة',
                    value: failed.toString(),
                    icon: Icons.error,
                    color: AppTheme.errorRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الأوامر الأكثر استخداماً',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._buildTopCommands(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent commands
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'آخر الأوامر',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._buildRecentCommands(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  List<Widget> _buildTopCommands() {
    final frequency = _statsService.getCommandFrequency();
    final sorted = frequency.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5);

    if (top5.isEmpty) {
      return [
        Center(
          child: Text(
            'لا توجد بيانات كافية',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ];
    }

    return top5.map((entry) {
      final percent = (entry.value / _statsService.totalCommands) * 100;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text('${entry.value} مرة', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cyanAccent),
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildRecentCommands() {
    final history = _statsService.commandHistory.take(10).toList();

    if (history.isEmpty) {
      return [
        Center(
          child: Text(
            'لا توجد أوامر حديثة',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ];
    }

    return history.map((cmd) {
      final success = cmd['success'] as bool;
      final timestamp = DateTime.parse(cmd['timestamp'] as String);
      
      return ListTile(
        leading: Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? AppTheme.successGreen : AppTheme.errorRed,
          size: 20,
        ),
        title: Text(cmd['command'], style: const TextStyle(color: Colors.white)),
        subtitle: Text(_formatTime(timestamp), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        trailing: success
            ? const Icon(Icons.thumb_up, color: AppTheme.successGreen, size: 16)
            : const Icon(Icons.thumb_down, color: AppTheme.errorRed, size: 16),
      );
    }).toList();
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('إعادة ضبط الإحصائيات', style: TextStyle(color: Colors.white)),
        content: const Text('هل أنت متأكد من إعادة ضبط جميع الإحصائيات؟', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              _statsService.resetStats();
              setState(() {});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('إعادة ضبط'),
          ),
        ],
      ),
    );
  }
}
