import 'package:flutter/material.dart';
import '../services/voice_service.dart';
import '../models/voice_state.dart';

class VoiceProvider extends ChangeNotifier {
  final VoiceService _voiceService = VoiceService();

  bool _isInitialized = false;
  VoiceState _state = VoiceState.idle;
  String _lastWords = '';
  String _lastError = '';
  List<String> _availableLanguages = [];

  // Getters
  bool get isInitialized => _isInitialized;
  VoiceState get state => _state;
  String get lastWords => _lastWords;
  String get lastError => _lastError;
  List<String> get availableLanguages => _availableLanguages;

  VoiceProvider() {
    _init();
    // الاستماع إلى حالة الاستماع من الـ Service
    _voiceService.listeningState.listen((isListening) {
      _state = isListening ? VoiceState.listening : VoiceState.idle;
      notifyListeners();
    });
    // الاستماع إلى الأخطاء
    _voiceService.errorStream.listen((error) {
      _lastError = error;
      _state = VoiceState.error;
      notifyListeners();
    });
  }

  Future<void> _init() async {
    _state = VoiceState.processing;
    notifyListeners();

    _isInitialized = await _voiceService.initialize();
    if (_isInitialized) {
      await loadLanguages();
      _state = VoiceState.idle;
    } else {
      _state = VoiceState.error;
      _lastError = 'فشل تهيئة خدمة الصوت';
    }
    notifyListeners();
  }

  Future<void> loadLanguages() async {
    _availableLanguages = await _voiceService.getAvailableLanguages();
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_isInitialized) return;
    _state = VoiceState.listening;
    notifyListeners();
    
    await _voiceService.startListening((result) {
      _lastWords = result;
      _state = VoiceState.processing;
      notifyListeners();
    });
  }

  Future<bool> stopListening() async {
    final result = await _voiceService.stopListening();
    _state = VoiceState.idle;
    notifyListeners();
    return result;
  }

  Future<bool> cancelListening() async {
    final result = await _voiceService.cancelListening();
    _state = VoiceState.idle;
    notifyListeners();
    return result;
  }

  Future<void> speak(String text) async {
    _state = VoiceState.speaking;
    notifyListeners();
    await _voiceService.speak(text);
    _state = VoiceState.idle;
    notifyListeners();
  }

  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
    _state = VoiceState.idle;
    notifyListeners();
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
    if (_state == VoiceState.error) {
      _state = VoiceState.idle;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
