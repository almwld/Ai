import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_ai/services/ai_service.dart';

void main() {
  group('AIService', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('should not be initialized initially', () {
      expect(aiService.isInitialized, isFalse);
    });

    test('should extract app name correctly', () async {
      // This test would require mocking the model file
      // For now, we test the fallback parsing
      
      final result1 = await aiService.processCommand('افتح واتساب');
      expect(result1.command, equals('OPEN_APP'));
      expect(result1.params['appName'], equals('واتساب'));

      final result2 = await aiService.processCommand('شغل يوتيوب');
      expect(result2.command, equals('OPEN_APP'));
      expect(result2.params['appName'], equals('يوتيوب'));
    });

    test('should detect wifi commands', () async {
      final result1 = await aiService.processCommand('شغل الواي فاي');
      expect(result1.command, equals('TOGGLE_WIFI'));
      expect(result1.params['enable'], isTrue);

      final result2 = await aiService.processCommand('اطفي الواي فاي');
      expect(result2.command, equals('TOGGLE_WIFI'));
      expect(result2.params['enable'], isFalse);
    });

    test('should detect bluetooth commands', () async {
      final result1 = await aiService.processCommand('شغل البلوتوث');
      expect(result1.command, equals('TOGGLE_BLUETOOTH'));
      expect(result1.params['enable'], isTrue);

      final result2 = await aiService.processCommand('اطفي البلوتوث');
      expect(result2.command, equals('TOGGLE_BLUETOOTH'));
      expect(result2.params['enable'], isFalse);
    });

    test('should detect brightness commands', () async {
      final result1 = await aiService.processCommand('زود السطوع');
      expect(result1.command, equals('SET_BRIGHTNESS'));
      expect(result1.params['action'], equals('increase'));

      final result2 = await aiService.processCommand('خفض السطوع');
      expect(result2.command, equals('SET_BRIGHTNESS'));
      expect(result2.params['action'], equals('decrease'));
    });

    test('should detect battery status commands', () async {
      final result = await aiService.processCommand('كم البطارية');
      expect(result.command, equals('GET_BATTERY'));
    });

    test('should detect storage info commands', () async {
      final result = await aiService.processCommand('كم المساحة');
      expect(result.command, equals('STORAGE_INFO'));
    });

    test('should detect memory info commands', () async {
      final result = await aiService.processCommand('كم الرام');
      expect(result.command, equals('MEMORY_INFO'));
    });

    test('should detect clear ram commands', () async {
      final result = await aiService.processCommand('نظف الذاكرة');
      expect(result.command, equals('CLEAR_RAM'));
    });

    test('should detect close all apps commands', () async {
      final result = await aiService.processCommand('أغلق كل التطبيقات');
      expect(result.command, equals('CLOSE_ALL_APPS'));
    });

    test('should return unknown for unrecognized commands', () async {
      final result = await aiService.processCommand('أمر غير معروف تماماً');
      expect(result.command, equals('UNKNOWN'));
      expect(result.confidence, equals(0.0));
    });
  });
}
