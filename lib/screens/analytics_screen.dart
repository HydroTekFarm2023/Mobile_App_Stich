import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(28.0),
          children: [
            Text('Analytics Trends', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Historical data and operational insights.', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
            const SizedBox(height: 32),

            // Bar chart placeholder styled up
            Container(
              height: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? null : Border.all(color: colorScheme.outlineVariant.withOpacity(0.2), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weekly Water Usage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text('Last 7 Days', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: colorScheme.primary, size: 16),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar(0.4, 'Mo', colorScheme.secondary),
                        _buildBar(0.6, 'Tu', colorScheme.secondary),
                        _buildBar(0.5, 'We', colorScheme.secondary),
                        _buildBar(0.8, 'Th', colorScheme.secondary),
                        _buildBar(0.7, 'Fr', colorScheme.secondary),
                        _buildBar(0.9, 'Sa', colorScheme.secondary),
                        _buildBar(0.65, 'Su', colorScheme.primary), // highlight current
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Key Performance Indicaors', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                 Expanded(
                    child: _buildKpiCard(context, 'Avg Temp', '23.1°C', Icons.thermostat, colorScheme.primary, progress: 0.55),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(context, 'Growth Rate', '+4.2%', Icons.trending_up, colorScheme.primaryContainer, isGood: true, progress: 0.8),
                  )
              ],
            ),
            const SizedBox(height: 16),
             Row(
              children: [
                 Expanded(
                    child: _buildKpiCard(context, 'Energy Use', '142 kWh', Icons.electrical_services, Colors.orange, progress: 0.7),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(context, 'Water Saved', '320 L', Icons.water_drop, colorScheme.secondary, progress: 0.4),
                  )
              ],
            )
          ],
        )
      )
    );
  }

  Widget _buildBar(double heightFactor, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
               return Container(
                  height: constraints.maxHeight * heightFactor,
                  width: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
            }
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, IconData icon, Color iconColor, {bool isGood = false, double progress = 0.5}) {
     final colorScheme = Theme.of(context).colorScheme;
     final isDark = colorScheme.brightness == Brightness.dark;

     return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? null : Border.all(color: colorScheme.outlineVariant.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor),
              Text(value, style: TextStyle(color: isGood ? colorScheme.primary : colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surface : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
