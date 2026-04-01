import 'package:flutter/material.dart';
import '../models/command_model.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  bool _isInitialized = false;
  String? _modelPath;

  // قائمة الأوامر المدعومة
  final Map<String, List<String>> _commandPatterns = {
    'OPEN_APP': ['افتح', 'شغل', 'فتح', 'open', 'start'],
    'CLOSE_APP': ['اغلق', 'اقفل', 'close', 'stop'],
    'MAKE_CALL': ['اتصل', 'كلم', 'call', 'phone'],
    'SEND_SMS': ['أرسل رسالة', 'ابعت رسالة', 'send sms', 'message'],
    'TOGGLE_WIFI': ['شغل الواي فاي', 'اطفي الواي فاي', 'wifi', 'الواي فاي'],
    'TOGGLE_BLUETOOTH': ['شغل البلوتوث', 'اطفي البلوتوث', 'bluetooth', 'البلوتوث'],
    'SET_BRIGHTNESS': ['زود السطوع', 'خفض السطوع', 'brightness', 'سطوع'],
    'SET_VOLUME': ['ارفع الصوت', 'خفض الصوت', 'volume', 'صوت'],
    'PLAY_MEDIA': ['شغل أغنية', 'شغل فيديو', 'play', 'music'],
    'PAUSE_MEDIA': ['وقف', 'pause', 'أوقف'],
    'NEXT_TRACK': ['التالي', 'next', 'اللي بعده'],
    'PREVIOUS_TRACK': ['السابق', 'previous', 'اللي قبله'],
    'TAKE_PHOTO': ['صور', 'التقط صورة', 'camera', 'كاميرا'],
    'GET_BATTERY': ['البطارية', 'كم البطارية', 'battery', 'شحن'],
    'STORAGE_INFO': ['المساحة', 'storage', 'تخزين'],
    'MEMORY_INFO': ['الرام', 'memory', 'ذاكرة'],
    'DEVICE_INFO': ['معلومات الجهاز', 'device info', 'عن الجهاز'],
    'READ_SCREEN': ['اقرأ الشاشة', 'read screen', 'اقرألي'],
    'CLEAR_RAM': ['نظف الذاكرة', 'clear ram', 'تنظيف'],
    'CLOSE_ALL_APPS': ['اغلق الكل', 'close all', 'مسح الكل'],
    'REBOOT': ['أعد تشغيل', 'restart', 'ريستارت'],
    'SHUTDOWN': ['اطفي', 'shutdown', 'قفل'],
    'INCREASE_FONT': ['كبر الخط', 'increase font', 'تكبير الخط'],
    'DECREASE_FONT': ['صغر الخط', 'decrease font', 'تصغير الخط'],
  };

  bool get isInitialized => _isInitialized;
  String? get modelPath => _modelPath;

  Future<void> initialize(String modelPath) async {
    _modelPath = modelPath;
    _isInitialized = true;
    debugPrint('AI Service initialized with model: $modelPath');
  }

  Future<CommandModel> processCommand(String userInput) async {
    debugPrint('Processing command: $userInput');
    return _parseCommand(userInput);
  }

  CommandModel _parseCommand(String input) {
    final lowerInput = input.toLowerCase().trim();

    for (var entry in _commandPatterns.entries) {
      for (var pattern in entry.value) {
        if (lowerInput.contains(pattern.toLowerCase())) {
          final params = _extractParams(entry.key, input, lowerInput, pattern);
          
          debugPrint('Matched command: ${entry.key} with params: $params');
          
          return CommandModel(
            originalInput: input,
            command: entry.key,
            params: params,
            confidence: 0.85,
            timestamp: DateTime.now(),
          );
        }
      }
    }

    debugPrint('No command matched for: $input');
    return CommandModel(
      originalInput: input,
      command: 'UNKNOWN',
      params: {},
      confidence: 0.0,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> _extractParams(String command, String originalInput, String lowerInput, String pattern) {
    final params = <String, dynamic>{};
    
    switch (command) {
      case 'OPEN_APP':
      case 'CLOSE_APP':
        String appName = _extractAfterCommand(originalInput, pattern);
        if (appName.isEmpty) appName = _extractAfterCommand(lowerInput, pattern);
        params['appName'] = appName.isNotEmpty ? appName : 'التطبيق';
        break;
        
      case 'MAKE_CALL':
        String contact = _extractAfterCommand(originalInput, pattern);
        if (contact.isEmpty) contact = _extractAfterCommand(lowerInput, pattern);
        if (RegExp(r'^\d+$').hasMatch(contact)) {
          params['phoneNumber'] = contact;
        } else {
          params['contactName'] = contact.isNotEmpty ? contact : 'جهة الاتصال';
        }
        break;
        
      case 'TOGGLE_WIFI':
      case 'TOGGLE_BLUETOOTH':
        params['enable'] = lowerInput.contains('شغل') || 
                           lowerInput.contains('فتح') || 
                           lowerInput.contains('on') ||
                           lowerInput.contains('enable');
        break;
        
      case 'SET_BRIGHTNESS':
      case 'SET_VOLUME':
        if (lowerInput.contains('زود') || lowerInput.contains('ارفع') || lowerInput.contains('increase')) {
          params['action'] = 'increase';
          params['value'] = 10;
        } else if (lowerInput.contains('خفض') || lowerInput.contains('قلل') || lowerInput.contains('decrease')) {
          params['action'] = 'decrease';
          params['value'] = 10;
        } else {
          params['action'] = 'set';
          params['value'] = _extractNumber(lowerInput) ?? 50;
        }
        break;
        
      case 'PLAY_MEDIA':
        if (lowerInput.contains('أغنية') || lowerInput.contains('song')) {
          params['type'] = 'song';
        } else if (lowerInput.contains('فيديو') || lowerInput.contains('video')) {
          params['type'] = 'video';
        } else {
          params['type'] = 'media';
        }
        String name = _extractAfterCommand(originalInput, pattern);
        params['name'] = name.isNotEmpty ? name : '';
        break;
    }
    
    return params;
  }

  String _extractAfterCommand(String input, String pattern) {
    final patternLower = pattern.toLowerCase();
    final inputLower = input.toLowerCase();
    final index = inputLower.indexOf(patternLower);
    
    if (index != -1) {
      String after = input.substring(index + pattern.length).trim();
      if (after.isNotEmpty) {
        return after;
      }
    }
    return '';
  }

  int? _extractNumber(String input) {
    final match = RegExp(r'(\d+)').firstMatch(input);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  List<String> getSuggestions(String partialInput) {
    if (partialInput.length < 2) return [];
    final suggestions = <String>[];
    final lowerPartial = partialInput.toLowerCase();

    _commandPatterns.forEach((command, patterns) {
      for (var pattern in patterns) {
        if (pattern.toLowerCase().contains(lowerPartial)) {
          suggestions.add(pattern);
        }
      }
    });

    return suggestions.toSet().toList()..take(5);
  }

  void dispose() {
    _isInitialized = false;
    _modelPath = null;
  }
}
