import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomCommandsScreen extends StatefulWidget {
  const CustomCommandsScreen({super.key});

  @override
  State<CustomCommandsScreen> createState() => _CustomCommandsScreenState();
}

class _CustomCommandsScreenState extends State<CustomCommandsScreen> {
  final List<Map<String, String>> _customCommands = [];

  final TextEditingController _commandController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();

  void _addCommand() {
    if (_commandController.text.isNotEmpty && _actionController.text.isNotEmpty) {
      setState(() {
        _customCommands.add({
          'command': _commandController.text,
          'action': _actionController.text,
        });
        _commandController.clear();
        _actionController.clear();
      });
    }
  }

  void _deleteCommand(int index) {
    setState(() {
      _customCommands.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('الأوامر المخصصة'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Add command form
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _commandController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'مثال: صباح الخير',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    labelText: 'الأمر الصوتي',
                    labelStyle: TextStyle(color: AppTheme.cyanAccent),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.cyanAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _actionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'مثال: افتح الأخبار',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    labelText: 'الإجراء',
                    labelStyle: TextStyle(color: AppTheme.purpleAccent),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.purpleAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addCommand,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة أمر'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyanAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // Commands list
          Expanded(
            child: _customCommands.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 80, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد أوامر مخصصة',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أضف أمرك الأول أعلاه',
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _customCommands.length,
                    itemBuilder: (context, index) {
                      final cmd = _customCommands[index];
                      return Card(
                        color: AppTheme.darkCard,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.cyanAccent.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.mic, color: AppTheme.cyanAccent),
                          ),
                          title: Text(cmd['command']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(cmd['action']!, style: TextStyle(color: Colors.white.withOpacity(0.5))),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: AppTheme.errorRed),
                            onPressed: () => _deleteCommand(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
