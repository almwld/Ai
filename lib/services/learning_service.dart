import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/learning_model.dart';

class LearningService {
  static final LearningService _instance = LearningService._internal();
  factory LearningService() => _instance;
  LearningService._internal();

  late Box _learningBox;
  bool _isInitialized = false;

  // In-memory cache
  final Map<String, LearningModel> _learningCache = {};
  final Map<String, VoiceProfileModel> _voiceProfiles = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    _learningBox = Hive.box(AppConstants.learningBox);
    
    // Load cached data
    await _loadFromStorage();
    
    _isInitialized = true;
  }

  Future<void> _loadFromStorage() async {
    try {
      // Load learning data
      final learningData = _learningBox.get('learning_data');
      if (learningData != null) {
        final Map<String, dynamic> decoded = jsonDecode(learningData);
        decoded.forEach((key, value) {
          _learningCache[key] = LearningModel.fromJson(value);
        });
      }

      // Load voice profiles
      final voiceData = _learningBox.get('voice_profiles');
      if (voiceData != null) {
        final Map<String, dynamic> decoded = jsonDecode(voiceData);
        decoded.forEach((key, value) {
          _voiceProfiles[key] = VoiceProfileModel.fromJson(value);
        });
      }
    } catch (e) {
      print('Error loading learning data: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      // Save learning data
      final learningJson = _learningCache.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await _learningBox.put('learning_data', jsonEncode(learningJson));

      // Save voice profiles
      final voiceJson = _voiceProfiles.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await _learningBox.put('voice_profiles', jsonEncode(voiceJson));
    } catch (e) {
      print('Error saving learning data: $e');
    }
  }

  // Record command usage
  Future<void> recordCommandUsage(
    String commandType,
    String input, {
    bool success = true,
    Map<String, dynamic> metadata = const {},
  }) async {
    if (!_isInitialized) await initialize();

    final now = DateTime.now();
    
    if (_learningCache.containsKey(commandType)) {
      final existing = _learningCache[commandType]!;
      _learningCache[commandType] = existing
          .incrementUsage()
          .updateSuccessRate(success)
          .addVariation(input);
    } else {
      _learningCache[commandType] = LearningModel(
        commandType: commandType,
        variations: [input],
        usageCount: 1,
        lastUsed: now,
        successRate: success ? 1.0 : 0.0,
        metadata: metadata,
      );
    }

    await _saveToStorage();
  }

  // Get learning data for a command type
  LearningModel? getLearningData(String commandType) {
    return _learningCache[commandType];
  }

  // Get all learning data
  Map<String, LearningModel> getAllLearningData() {
    return Map.unmodifiable(_learningCache);
  }

  // Get most used commands
  List<MapEntry<String, LearningModel>> getMostUsedCommands({int limit = 5}) {
    final sorted = _learningCache.entries.toList()
      ..sort((a, b) => b.value.usageCount.compareTo(a.value.usageCount));
    return sorted.take(limit).toList();
  }

  // Get commands with highest success rate
  List<MapEntry<String, LearningModel>> getMostSuccessfulCommands({int limit = 5}) {
    final sorted = _learningCache.entries.toList()
      ..sort((a, b) => b.value.successRate.compareTo(a.value.successRate));
    return sorted.take(limit).toList();
  }

  // Get recently used commands
  List<MapEntry<String, LearningModel>> getRecentlyUsedCommands({int limit = 5}) {
    final sorted = _learningCache.entries.toList()
      ..sort((a, b) => b.value.lastUsed.compareTo(a.value.lastUsed));
    return sorted.take(limit).toList();
  }

  // Get command suggestions based on input
  List<String> getSuggestions(String input, {int limit = 5}) {
    if (input.length < 2) return [];

    final suggestions = <String>[];
    final lowerInput = input.toLowerCase();

    _learningCache.forEach((commandType, data) {
      for (var variation in data.variations) {
        if (variation.toLowerCase().contains(lowerInput)) {
          suggestions.add(variation);
        }
      }
    });

    return suggestions.toSet().toList()..take(limit);
  }

  // Voice Profile Methods
  Future<void> createVoiceProfile(String name, {Map<String, dynamic>? characteristics}) async {
    if (!_isInitialized) await initialize();

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _voiceProfiles[id] = VoiceProfileModel(
      id: id,
      name: name,
      voiceCharacteristics: characteristics ?? {},
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
    );

    await _saveToStorage();
  }

  VoiceProfileModel? getVoiceProfile(String id) {
    return _voiceProfiles[id];
  }

  List<VoiceProfileModel> getAllVoiceProfiles() {
    return _voiceProfiles.values.toList();
  }

  Future<void> updateVoiceProfile(String id, {String? name, Map<String, dynamic>? characteristics}) async {
    if (!_isInitialized) await initialize();

    final profile = _voiceProfiles[id];
    if (profile != null) {
      _voiceProfiles[id] = profile.copyWith(
        name: name,
        voiceCharacteristics: characteristics,
        lastUsed: DateTime.now(),
      );
      await _saveToStorage();
    }
  }

  Future<void> deleteVoiceProfile(String id) async {
    if (!_isInitialized) await initialize();

    _voiceProfiles.remove(id);
    await _saveToStorage();
  }

  Future<void> incrementVoiceProfileUsage(String id) async {
    if (!_isInitialized) await initialize();

    final profile = _voiceProfiles[id];
    if (profile != null) {
      _voiceProfiles[id] = profile.copyWith(
        usageCount: profile.usageCount + 1,
        lastUsed: DateTime.now(),
      );
      await _saveToStorage();
    }
  }

  // Clear all learning data
  Future<void> clearAllData() async {
    _learningCache.clear();
    _voiceProfiles.clear();
    await _learningBox.clear();
  }

  // Get learning statistics
  Map<String, dynamic> getStatistics() {
    final totalCommands = _learningCache.length;
    final totalUsages = _learningCache.values.fold<int>(
      0, (sum, data) => sum + data.usageCount,
    );
    final averageSuccessRate = _learningCache.isEmpty
        ? 0.0
        : _learningCache.values.fold<double>(
              0, (sum, data) => sum + data.successRate,
            ) /
            _learningCache.length;

    return {
      'totalCommands': totalCommands,
      'totalUsages': totalUsages,
      'averageSuccessRate': averageSuccessRate,
      'voiceProfiles': _voiceProfiles.length,
    };
  }

  // Export learning data
  String exportData() {
    final export = {
      'learningData': _learningCache.map((k, v) => MapEntry(k, v.toJson())),
      'voiceProfiles': _voiceProfiles.map((k, v) => MapEntry(k, v.toJson())),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return jsonEncode(export);
  }

  // Import learning data
  Future<bool> importData(String jsonData) async {
    try {
      final decoded = jsonDecode(jsonData);
      
      if (decoded['learningData'] != null) {
        final learningData = Map<String, dynamic>.from(decoded['learningData']);
        learningData.forEach((key, value) {
          _learningCache[key] = LearningModel.fromJson(value);
        });
      }

      if (decoded['voiceProfiles'] != null) {
        final voiceData = Map<String, dynamic>.from(decoded['voiceProfiles']);
        voiceData.forEach((key, value) {
          _voiceProfiles[key] = VoiceProfileModel.fromJson(value);
        });
      }

      await _saveToStorage();
      return true;
    } catch (e) {
      print('Error importing learning data: $e');
      return false;
    }
  }

  void dispose() {
    _saveToStorage();
  }
}
