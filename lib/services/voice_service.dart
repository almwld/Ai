import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isAvailable = false;
  List<LocaleName> _availableLocales = [];
  String _lastWords = '';
  bool _isListening = false;

  // Stream controllers للحالة والأخطاء
  final _listeningStateController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Getters للـ Streams
  Stream<bool> get listeningState => _listeningStateController.stream;
  Stream<String> get errorStream => _errorController.stream;

  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (error) => _errorController.add(error.errorMsg),
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            _isListening = false;
            _listeningStateController.add(false);
          } else if (status == 'listening') {
            _isListening = true;
            _listeningStateController.add(true);
          }
        },
      );
      if (_isAvailable) {
        _availableLocales = await _speech.locales();
      }
      await _tts.setLanguage('ar-SA');
      return _isAvailable;
    } catch (e) {
      _errorController.add('خطأ في التهيئة: $e');
      return false;
    }
  }

  List<LocaleName> get availableLocales => _availableLocales;
  String get lastWords => _lastWords;
  bool get isListening => _isListening;

  // جلب قائمة اللغات المتاحة كنصوص
  Future<List<String>> getAvailableLanguages() async {
    return _availableLocales.map((locale) => locale.name).toList();
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isAvailable) return;
    try {
      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          onResult(result.recognizedWords);
        },
        localeId: 'ar_SA',
        listenFor: const Duration(seconds: 30),
      );
    } catch (e) {
      _errorController.add('خطأ في الاستماع: $e');
    }
  }

  Future<bool> stopListening() async {
    try {
      await _speech.stop();
      _isListening = false;
      _listeningStateController.add(false);
      return true;
    } catch (e) {
      _errorController.add('خطأ في إيقاف الاستماع: $e');
      return false;
    }
  }

  // تعديل cancelListening لترجع Future<bool>
  Future<bool> cancelListening() => stopListening();

  Future<void> speak(String text, {double? rate, double? volume}) async {
    try {
      if (rate != null) await _tts.setSpeechRate(rate);
      if (volume != null) await _tts.setVolume(volume);
      await _tts.speak(text);
    } catch (e) {
      _errorController.add('خطأ في النطق: $e');
    }
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  void clearLastWords() {
    _lastWords = '';
  }

  void dispose() {
    _speech.stop();
    _tts.stop();
    _listeningStateController.close();
    _errorController.close();
  }
}
