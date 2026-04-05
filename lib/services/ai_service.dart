import 'package:flutter/material.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  bool _isInitialized = false;
  
  // قاعدة البيانات المحلية للأوامر
  final Map<String, String> _commandResponses = {
    'مرحباً': 'أهلاً بك! كيف يمكنني مساعدتك اليوم؟',
    'السلام عليكم': 'وعليكم السلام ورحمة الله وبركاته',
    'كيف حالك': 'أنا بخير والحمد لله، شكراً لسؤالك',
    'شكراً': 'عفواً، هذا من دواعي سروري',
    'ما اسمك': 'أنا مساعد Maestro AI، تحت أمرك',
    'من صنعك': 'تم تطويري بواسطة فريق Maestro AI المحترف',
    'وداعاً': 'وداعاً، أتمنى لك يوماً سعيداً',
  };

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _isInitialized = true;
    debugPrint('AI Service initialized successfully');
  }

  Future<String> processCommand(String command) async {
    if (!_isInitialized) await initialize();
    
    final lowerCommand = command.toLowerCase().trim();
    
    // البحث عن تطابق في قاعدة البيانات
    for (var entry in _commandResponses.entries) {
      if (lowerCommand.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    // معالجة الأوامر الديناميكية
    if (lowerCommand.contains('افتح') || lowerCommand.contains('شغل')) {
      final appName = _extractAppName(command);
      return 'جاري فتح $appName';
    }
    
    if (lowerCommand.contains('اتصل') || lowerCommand.contains('كلم')) {
      final contact = _extractContact(command);
      return 'جاري الاتصال بـ $contact';
    }
    
    if (lowerCommand.contains('أرسل رسالة') || lowerCommand.contains('رسالة')) {
      return 'جاري فتح تطبيق الرسائل';
    }
    
    if (lowerCommand.contains('طقس') || lowerCommand.contains('الطقس')) {
      return 'درجة الحرارة اليوم 28 درجة مئوية، مشمس';
    }
    
    if (lowerCommand.contains('وقت') || lowerCommand.contains('الساعة')) {
      final now = DateTime.now();
      return 'الساعة الآن ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    }
    
    if (lowerCommand.contains('تاريخ') || lowerCommand.contains('اليوم')) {
      final now = DateTime.now();
      return 'اليوم ${now.day}/${now.month}/${now.year}';
    }
    
    return 'آسف، لم أتمكن من فهم الأمر. حاول مرة أخرى';
  }

  String _extractAppName(String command) {
    final keywords = ['افتح', 'شغل', 'فتح', 'ابدأ'];
    for (var keyword in keywords) {
      if (command.contains(keyword)) {
        return command.replaceAll(keyword, '').trim();
      }
    }
    return 'التطبيق';
  }

  String _extractContact(String command) {
    final keywords = ['اتصل', 'كلم', 'اتصل ب', 'كلم'];
    for (var keyword in keywords) {
      if (command.contains(keyword)) {
        return command.replaceAll(keyword, '').trim();
      }
    }
    return 'جهة الاتصال';
  }

  void dispose() {
    _isInitialized = false;
  }
}
