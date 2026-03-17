import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  String _selectedLocaleId = 'ar_SA';

  // Stream controllers
  final _speechStreamController = StreamController<String>.broadcast();
  final _listeningStateController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  Stream<String> get speechStream => _speechStreamController.stream;
  Stream<bool> get listeningState => _listeningStateController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Available languages
  List<LocaleName> _availableLocales = [];
  List<LocaleName> get availableLocales => _availableLocales;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize speech to text
      final speechAvailable = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech error: $error');
          _errorController.add(error.errorMsg);
          _isListening = false;
          _listeningStateController.add(false);
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            _listeningStateController.add(false);
          }
        },
      );

      if (speechAvailable) {
        _availableLocales = await _speech.locales();
        
        // Find Arabic locale
        final arabicLocale = _availableLocales.firstWhere(
          (locale) => locale.localeId.startsWith('ar'),
          orElse: () => _availableLocales.first,
        );
        _selectedLocaleId = arabicLocale.localeId;
      }

      // Initialize text to speech
      await _tts.setLanguage('ar-SA');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Voice service initialization error: $e');
      _errorController.add('Failed to initialize voice service');
    }
  }

  Future<bool> startListening({
    Duration? listenFor,
    Duration? pauseFor,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      _lastWords = '';
      _isListening = true;
      _listeningStateController.add(true);

      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          if (result.finalResult) {
            _speechStreamController.add(_lastWords);
            _isListening = false;
            _listeningStateController.add(false);
          }
        },
        listenFor: listenFor ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 5),
        localeId: localeId ?? _selectedLocaleId,
        cancelOnError: true,
        partialResults: true,
        listenMode: ListenMode.confirmation,
      );

      return true;
    } catch (e) {
      debugPrint('Start listening error: $e');
      _isListening = false;
      _listeningStateController.add(false);
      _errorController.add('Failed to start listening');
      return false;
    }
  }

  Future<bool> stopListening() async {
    if (!_isListening) return true;

    try {
      await _speech.stop();
      _isListening = false;
      _listeningStateController.add(false);
      return true;
    } catch (e) {
      debugPrint('Stop listening error: $e');
      return false;
    }
  }

  Future<bool> cancelListening() async {
    if (!_isListening) return true;

    try {
      await _speech.cancel();
      _isListening = false;
      _listeningStateController.add(false);
      _lastWords = '';
      return true;
    } catch (e) {
      debugPrint('Cancel listening error: $e');
      return false;
    }
  }

  Future<void> speak(String text, {double? rate, double? volume}) async {
    if (text.isEmpty) return;

    try {
      await _tts.setSpeechRate(rate ?? 0.5);
      await _tts.setVolume(volume ?? 1.0);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS error: $e');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('Stop speaking error: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      _selectedLocaleId = languageCode;
      await _tts.setLanguage(languageCode);
    } catch (e) {
      debugPrint('Set language error: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate);
    } catch (e) {
      debugPrint('Set speech rate error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _tts.setVolume(volume);
    } catch (e) {
      debugPrint('Set volume error: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch);
    } catch (e) {
      debugPrint('Set pitch error: $e');
    }
  }

  Future<List<String>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _availableLocales.map((locale) => locale.localeId).toList();
  }

  bool get hasRecognizedWords => _lastWords.isNotEmpty;

  void clearLastWords() {
    _lastWords = '';
  }

  void dispose() {
    _speech.cancel();
    _tts.stop();
    _speechStreamController.close();
    _listeningStateController.close();
    _errorController.close();
    _isInitialized = false;
  }
}

class LocaleName {
  final String localeId;
  final String name;

  LocaleName(this.localeId, this.name);

  @override
  String toString() => '$name ($localeId)';
}
