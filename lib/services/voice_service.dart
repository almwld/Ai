import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isAvailable = false;
  List<LocaleName> _availableLocales = [];

  Future<bool> initialize() async {
    _isAvailable = await _speech.initialize();
    if (_isAvailable) {
      _availableLocales = await _speech.locales();
    }
    return _isAvailable;
  }

  List<LocaleName> get availableLocales => _availableLocales;
}
