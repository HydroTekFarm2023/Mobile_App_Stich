import 'package:flutter/material.dart';
import '../core/plant_presets.dart';

class ControlScreen extends StatefulWidget {
  final String selectedPlant;
  final ValueChanged<String> onPlantChanged;

  const ControlScreen({
    super.key,
    required this.selectedPlant,
    required this.onPlantChanged,
  });

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _waterPumps = true;
  double _waterPumpsIntensity = 0.85;

  bool _growLights = true;
  double _growLightsIntensity = 1.0;

  bool _ventilation = false;
  double _ventilationIntensity = 0.0;

  bool _nutrientDosing = true;
  double _nutrientDosingIntensity = 0.5;

  double _targetTemp = 22.5;

  @override
  void initState() {
    super.initState();
    _loadPreset();
  }

  @override
  void didUpdateWidget(ControlScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPlant != widget.selectedPlant) {
      _loadPreset();
    }
  }

  void _loadPreset() {
    final preset = PlantPresets.presets[widget.selectedPlant] ??
        PlantPresets.presets['Strawberry']!;
    _waterPumps = preset.waterPumps;
    _waterPumpsIntensity = preset.waterPumpsIntensity;
    _growLights = preset.growLights;
    _growLightsIntensity = preset.growLightsIntensity;
    _ventilation = preset.ventilation;
    _ventilationIntensity = preset.ventilationIntensity;
    _nutrientDosing = preset.nutrientDosing;
    _nutrientDosingIntensity = preset.nutrientDosingIntensity;
    _targetTemp = preset.targetTemp;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final preset = PlantPresets.presets[widget.selectedPlant] ??
        PlantPresets.presets['Strawberry']!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
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
                        'Actuator Control',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage greenhouse systems and targets.',
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
                    color: isDark
                        ? colorScheme.surfaceContainerHighest
                        : const Color(0xFFF4F9F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.selectedPlant,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      dropdownColor: isDark
                          ? colorScheme.surfaceContainerHighest
                          : Colors.white,
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
                          widget.onPlantChanged(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSwitchCard(
              title: 'Water Pumps',
              subtitle: preset.waterPumpsStatus,
              value: _waterPumps,
              onChanged: (val) => setState(() {
                _waterPumps = val;
                if (val && _waterPumpsIntensity == 0.0) {
                  _waterPumpsIntensity = 0.5;
                }
              }),
              icon: Icons.water_drop,
              color: colorScheme.secondary,
              intensity: _waterPumpsIntensity,
              onIntensityChanged: (val) =>
                  setState(() => _waterPumpsIntensity = val),
            ),
            _buildSwitchCard(
              title: 'Grow Lights (Spectrum A)',
              subtitle: preset.growLightsStatus,
              value: _growLights,
              onChanged: (val) => setState(() {
                _growLights = val;
                if (val && _growLightsIntensity == 0.0) {
                  _growLightsIntensity = 0.5;
                }
              }),
              icon: Icons.lightbulb,
              color: colorScheme.primary,
              intensity: _growLightsIntensity,
              onIntensityChanged: (val) =>
                  setState(() => _growLightsIntensity = val),
            ),
            _buildSwitchCard(
              title: 'Ventilation Fans',
              subtitle: preset.ventilationStatus,
              value: _ventilation,
              onChanged: (val) => setState(() {
                _ventilation = val;
                if (val && _ventilationIntensity == 0.0) {
                  _ventilationIntensity = 0.5;
                }
              }),
              icon: Icons.air,
              color: Colors.blueGrey,
              intensity: _ventilationIntensity,
              onIntensityChanged: (val) =>
                  setState(() => _ventilationIntensity = val),
            ),
            _buildSwitchCard(
              title: 'Nutrient Dosing Pump',
              subtitle: preset.nutrientDosingStatus,
              value: _nutrientDosing,
              onChanged: (val) => setState(() {
                _nutrientDosing = val;
                if (val && _nutrientDosingIntensity == 0.0) {
                  _nutrientDosingIntensity = 0.5;
                }
              }),
              icon: Icons.science,
              color: colorScheme.tertiary,
              intensity: _nutrientDosingIntensity,
              onIntensityChanged: (val) =>
                  setState(() => _nutrientDosingIntensity = val),
            ),
            const SizedBox(height: 32),
            Text('Climate Target',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildSliderCard(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
    required double intensity,
    required ValueChanged<double> onIntensityChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? null
              : Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.2), width: 1),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: value
                        ? color.withOpacity(0.15)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      color: value ? color : colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13)),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: color,
                  activeTrackColor: color.withOpacity(0.3),
                )
              ],
            ),
            if (value) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Intensity',
                      style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: color,
                        inactiveTrackColor: isDark
                            ? colorScheme.surface
                            : colorScheme.surfaceContainerLow,
                        thumbColor: color,
                        trackHeight: 4,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: intensity,
                        min: 0.0,
                        max: 1.0,
                        onChanged: onIntensityChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(intensity * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ]
          ],
        ));
  }

  Widget _buildSliderCard(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? null
              : Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.2), width: 1),
        ),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Target Temperature',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500)),
              Text('${_targetTemp.toStringAsFixed(1)} °C',
                  style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primaryContainer,
              inactiveTrackColor: colorScheme.surfaceContainerHigh,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: _targetTemp,
              min: 15.0,
              max: 30.0,
              divisions: 30,
              onChanged: (val) {
                setState(() {
                  _targetTemp = val;
                });
              },
            ),
          ),
        ]));
  }
}
