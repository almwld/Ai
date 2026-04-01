import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_model.dart';
import '../services/learning_service.dart';

final learningProvider = StateNotifierProvider<LearningNotifier, LearningState>((ref) {
  return LearningNotifier();
});

class LearningState {
  final bool isInitialized;
  final Map<String, LearningModel> learningData;
  final List<VoiceProfileModel> voiceProfiles;
  final Map<String, dynamic> statistics;
  final String? error;

  LearningState({
    this.isInitialized = false,
    this.learningData = const {},
    this.voiceProfiles = const [],
    this.statistics = const {},
    this.error,
  });

  LearningState copyWith({
    bool? isInitialized,
    Map<String, LearningModel>? learningData,
    List<VoiceProfileModel>? voiceProfiles,
    Map<String, dynamic>? statistics,
    String? error,
  }) {
    return LearningState(
      isInitialized: isInitialized ?? this.isInitialized,
      learningData: learningData ?? this.learningData,
      voiceProfiles: voiceProfiles ?? this.voiceProfiles,
      statistics: statistics ?? this.statistics,
      error: error,
    );
  }
}

class LearningNotifier extends StateNotifier<LearningState> {
  final LearningService _learningService = LearningService();

  LearningNotifier() : super(LearningState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _learningService.initialize();
    state = state.copyWith(
      isInitialized: true,
      learningData: _learningService.getAllLearningData(),
      voiceProfiles: _learningService.getAllVoiceProfiles(),
      statistics: _learningService.getStatistics(),
    );
  }

  void recordCommandUsage(String commandType, String input, {bool success = true}) {
    _learningService.recordCommandUsage(commandType, input, success: success);
    state = state.copyWith(
      learningData: _learningService.getAllLearningData(),
      statistics: _learningService.getStatistics(),
    );
  }

  @override
  void dispose() {
    _learningService.dispose();
    super.dispose();
  }
}
