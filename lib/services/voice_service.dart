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

  Future<bool> stopListening() async {
    await _speech.stop();
    return true;
  }

  void cancelListening() => stopListening();

  Future<void> speak(String text, {double? rate, double? volume}) async {
    if (rate != null) await _tts.setSpeechRate(rate);
    if (volume != null) await _tts.setVolume(volume);
    await _tts.speak(text);
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
  }
}
