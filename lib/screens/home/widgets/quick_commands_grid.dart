import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/command_categories.dart';

class QuickCommandsGrid extends StatelessWidget {
  final Function(String) onCommandSelected;

  const QuickCommandsGrid({
    super.key,
    required this.onCommandSelected,
  });

  final List<Map<String, dynamic>> _quickCommands = const [
    {'icon': Icons.wifi, 'label': 'واي فاي', 'command': 'TOGGLE_WIFI', 'params': {'enable': true}},
    {'icon': Icons.bluetooth, 'label': 'بلوتوث', 'command': 'TOGGLE_BLUETOOTH', 'params': {'enable': true}},
    {'icon': Icons.brightness_6, 'label': 'سطوع', 'command': 'SET_BRIGHTNESS', 'params': {'action': 'increase'}},
    {'icon': Icons.volume_up, 'label': 'صوت', 'command': 'SET_VOLUME', 'params': {'action': 'increase'}},
    {'icon': Icons.battery_full, 'label': 'بطارية', 'command': 'BATTERY_STATUS'},
    {'icon': Icons.cleaning_services, 'label': 'تنظيف', 'command': 'CLEAR_RAM'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أوامر سريعة',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _quickCommands.map((cmd) {
              return _QuickCommandButton(
                icon: cmd['icon'] as IconData,
                label: cmd['label'] as String,
                onTap: () => onCommandSelected(cmd['command'] as String),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickCommandButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickCommandButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cyanAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cyanAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppTheme.cyanAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
