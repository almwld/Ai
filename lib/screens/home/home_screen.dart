import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/voice_provider.dart';
import '../../providers/command_provider.dart';
import '../../models/voice_state.dart';
import '../../models/command_state.dart'; // استيراد واحد فقط
import '../../providers/providers.dart'; // تأكد من استيراد providers.dart
import 'widgets/glowing_brain.dart';
import 'widgets/voice_visualizer.dart';
import 'widgets/command_result_card.dart';
import 'widgets/quick_commands_grid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    await ref.read(voiceProvider.notifier).startListening();
  }

  Future<void> _stopListening() async {
    final voice = ref.read(voiceProvider);
    await ref.read(voiceProvider.notifier).stopListening();

    // Process the recognized text
    if (voice.lastWords.isNotEmpty) {
      await ref.read(commandProvider.notifier).processCommand(voice.lastWords);
    }
  }

  void _executeQuickCommand(String command) {
    ref.read(commandProvider.notifier).executeQuickCommand(command);
  }

  String _getStatusText(VoiceProvider voiceProv, CommandState commandState) {
    final voiceState = voiceProv.state;

    if (voiceState == VoiceState.listening) {
      return 'استمع... تحدث الآن';
    }
    if (commandState == CommandState.processing) {
      return 'جاري معالجة الأمر...';
    }
    // لاحظ أننا لا نستطيع الوصول إلى lastCommand مباشرة من commandProvider هنا
    // لأن commandProvider هو StateNotifierProvider وليس الكائن نفسه.
    // سنحتاج إلى قراءة الحالة من الـ notifier بطريقة مختلفة.
    // هذا الجزء سيحتاج إلى تعديل حسب بنية command_provider.dart.
    // بشكل مؤقت، سنستخدم قيمة افتراضية.
    return 'اضغط على الميكروفون للتحدث';
  }

  @override
  Widget build(BuildContext context) {
    final voiceProv = ref.watch(voiceProvider);
    // لقراءة حالة commandProvider، يجب أن نستخدم ref.watch على الـ provider نفسه
    // ثم نصل إلى الخصائص عبر state
    final commandState = ref.watch(commandProvider); // هذا يعيد كائن CommandState (من command_provider.dart)
    // لكن لاحظ أن commandProvider هنا هو StateNotifierProvider، وليس الكائن.
    // الطريقة الصحيحة: final commandNotifier = ref.watch(commandProvider.notifier); ثم الوصول إلى state.
    // لكن بما أننا نريد الحالة فقط، يمكننا استخدام ref.watch(commandProvider) الذي يعيد CommandState.

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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cyanAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.cyanAccent.withOpacity(0.5),
                              ),
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
                            onPressed: () {
                              Navigator.pushNamed(context, '/command_history');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white70),
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
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
                        _getStatusText(voiceProv, commandState),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ).animate().fadeIn(),

                      const SizedBox(height: 20),

                      // Glowing brain
                      GlowingBrain(
                        isListening: voiceProv.isListening,
                        pulseController: _pulseController,
                      ),

                      const SizedBox(height: 40),

                      // Last command result - يجب الوصول إلى lastCommand عبر commandState
                      // if (commandState.lastCommand != null)
                      //   CommandResultCard(
                      //     command: commandState.lastCommand!,
                      //   ).animate().slideY(
                      //     begin: 0.5,
                      //     end: 0,
                      //     duration: 500.ms,
                      //     curve: Curves.easeOut,
                      //   ),

                      const SizedBox(height: 20),

                      // Voice visualizer and mic button
                      VoiceVisualizer(
                        isListening: voiceProv.isListening,
                        onListeningStart: _startListening,
                        onListeningStop: _stopListening,
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
