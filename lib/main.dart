import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:maestro_ai/core/theme/app_theme.dart';
import 'package:maestro_ai/screens/home/home_screen.dart';
import 'package:maestro_ai/screens/settings/settings_screen.dart';
import 'package:maestro_ai/screens/commands/command_history_screen.dart';
import 'package:maestro_ai/screens/commands/custom_commands_screen.dart';
import 'package:maestro_ai/screens/profile/profile_screen.dart';
import 'package:maestro_ai/screens/notifications/notifications_screen.dart';
import 'package:maestro_ai/screens/categories/categories_screen.dart';
import 'package:maestro_ai/screens/search/search_screen.dart';
import 'package:maestro_ai/screens/about/about_screen.dart';
import 'package:maestro_ai/screens/stats/stats_screen.dart';
import 'package:maestro_ai/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('commands');
  await Hive.openBox('custom_commands');
  
  NotificationService().showTestNotification();
  
  runApp(
    const ProviderScope(
      child: MaestroAIApp(),
    ),
  );
}

class MaestroAIApp extends StatelessWidget {
  const MaestroAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maestro AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: const Locale('ar', 'SA'),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/command_history': (context) => const CommandHistoryScreen(),
        '/custom_commands': (context) => const CustomCommandsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/search': (context) => const SearchScreen(),
        '/about': (context) => const AboutScreen(),
        '/stats': (context) => const StatsScreen(),
      },
    );
  }
}
