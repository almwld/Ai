import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'voice_provider.dart';

final voiceProvider = ChangeNotifierProvider<VoiceProvider>((ref) {
  return VoiceProvider();
});
