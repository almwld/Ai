import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/command_categories.dart';

class AllCommandsScreen extends StatelessWidget {
  const AllCommandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = CommandCategories.categories;

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('جميع الأوامر'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final entry = categories.entries.elementAt(index);
          return _CategoryCard(
            categoryKey: entry.key,
            categoryData: entry.value,
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryKey;
  final Map<String, dynamic> categoryData;

  const _CategoryCard({
    required this.categoryKey,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(categoryData['color'] as int);
    final commands = categoryData['commands'] as List<Map<String, dynamic>>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Icon(
            _getIconData(categoryData['icon'] as String),
            color: color,
          ),
        ),
        title: Text(
          categoryData['name'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${commands.length} أمر',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        children: commands.map((cmd) {
          return _CommandTile(
            command: cmd['command'] as String,
            example: cmd['example'] as String,
            description: cmd['description'] as String,
            color: color,
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'apps':
        return Icons.apps;
      case 'phone':
        return Icons.phone;
      case 'message':
        return Icons.message;
      case 'settings':
        return Icons.settings;
      case 'memory':
        return Icons.memory;
      case 'play_circle':
        return Icons.play_circle;
      case 'folder':
        return Icons.folder;
      case 'accessibility':
        return Icons.accessibility;
      default:
        return Icons.help;
    }
  }
}

class _CommandTile extends StatelessWidget {
  final String command;
  final String example;
  final String description;
  final Color color;

  const _CommandTile({
    required this.command,
    required this.example,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
      title: Text(
        example,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          command,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
