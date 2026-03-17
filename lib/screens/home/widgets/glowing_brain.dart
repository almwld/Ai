import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GlowingBrain extends StatelessWidget {
  final bool isListening;
  final AnimationController pulseController;

  const GlowingBrain({
    super.key,
    required this.isListening,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final scale = isListening
            ? 1.0 + (pulseController.value * 0.1)
            : 1.0 + (pulseController.value * 0.05);
        
        final glowOpacity = isListening
            ? 0.6 + (pulseController.value * 0.4)
            : 0.3 + (pulseController.value * 0.2);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.cyanAccent.withOpacity(glowOpacity),
                  AppTheme.purpleAccent.withOpacity(glowOpacity * 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cyanAccent.withOpacity(glowOpacity * 0.5),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
                BoxShadow(
                  color: AppTheme.purpleAccent.withOpacity(glowOpacity * 0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.cyanAccent,
                      AppTheme.purpleAccent.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.psychology,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
