import '../models/command_model.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  bool _isInitialized = false;
  String? _modelPath;

  final Map<String, List<String>> _commandPatterns = {
    'OPEN_APP': ['افتح', 'شغل', 'فتح', 'open'],
    'CLOSE_APP': ['اغلق', 'اقفل', 'close'],
    'MAKE_CALL': ['اتصل', 'كلم', 'call'],
    'SEND_SMS': ['أرسل رسالة', 'ابعت رسالة', 'send sms'],
    'TOGGLE_WIFI': ['الواي فاي', 'wifi'],
    'TOGGLE_BLUETOOTH': ['البلوتوث', 'bluetooth'],
    'SET_BRIGHTNESS': ['السطوع', 'brightness'],
    'SET_VOLUME': ['الصوت', 'volume'],
    'PLAY_MEDIA': ['شغل أغنية', 'شغل فيديو', 'play'],
    'GET_BATTERY': ['البطارية', 'battery'],
    'STORAGE_INFO': ['المساحة', 'storage'],
    'DEVICE_INFO': ['معلومات الجهاز', 'device info'],
  };

  bool get isInitialized => _isInitialized;
  String? get modelPath => _modelPath;

  Future<void> initialize(String modelPath) async {
    _modelPath = modelPath;
    _isInitialized = true;
  }

  Future<CommandModel> processCommand(String userInput) async {
    final lowerInput = userInput.toLowerCase().trim();

    for (var entry in _commandPatterns.entries) {
      for (var pattern in entry.value) {
        if (lowerInput.contains(pattern.toLowerCase())) {
          return CommandModel(
            originalInput: userInput,
            command: entry.key,
            params: {},
            confidence: 0.8,
            timestamp: DateTime.now(),
          );
        }
      }
    }

    return CommandModel(
      originalInput: userInput,
      command: 'UNKNOWN',
      params: {},
      confidence: 0.0,
      timestamp: DateTime.now(),
    );
  }

  void dispose() {
    _isInitialized = false;
    _modelPath = null;
  }
}
