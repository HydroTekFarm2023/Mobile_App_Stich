import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Camera Feeds',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 32),
            _buildCameraCard(context, 'CAM 01 - MAIN TANK', 0.85, 'Connection Quality', theme.colorScheme.primary),
            const SizedBox(height: 24),
            _buildCameraCard(context, 'CAM 02 - SEEDLINGS', 0.40, 'Connection Quality', theme.colorScheme.error),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraCard(BuildContext context, String title, double progress, String metricName, Color barColor) {
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? null : Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.videocam_off,
                  size: 64,
                  color: Colors.white24,
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(metricName, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('${(progress * 100).toInt()}%', style: TextStyle(color: barColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
