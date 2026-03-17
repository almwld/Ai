import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_ai/core/utils/command_parser.dart';

void main() {
  group('CommandParser', () {
    test('extractAppName should extract app name from command', () {
      expect(CommandParser.extractAppName('افتح واتساب'), equals('واتساب'));
      expect(CommandParser.extractAppName('شغل يوتيوب'), equals('يوتيوب'));
      expect(CommandParser.extractAppName('open facebook'), equals('facebook'));
      expect(CommandParser.extractAppName('start chrome'), equals('chrome'));
    });

    test('extractContact should extract contact name or number', () {
      expect(CommandParser.extractContact('اتصل بأحمد'), equals('أحمد'));
      expect(CommandParser.extractContact('كلم محمد'), equals('محمد'));
      expect(CommandParser.extractContact('call John'), equals('John'));
    });

    test('extractSmsInfo should extract SMS recipient and message', () {
      final result1 = CommandParser.extractSmsInfo('أرسل رسالة لأحمد: مرحبا');
      expect(result1, isNotNull);
      expect(result1!['recipient'], equals('أحمد'));
      expect(result1['message'], equals('مرحبا'));

      final result2 = CommandParser.extractSmsInfo('send sms to John: Hello');
      expect(result2, isNotNull);
      expect(result2!['recipient'], equals('John'));
      expect(result2['message'], equals('Hello'));
    });

    test('extractNumber should extract number from text', () {
      expect(CommandParser.extractNumber('السطوع 50'), equals(50));
      expect(CommandParser.extractNumber('volume 75'), equals(75));
      expect(CommandParser.extractNumber('no number here'), isNull);
    });

    test('isEnableCommand should detect enable/disable commands', () {
      expect(CommandParser.isEnableCommand('شغل الواي فاي'), isTrue);
      expect(CommandParser.isEnableCommand('فتح البلوتوث'), isTrue);
      expect(CommandParser.isEnableCommand('اطفي الواي فاي'), isFalse);
      expect(CommandParser.isEnableCommand('turn on wifi'), isTrue);
      expect(CommandParser.isEnableCommand('turn off bluetooth'), isFalse);
    });

    test('parseLevelCommand should parse level adjustment commands', () {
      final result1 = CommandParser.parseLevelCommand('زود السطوع');
      expect(result1, isNotNull);
      expect(result1!['action'], equals('increase'));

      final result2 = CommandParser.parseLevelCommand('خفض الصوت');
      expect(result2, isNotNull);
      expect(result2!['action'], equals('decrease'));

      final result3 = CommandParser.parseLevelCommand('السطوع 50');
      expect(result3, isNotNull);
      expect(result3!['action'], equals('set'));
      expect(result3['value'], equals(50));
    });

    test('cleanInput should clean and normalize input', () {
      expect(CommandParser.cleanInput('  افتح   واتساب  '), equals('افتح واتساب'));
      expect(CommandParser.cleanInput('open!!! facebook???'), equals('open facebook'));
    });

    test('detectLanguage should detect Arabic or English', () {
      expect(CommandParser.detectLanguage('افتح واتساب'), equals('ar'));
      expect(CommandParser.detectLanguage('open whatsapp'), equals('en'));
    });

    test('formatFileSize should format bytes correctly', () {
      expect(CommandParser.calculateConfidence('افتح واتساب', 'OPEN_APP'), greaterThan(0.0));
    });
  });
}
