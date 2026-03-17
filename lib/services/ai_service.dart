import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/command_model.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  bool _isInitialized = false;
  String? _modelPath;
  
  // Learning data
  final Map<String, List<String>> _learningData = {};
  final Map<String, int> _commandFrequency = {};

  // Command patterns for Arabic language
  final Map<String, List<String>> _commandPatterns = {
    'OPEN_APP': [
      'افتح', 'شغل', 'اعرض', 'ارفع', 'شوف', 'ادخل', 'فتح', 'شغللي',
      'افتحلي', 'ابدأ', 'start', 'open'
    ],
    'CLOSE_APP': [
      'اغلق', 'اقفل', 'سكر', 'اطفي', 'وقف', 'close', 'stop'
    ],
    'MAKE_CALL': [
      'اتصل', 'كلم', 'اتصل ب', 'رن على', 'اتصل على', 'كلم', 'call'
    ],
    'SEND_SMS': [
      'أرسل رسالة', 'ابعت رسالة', 'رسالة ل', 'message to', 'send sms'
    ],
    'TOGGLE_WIFI': [
      'شغل الواي فاي', 'اطفي الواي فاي', 'فتح الواي فاي', 'قطع النت',
      'شبكة الواي فاي', 'wifi'
    ],
    'TOGGLE_BLUETOOTH': [
      'شغل البلوتوث', 'اطفي البلوتوث', 'فتح البلوتوث', 'bluetooth'
    ],
    'TOGGLE_LOCATION': [
      'شغل الموقع', 'اطفي الموقع', 'فتح الموقع', 'gps', 'location'
    ],
    'SET_BRIGHTNESS': [
      'زود السطوع', 'خفض السطوع', 'غير السطوع', 'حط السطوع',
      'brightness', 'سطوع'
    ],
    'SET_VOLUME': [
      'ارفع الصوت', 'خفض الصوت', 'زود الصوت', 'volume', 'صوت'
    ],
    'PLAY_MEDIA': [
      'شغل أغنية', 'شغل فيديو', 'شغل موسيقى', 'اعرض فيلم', 'play'
    ],
    'PAUSE_MEDIA': [
      'وقف', 'أوقف', 'pause', 'stop music'
    ],
    'NEXT_TRACK': [
      'التالي', 'اللي بعده', 'next'
    ],
    'PREVIOUS_TRACK': [
      'السابق', 'اللي قبله', 'previous'
    ],
    'TAKE_PHOTO': [
      'صور', 'التقط صورة', 'صورني', 'كاميرا', 'camera', 'photo'
    ],
    'GET_BATTERY': [
      'البطارية', 'كم البطارية', 'شحن', 'حالة البطارية', 'battery'
    ],
    'STORAGE_INFO': [
      'المساحة', 'كم المساحة', 'التخزين', 'storage'
    ],
    'MEMORY_INFO': [
      'الرام', 'الذاكرة', 'كم الرام', 'memory', 'ram'
    ],
    'DEVICE_INFO': [
      'معلومات الجهاز', 'عن الجهاز', 'device info', 'system info'
    ],
    'REBOOT': [
      'أعد تشغيل', 'ريستارت', 'restart', 'اعادة تشغيل', 'reboot'
    ],
    'SHUTDOWN': [
      'اطفي', 'قفل', 'shutdown', 'power off', 'أطفئ'
    ],
    'READ_SCREEN': [
      'اقرأ الشاشة', 'اقرألي', 'ايش مكتوب', 'read screen', 'what is on screen'
    ],
    'CLOSE_ALL_APPS': [
      'قفل التطبيقات', 'اغلق الكل', 'close all', 'مسح الخلفية', 'close apps'
    ],
    'CLEAR_RAM': [
      'نظف الذاكرة', 'تنظيف', 'clear ram', 'clean memory', 'free up memory'
    ],
    'LIST_FILES': [
      'اعرض الملفات', 'ملفاتي', 'my files', 'list files'
    ],
    'CREATE_FOLDER': [
      'أنشئ مجلد', 'مجلد جديد', 'create folder', 'new folder'
    ],
    'DELETE_FILE': [
      'احذف الملف', 'امسح الملف', 'delete file', 'remove file'
    ],
    'INCREASE_FONT': [
      'كبر الخط', 'تكبير الخط', 'increase font', 'bigger text'
    ],
    'DECREASE_FONT': [
      'صغر الخط', 'تصغير الخط', 'decrease font', 'smaller text'
    ],
    'TOGGLE_SILENT': [
      'الوضع الصامت', 'صامت', 'silent mode', 'mute'
    ],
    'TOGGLE_DND': [
      'عدم الإزعاج', 'dnd', 'do not disturb'
    ],
  };

  // Common app package names
  final Map<String, String> _commonApps = {
    'واتساب': 'com.whatsapp',
    'واتس': 'com.whatsapp',
    'whatsapp': 'com.whatsapp',
    'فيسبوك': 'com.facebook.katana',
    'فيس': 'com.facebook.katana',
    'facebook': 'com.facebook.katana',
    'انستغرام': 'com.instagram.android',
    'انستا': 'com.instagram.android',
    'instagram': 'com.instagram.android',
    'يوتيوب': 'com.google.android.youtube',
    'youtube': 'com.google.android.youtube',
    'تيك توك': 'com.zhiliaoapp.musically',
    'تيكتوك': 'com.zhiliaoapp.musically',
    'tiktok': 'com.zhiliaoapp.musically',
    'تويتر': 'com.twitter.android',
    'twitter': 'com.twitter.android',
    'x': 'com.twitter.android',
    'سناب شات': 'com.snapchat.android',
    'سناب': 'com.snapchat.android',
    'snapchat': 'com.snapchat.android',
    'تيليجرام': 'org.telegram.messenger',
    'تلجرام': 'org.telegram.messenger',
    'telegram': 'org.telegram.messenger',
    'جيميل': 'com.google.android.gm',
    'gmail': 'com.google.android.gm',
    'خرائط': 'com.google.android.apps.maps',
    'maps': 'com.google.android.apps.maps',
    'google maps': 'com.google.android.apps.maps',
    'كروم': 'com.android.chrome',
    'chrome': 'com.android.chrome',
    'متصفح': 'com.android.chrome',
    'browser': 'com.android.chrome',
    'كاميرا': 'com.android.camera',
    'camera': 'com.android.camera',
    'إعدادات': 'com.android.settings',
    'settings': 'com.android.settings',
    'الإعدادات': 'com.android.settings',
    'حاسبة': 'com.google.android.calculator',
    'calculator': 'com.google.android.calculator',
    'تقويم': 'com.google.android.calendar',
    'calendar': 'com.google.android.calendar',
    'ساعة': 'com.google.android.deskclock',
    'clock': 'com.google.android.deskclock',
    'منبه': 'com.google.android.deskclock',
    'alarm': 'com.google.android.deskclock',
    'ملاحظات': 'com.google.android.keep',
    'notes': 'com.google.android.keep',
    'keep': 'com.google.android.keep',
    'موسيقى': 'com.google.android.music',
    'music': 'com.google.android.music',
    'فيديو': 'com.google.android.videos',
    'video': 'com.google.android.videos',
    'صور': 'com.google.android.apps.photos',
    'photos': 'com.google.android.apps.photos',
    'gallery': 'com.google.android.apps.photos',
  };

  bool get isInitialized => _isInitialized;
  String? get modelPath => _modelPath;

  Future<void> initialize(String modelPath) async {
    _modelPath = modelPath;
    
    // Check if model file exists
    final file = File(modelPath);
    if (!await file.exists()) {
      throw Exception('Model file not found at: $modelPath');
    }

    _isInitialized = true;
  }

  Future<CommandModel> processCommand(String userInput) async {
    if (!_isInitialized) {
      // Use fallback parsing if model is not initialized
      return _fallbackParse(userInput);
    }

    try {
      // Build prompt for the AI model
      final prompt = _buildPrompt(userInput);
      
      // Here you would call the actual Llama model
      // For now, we'll use fallback parsing
      // final response = await _llama.complete(prompt: prompt);
      // return _parseResponse(response, userInput);
      
      return _fallbackParse(userInput);
    } catch (e) {
      return _fallbackParse(userInput);
    }
  }

  String _buildPrompt(String userInput) {
    return '''
أنت Maestro AI، مساعد ذكي يتحكم بنظام Android بالكامل. مهمتك فهم أوامر المستخدم وتحديد النية والمعاملات المطلوبة.

قائمة الأوامر المدعومة مع أمثلة:
1. OPEN_APP: لفتح أي تطبيق
   - "افتح واتساب" → {"command": "OPEN_APP", "params": {"appName": "واتساب", "packageName": "com.whatsapp"}}
   - "شغل يوتيوب" → {"command": "OPEN_APP", "params": {"appName": "يوتيوب", "packageName": "com.google.android.youtube"}}

2. CLOSE_APP: لإغلاق تطبيق
   - "اغلق فيسبوك" → {"command": "CLOSE_APP", "params": {"appName": "فيسبوك", "packageName": "com.facebook.katana"}}

3. MAKE_CALL: للاتصال
   - "اتصل بأحمد" → {"command": "MAKE_CALL", "params": {"contactName": "أحمد"}}
   - "كلم 771234567" → {"command": "MAKE_CALL", "params": {"phoneNumber": "771234567"}}

4. SEND_SMS: لإرسال رسالة
   - "أرسل رسالة لمحمد: تعال بسرعة" → {"command": "SEND_SMS", "params": {"contactName": "محمد", "message": "تعال بسرعة"}}
   - "رسالة إلى 771234567: وصلت" → {"command": "SEND_SMS", "params": {"phoneNumber": "771234567", "message": "وصلت"}}

5. TOGGLE_WIFI: للتحكم بالواي فاي
   - "شغل الواي فاي" → {"command": "TOGGLE_WIFI", "params": {"enable": true}}
   - "اطفي الواي فاي" → {"command": "TOGGLE_WIFI", "params": {"enable": false}}

6. TOGGLE_BLUETOOTH: للتحكم بالبلوتوث
   - "شغل البلوتوث" → {"command": "TOGGLE_BLUETOOTH", "params": {"enable": true}}
   - "اطفي البلوتوث" → {"command": "TOGGLE_BLUETOOTH", "params": {"enable": false}}

7. SET_BRIGHTNESS: للتحكم بالسطوع
   - "زود السطوع" → {"command": "SET_BRIGHTNESS", "params": {"action": "increase", "value": 10}}
   - "خفض السطوع 50%" → {"command": "SET_BRIGHTNESS", "params": {"action": "set", "value": 50}}

8. SET_VOLUME: للتحكم بالصوت
   - "ارفع الصوت" → {"command": "SET_VOLUME", "params": {"action": "increase", "value": 10}}
   - "خفض الصوت" → {"command": "SET_VOLUME", "params": {"action": "decrease", "value": 10}}

9. PLAY_MEDIA: للتحكم بالوسائط
   - "شغل أغنية حبيبتي" → {"command": "PLAY_MEDIA", "params": {"type": "song", "name": "حبيبتي"}}
   - "شغل فيديو تعلم" → {"command": "PLAY_MEDIA", "params": {"type": "video", "name": "تعلم"}}

10. SYSTEM_COMMAND: أوامر النظام
    - "كم البطارية" → {"command": "GET_BATTERY"}
    - "كم المساحة" → {"command": "STORAGE_INFO"}
    - "كم الرام" → {"command": "MEMORY_INFO"}
    - "أعد تشغيل الجهاز" → {"command": "REBOOT"}
    - "اطفي الجهاز" → {"command": "SHUTDOWN"}

المستخدم قال: "$userInput"

أعد فقط JSON بالشكل المحدد بدون أي نص إضافي.
''';}

  CommandModel _parseResponse(String response, String originalInput) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;

      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final Map<String, dynamic> json = jsonDecode(jsonStr);

        return CommandModel(
          originalInput: originalInput,
          command: json['command'] ?? 'UNKNOWN',
          params: Map<String, dynamic>.from(json['params'] ?? {}),
          confidence: 1.0,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error parsing AI response: $e');
    }

    return _fallbackParse(originalInput);
  }

  CommandModel _fallbackParse(String input) {
    final lowerInput = input.toLowerCase().trim();

    // Check each command pattern
    for (var entry in _commandPatterns.entries) {
      for (var pattern in entry.value) {
        if (lowerInput.contains(pattern.toLowerCase())) {
          return _extractCommandParams(entry.key, lowerInput, input);
        }
      }
    }

    // If no pattern matched
    return CommandModel(
      originalInput: input,
      command: 'UNKNOWN',
      params: {},
      confidence: 0.0,
      timestamp: DateTime.now(),
    );
  }

  CommandModel _extractCommandParams(String command, String lowerInput, String originalInput) {
    final params = <String, dynamic>{};

    switch (command) {
      case 'OPEN_APP':
      case 'CLOSE_APP':
        final appName = _extractAppName(lowerInput);
        params['appName'] = appName;
        params['packageName'] = _commonApps[appName.toLowerCase()] ?? '';
        break;

      case 'MAKE_CALL':
        final contact = _extractContactOrNumber(lowerInput);
        if (RegExp(r'^\d+$').hasMatch(contact)) {
          params['phoneNumber'] = contact;
        } else {
          params['contactName'] = contact;
        }
        break;

      case 'SEND_SMS':
        final parts = _extractSmsParts(lowerInput);
        if (parts != null) {
          params.addAll(parts);
        }
        break;

      case 'TOGGLE_WIFI':
      case 'TOGGLE_BLUETOOTH':
      case 'TOGGLE_LOCATION':
      case 'TOGGLE_SILENT':
      case 'TOGGLE_DND':
        params['enable'] = _isEnableCommand(lowerInput);
        break;

      case 'SET_BRIGHTNESS':
      case 'SET_VOLUME':
        final value = _extractNumber(lowerInput);
        if (value != null) {
          params['value'] = value;
          params['action'] = 'set';
        } else if (lowerInput.contains('زود') || lowerInput.contains('ارفع') || lowerInput.contains('increase')) {
          params['action'] = 'increase';
          params['value'] = 10;
        } else if (lowerInput.contains('خفض') || lowerInput.contains('قلل') || lowerInput.contains('decrease')) {
          params['action'] = 'decrease';
          params['value'] = 10;
        }
        break;

      case 'PLAY_MEDIA':
        final mediaInfo = _extractMediaInfo(lowerInput);
        if (mediaInfo != null) {
          params.addAll(mediaInfo);
        }
        break;

      case 'CREATE_FOLDER':
      case 'DELETE_FILE':
        final name = _extractFileName(lowerInput);
        if (name != null) {
          params['name'] = name;
        }
        break;
    }

    // Update learning data
    _learnFromCommand(command, originalInput);

    return CommandModel(
      originalInput: originalInput,
      command: command,
      params: params,
      confidence: 0.8,
      timestamp: DateTime.now(),
    );
  }

  String _extractAppName(String input) {
    // Remove command words
    final commandWords = [
      'افتح', 'شغل', 'اعرض', 'ارفع', 'شوف', 'ادخل', 'فتح', 'شغللي',
      'افتحلي', 'ابدأ', 'start', 'open', 'اغلق', 'اقفل', 'سكر', 'اطفي', 'وقف', 'close', 'stop'
    ];
    
    String result = input;
    for (var word in commandWords) {
      result = result.replaceAll(word.toLowerCase(), '');
    }
    
    return result.trim();
  }

  String _extractContactOrNumber(String input) {
    // Remove command words
    final commandWords = ['اتصل', 'كلم', 'اتصل ب', 'رن على', 'اتصل على', 'كلم', 'call'];
    
    String result = input;
    for (var word in commandWords) {
      result = result.replaceAll(word.toLowerCase(), '');
    }
    
    return result.trim();
  }

  Map<String, dynamic>? _extractSmsParts(String input) {
    // Try to extract recipient and message
    final patterns = [
      RegExp(r'رسالة\s+(?:ل|لل|إلى)\s+([^:]+):?\s*(.*)'),
      RegExp(r'message\s+(?:to)\s+([^:]+):?\s*(.*)'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        final recipient = match.group(1)?.trim() ?? '';
        final message = match.group(2)?.trim() ?? '';
        
        if (RegExp(r'^\d+$').hasMatch(recipient)) {
          return {'phoneNumber': recipient, 'message': message};
        } else {
          return {'contactName': recipient, 'message': message};
        }
      }
    }

    return null;
  }

  bool _isEnableCommand(String input) {
    final enableWords = ['شغل', 'فتح', 'شغلي', 'enable', 'on', 'turn on', 'start'];
    final disableWords = ['اطفي', 'اقفل', 'سكر', 'disable', 'off', 'turn off', 'stop'];

    for (var word in enableWords) {
      if (input.contains(word.toLowerCase())) return true;
    }
    for (var word in disableWords) {
      if (input.contains(word.toLowerCase())) return false;
    }

    return true; // Default to enable
  }

  int? _extractNumber(String input) {
    final match = RegExp(r'(\d+)').firstMatch(input);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  Map<String, dynamic>? _extractMediaInfo(String input) {
    final type = input.contains('أغنية') || input.contains('song') || input.contains('موسيقى')
        ? 'song'
        : input.contains('فيديو') || input.contains('video') || input.contains('فلم')
            ? 'video'
            : 'media';

    // Extract name after media type keywords
    final keywords = ['أغنية', 'فيديو', 'موسيقى', 'فلم', 'song', 'video', 'music', 'media', 'play'];
    String name = input;
    for (var keyword in keywords) {
      name = name.replaceAll(keyword.toLowerCase(), '');
    }

    return {'type': type, 'name': name.trim()};
  }

  String? _extractFileName(String input) {
    final keywords = ['مجلد', 'ملف', 'folder', 'file', 'create', 'delete', 'أنشئ', 'احذف', 'امسح'];
    String result = input;
    for (var keyword in keywords) {
      result = result.replaceAll(keyword.toLowerCase(), '');
    }
    result = result.trim();
    return result.isNotEmpty ? result : null;
  }

  void _learnFromCommand(String command, String originalInput) {
    if (!_learningData.containsKey(command)) {
      _learningData[command] = [];
    }
    
    if (!_learningData[command]!.contains(originalInput)) {
      _learningData[command]!.add(originalInput);
    }

    _commandFrequency[command] = (_commandFrequency[command] ?? 0) + 1;
  }

  // Get command suggestions based on partial input
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

    // Add from learning data
    _learningData.forEach((command, inputs) {
      for (var input in inputs) {
        if (input.toLowerCase().contains(lowerPartial)) {
          suggestions.add(input);
        }
      }
    });

    return suggestions.toSet().toList()..take(5);
  }

  // Get most used commands
  List<MapEntry<String, int>> getMostUsedCommands({int limit = 5}) {
    final sorted = _commandFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  void dispose() {
    _isInitialized = false;
    _modelPath = null;
  }
}
