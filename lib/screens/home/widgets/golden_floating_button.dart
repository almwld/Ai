import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class GoldenFloatingButton extends StatefulWidget {
  final VoidCallback onCommandSelected;
  final List<QuickAction> actions;

  const GoldenFloatingButton({
    super.key,
    required this.onCommandSelected,
    required this.actions,
  });

  @override
  State<GoldenFloatingButton> createState() => _GoldenFloatingButtonState();
}

class _GoldenFloatingButtonState extends State<GoldenFloatingButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _rotationController.forward();
      } else {
        _rotationController.reverse();
      }
    });
  }

  @override
Widget build(BuildContext context) {
  return Stack(
    alignment: Alignment.bottomCenter,
    children: [
      // الخيارات الأربعة (تظهر عند الضغط)
      if (_isExpanded)
        Positioned(
          bottom: 80,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.goldColor.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;
                return _buildActionButton(
                  action,
                  index,
                  widget.actions.length,
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 50 * index),
                  duration: 300.ms,
                ).scale(
                  begin: const Offset(0, 0.5),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                );
              }).toList(),
            ),
          ),
        ),

      // الزر الذهبي الدوار
      Positioned(
        bottom: 20,
        child: GestureDetector(
          onTap: _toggleExpand,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 3.14159 * 2,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.goldColor,
                        AppTheme.goldColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldColor.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

  Widget _buildActionButton(QuickAction action, int index, int total) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: index == 0 || index == total - 1 ? 8 : 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _toggleExpand();
                action.onTap();
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: action.color.withOpacity(0.2),
                  border: Border.all(
                    color: action.color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
