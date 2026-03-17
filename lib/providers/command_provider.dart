import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/command_model.dart';
import '../services/ai_service.dart';
import '../services/native_bridge.dart';
import '../services/learning_service.dart';

final commandProvider = StateNotifierProvider<CommandNotifier, CommandState>((ref) {
  return CommandNotifier();
});

class CommandState {
  final bool isProcessing;
  final CommandModel? lastCommand;
  final List<CommandModel> commandHistory;
  final String? error;
  final bool isModelLoaded;
  final double modelLoadProgress;

  CommandState({
    this.isProcessing = false,
    this.lastCommand,
    this.commandHistory = const [],
    this.error,
    this.isModelLoaded = false,
    this.modelLoadProgress = 0.0,
  });

  CommandState copyWith({
    bool? isProcessing,
    CommandModel? lastCommand,
    List<CommandModel>? commandHistory,
    String? error,
    bool? isModelLoaded,
    double? modelLoadProgress,
  }) {
    return CommandState(
      isProcessing: isProcessing ?? this.isProcessing,
      lastCommand: lastCommand ?? this.lastCommand,
      commandHistory: commandHistory ?? this.commandHistory,
      error: error,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
      modelLoadProgress: modelLoadProgress ?? this.modelLoadProgress,
    );
  }
}

class CommandNotifier extends StateNotifier<CommandState> {
  final AIService _aiService = AIService();
  final LearningService _learningService = LearningService();
  late Box _commandsBox;

  CommandNotifier() : super(CommandState()) {
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

  Future<void> processCommand(String userInput) async {
    if (userInput.trim().isEmpty) return;

    state = state.copyWith(isProcessing: true, error: null);

    try {
      // Process command with AI service
      final command = await _aiService.processCommand(userInput);
      
      state = state.copyWith(lastCommand: command);

      // Execute the command
      final result = await _executeCommand(command);
      
      // Update command with result
      final updatedCommand = command.copyWith(
        success: result['success'] ?? false,
        result: result.toString(),
        errorMessage: result['error'],
      );

      // Add to history
      final newHistory = [updatedCommand, ...state.commandHistory];
      if (newHistory.length > AppConstants.maxCommandHistory) {
        newHistory.removeLast();
      }

      state = state.copyWith(
        isProcessing: false,
        lastCommand: updatedCommand,
        commandHistory: newHistory,
      );

      // Save history
      await _saveCommandHistory();

      // Record for learning
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

  Future<Map<String, dynamic>> _executeCommand(CommandModel command) async {
    try {
      return await NativeBridge.executeCommand(
        command.command,
        params: command.params,
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Execution error: $e',
      };
    }
  }

  Future<void> executeQuickCommand(String commandType, {Map<String, dynamic> params = const {}}) async {
    final command = CommandModel(
      originalInput: commandType,
      command: commandType,
      params: params,
      confidence: 1.0,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(lastCommand: command);

    final result = await _executeCommand(command);
    
    final updatedCommand = command.copyWith(
      success: result['success'] ?? false,
      result: result.toString(),
    );

    final newHistory = [updatedCommand, ...state.commandHistory];
    if (newHistory.length > AppConstants.maxCommandHistory) {
      newHistory.removeLast();
    }

    state = state.copyWith(
      lastCommand: updatedCommand,
      commandHistory: newHistory,
    );

    await _saveCommandHistory();
  }

  Future<void> clearHistory() async {
    state = state.copyWith(commandHistory: []);
    await _commandsBox.delete('history');
  }

  Future<void> removeFromHistory(int index) async {
    final newHistory = List<CommandModel>.from(state.commandHistory);
    if (index >= 0 && index < newHistory.length) {
      newHistory.removeAt(index);
      state = state.copyWith(commandHistory: newHistory);
      await _saveCommandHistory();
    }
  }

  List<CommandModel> getSuccessfulCommands() {
    return state.commandHistory.where((cmd) => cmd.success == true).toList();
  }

  List<CommandModel> getFailedCommands() {
    return state.commandHistory.where((cmd) => cmd.success == false).toList();
  }

  List<CommandModel> getCommandsByType(String commandType) {
    return state.commandHistory.where((cmd) => cmd.command == commandType).toList();
  }

  Map<String, int> getCommandTypeCounts() {
    final counts = <String, int>{};
    for (var cmd in state.commandHistory) {
      counts[cmd.command] = (counts[cmd.command] ?? 0) + 1;
    }
    return counts;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearLastCommand() {
    state = state.copyWith(lastCommand: null);
  }

  @override
  void dispose() {
    _aiService.dispose();
    _learningService.dispose();
    super.dispose();
  }
}
