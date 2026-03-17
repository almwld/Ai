class CommandCategories {
  static const Map<String, Map<String, dynamic>> categories = {
    'apps': {
      'name': 'التطبيقات',
      'icon': 'apps',
      'color': 0xFF00D4FF,
      'commands': [
        {'command': 'OPEN_APP', 'example': 'افتح واتساب', 'description': 'فتح تطبيق'},
        {'command': 'CLOSE_APP', 'example': 'اغلق فيسبوك', 'description': 'إغلاق تطبيق'},
        {'command': 'GET_APPS', 'example': 'اعرض التطبيقات', 'description': 'عرض التطبيقات المثبتة'},
      ],
    },
    'calls': {
      'name': 'المكالمات',
      'icon': 'phone',
      'color': 0xFF00C853,
      'commands': [
        {'command': 'MAKE_CALL', 'example': 'اتصل بأحمد', 'description': 'إجراء مكالمة'},
        {'command': 'END_CALL', 'example': 'انهِ المكالمة', 'description': 'إنهاء المكالمة'},
        {'command': 'MUTE_CALL', 'example': 'كتم المكالمة', 'description': 'كتم صوت المكالمة'},
        {'command': 'SPEAKER_ON', 'example': 'شغل مكبر الصوت', 'description': 'تشغيل مكبر الصوت'},
      ],
    },
    'messages': {
      'name': 'الرسائل',
      'icon': 'message',
      'color': 0xFFFFAB40,
      'commands': [
        {'command': 'SEND_SMS', 'example': 'أرسل رسالة لمحمد', 'description': 'إرسال رسالة نصية'},
        {'command': 'READ_SMS', 'example': 'اقرأ آخر رسالة', 'description': 'قراءة الرسائل'},
      ],
    },
    'settings': {
      'name': 'الإعدادات',
      'icon': 'settings',
      'color': 0xFF9D4EDD,
      'commands': [
        {'command': 'TOGGLE_WIFI', 'example': 'شغل الواي فاي', 'description': 'تشغيل/إطفاء الواي فاي'},
        {'command': 'TOGGLE_BLUETOOTH', 'example': 'شغل البلوتوث', 'description': 'تشغيل/إطفاء البلوتوث'},
        {'command': 'SET_BRIGHTNESS', 'example': 'زود السطوع', 'description': 'ضبط السطوع'},
        {'command': 'SET_VOLUME', 'example': 'ارفع الصوت', 'description': 'ضبط الصوت'},
        {'command': 'TOGGLE_SILENT', 'example': 'شغل الوضع الصامت', 'description': 'الوضع الصامت'},
      ],
    },
    'system': {
      'name': 'النظام',
      'icon': 'memory',
      'color': 0xFFFF5252,
      'commands': [
        {'command': 'BATTERY_STATUS', 'example': 'كم البطارية', 'description': 'حالة البطارية'},
        {'command': 'STORAGE_INFO', 'example': 'كم المساحة', 'description': 'المساحة التخزينية'},
        {'command': 'MEMORY_INFO', 'example': 'كم الرام', 'description': 'الذاكرة المستخدمة'},
        {'command': 'DEVICE_INFO', 'example': 'معلومات الجهاز', 'description': 'معلومات الجهاز'},
        {'command': 'CLEAR_RAM', 'example': 'نظف الذاكرة', 'description': 'تنظيف الذاكرة'},
        {'command': 'CLOSE_ALL_APPS', 'example': 'أغلق كل التطبيقات', 'description': 'إغلاق جميع التطبيقات'},
      ],
    },
    'media': {
      'name': 'الوسائط',
      'icon': 'play_circle',
      'color': 0xFFE91E63,
      'commands': [
        {'command': 'PLAY_MEDIA', 'example': 'شغل أغنية', 'description': 'تشغيل وسائط'},
        {'command': 'PAUSE_MEDIA', 'example': 'وقف', 'description': 'إيقاف مؤقت'},
        {'command': 'NEXT_TRACK', 'example': 'التالي', 'description': 'المقطع التالي'},
        {'command': 'PREVIOUS_TRACK', 'example': 'السابق', 'description': 'المقطع السابق'},
        {'command': 'TAKE_PHOTO', 'example': 'صور', 'description': 'التقاط صورة'},
      ],
    },
    'files': {
      'name': 'الملفات',
      'icon': 'folder',
      'color': 0xFF795548,
      'commands': [
        {'command': 'LIST_FILES', 'example': 'اعرض الملفات', 'description': 'عرض الملفات'},
        {'command': 'CREATE_FOLDER', 'example': 'أنشئ مجلد', 'description': 'إنشاء مجلد'},
        {'command': 'DELETE_FILE', 'example': 'احذف الملف', 'description': 'حذف ملف'},
      ],
    },
    'accessibility': {
      'name': 'إمكانية الوصول',
      'icon': 'accessibility',
      'color': 0xFF3F51B5,
      'commands': [
        {'command': 'READ_SCREEN', 'example': 'اقرأ الشاشة', 'description': 'قراءة محتوى الشاشة'},
        {'command': 'INCREASE_FONT', 'example': 'كبر الخط', 'description': 'تكبير حجم الخط'},
        {'command': 'DECREASE_FONT', 'example': 'صغر الخط', 'description': 'تصغير حجم الخط'},
      ],
    },
  };

  static List<Map<String, dynamic>> getAllCommands() {
    List<Map<String, dynamic>> allCommands = [];
    categories.forEach((categoryKey, categoryData) {
      final commands = categoryData['commands'] as List<Map<String, dynamic>>;
      for (var command in commands) {
        allCommands.add({
          ...command,
          'category': categoryKey,
          'categoryName': categoryData['name'],
          'categoryIcon': categoryData['icon'],
          'categoryColor': categoryData['color'],
        });
      }
    });
    return allCommands;
  }

  static Map<String, dynamic>? getCommandById(String commandId) {
    final allCommands = getAllCommands();
    try {
      return allCommands.firstWhere((cmd) => cmd['command'] == commandId);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> getCommandsByCategory(String category) {
    final categoryData = categories[category];
    if (categoryData == null) return [];
    return (categoryData['commands'] as List<Map<String, dynamic>>).map((cmd) => {
      ...cmd,
      'category': category,
      'categoryName': categoryData['name'],
      'categoryIcon': categoryData['icon'],
      'categoryColor': categoryData['color'],
    }).toList();
  }
}
