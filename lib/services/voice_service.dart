import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isAvailable = false;
  List<LocaleName> _availableLocales = [];
  String _lastWords = '';

  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize();
    if (_isAvailable) {
      _availableLocales = await _speech.locales();
    }
    await _tts.setLanguage('ar-SA');
    return _isAvailable;
  }

  List<LocaleName> get availableLocales => _availableLocales;
  String get lastWords => _lastWords;

  Future<void> startListening(Function(String) onResult) async {
    if (!_isAvailable) return;
    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult(result.recognizedWords);
      },
      localeId: 'ar_SA',
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
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
  }
}
