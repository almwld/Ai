import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/command_model.dart';
import '../services/ai_service.dart';
import '../services/native_bridge.dart';
import '../services/learning_service.dart';

class CommandUIState {
  final bool isProcessing;
  final CommandModel? lastCommand;
  final List<CommandModel> commandHistory;
  final String? error;
  final bool isModelLoaded;
  final double modelLoadProgress;

  CommandUIState({
    this.isProcessing = false,
    this.lastCommand,
    this.commandHistory = const [],
    this.error,
    this.isModelLoaded = false,
    this.modelLoadProgress = 0.0,
  });

  CommandUIState copyWith({
    bool? isProcessing,
    CommandModel? lastCommand,
    List<CommandModel>? commandHistory,
    String? error,
    bool? isModelLoaded,
    double? modelLoadProgress,
  }) {
    return CommandUIState(
      isProcessing: isProcessing ?? this.isProcessing,
      lastCommand: lastCommand ?? this.lastCommand,
      commandHistory: commandHistory ?? this.commandHistory,
      error: error,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
      modelLoadProgress: modelLoadProgress ?? this.modelLoadProgress,
    );
  }
}

final commandProvider = StateNotifierProvider<CommandNotifier, CommandUIState>((ref) {
  return CommandNotifier();
});

class CommandNotifier extends StateNotifier<CommandUIState> {
  final AIService _aiService = AIService();
  final LearningService _learningService = LearningService();
  late Box _commandsBox;

  CommandNotifier() : super(CommandUIState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    _commandsBox = Hive.box(AppConstants.commandsBox);
    await _loadCommandHistory();
    await _learningService.initialize();
  }

  Future<void> _loadCommandHistory() async {
    try {
      final historyJson = _commandsBox.get('history') as List<dynamic>?;
      if (historyJson != null) {
        final history = historyJson
            .map((json) => CommandModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        state = state.copyWith(commandHistory: history);
      }
    } catch (e) {
      print('Error loading command history: $e');
    }
  }

  Future<void> _saveCommandHistory() async {
    try {
      final historyJson = state.commandHistory.map((cmd) => cmd.toJson()).toList();
      await _commandsBox.put('history', historyJson);
    } catch (e) {
      print('Error saving command history: $e');
    }
  }

  Future<void> initializeModel(String modelPath) async {
    try {
      state = state.copyWith(modelLoadProgress: 0.1);
      await _aiService.initialize(modelPath);
      state = state.copyWith(
        isModelLoaded: true,
        modelLoadProgress: 1.0,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load AI model: $e',
        modelLoadProgress: 0.0,
      );
    }
  }

  Future<void> executeCommand(String userInput) async {
    if (userInput.trim().isEmpty) return;

    state = state.copyWith(isProcessing: true, error: null);

    try {
      final command = await _aiService.processCommand(userInput);
      
      state = state.copyWith(lastCommand: command);

      final result = await NativeBridge.executeCommand(
        command.command,
        params: command.params,
      );
      
      final updatedCommand = command.copyWith(
        success: result['success'] ?? false,
        result: result.toString(),
        errorMessage: result['error'],
      );

      final newHistory = [updatedCommand, ...state.commandHistory];
      if (newHistory.length > AppConstants.maxCommandHistory) {
        newHistory.removeLast();
      }

      state = state.copyWith(
        isProcessing: false,
        lastCommand: updatedCommand,
        commandHistory: newHistory,
      );

      await _saveCommandHistory();

      await _learningService.recordCommandUsage(
        command.command,
        userInput,
        success: result['success'] ?? false,
        metadata: {'params': command.params},
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error processing command: $e',
      );
    }
  }

  void clearLastResult() {
    state = state.copyWith(lastCommand: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearHistory() {
    state = state.copyWith(commandHistory: []);
    _commandsBox.delete('history');
  }

  void removeFromHistory(int index) {
    final newHistory = List<CommandModel>.from(state.commandHistory);
    if (index >= 0 && index < newHistory.length) {
      newHistory.removeAt(index);
      state = state.copyWith(commandHistory: newHistory);
      _saveCommandHistory();
    }
  }

  @override
  void dispose() {
    _aiService.dispose();
    _learningService.dispose();
    super.dispose();
  }
}
