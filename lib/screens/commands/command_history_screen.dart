import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CommandHistoryScreen extends StatefulWidget {
  const CommandHistoryScreen({super.key});

  @override
  State<CommandHistoryScreen> createState() => _CommandHistoryScreenState();
}

class _CommandHistoryScreenState extends State<CommandHistoryScreen> {
  final List<Map<String, dynamic>> _commands = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    // تحميل من Hive لاحقاً
    setState(() {
      _commands.addAll([
        {'command': 'افتح واتساب', 'time': DateTime.now().subtract(const Duration(minutes: 5)), 'status': 'success'},
        {'command': 'شغل الواي فاي', 'time': DateTime.now().subtract(const Duration(hours: 1)), 'status': 'success'},
        {'command': 'اتصل بأحمد', 'time': DateTime.now().subtract(const Duration(hours: 2)), 'status': 'failed'},
        {'command': 'كم البطارية', 'time': DateTime.now().subtract(const Duration(days: 1)), 'status': 'success'},
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('سجل الأوامر'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: () => setState(() => _commands.clear()),
          ),
        ],
      ),
      body: _commands.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('لا يوجد سجل', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 20)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _commands.length,
              itemBuilder: (context, index) {
                final cmd = _commands[index];
                return _HistoryItem(
                  command: cmd['command'],
                  time: cmd['time'],
                  status: cmd['status'],
                );
              },
            ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String command;
  final DateTime time;
  final String status;

  const _HistoryItem({
    required this.command,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.darkCard,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: status == 'success' ? AppTheme.successGreen.withOpacity(0.2) : AppTheme.errorRed.withOpacity(0.2),
          ),
          child: Icon(
            status == 'success' ? Icons.check_circle : Icons.error,
            color: status == 'success' ? AppTheme.successGreen : AppTheme.errorRed,
            size: 20,
          ),
        ),
        title: Text(command, style: const TextStyle(color: Colors.white, fontSize: 16)),
        subtitle: Text(
          _formatTime(time),
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
