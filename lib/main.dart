import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:maestro_ai/core/constants/app_constants.dart';
import 'package:maestro_ai/core/theme/app_theme.dart';
import 'package:maestro_ai/routes/app_router.dart';
import 'package:maestro_ai/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox(AppConstants.commandsBox);
  await Hive.openBox(AppConstants.learningBox);
  
  runApp(
    const ProviderScope(
      child: MaestroAIApp(),
    ),
  );
}

class MaestroAIApp extends ConsumerStatefulWidget {
  const MaestroAIApp({super.key});

  @override
  ConsumerState<MaestroAIApp> createState() => _MaestroAIAppState();
}

class _MaestroAIAppState extends ConsumerState<MaestroAIApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
