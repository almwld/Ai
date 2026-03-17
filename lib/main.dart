import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/download_progress_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/commands/all_commands_screen.dart';
import 'screens/commands/command_history_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/permissions_screen.dart';
import 'screens/settings/apps_management_screen.dart';
import 'screens/settings/model_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open Hive boxes
  await Hive.openBox('settings');
  await Hive.openBox('commands');
  await Hive.openBox('learning');
  
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
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/download': (context) => const DownloadProgressScreen(),
        '/home': (context) => const HomeScreen(),
        '/commands': (context) => const AllCommandsScreen(),
        '/command_history': (context) => const CommandHistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/permissions': (context) => const PermissionsScreen(),
        '/apps_management': (context) => const AppsManagementScreen(),
        '/model_management': (context) => const ModelManagementScreen(),
      },
    );
  }
}
