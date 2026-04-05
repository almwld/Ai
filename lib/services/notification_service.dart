import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => n['read'] == false).length;

  void addNotification({
    required String title,
    required String body,
    String? icon,
  }) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': title,
      'body': body,
      'icon': icon ?? '🔔',
      'time': DateTime.now(),
      'read': false,
    });
    
    if (_notifications.length > 50) {
      _notifications.removeLast();
    }
  }

  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['read'] = true;
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
  }

  void deleteNotification(int id) {
    _notifications.removeWhere((n) => n['id'] == id);
  }

  void clearAll() {
    _notifications.clear();
  }

  void showTestNotification() {
    addNotification(
      title: 'مرحباً في Maestro AI',
      body: 'تم تشغيل التطبيق بنجاح! يمكنك الآن استخدام الأوامر الصوتية',
      icon: '🎉',
    );
  }
}
