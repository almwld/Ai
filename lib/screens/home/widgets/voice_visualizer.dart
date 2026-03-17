import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class VoiceVisualizer extends StatelessWidget {
  final bool isListening;
  final VoidCallback onListeningStart;
  final VoidCallback onListeningStop;

  const VoiceVisualizer({
    super.key,
    required this.isListening,
    required this.onListeningStart,
    required this.onListeningStop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Voice wave bars (shown when listening)
        if (isListening)
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                20,
                (index) => _VoiceWaveBar(
                  delay: index * 50,
                  color: AppTheme.cyanAccent,
                ),
              ),
            ),
          )
        else
          const SizedBox(height: 60),

        const SizedBox(height: 20),

        // Mic button
        GestureDetector(
          onTapDown: (_) => onListeningStart(),
          onTapUp: (_) => onListeningStop(),
          onTapCancel: () => onListeningStop(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isListening
                    ? [AppTheme.errorRed, AppTheme.errorRed.withOpacity(0.7)]
                    : [AppTheme.cyanAccent, AppTheme.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isListening
                      ? AppTheme.errorRed.withOpacity(0.5)
                      : AppTheme.cyanAccent.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: isListening ? 15 : 5,
                ),
              ],
            ),
            child: Icon(
              isListening ? Icons.stop : Icons.mic,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Hint text
        Text(
          isListening ? 'أفلت للإيقاف' : 'اضغط مطولاً للتحدث',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _VoiceWaveBar extends StatefulWidget {
  final int delay;
  final Color color;

  const _VoiceWaveBar({
    required this.delay,
    required this.color,
  });

  @override
  State<_VoiceWaveBar> createState() => _VoiceWaveBarState();
}

class _VoiceWaveBarState extends State<_VoiceWaveBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 4,
          height: 40 * _animation.value,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.5 + (_animation.value * 0.5)),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
