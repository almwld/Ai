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
    
    _refreshState();
  }

  void _refreshState() {
    state = state.copyWith(
      isInitialized: true,
      learningData: _learningService.getAllLearningData(),
      voiceProfiles: _learningService.getAllVoiceProfiles(),
      statistics: _learningService.getStatistics(),
    );
  }

  Future<void> recordCommandUsage(
    String commandType,
    String input, {
    bool success = true,
    Map<String, dynamic> metadata = const {},
  }) async {
    await _learningService.recordCommandUsage(
      commandType,
      input,
      success: success,
      metadata: metadata,
    );
    
    _refreshState();
  }

  LearningModel? getLearningData(String commandType) {
    return _learningService.getLearningData(commandType);
  }

  List<MapEntry<String, LearningModel>> getMostUsedCommands({int limit = 5}) {
    return _learningService.getMostUsedCommands(limit: limit);
  }

  List<MapEntry<String, LearningModel>> getMostSuccessfulCommands({int limit = 5}) {
    return _learningService.getMostSuccessfulCommands(limit: limit);
  }

  List<MapEntry<String, LearningModel>> getRecentlyUsedCommands({int limit = 5}) {
    return _learningService.getRecentlyUsedCommands(limit: limit);
  }

  List<String> getSuggestions(String input, {int limit = 5}) {
    return _learningService.getSuggestions(input, limit: limit);
  }

  // Voice Profile Methods
  Future<void> createVoiceProfile(String name, {Map<String, dynamic>? characteristics}) async {
    await _learningService.createVoiceProfile(name, characteristics: characteristics);
    _refreshState();
  }

  Future<void> updateVoiceProfile(
    String id, {
    String? name,
    Map<String, dynamic>? characteristics,
  }) async {
    await _learningService.updateVoiceProfile(
      id,
      name: name,
      characteristics: characteristics,
    );
    _refreshState();
  }

  Future<void> deleteVoiceProfile(String id) async {
    await _learningService.deleteVoiceProfile(id);
    _refreshState();
  }

  Future<void> incrementVoiceProfileUsage(String id) async {
    await _learningService.incrementVoiceProfileUsage(id);
    _refreshState();
  }

  VoiceProfileModel? getVoiceProfile(String id) {
    return _learningService.getVoiceProfile(id);
  }

  // Data Management
  Future<void> clearAllData() async {
    await _learningService.clearAllData();
    _refreshState();
  }

  String exportData() {
    return _learningService.exportData();
  }

  Future<bool> importData(String jsonData) async {
    final result = await _learningService.importData(jsonData);
    if (result) {
      _refreshState();
    }
    return result;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _learningService.dispose();
    super.dispose();
  }
}
