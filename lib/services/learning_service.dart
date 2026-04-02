import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/learning_model.dart';

class LearningService {
  static final LearningService _instance = LearningService._internal();
  factory LearningService() => _instance;
  LearningService._internal();

  late Box _learningBox;
  bool _isInitialized = false;

  final Map<String, LearningModel> _learningCache = {};

  Future<void> initialize() async {
    if (_isInitialized) return;
    _learningBox = Hive.box(AppConstants.learningBox);
    _isInitialized = true;
  }

  Future<void> recordCommandUsage(
    String commandType,
    String input, {
    bool success = true,
    Map<String, dynamic> metadata = const {},
  }) async {
    if (!_isInitialized) await initialize();

    if (_learningCache.containsKey(commandType)) {
      final existing = _learningCache[commandType]!;
      _learningCache[commandType] = LearningModel(
        commandType: commandType,
        variations: [...existing.variations, input],
        usageCount: existing.usageCount + 1,
        lastUsed: DateTime.now(),
        successRate: success ? existing.successRate : existing.successRate * 0.9,
        metadata: metadata,
      );
    } else {
      _learningCache[commandType] = LearningModel(
        commandType: commandType,
        variations: [input],
        usageCount: 1,
        lastUsed: DateTime.now(),
        successRate: success ? 1.0 : 0.0,
        metadata: metadata,
      );
    }

    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final data = _learningCache.map((k, v) => MapEntry(k, v.toJson()));
      await _learningBox.put('learning_data', data);
    } catch (e) {
      print('Error saving: $e');
    }
  }

  Map<String, LearningModel> getAllLearningData() {
    return Map.unmodifiable(_learningCache);
  }

  List<VoiceProfileModel> getAllVoiceProfiles() {
    return [];
  }

  Map<String, dynamic> getStatistics() {
    return {
      'totalCommands': _learningCache.length,
      'totalUsages': _learningCache.values.fold<int>(0, (sum, data) => sum + data.usageCount),
      'averageSuccessRate': _learningCache.isEmpty ? 0.0 : 
          _learningCache.values.fold<double>(0, (sum, data) => sum + data.successRate) / _learningCache.length,
    };
  }

  void dispose() {
    _saveToStorage();
  }
}
