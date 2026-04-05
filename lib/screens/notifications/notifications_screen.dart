import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _notificationService.markAllAsRead();
                });
              },
            ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _notificationService.clearAll();
                });
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد إشعارات',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ستظهر الإشعارات هنا عند استلامها',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () {
                    setState(() {
                      _notificationService.markAsRead(notification['id']);
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _notificationService.deleteNotification(notification['id']);
                    });
                  },
                );
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['read'] == true;
    final time = notification['time'] as DateTime;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? AppTheme.darkCard : AppTheme.darkCard.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? Colors.white.withOpacity(0.1) : AppTheme.cyanAccent.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cyanAccent.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  notification['icon'] ?? '🔔',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'],
                    style: TextStyle(
                      color: isRead ? Colors.white.withOpacity(0.7) : Colors.white,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['body'],
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(time),
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cyanAccent,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 18),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${time.day}/${time.month}/${time.year}';
  }
}
