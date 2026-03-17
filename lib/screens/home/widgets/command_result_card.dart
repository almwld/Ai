import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/command_model.dart';

class CommandResultCard extends StatelessWidget {
  final CommandModel command;

  const CommandResultCard({
    super.key,
    required this.command,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = command.success == true;
    final isError = command.success == false;
    final isPending = command.success == null;

    Color statusColor;
    IconData statusIcon;

    if (isSuccess) {
      statusColor = AppTheme.successGreen;
      statusIcon = Icons.check_circle;
    } else if (isError) {
      statusColor = AppTheme.errorRed;
      statusIcon = Icons.error;
    } else {
      statusColor = AppTheme.warningOrange;
      statusIcon = Icons.pending;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              // Command icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(command.getColorValue()).withOpacity(0.2),
                ),
                child: Icon(
                  _getIconData(command.getIconName()),
                  color: Color(command.getColorValue()),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Command text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      command.getDisplayText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      command.originalInput,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status icon
              Icon(
                statusIcon,
                color: statusColor,
                size: 28,
              ),
            ],
          ),

          // Error message if any
          if (isError && command.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.errorRed.withOpacity(0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      command.errorMessage!,
                      style: TextStyle(
                        color: AppTheme.errorRed.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Confidence indicator
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'الثقة: ${(command.confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: command.confidence,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      command.confidence > 0.8
                          ? AppTheme.successGreen
                          : command.confidence > 0.5
                              ? AppTheme.warningOrange
                              : AppTheme.errorRed,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'apps':
        return Icons.apps;
      case 'phone':
        return Icons.phone;
      case 'message':
        return Icons.message;
      case 'wifi':
        return Icons.wifi;
      case 'bluetooth':
        return Icons.bluetooth;
      case 'location_on':
        return Icons.location_on;
      case 'brightness_6':
        return Icons.brightness_6;
      case 'volume_up':
        return Icons.volume_up;
      case 'play_circle':
        return Icons.play_circle;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'battery_full':
        return Icons.battery_full;
      case 'storage':
        return Icons.storage;
      case 'memory':
        return Icons.memory;
      case 'phone_android':
        return Icons.phone_android;
      case 'power_settings_new':
        return Icons.power_settings_new;
      case 'screen_share':
        return Icons.screen_share;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'folder':
        return Icons.folder;
      default:
        return Icons.assistant;
    }
  }
}
