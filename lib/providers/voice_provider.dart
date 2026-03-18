import 'package:flutter/material.dart';
import '../services/voice_service.dart';

class VoiceProvider extends ChangeNotifier {
  final VoiceService _voiceService = VoiceService();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  String _lastError = '';
  List<String> _availableLanguages = [];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  String get lastError => _lastError;
  List<String> get availableLanguages => _availableLanguages;

  VoiceProvider() {
    _init();
    // الاستماع إلى حالة الاستماع من الـ Service
    _voiceService.listeningState.listen((isListening) {
      _isListening = isListening;
      notifyListeners();
    });
    // الاستماع إلى الأخطاء
    _voiceService.errorStream.listen((error) {
      _lastError = error;
      notifyListeners();
    });
  }

  Future<void> _init() async {
    _isInitialized = await _voiceService.initialize();
    if (_isInitialized) {
      await loadLanguages();
    }
    notifyListeners();
  }

  Future<void> loadLanguages() async {
    _availableLanguages = await _voiceService.getAvailableLanguages();
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_isInitialized) return;
    await _voiceService.startListening((result) {
      _lastWords = result;
      notifyListeners();
    });
  }

  Future<bool> stopListening() async {
    return await _voiceService.stopListening();
  }

  Future<bool> cancelListening() async {
    return await _voiceService.cancelListening();
  }

  Future<void> speak(String text) async {
    await _voiceService.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
  }

  Future<void> setLanguage(String language) async {
    await _voiceService.setLanguage(language);
  }

  void clearLastWords() {
    _lastWords = '';
    notifyListeners();
  }

  void clearError() {
    _lastError = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
