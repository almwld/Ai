import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/voice_service.dart';

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  return VoiceNotifier();
});

class VoiceState {
  final bool isInitialized;
  final bool isListening;
  final String lastWords;
  final String? error;
  final List<String> availableLanguages;
  final String selectedLanguage;

  VoiceState({
    this.isInitialized = false,
    this.isListening = false,
    this.lastWords = '',
    this.error,
    this.availableLanguages = const [],
    this.selectedLanguage = 'ar_SA',
  });

  VoiceState copyWith({
    bool? isInitialized,
    bool? isListening,
    String? lastWords,
    String? error,
    List<String>? availableLanguages,
    String? selectedLanguage,
  }) {
    return VoiceState(
      isInitialized: isInitialized ?? this.isInitialized,
      isListening: isListening ?? this.isListening,
      lastWords: lastWords ?? this.lastWords,
      error: error,
      availableLanguages: availableLanguages ?? this.availableLanguages,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  final VoiceService _voiceService = VoiceService();

  VoiceNotifier() : super(VoiceState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _voiceService.initialize();
    
    // Listen to speech stream
    _voiceService.speechStream.listen((words) {
      state = state.copyWith(lastWords: words);
    });

    // Listen to listening state
    _voiceService.listeningState.listen((isListening) {
      state = state.copyWith(isListening: isListening);
    });

    // Listen to errors
    _voiceService.errorStream.listen((error) {
      state = state.copyWith(error: error);
    });

    // Get available languages
    final languages = await _voiceService.getAvailableLanguages();

    state = state.copyWith(
      isInitialized: true,
      availableLanguages: languages,
    );
  }

  Future<bool> startListening({
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    state = state.copyWith(error: null, lastWords: '');
    return await _voiceService.startListening(
      listenFor: listenFor,
      pauseFor: pauseFor,
    );
  }

  Future<bool> stopListening() async {
    return await _voiceService.stopListening();
  }

  Future<bool> cancelListening() async {
    return await _voiceService.cancelListening();
  }

  Future<void> speak(String text, {double? rate, double? volume}) async {
    await _voiceService.speak(text, rate: rate, volume: volume);
  }

  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
  }

  Future<void> setLanguage(String languageCode) async {
    await _voiceService.setLanguage(languageCode);
    state = state.copyWith(selectedLanguage: languageCode);
  }

  Future<void> setSpeechRate(double rate) async {
    await _voiceService.setSpeechRate(rate);
  }

  void clearLastWords() {
    _voiceService.clearLastWords();
    state = state.copyWith(lastWords: '');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}
