import 'dart:convert';

class CommandModel {
  final String originalInput;
  final String command;
  final Map<String, dynamic> params;
  final double confidence;
  final DateTime timestamp;
  bool? success;
  String? result;
  String? errorMessage;
  
  CommandModel({
    required this.originalInput,
    required this.command,
    required this.params,
    required this.confidence,
    required this.timestamp,
    this.success,
    this.result,
    this.errorMessage,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'originalInput': originalInput,
      'command': command,
      'params': params,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'result': result,
      'errorMessage': errorMessage,
    };
  }
  
  factory CommandModel.fromJson(Map<String, dynamic> json) {
    return CommandModel(
      originalInput: json['originalInput'] ?? '',
      command: json['command'] ?? '',
      params: Map<String, dynamic>.from(json['params'] ?? {}),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      success: json['success'],
      result: json['result'],
      errorMessage: json['errorMessage'],
    );
  }
  
  String toJsonString() => jsonEncode(toJson());
  
  factory CommandModel.fromJsonString(String jsonString) {
    return CommandModel.fromJson(jsonDecode(jsonString));
  }
  
  CommandModel copyWith({
    String? originalInput,
    String? command,
    Map<String, dynamic>? params,
    double? confidence,
    DateTime? timestamp,
    bool? success,
    String? result,
    String? errorMessage,
  }) {
    return CommandModel(
      originalInput: originalInput ?? this.originalInput,
      command: command ?? this.command,
      params: params ?? this.params,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      success: success ?? this.success,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  String getDisplayText() {
    switch (command) {
      case 'OPEN_APP':
        return 'فتح تطبيق ${params['appName'] ?? params['packageName'] ?? ''}';
      case 'CLOSE_APP':
        return 'إغلاق تطبيق ${params['appName'] ?? params['packageName'] ?? ''}';
      case 'MAKE_CALL':
        return 'الاتصال بـ ${params['contactName'] ?? params['phoneNumber'] ?? ''}';
      case 'SEND_SMS':
        return 'إرسال رسالة إلى ${params['contactName'] ?? params['phoneNumber'] ?? ''}';
      case 'TOGGLE_WIFI':
        return params['enable'] == true ? 'تشغيل الواي فاي' : 'إطفاء الواي فاي';
      case 'TOGGLE_BLUETOOTH':
        return params['enable'] == true ? 'تشغيل البلوتوث' : 'إطفاء البلوتوث';
      case 'SET_BRIGHTNESS':
        if (params['action'] == 'increase') {
          return 'زيادة السطوع';
        } else if (params['action'] == 'decrease') {
          return 'خفض السطوع';
        } else {
          return 'تغيير السطوع إلى ${params['value']}%';
        }
      case 'SET_VOLUME':
        if (params['action'] == 'increase') {
          return 'رفع الصوت';
        } else if (params['action'] == 'decrease') {
          return 'خفض الصوت';
        } else {
          return 'تغيير الصوت إلى ${params['value']}%';
        }
      case 'PLAY_MEDIA':
        return 'تشغيل ${params['type'] == 'song' ? 'أغنية' : 'فيديو'} ${params['name'] ?? ''}';
      case 'PAUSE_MEDIA':
        return 'إيقاف الوسائط';
      case 'NEXT_TRACK':
        return 'المقطع التالي';
      case 'PREVIOUS_TRACK':
        return 'المقطع السابق';
      case 'TAKE_PHOTO':
        return 'التقاط صورة';
      case 'BATTERY_STATUS':
        return 'فحص حالة البطارية';
      case 'STORAGE_INFO':
        return 'عرض المساحة التخزينية';
      case 'MEMORY_INFO':
        return 'عرض معلومات الذاكرة';
      case 'DEVICE_INFO':
        return 'عرض معلومات الجهاز';
      case 'REBOOT':
        return 'إعادة تشغيل الجهاز';
      case 'SHUTDOWN':
        return 'إطفاء الجهاز';
      case 'READ_SCREEN':
        return 'قراءة محتوى الشاشة';
      case 'CLOSE_ALL_APPS':
        return 'إغلاق جميع التطبيقات';
      case 'CLEAR_RAM':
        return 'تنظيف الذاكرة';
      case 'LIST_FILES':
        return 'عرض الملفات';
      case 'CREATE_FOLDER':
        return 'إنشاء مجلد ${params['name'] ?? ''}';
      case 'DELETE_FILE':
        return 'حذف ملف ${params['name'] ?? ''}';
      case 'INCREASE_FONT':
        return 'تكبير حجم الخط';
      case 'DECREASE_FONT':
        return 'تصغير حجم الخط';
      case 'TOGGLE_SILENT':
        return params['enable'] == true ? 'تشغيل الوضع الصامت' : 'إطفاء الوضع الصامت';
      case 'TOGGLE_DND':
        return params['enable'] == true ? 'تشغيل عدم الإزعاج' : 'إطفاء عدم الإزعاج';
      case 'UNKNOWN':
        return 'أمر غير معروف: $originalInput';
      default:
        return originalInput;
    }
  }
  
  String getIconName() {
    switch (command) {
      case 'OPEN_APP':
      case 'CLOSE_APP':
      case 'GET_APPS':
        return 'apps';
      case 'MAKE_CALL':
      case 'END_CALL':
      case 'MUTE_CALL':
      case 'SPEAKER_ON':
        return 'phone';
      case 'SEND_SMS':
      case 'READ_SMS':
        return 'message';
      case 'TOGGLE_WIFI':
        return 'wifi';
      case 'TOGGLE_BLUETOOTH':
        return 'bluetooth';
      case 'TOGGLE_LOCATION':
        return 'location_on';
      case 'SET_BRIGHTNESS':
        return 'brightness_6';
      case 'SET_VOLUME':
        return 'volume_up';
      case 'PLAY_MEDIA':
      case 'PAUSE_MEDIA':
      case 'NEXT_TRACK':
      case 'PREVIOUS_TRACK':
        return 'play_circle';
      case 'TAKE_PHOTO':
      case 'RECORD_VIDEO':
        return 'camera_alt';
      case 'BATTERY_STATUS':
        return 'battery_full';
      case 'STORAGE_INFO':
        return 'storage';
      case 'MEMORY_INFO':
        return 'memory';
      case 'DEVICE_INFO':
        return 'phone_android';
      case 'REBOOT':
      case 'SHUTDOWN':
        return 'power_settings_new';
      case 'READ_SCREEN':
        return 'screen_share';
      case 'CLOSE_ALL_APPS':
      case 'CLEAR_RAM':
        return 'cleaning_services';
      case 'LIST_FILES':
      case 'CREATE_FOLDER':
      case 'DELETE_FILE':
        return 'folder';
      default:
        return 'assistant';
    }
  }
  
  int getColorValue() {
    switch (command) {
      case 'OPEN_APP':
      case 'CLOSE_APP':
      case 'GET_APPS':
        return 0xFF00D4FF;
      case 'MAKE_CALL':
      case 'END_CALL':
      case 'MUTE_CALL':
      case 'SPEAKER_ON':
        return 0xFF00C853;
      case 'SEND_SMS':
      case 'READ_SMS':
        return 0xFFFFAB40;
      case 'TOGGLE_WIFI':
      case 'TOGGLE_BLUETOOTH':
      case 'SET_BRIGHTNESS':
      case 'SET_VOLUME':
        return 0xFF9D4EDD;
      case 'PLAY_MEDIA':
      case 'PAUSE_MEDIA':
      case 'NEXT_TRACK':
      case 'PREVIOUS_TRACK':
      case 'TAKE_PHOTO':
        return 0xFFE91E63;
      case 'BATTERY_STATUS':
      case 'STORAGE_INFO':
      case 'MEMORY_INFO':
      case 'DEVICE_INFO':
        return 0xFFFF5252;
      default:
        return 0xFF00D4FF;
    }
  }
  
  bool get isSuccess => success == true;
  bool get isError => success == false;
  bool get isPending => success == null;
}
