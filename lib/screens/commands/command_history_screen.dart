import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/command_provider.dart';

class CommandHistoryScreen extends ConsumerWidget {
  const CommandHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commandState = ref.watch(commandProvider);
    final history = commandState.commandHistory;

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('سجل الأوامر'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showClearConfirmation(context, ref);
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final command = history[index];
                return _HistoryItem(
                  command: command,
                  onDelete: () {
                    ref.read(commandProvider.notifier).removeFromHistory(index);
                  },
                ).animate().fadeIn(delay: (index * 50).ms).slideX();
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد سجل',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الأوامر التي تنفذها ستظهر هنا',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'مسح السجل',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'هل أنت متأكد من مسح جميع الأوامر؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(commandProvider.notifier).clearHistory();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final dynamic command;
  final VoidCallback onDelete;

  const _HistoryItem({
    required this.command,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = command.success == true;
    final isError = command.success == false;

    Color statusColor;
    IconData statusIcon;

    if (isSuccess) {
      statusColor = AppTheme.successGreen;
      statusIcon = Icons.check_circle;
    } else if (isError) {
      statusColor = AppTheme.errorRed;
      statusIcon = Icons.error;
    } else {
      statusColor = AppTheme.warningOrange;
      statusIcon = Icons.pending;
    }

    return Dismissible(
      key: Key(command.timestamp.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(command.getColorValue()).withOpacity(0.2),
            ),
            child: Icon(
              _getIconData(command.getIconName()),
              color: Color(command.getColorValue()),
              size: 20,
            ),
          ),
          title: Text(
            command.getDisplayText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatTime(command.timestamp),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'منذ ثوانٍ';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'apps':
        return Icons.apps;
      case 'phone':
        return Icons.phone;
      case 'message':
        return Icons.message;
      case 'wifi':
        return Icons.wifi;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'location_on':
        return Icons.location_on;
      case 'brightness_6':
        return Icons.brightness_6;
      case 'volume_up':
        return Icons.volume_up;
      case 'play_circle':
        return Icons.play_circle;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'battery_full':
        return Icons.battery_full;
      case 'storage':
        return Icons.storage;
      case 'memory':
        return Icons.memory;
      case 'phone_android':
        return Icons.phone_android;
      case 'power_settings_new':
        return Icons.power_settings_new;
      case 'screen_share':
        return Icons.screen_share;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'folder':
        return Icons.folder;
      default:
        return Icons.assistant;
    }
  }
}
