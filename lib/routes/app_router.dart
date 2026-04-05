import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/download_progress_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/commands/all_commands_screen.dart';
import '../screens/commands/command_history_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/permissions_screen.dart';
import '../screens/settings/apps_management_screen.dart';
import '../screens/settings/model_management_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String download = '/download';
  static const String home = '/home';
  static const String commands = '/commands';
  static const String commandHistory = '/command_history';
  static const String settings = '/settings';
  static const String permissions = '/permissions';
  static const String appsManagement = '/apps_management';
  static const String modelManagement = '/model_management';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRouter.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case AppRouter.download:
        return MaterialPageRoute(builder: (_) => const DownloadProgressScreen());
      case AppRouter.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRouter.commands:
        return MaterialPageRoute(builder: (_) => const AllCommandsScreen());
      case AppRouter.commandHistory:
        return MaterialPageRoute(builder: (_) => const CommandHistoryScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRouter.permissions:
        return MaterialPageRoute(builder: (_) => const PermissionsScreen());
      case AppRouter.appsManagement:
        return MaterialPageRoute(builder: (_) => const AppsManagementScreen());
      case AppRouter.modelManagement:
        return MaterialPageRoute(builder: (_) => const ModelManagementScreen());
      case AppRouter.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))));
    }
  }
}
