import 'package:flutter/material.dart';
import '../core/plant_presets.dart';

class DashboardScreen extends StatelessWidget {
  final String selectedPlant;
  final ValueChanged<String> onPlantChanged;

  const DashboardScreen({
    super.key,
    required this.selectedPlant,
    required this.onPlantChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final preset = PlantPresets.presets[selectedPlant] ?? PlantPresets.presets['Strawberry']!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView(
            padding: const EdgeInsets.all(28.0),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Greenhouse Status',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'System running optimally.',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 140,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFF4F9F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPlant,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        dropdownColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        items: PlantPresets.plants.map((String plant) {
                          return DropdownMenuItem<String>(
                            value: plant,
                            child: Text(plant),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            onPlantChanged(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // The Metric Lens (Hero card)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: const GradientRotation(2.356),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark ? [] : const [
                    BoxShadow(color: Color(0x1F166C44), blurRadius: 30, offset: Offset(0, 10))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Overall Yield Health', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(preset.overallHealth, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                     Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('${preset.overallHealthScore}', style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold, letterSpacing: -1.5)),
                        Text('%', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 24, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
               Row(
                children: [
                   Expanded(
                    child: _buildMetricCard(context, 'Temperature', '${preset.currentTemp} °C', Icons.thermostat, colorScheme.primary, progress: preset.currentTemp / 40.0),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(context, 'Humidity', '${preset.currentHumidity}%', Icons.water_drop_outlined, colorScheme.secondary, progress: preset.currentHumidity / 100.0),
                  )
                ],
              ),
               const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                    child: _buildMetricCard(context, 'Nutrient pH', '${preset.nutrientPh}', Icons.science_outlined, colorScheme.tertiary, progress: preset.nutrientPh / 14.0),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(context, 'Light Int.', preset.lightIntensity, Icons.light_mode_outlined, Colors.amber.shade700, progress: preset.lightProgress),
                  )
                ],
              ),
              const SizedBox(height: 32),
              Text('Recent Alerts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildAlertCard(context, 'pH Level Fluctuating', 'Bay 3 - 10 mins ago', Icons.warning_amber_rounded, colorScheme.error),
               _buildAlertCard(context, 'Routine Maintenance Due', 'Pump Station B - 2 hours ago', Icons.info_outline_rounded, colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color iconColor, {double progress = 0.5}) {
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
              Icon(icon, color: iconColor, size: 28),
              Text(value, style: TextStyle(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          // Rectangular Bar
          Container(
            height: 8,
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

  Widget _buildAlertCard(BuildContext context, String title, String subtitle, IconData icon, Color iconColor) {
      final colorScheme = Theme.of(context).colorScheme;
      final isDark = colorScheme.brightness == Brightness.dark;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
         decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? null : Border.all(color: colorScheme.outlineVariant.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        )
      );
  }
}
