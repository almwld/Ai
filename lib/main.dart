import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:maestro_ai/core/theme/app_theme.dart';
import 'package:maestro_ai/screens/home/home_screen.dart';
import 'package:maestro_ai/screens/settings/settings_screen.dart';
import 'package:maestro_ai/screens/commands/command_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('commands');
  
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
      },
    );
  }
}
