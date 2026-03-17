import '../constants/command_categories.dart';

class CommandParser {
  // Extract app name from command text
  static String? extractAppName(String input) {
    final patterns = [
      RegExp(r'افتح\s+(.+)', caseSensitive: false),
      RegExp(r'شغل\s+(.+)', caseSensitive: false),
      RegExp(r'open\s+(.+)', caseSensitive: false),
      RegExp(r'start\s+(.+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }

  // Extract contact name or phone number
  static String? extractContact(String input) {
    final patterns = [
      RegExp(r'اتصل\s+(?:ب)?\s*(.+)', caseSensitive: false),
      RegExp(r'كلم\s+(.+)', caseSensitive: false),
      RegExp(r'call\s+(.+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }

  // Extract SMS message and recipient
  static Map<String, String>? extractSmsInfo(String input) {
    final patterns = [
      RegExp(r'أرسل\s+رسالة\s+(?:ل|لل|إلى)?\s*([^:]+):?\s*(.*)', caseSensitive: false),
      RegExp(r'ابعت\s+رسالة\s+(?:ل|لل|إلى)?\s*([^:]+):?\s*(.*)', caseSensitive: false),
      RegExp(r'send\s+sms\s+to\s+([^:]+):?\s*(.*)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(input);
      if (match != null) {
        return {
          'recipient': match.group(1)?.trim() ?? '',
          'message': match.group(2)?.trim() ?? '',
        };
      }
    }
    return null;
  }

  // Extract number from text
  static int? extractNumber(String input) {
    final match = RegExp(r'(\d+)').firstMatch(input);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  // Check if command is enabling or disabling
  static bool isEnableCommand(String input) {
    final enablePatterns = [
      'شغل',
      'فتح',
      'تشغيل',
      'enable',
      'on',
      'turn on',
      'start',
    ];

    final disablePatterns = [
      'اطفي',
      'اقفل',
      'سكر',
      'إطفاء',
      'disable',
      'off',
      'turn off',
      'stop',
    ];

    final lowerInput = input.toLowerCase();

    for (final pattern in enablePatterns) {
      if (lowerInput.contains(pattern.toLowerCase())) return true;
    }

    for (final pattern in disablePatterns) {
      if (lowerInput.contains(pattern.toLowerCase())) return false;
    }

    return true; // Default to enable
  }

  // Parse brightness/volume action
  static Map<String, dynamic>? parseLevelCommand(String input) {
    final increasePatterns = ['زود', 'ارفع', ' increase', 'raise', 'up'];
    final decreasePatterns = ['خفض', 'قلل', ' decrease', 'lower', 'down'];

    final lowerInput = input.toLowerCase();

    for (final pattern in increasePatterns) {
      if (lowerInput.contains(pattern.toLowerCase())) {
        return {'action': 'increase', 'value': 10};
      }
    }

    for (final pattern in decreasePatterns) {
      if (lowerInput.contains(pattern.toLowerCase())) {
        return {'action': 'decrease', 'value': 10};
      }
    }

    // Try to extract specific value
    final number = extractNumber(input);
    if (number != null) {
      return {'action': 'set', 'value': number};
    }

    return null;
  }

  // Match command to known patterns
  static String? matchCommand(String input) {
    final lowerInput = input.toLowerCase().trim();

    final patterns = CommandCategories.categories;

    for (final category in patterns.values) {
      final commands = category['commands'] as List<Map<String, dynamic>>;
      for (final cmd in commands) {
        final commandId = cmd['command'] as String;
        final examples = cmd['example'] as String;

        // Simple matching - check if input contains example words
        final exampleWords = examples.toLowerCase().split(' ');
        int matchCount = 0;
        for (final word in exampleWords) {
          if (lowerInput.contains(word)) matchCount++;
        }

        if (matchCount >= exampleWords.length ~/ 2) {
          return commandId;
        }
      }
    }

    return null;
  }

  // Get command confidence score
  static double calculateConfidence(String input, String commandId) {
    final command = CommandCategories.getCommandById(commandId);
    if (command == null) return 0.0;

    final example = command['example'] as String;
    final exampleWords = example.toLowerCase().split(' ');
    final inputWords = input.toLowerCase().split(' ');

    int matches = 0;
    for (final word in exampleWords) {
      if (inputWords.contains(word)) matches++;
    }

    return matches / exampleWords.length;
  }

  // Clean input text
  static String cleanInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '');
  }

  // Detect language (simple detection)
  static String detectLanguage(String input) {
    final arabicPattern = RegExp(r'[\u0600-\u06FF]');
    if (arabicPattern.hasMatch(input)) {
      return 'ar';
    }
    return 'en';
  }
}
