import 'package:hive_flutter/hive_flutter.dart';

class StatsService {
  static final StatsService _instance = StatsService._internal();
  factory StatsService() => _instance;
  StatsService._internal();

  late Box _statsBox;

  Future<void> initialize() async {
    _statsBox = Hive.box('stats');
  }

  void incrementCommandCount() {
    final count = _statsBox.get('total_commands', defaultValue: 0);
    _statsBox.put('total_commands', count + 1);
  }

  void incrementSuccessCount() {
    final count = _statsBox.get('success_commands', defaultValue: 0);
    _statsBox.put('success_commands', count + 1);
  }

  void incrementFailedCount() {
    final count = _statsBox.get('failed_commands', defaultValue: 0);
    _statsBox.put('failed_commands', count + 1);
  }

  void addCommandToHistory(String command, bool success) {
    final history = List<Map<String, dynamic>>.from(
      _statsBox.get('command_history', defaultValue: [])
    );
    
    history.insert(0, {
      'command': command,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    if (history.length > 100) history.removeLast();
    _statsBox.put('command_history', history);
  }

  int get totalCommands => _statsBox.get('total_commands', defaultValue: 0);
  int get successCommands => _statsBox.get('success_commands', defaultValue: 0);
  int get failedCommands => _statsBox.get('failed_commands', defaultValue: 0);
  double get successRate => totalCommands > 0 ? successCommands / totalCommands : 0;
  
  List<Map<String, dynamic>> get commandHistory => 
    List<Map<String, dynamic>>.from(_statsBox.get('command_history', defaultValue: []));

  Map<String, int> getCommandFrequency() {
    final frequency = <String, int>{};
    for (var cmd in commandHistory) {
      final command = cmd['command'] as String;
      frequency[command] = (frequency[command] ?? 0) + 1;
    }
    return frequency;
  }

  void resetStats() {
    _statsBox.put('total_commands', 0);
    _statsBox.put('success_commands', 0);
    _statsBox.put('failed_commands', 0);
    _statsBox.put('command_history', []);
  }
}
