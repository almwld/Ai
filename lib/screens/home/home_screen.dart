import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/glowing_brain.dart';
import 'widgets/voice_visualizer.dart';
import 'widgets/quick_commands_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _lastCommand = '';
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _checkPermissions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.status;
    setState(() {
      _hasPermission = status.isGranted;
    });
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _startListening() async {
    if (!_hasPermission) {
      await _checkPermissions();
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _lastCommand = result.recognizedWords;
              _isListening = false;
            });
            _processCommand(result.recognizedWords);
          }
        },
        localeId: 'ar_SA',
        listenFor: const Duration(seconds: 5),
      );
    }
  }

  void _processCommand(String command) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تنفيذ: $command'),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _executeQuickCommand(String command) {
    _processCommand(command);
  }

  void _openProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _openHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سجل الأوامر - قريباً')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      body: SafeArea(
        child: Stack(
          children: [
            // Animated background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.cyanAccent.withOpacity(0.1),
                      AppTheme.deepNavy,
                      AppTheme.darkSlate,
                    ],
                    center: Alignment.center,
                    radius: 0.8,
                  ),
                ),
              ),
            ),

            // Floating particles
            ...List.generate(15, (index) {
              return Positioned(
                left: (index * 45.0) % MediaQuery.of(context).size.width,
                top: (index * 30.0) % MediaQuery.of(context).size.height,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppTheme.cyanAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ).animate(
                  onPlay: (controller) => controller.repeat(),
                ).shimmer(
                  duration: 3.seconds,
                  color: AppTheme.cyanAccent.withOpacity(0.3),
                ),
              );
            }),

            Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.cyanAccent.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: AppTheme.cyanAccent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Maestro',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.cyanAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.cyanAccent.withOpacity(0.5)),
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                color: AppTheme.cyanAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history, color: Colors.white70),
                            onPressed: _openHistory,
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white70),
                            onPressed: _openSettings,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status text
                      Text(
                        _isListening ? '🎤 استمع... تحدث الآن' : '🎙️ اضغط على الميكروفون للتحدث',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ).animate().fadeIn(),

                      const SizedBox(height: 20),

                      // Glowing brain
                      GlowingBrain(
                        isListening: _isListening,
                        pulseController: _pulseController,
                      ),

                      const SizedBox(height: 40),

                      // Last command
                      if (_lastCommand.isNotEmpty && !_isListening)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.darkCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.cyanAccent.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'آخر أمر',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _lastCommand,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Voice visualizer and mic button
                      VoiceVisualizer(
                        isListening: _isListening,
                        onListeningStart: _startListening,
                        onListeningStop: () {
                          if (_speech.isListening) {
                            _speech.stop();
                            setState(() => _isListening = false);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // Quick commands grid
                      QuickCommandsGrid(
                        onCommandSelected: _executeQuickCommand,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
