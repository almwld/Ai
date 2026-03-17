class AppConstants {
  // App Info
  static const String appName = 'Maestro AI';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'تحكم في هاتفك بصوتك';
  
  // Model Info
  static const String modelUrl = 
      'https://huggingface.co/lmstudio-community/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf';
  static const String modelFileName = 'llama_model.gguf';
  static const int modelSizeMB = 780;
  
  // Storage Keys
  static const String settingsBox = 'settings';
  static const String commandsBox = 'commands';
  static const String learningBox = 'learning';
  static const String keyFirstRun = 'first_run';
  static const String keyModelDownloaded = 'model_downloaded';
  static const String keyModelPath = 'model_path';
  static const String keyLanguage = 'language';
  static const String keyDarkMode = 'dark_mode';
  
  // Method Channel
  static const String methodChannel = 'maestro_ai/native';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);
  
  // Voice Settings
  static const Duration listeningTimeout = Duration(seconds: 10);
  static const String defaultLanguage = 'ar_SA';
  
  // Commands
  static const int maxCommandHistory = 100;
  static const double minConfidenceThreshold = 0.6;
}
