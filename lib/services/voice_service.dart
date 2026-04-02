import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isAvailable = false;
  bool _isListening = false;

  final _listeningStateController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

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
      await _tts.setLanguage('ar-SA');
      return _isAvailable;
    } catch (e) {
      _errorController.add('خطأ في التهيئة: $e');
      return false;
    }
  }

  Future<List<String>> getAvailableLanguages() async {
    final locales = await _speech.locales();
    return locales.map((l) => l.localeId).toList();
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_isAvailable) return;
    try {
      await _speech.listen(
        onResult: (result) {
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

  Future<bool> cancelListening() async {
    return stopListening();
  }

  Future<void> speak(String text) async {
    try {
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

  void dispose() {
    _speech.stop();
    _tts.stop();
    _listeningStateController.close();
    _errorController.close();
  }
}
