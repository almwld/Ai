import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'التطبيقات', 'icon': Icons.apps, 'color': 0xFF00BCD4, 'count': 24},
    {'name': 'المكالمات', 'icon': Icons.phone, 'color': 0xFF4CAF50, 'count': 12},
    {'name': 'الرسائل', 'icon': Icons.message, 'color': 0xFFFF9800, 'count': 8},
    {'name': 'الإعدادات', 'icon': Icons.settings, 'color': 0xFF9C27B0, 'count': 16},
    {'name': 'الوسائط', 'icon': Icons.music_note, 'color': 0xFFE91E63, 'count': 20},
    {'name': 'الملفات', 'icon': Icons.folder, 'color': 0xFF795548, 'count': 10},
    {'name': 'النظام', 'icon': Icons.memory, 'color': 0xFFF44336, 'count': 14},
    {'name': 'المفضلة', 'icon': Icons.favorite, 'color': 0xFFFF4081, 'count': 6},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('الأقسام'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _CategoryCard(
            name: category['name'],
            icon: category['icon'],
            color: Color(category['color']),
            count: category['count'],
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$count أمر',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
