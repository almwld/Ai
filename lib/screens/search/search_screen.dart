import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  final List<Map<String, dynamic>> _allCommands = [
    {'command': 'افتح واتساب', 'category': 'التطبيقات', 'icon': Icons.chat},
    {'command': 'شغل الواي فاي', 'category': 'الإعدادات', 'icon': Icons.wifi},
    {'command': 'اتصل بأحمد', 'category': 'المكالمات', 'icon': Icons.phone},
    {'command': 'أرسل رسالة', 'category': 'الرسائل', 'icon': Icons.message},
    {'command': 'كم البطارية', 'category': 'النظام', 'icon': Icons.battery_full},
    {'command': 'شغل أغنية', 'category': 'الوسائط', 'icon': Icons.music_note},
    {'command': 'صور', 'category': 'الوسائط', 'icon': Icons.camera_alt},
    {'command': 'نظف الذاكرة', 'category': 'النظام', 'icon': Icons.cleaning_services},
  ];

  List<Map<String, dynamic>> get _filteredCommands {
    if (_searchQuery.isEmpty) return _allCommands;
    return _allCommands.where((cmd) =>
      cmd['command'].toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        title: const Text('البحث'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ابحث عن أمر...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.5)),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.darkCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Results
          Expanded(
            child: _filteredCommands.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد نتائج',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCommands.length,
                    itemBuilder: (context, index) {
                      final cmd = _filteredCommands[index];
                      return _SearchResultCard(
                        command: cmd['command'],
                        category: cmd['category'],
                        icon: cmd['icon'],
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم تنفيذ: ${cmd['command']}')),
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String command;
  final String category;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.command,
    required this.category,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.darkCard,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cyanAccent.withOpacity(0.2),
          ),
          child: Icon(icon, color: AppTheme.cyanAccent, size: 20),
        ),
        title: Text(command, style: const TextStyle(color: Colors.white)),
        subtitle: Text(category, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        trailing: const Icon(Icons.play_arrow, color: AppTheme.cyanAccent),
      ),
    );
  }
}
